package handlers

import (
	"context"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/gin-contrib/sessions"
	"github.com/gin-gonic/gin"
	"github.com/go-ldap/ldap/v3"
	clientv3 "go.etcd.io/etcd/client/v3"

	"dynagate/pkg/audit"
	"dynagate/pkg/validator"
)

type Handler struct {
	etcdClient  *clientv3.Client
	ldapURL     string
	ldapBaseDN  string
	ldapBindDN  string
	ldapBindPwd string
	ldapUserDN  string
	ldapGroupDN string
	auditLog    *audit.Logger
}

func NewHandler(etcdClient *clientv3.Client, ldapURL, ldapBaseDN, ldapBindDN, ldapBindPwd, ldapUserDN, ldapGroupDN string) *Handler {
	return &Handler{
		etcdClient:  etcdClient,
		ldapURL:     ldapURL,
		ldapBaseDN:  ldapBaseDN,
		ldapBindDN:  ldapBindDN,
		ldapBindPwd: ldapBindPwd,
		ldapUserDN:  ldapUserDN,
		ldapGroupDN: ldapGroupDN,
		auditLog:    audit.NewLogger(etcdClient),
	}
}

// AuthMiddleware 验证用户是否已登录
func (h *Handler) AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		session := sessions.Default(c)
		user := session.Get("user")
		if user == nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
			c.Abort()
			return
		}
		c.Set("user", user.(string))
		c.Next()
	}
}

