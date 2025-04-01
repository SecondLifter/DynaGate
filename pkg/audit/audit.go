package audit

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	clientv3 "go.etcd.io/etcd/client/v3"
)

// Action represents the type of action performed
type Action string

const (
	ActionCreate Action = "create"
	ActionUpdate Action = "update"
	ActionDelete Action = "delete"
)

// AuditLog represents a single audit log entry
type AuditLog struct {
	Timestamp time.Time `json:"timestamp"`
	User      string    `json:"user"`
	Action    Action    `json:"action"`
	Key       string    `json:"key"`
	OldValue  string    `json:"old_value,omitempty"`
	NewValue  string    `json:"new_value,omitempty"`
}

// Logger handles audit logging
type Logger struct {
	client *clientv3.Client
	prefix string
}

// NewLogger creates a new audit logger
func NewLogger(client *clientv3.Client) *Logger {
	return &Logger{
		client: client,
		prefix: "/audit/logs/",
	}
}

// Log records an audit log entry
func (l *Logger) Log(ctx context.Context, entry AuditLog) error {
	// 生成唯一的日志ID（使用时间戳）
	logID := fmt.Sprintf("%s%d", l.prefix, entry.Timestamp.UnixNano())

	// 序列化日志条目
	data, err := json.Marshal(entry)
	if err != nil {
		return fmt.Errorf("failed to marshal audit log: %v", err)
	}

	// 存储到ETCD
	_, err = l.client.Put(ctx, logID, string(data))
	if err != nil {
		return fmt.Errorf("failed to store audit log: %v", err)
	}

	return nil
}

// GetLogs retrieves audit logs within a time range
func (l *Logger) GetLogs(ctx context.Context, start, end time.Time) ([]AuditLog, error) {
	// 构建范围查询
	startKey := fmt.Sprintf("%s%d", l.prefix, start.UnixNano())
	endKey := fmt.Sprintf("%s%d", l.prefix, end.UnixNano())

	resp, err := l.client.Get(ctx, startKey, clientv3.WithRange(endKey))
	if err != nil {
		return nil, fmt.Errorf("failed to retrieve audit logs: %v", err)
	}

	logs := make([]AuditLog, 0, len(resp.Kvs))
	for _, kv := range resp.Kvs {
		var log AuditLog
		if err := json.Unmarshal(kv.Value, &log); err != nil {
			return nil, fmt.Errorf("failed to unmarshal audit log: %v", err)
		}
		logs = append(logs, log)
	}

	return logs, nil
}

// GetLogsByUser retrieves audit logs for a specific user
func (l *Logger) GetLogsByUser(ctx context.Context, user string, start, end time.Time) ([]AuditLog, error) {
	logs, err := l.GetLogs(ctx, start, end)
	if err != nil {
		return nil, err
	}

	userLogs := make([]AuditLog, 0)
	for _, log := range logs {
		if log.User == user {
			userLogs = append(userLogs, log)
		}
	}

	return userLogs, nil
}

// GetLogsByKey retrieves audit logs for a specific key
func (l *Logger) GetLogsByKey(ctx context.Context, key string, start, end time.Time) ([]AuditLog, error) {
	logs, err := l.GetLogs(ctx, start, end)
	if err != nil {
		return nil, err
	}

	keyLogs := make([]AuditLog, 0)
	for _, log := range logs {
		if log.Key == key {
			keyLogs = append(keyLogs, log)
		}
	}

	return keyLogs, nil
}
