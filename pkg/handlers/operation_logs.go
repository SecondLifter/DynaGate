package handlers

import (
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"

	"dynagate/pkg/database"
)

// 操作日志处理器结构
type OperationLogHandler struct {
	db *database.SQLiteDB
}

// 创建新的操作日志处理器
func NewOperationLogHandler(dbPath string) (*OperationLogHandler, error) {
	db, err := database.NewSQLiteDB(dbPath)
	if err != nil {
		return nil, err
	}
	return &OperationLogHandler{db: db}, nil
}

// Close 关闭数据库连接
func (h *OperationLogHandler) Close() error {
	return h.db.Close()
}

// AddOperationLog 添加操作日志的API处理函数
func (h *OperationLogHandler) AddOperationLog(c *gin.Context) {
	var req struct {
		Operation string `json:"operation" binding:"required"`
		Key       string `json:"key" binding:"required"`
		User      string `json:"user" binding:"required"`
		Timestamp string `json:"timestamp" binding:"required"`
		OldValue  string `json:"old_value"`
		NewValue  string `json:"new_value"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 解析时间戳
	timestamp, err := time.Parse(time.RFC3339, req.Timestamp)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid timestamp format, must be RFC3339"})
		return
	}

	// 创建操作日志记录
	log := database.OperationLog{
		Operation: req.Operation,
		Key:       req.Key,
		User:      req.User,
		Timestamp: timestamp,
		OldValue:  req.OldValue,
		NewValue:  req.NewValue,
	}

	// 保存到数据库
	id, err := h.db.AddOperationLog(log)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"id":      id,
		"message": "Operation log created successfully",
	})
}

// GetOperationLogs 获取操作日志的API处理函数
func (h *OperationLogHandler) GetOperationLogs(c *gin.Context) {
	// 解析查询参数
	filters := make(map[string]interface{})

	// 提取用户过滤
	if user := c.Query("user"); user != "" {
		filters["user"] = user
	}

	// 提取键过滤
	if key := c.Query("key"); key != "" {
		filters["key"] = key
	}

	// 提取操作类型过滤
	if operation := c.Query("operation"); operation != "" {
		filters["operation"] = operation
	}

	// 提取开始时间过滤
	if startStr := c.Query("start_time"); startStr != "" {
		startTime, err := time.Parse(time.RFC3339, startStr)
		if err == nil {
			filters["start_time"] = startTime
		}
	}

	// 提取结束时间过滤
	if endStr := c.Query("end_time"); endStr != "" {
		endTime, err := time.Parse(time.RFC3339, endStr)
		if err == nil {
			filters["end_time"] = endTime
		}
	}

	// 提取限制数量
	if limitStr := c.Query("limit"); limitStr != "" {
		var limit int
		if n, err := fmt.Sscanf(limitStr, "%d", &limit); err == nil && n == 1 && limit > 0 {
			filters["limit"] = limit
		}
	}

	// 查询数据库
	logs, err := h.db.GetOperationLogs(filters)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 记录一些调试信息
	fmt.Printf("Found %d operation logs\n", len(logs))

	// 返回统一的JSON格式
	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"count":  len(logs),
		"logs":   logs,
	})
}

// DeleteOperationLogs 删除操作日志的API处理函数
func (h *OperationLogHandler) DeleteOperationLogs(c *gin.Context) {
	var req struct {
		ID        int64     `json:"id"`
		User      string    `json:"user"`
		Key       string    `json:"key"`
		Operation string    `json:"operation"`
		StartTime time.Time `json:"start_time"`
		EndTime   time.Time `json:"end_time"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 创建过滤条件
	filters := make(map[string]interface{})
	if req.ID > 0 {
		filters["id"] = req.ID
	}
	if req.User != "" {
		filters["user"] = req.User
	}
	if req.Key != "" {
		filters["key"] = req.Key
	}
	if req.Operation != "" {
		filters["operation"] = req.Operation
	}
	if !req.StartTime.IsZero() {
		filters["start_time"] = req.StartTime
	}
	if !req.EndTime.IsZero() {
		filters["end_time"] = req.EndTime
	}

	// 检查是否有过滤条件
	if len(filters) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No filter conditions provided"})
		return
	}

	// 执行删除
	count, err := h.db.DeleteOperationLogs(filters)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"count":   count,
		"message": "Operation logs deleted successfully",
	})
}