// Login 处理用户登录
func (h *Handler) Login(c *gin.Context) {
	var req struct {
		Username string `json:"username" binding:"required"`
		Password string `json:"password" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 添加测试账户
	if req.Username == "admin" && req.Password == "Cy5#*d9E7G" {
		session := sessions.Default(c)
		session.Set("user", req.Username)
		session.Save()

		c.JSON(http.StatusOK, gin.H{"status": "ok"})
		return
	}

	// 如果不是测试账户，则尝试LDAP认证
	l, err := ldap.DialURL(h.ldapURL)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to connect to LDAP server"})
		return
	}
	defer l.Close()

	// 先使用管理员绑定（如果配置了绑定DN）
	if h.ldapBindDN != "" && h.ldapBindPwd != "" {
		err = l.Bind(h.ldapBindDN, h.ldapBindPwd)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to bind with admin credentials"})
			return
		}
	}

	// 构建用户DN
	var userDN string
	if h.ldapUserDN != "" {
		userDN = fmt.Sprintf("uid=%s,%s,%s", req.Username, h.ldapUserDN, h.ldapBaseDN)
	} else {
		userDN = fmt.Sprintf("uid=%s,%s", req.Username, h.ldapBaseDN)
	}

	// 如果使用管理员绑定，先进行用户搜索
	if h.ldapBindDN != "" && h.ldapBindPwd != "" {
		searchRequest := ldap.NewSearchRequest(
			h.ldapBaseDN,
			ldap.ScopeWholeSubtree, ldap.NeverDerefAliases, 0, 0, false,
			fmt.Sprintf("(uid=%s)", req.Username),
			[]string{"dn"},
			nil,
		)

		sr, err := l.Search(searchRequest)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to search for user"})
			return
		}

		if len(sr.Entries) != 1 {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "user not found or multiple entries found"})
			return
		}

		userDN = sr.Entries[0].DN
	}

	// 尝试用户绑定（验证密码）
	err = l.Bind(userDN, req.Password)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
		return
	}

	session := sessions.Default(c)
	session.Set("user", req.Username)
	session.Save()

	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

// Logout 处理用户登出
func (h *Handler) Logout(c *gin.Context) {
	session := sessions.Default(c)
	session.Clear()
	session.Save()
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

// GetValue 获取ETCD中的值
func (h *Handler) GetValue(c *gin.Context) {
	key := c.Param("key")
	if key == "" {
		key = "/"
	}

	// 使用WithPrefix()选项来获取所有键值对
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	resp, err := h.etcdClient.Get(ctx, key, clientv3.WithPrefix())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 构建树形结构
	tree := make(map[string]interface{})
	for _, kv := range resp.Kvs {
		key := string(kv.Key)
		value := string(kv.Value)

		// 将路径分割成部分
		parts := strings.Split(strings.TrimPrefix(key, "/"), "/")
		current := tree

		// 构建嵌套的map结构
		for i, part := range parts {
			if part == "" {
				continue
			}

			if i == len(parts)-1 {
				// 最后一个部分，存储实际的值
				current[part] = value
			} else {
				// 中间节点，确保存在一个map
				if nextMap, exists := current[part]; !exists {
					// 如果不存在，创建新的map
					newMap := make(map[string]interface{})
					current[part] = newMap
					current = newMap
				} else {
					// 如果存在，检查类型
					if existingMap, ok := nextMap.(map[string]interface{}); ok {
						current = existingMap
					} else {
						// 如果已存在的值不是map，创建新的map并保留原值
						newMap := make(map[string]interface{})
						newMap["value"] = nextMap
						current[part] = newMap
						current = newMap
					}
				}
			}
		}
	}

	c.JSON(http.StatusOK, tree)
}

// SetValue 设置ETCD中的值
func (h *Handler) SetValue(c *gin.Context) {
	key := c.Param("key")
	var req struct {
		Value string `json:"value" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 根据key前缀判断配置类型并验证
	configType := ""
	if strings.HasPrefix(key, "/nginx/") {
		configType = "nginx"
	} else if strings.HasPrefix(key, "/coredns/") {
		configType = "coredns"
	}

	// 检查是否为hosts文件格式
	if strings.Contains(key, "/hosts/") {
		// 对于hosts文件，只需要简单验证有没有IP地址格式的行
		lines := strings.Split(req.Value, "\n")
		valid := false

		for _, line := range lines {
			line = strings.TrimSpace(line)
			// 跳过空行和注释行
			if line == "" || strings.HasPrefix(line, "#") {
				continue
			}

			// 检查是否至少有两列，并且第一列是IP地址格式
			fields := strings.Fields(line)
			if len(fields) >= 2 {
				// 简单检查IP格式 (需要包含3个点，表示x.x.x.x)
				if strings.Count(fields[0], ".") == 3 {
					valid = true
					break
				}
			}
		}

		if !valid && strings.TrimSpace(req.Value) != "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "无效的hosts文件格式: 缺少IP地址映射"})
			return
		}
	} else if configType != "" {
		result := validator.ValidateConfig(configType, req.Value)
		if !result.Valid {
			c.JSON(http.StatusBadRequest, gin.H{"error": result.Message})
			return
		}
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// 获取旧值（用于标准输出日志）
	oldValue := ""
	resp, err := h.etcdClient.Get(ctx, key)
	if err == nil && len(resp.Kvs) > 0 {
		oldValue = string(resp.Kvs[0].Value)
	}

	// 设置新值
	_, err = h.etcdClient.Put(ctx, key, req.Value)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 记录操作日志（仅控制台输出，不存储在etcd）
	operation := "Update"
	if oldValue == "" {
		operation = "Create"
	}

	fmt.Printf("Operation: %s, User: %s, Key: %s\n", operation, c.GetString("user"), key)

	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

// DeleteValue 删除ETCD中的值
func (h *Handler) DeleteValue(c *gin.Context) {
	key := c.Param("key")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// 获取旧值（用于日志）
	var oldValue string
	resp, err := h.etcdClient.Get(ctx, key)
	if err == nil && len(resp.Kvs) > 0 {
		oldValue = string(resp.Kvs[0].Value)
	}

	// 删除值
	_, err = h.etcdClient.Delete(ctx, key)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 记录操作日志（仅控制台输出，不存储在etcd）
	fmt.Printf("Operation: Delete, User: %s, Key: %s, OldValue: %s\n", c.GetString("user"), key, oldValue)

	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

// GetAuditLogs 获取审计日志
func (h *Handler) GetAuditLogs(c *gin.Context) {
	startTime := c.Query("start")
	endTime := c.Query("end")
	user := c.Query("user")
	key := c.Query("key")

	start, err := time.Parse(time.RFC3339, startTime)
	if err != nil {
		start = time.Now().AddDate(0, 0, -7) // 默认查询最近7天
	}

	end, err := time.Parse(time.RFC3339, endTime)
	if err != nil {
		end = time.Now()
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	var logs []audit.AuditLog
	var logErr error

	if user != "" {
		logs, logErr = h.auditLog.GetLogsByUser(ctx, user, start, end)
	} else if key != "" {
		logs, logErr = h.auditLog.GetLogsByKey(ctx, key, start, end)
	} else {
		logs, logErr = h.auditLog.GetLogs(ctx, start, end)
	}

	if logErr != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": logErr.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"logs": logs})
}

// CheckAuthStatus 检查用户的认证状态
func (h *Handler) CheckAuthStatus(c *gin.Context) {
	session := sessions.Default(c)
	user := session.Get("user")
	c.JSON(http.StatusOK, gin.H{
		"loggedIn": user != nil,
		"user":     user,
	})
}
