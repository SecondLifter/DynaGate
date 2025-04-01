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

	"dynagate/pkg/config"
	"dynagate/pkg/database"
	"dynagate/pkg/handlers"
)

var (
	configFile = flag.String("config", "config.yaml", "Path to configuration file")
)

func main() {
	flag.Parse()

	// 加载配置文件
	cfg, err := config.LoadConfig(*configFile)
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	// 初始化MySQL连接
	dbConfig := &database.Config{
		Host:     cfg.MySQL.Host,
		Port:     cfg.MySQL.Port,
		User:     cfg.MySQL.User,
		Password: cfg.MySQL.Password,
		DBName:   cfg.MySQL.Database,
	}

	if err := database.Initialize(dbConfig); err != nil {
		log.Fatalf("Failed to initialize database: %v", err)
	}

	// 创建操作日志处理器
	opLogHandler, err := handlers.NewOperationLogHandler()
	if err != nil {
		log.Fatalf("Failed to create operation log handler: %v", err)
	}
	defer opLogHandler.Close()

	// 配置ETCD客户端
	etcdConfig := clientv3.Config{
		Endpoints:   cfg.ETCD.Endpoints,
		DialTimeout: time.Duration(cfg.ETCD.Timeout) * time.Second,
	}

	// 配置ETCD认证
	if cfg.ETCD.Username != "" && cfg.ETCD.Password != "" {
		etcdConfig.Username = cfg.ETCD.Username
		etcdConfig.Password = cfg.ETCD.Password
	}

	// 配置ETCD TLS
	if cfg.ETCD.CACert != "" && cfg.ETCD.Cert != "" && cfg.ETCD.Key != "" {
		cert, err := tls.LoadX509KeyPair(cfg.ETCD.Cert, cfg.ETCD.Key)
		if err != nil {
			log.Fatalf("Failed to load client cert/key pair: %v", err)
		}

		caData, err := ioutil.ReadFile(cfg.ETCD.CACert)
		if err != nil {
			log.Fatalf("Failed to read CA cert: %v", err)
		}

		pool := x509.NewCertPool()
		if !pool.AppendCertsFromPEM(caData) {
			log.Fatal("Failed to add CA cert to pool")
		}

		etcdConfig.TLS = &tls.Config{
			Certificates: []tls.Certificate{cert},
			RootCAs:      pool,
		}
	}

	// 创建ETCD客户端
	etcdClient, err := clientv3.New(etcdConfig)
	if err != nil {
		log.Fatalf("Failed to create etcd client: %v", err)
	}
	defer etcdClient.Close()

	// 创建处理程序
	h := handlers.NewHandler(etcdClient, cfg.LDAP.URL, cfg.LDAP.BaseDN, cfg.LDAP.BindDN,
		cfg.LDAP.BindPass, cfg.LDAP.UserDN, cfg.LDAP.GroupDN)

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
		api.POST("/operation_logs", opLogHandler.HandleAddOperationLog)
		api.GET("/operation_logs", opLogHandler.HandleGetOperationLogs)
		api.DELETE("/operation_logs", opLogHandler.HandleDeleteOperationLogs)

		// 审计日志
		api.GET("/audit", h.GetAuditLogs)
	}

	// 启动服务器
	addr := fmt.Sprintf("%s:%d", cfg.Server.Host, cfg.Server.Port)
	log.Printf("Server starting on %s", addr)
	if err := r.Run(addr); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
