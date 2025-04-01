package handlers

import (
	"fmt"
	"net/http"
	"strconv"
	"time"

	"dynagate/pkg/database"
	"dynagate/pkg/models"

	"github.com/gin-gonic/gin"
)

// OperationLogHandler 处理操作日志的结构体
type OperationLogHandler struct {
}

// NewOperationLogHandler 创建一个新的操作日志处理器
func NewOperationLogHandler() (*OperationLogHandler, error) {
	return &OperationLogHandler{}, nil
}

// AddOperationLog 添加一条操作日志
func (h *OperationLogHandler) AddOperationLog(log models.OperationLog) (int64, error) {
	result := database.GetDB().Create(&log)
	if result.Error != nil {
		return 0, result.Error
	}
	return int64(log.ID), nil
}

// GetOperationLogs 获取操作日志，支持可选的过滤条件
func (h *OperationLogHandler) GetOperationLogs(filters map[string]interface{}) ([]models.OperationLog, error) {
	var logs []models.OperationLog
	db := database.GetDB()

	// 构建查询
	query := db.Model(&models.OperationLog{})

	// 应用过滤条件
	if user, ok := filters["user"].(string); ok && user != "" {
		query = query.Where("user = ?", user)
	}
	if key, ok := filters["key"].(string); ok && key != "" {
		query = query.Where("key LIKE ?", "%"+key+"%")
	}
	if operation, ok := filters["operation"].(string); ok && operation != "" {
		query = query.Where("operation = ?", operation)
	}
	if startTime, ok := filters["start_time"].(time.Time); ok {
		query = query.Where("timestamp >= ?", startTime)
	}
	if endTime, ok := filters["end_time"].(time.Time); ok {
		query = query.Where("timestamp <= ?", endTime)
	}

	// 添加排序
	query = query.Order("timestamp DESC")

	// 添加限制
	if limit, ok := filters["limit"].(int); ok && limit > 0 {
		query = query.Limit(limit)
	}

	// 执行查询
	result := query.Find(&logs)
	if result.Error != nil {
		return nil, result.Error
	}

	return logs, nil
}

// DeleteOperationLogs 删除指定条件的操作日志
func (h *OperationLogHandler) DeleteOperationLogs(filters map[string]interface{}) (int64, error) {
	db := database.GetDB()
	query := db.Model(&models.OperationLog{})

	// 应用过滤条件
	if id, ok := filters["id"].(int64); ok && id > 0 {
		query = query.Where("id = ?", id)
	}
	if user, ok := filters["user"].(string); ok && user != "" {
		query = query.Where("user = ?", user)
	}
	if key, ok := filters["key"].(string); ok && key != "" {
		query = query.Where("key LIKE ?", "%"+key+"%")
	}
	if operation, ok := filters["operation"].(string); ok && operation != "" {
		query = query.Where("operation = ?", operation)
	}
	if startTime, ok := filters["start_time"].(time.Time); ok {
		query = query.Where("timestamp >= ?", startTime)
	}
	if endTime, ok := filters["end_time"].(time.Time); ok {
		query = query.Where("timestamp <= ?", endTime)
	}

	// 执行删除
	result := query.Delete(&models.OperationLog{})
	if result.Error != nil {
		return 0, result.Error
	}

	return result.RowsAffected, nil
}

// LogOperation 记录操作日志
func (h *OperationLogHandler) LogOperation(user, operation, key, value, newValue, oldValue string) error {
	log := &models.OperationLog{
		User:      user,
		Operation: operation,
		Key:       key,
		Value:     value,
		NewValue:  newValue,
		OldValue:  oldValue,
		Timestamp: time.Now(),
	}

	result := database.GetDB().Create(log)
	return result.Error
}

// Close 关闭处理器
func (h *OperationLogHandler) Close() error {
	return nil
}

// HTTP 处理函数

// HandleAddOperationLog 处理添加操作日志的HTTP请求
func (h *OperationLogHandler) HandleAddOperationLog(c *gin.Context) {
	var log models.OperationLog
	if err := c.ShouldBindJSON(&log); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 确保必填字段不为空
	if log.Operation == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "operation field is required"})
		return
	}
	if log.Key == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "key field is required"})
		return
	}
	if log.User == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "user field is required"})
		return
	}

	// 处理空值情况
	if log.Value == "" {
		log.Value = "-"
	}
	if log.OldValue == "" {
		log.OldValue = "-"
	}
	if log.NewValue == "" {
		log.NewValue = "-"
	}

	// 确保时间戳存在
	if log.Timestamp.IsZero() {
		log.Timestamp = time.Now()
	}

	// 移除可能的测试数据标记
	if log.Value == "test" || log.Value == "测试" {
		log.Value = "-"
	}
	if log.OldValue == "test" || log.OldValue == "测试" {
		log.OldValue = "-"
	}
	if log.NewValue == "test" || log.NewValue == "测试" {
		log.NewValue = "-"
	}

	id, err := h.AddOperationLog(log)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"id":      id,
		"status":  "success",
		"message": "Operation log added successfully",
	})
}

// HandleGetOperationLogs 处理获取操作日志的HTTP请求
func (h *OperationLogHandler) HandleGetOperationLogs(c *gin.Context) {
	filters := make(map[string]interface{})

	// 解析查询参数
	if user := c.Query("user"); user != "" {
		filters["user"] = user
	}
	if key := c.Query("key"); key != "" {
		filters["key"] = key
	}
	if operation := c.Query("operation"); operation != "" {
		filters["operation"] = operation
	}
	if startTime := c.Query("start_time"); startTime != "" {
		if t, err := time.Parse(time.RFC3339, startTime); err == nil {
			filters["start_time"] = t
		}
	}
	if endTime := c.Query("end_time"); endTime != "" {
		if t, err := time.Parse(time.RFC3339, endTime); err == nil {
			filters["end_time"] = t
		}
	}
	if limit := c.Query("limit"); limit != "" {
		if l, err := strconv.Atoi(limit); err == nil {
			filters["limit"] = l
		}
	}

	logs, err := h.GetOperationLogs(filters)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 转换响应格式以匹配前端期望
	response := gin.H{
		"logs":  logs,
		"total": len(logs),
	}

	c.JSON(http.StatusOK, response)
}

// HandleDeleteOperationLogs 处理删除操作日志的HTTP请求
func (h *OperationLogHandler) HandleDeleteOperationLogs(c *gin.Context) {
	filters := make(map[string]interface{})

	// 解析查询参数
	if user := c.Query("user"); user != "" {
		filters["user"] = user
	}
	if key := c.Query("key"); key != "" {
		filters["key"] = key
	}
	if operation := c.Query("operation"); operation != "" {
		filters["operation"] = operation
	}
	if startTime := c.Query("start_time"); startTime != "" {
		if t, err := time.Parse(time.RFC3339, startTime); err == nil {
			filters["start_time"] = t
		}
	}
	if endTime := c.Query("end_time"); endTime != "" {
		if t, err := time.Parse(time.RFC3339, endTime); err == nil {
			filters["end_time"] = t
		}
	}
	if id := c.Query("id"); id != "" {
		if i, err := strconv.ParseInt(id, 10, 64); err == nil {
			filters["id"] = i
		}
	}

	count, err := h.DeleteOperationLogs(filters)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"deleted": count,
		"status":  "success",
		"message": fmt.Sprintf("Successfully deleted %d operation logs", count),
	})
}
