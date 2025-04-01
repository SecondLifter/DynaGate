package main

import (
	"crypto/tls"
	"crypto/x509"
	"flag"
	"fmt"
	"html/template"
	"io/ioutil"
	"log"
	"time"

	"github.com/gin-contrib/sessions"
	"github.com/gin-contrib/sessions/cookie"
	"github.com/gin-gonic/gin"
	clientv3 "go.etcd.io/etcd/client/v3"

	"dynagate/pkg/handlers"
)

var (
	host          = flag.String("h", "0.0.0.0", "host name or ip address")
	port          = flag.Int("p", 8080, "port")
	ldapURL       = flag.String("ldap-url", "ldap://localhost:389", "LDAP server URL")
	ldapBaseDN    = flag.String("ldap-base", "dc=example,dc=com", "LDAP base DN")
	etcdTimeout   = flag.Duration("etcd-timeout", 5*time.Second, "ETCD client timeout")
	etcdEndpoints = flag.String("etcd-endpoints", "localhost:2379", "ETCD endpoints (comma separated)")

	// ETCD认证相关参数
	etcdUsername = flag.String("etcd-username", "", "ETCD authentication username")
	etcdPassword = flag.String("etcd-password", "", "ETCD authentication password")

	// ETCD TLS相关参数
	etcdCACert = flag.String("cacert", "", "verify certificates of TLS-enabled secure servers using this CA bundle")
	etcdCert   = flag.String("cert", "", "identify secure client using this TLS certificate file")
	etcdKey    = flag.String("key", "", "identify secure client using this TLS key file")
)

func main() {
	flag.Parse()

	// 配置ETCD客户端
	config := clientv3.Config{
		Endpoints:   []string{*etcdEndpoints},
		DialTimeout: *etcdTimeout,
	}

	// 如果提供了认证信息，配置认证
	if *etcdUsername != "" && *etcdPassword != "" {
		config.Username = *etcdUsername
		config.Password = *etcdPassword
	}

	// 如果提供了TLS证书，配置TLS
	if *etcdCACert != "" && *etcdCert != "" && *etcdKey != "" {
		cert, err := tls.LoadX509KeyPair(*etcdCert, *etcdKey)
		if err != nil {
			log.Fatalf("Failed to load client cert/key pair: %v", err)
		}

		caData, err := ioutil.ReadFile(*etcdCACert)
		if err != nil {
			log.Fatalf("Failed to read CA cert: %v", err)
		}

		pool := x509.NewCertPool()
		if !pool.AppendCertsFromPEM(caData) {
			log.Fatal("Failed to add CA cert to pool")
		}

		config.TLS = &tls.Config{
			Certificates: []tls.Certificate{cert},
			RootCAs:      pool,
		}
	}

	// 创建ETCD客户端
	etcdClient, err := clientv3.New(config)
	if err != nil {
		log.Fatalf("Failed to create etcd client: %v", err)
	}
	defer etcdClient.Close()

	// 创建处理程序
	h := handlers.NewHandler(etcdClient, *ldapURL, *ldapBaseDN)

	// 创建SQLite操作日志处理器
	dbPath := "./data/operation_logs.db"
	opLogHandler, err := handlers.NewOperationLogHandler(dbPath)
	if err != nil {
		log.Fatalf("Failed to create operation log handler: %v", err)
	}
	defer opLogHandler.Close()

	// 设置Gin路由
	r := gin.Default()

	// 配置session中间件
	store := cookie.NewStore([]byte("secret"))
	r.Use(sessions.Sessions("dynagate_session", store))

	// 配置模板定界符
	r.SetFuncMap(template.FuncMap{})
	r.Delims("[[", "]]")

	// 设置静态文件目录
	r.Static("/static", "./static")
	r.LoadHTMLGlob("templates/*")

	// 公开路由
	r.GET("/", func(c *gin.Context) {
		c.HTML(200, "index.html", gin.H{
			"title": "DynaGate - ETCD Web UI",
		})
	})
	r.POST("/login", h.Login)
	r.GET("/api/auth/status", h.CheckAuthStatus)
	r.POST("/logout", h.Logout)

	// API路由组 - 需要认证
	api := r.Group("/api")
	api.Use(h.AuthMiddleware())
	{
		// ETCD操作
		api.GET("/etcd/*key", h.GetValue)
		api.PUT("/etcd/*key", h.SetValue)
		api.DELETE("/etcd/*key", h.DeleteValue)

		// 操作日志API
		api.POST("/operation_logs", opLogHandler.AddOperationLog)
		api.GET("/operation_logs", opLogHandler.GetOperationLogs)
		api.DELETE("/operation_logs", opLogHandler.DeleteOperationLogs)

		// 审计日志
		api.GET("/audit", h.GetAuditLogs)
	}

	// 启动服务器
	addr := fmt.Sprintf("%s:%d", *host, *port)
	log.Printf("Server starting on %s", addr)
	if err := r.Run(addr); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
