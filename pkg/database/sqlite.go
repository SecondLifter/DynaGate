package database

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"time"

	_ "github.com/mattn/go-sqlite3"
)

// OperationLog 表示一条操作日志
type OperationLog struct {
	ID        int64     `json:"id"`
	Operation string    `json:"operation"`
	Key       string    `json:"key"`
	User      string    `json:"user"`
	Timestamp time.Time `json:"timestamp"`
	OldValue  string    `json:"old_value,omitempty"`
	NewValue  string    `json:"new_value,omitempty"`
}

// SQLiteDB 管理SQLite数据库连接和操作
type SQLiteDB struct {
	db *sql.DB
}

// NewSQLiteDB 创建一个新的SQLite数据库连接
func NewSQLiteDB(dbPath string) (*SQLiteDB, error) {
	// 确保目录存在
	dir := filepath.Dir(dbPath)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return nil, fmt.Errorf("failed to create directory for SQLite DB: %v", err)
	}

	// 连接数据库
	db, err := sql.Open("sqlite3", dbPath)
	if err != nil {
		return nil, fmt.Errorf("failed to open SQLite DB: %v", err)
	}

	// 创建表
	if err := initDB(db); err != nil {
		db.Close()
		return nil, fmt.Errorf("failed to initialize SQLite DB: %v", err)
	}

	return &SQLiteDB{db: db}, nil
}

// Close 关闭数据库连接
func (s *SQLiteDB) Close() error {
	return s.db.Close()
}

// 初始化数据库表
func initDB(db *sql.DB) error {
	createTableSQL := `
	CREATE TABLE IF NOT EXISTS operation_logs (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		operation TEXT NOT NULL,
		key TEXT NOT NULL,
		user TEXT NOT NULL,
		timestamp TEXT NOT NULL,
		old_value TEXT,
		new_value TEXT
	);
	CREATE INDEX IF NOT EXISTS idx_operation_logs_timestamp ON operation_logs(timestamp);
	CREATE INDEX IF NOT EXISTS idx_operation_logs_user ON operation_logs(user);
	CREATE INDEX IF NOT EXISTS idx_operation_logs_key ON operation_logs(key);
	`

	_, err := db.Exec(createTableSQL)
	return err
}

// AddOperationLog 添加一条操作日志
func (s *SQLiteDB) AddOperationLog(log OperationLog) (int64, error) {
	insertSQL := `
	INSERT INTO operation_logs 
	(operation, key, user, timestamp, old_value, new_value) 
	VALUES (?, ?, ?, ?, ?, ?)`

	timestampStr := log.Timestamp.Format(time.RFC3339)
	res, err := s.db.Exec(insertSQL, log.Operation, log.Key, log.User,
		timestampStr, log.OldValue, log.NewValue)
	if err != nil {
		return 0, fmt.Errorf("failed to insert operation log: %v", err)
	}

	// 返回新插入记录的ID
	id, err := res.LastInsertId()
	if err != nil {
		fmt.Printf("Warning: could not get last insert ID: %v\n", err)
	}
	return id, nil
}

// GetOperationLogs 获取操作日志，支持可选的过滤条件
func (s *SQLiteDB) GetOperationLogs(filters map[string]interface{}) ([]OperationLog, error) {
	// 构建查询SQL
	querySQL := `
	SELECT id, operation, key, user, timestamp, old_value, new_value 
	FROM operation_logs
	WHERE 1=1`

	var args []interface{}

	// 应用过滤条件
	if user, ok := filters["user"].(string); ok && user != "" {
		querySQL += " AND user = ?"
		args = append(args, user)
	}
	if key, ok := filters["key"].(string); ok && key != "" {
		querySQL += " AND key LIKE ?"
		args = append(args, "%"+key+"%")
	}
	if operation, ok := filters["operation"].(string); ok && operation != "" {
		querySQL += " AND operation = ?"
		args = append(args, operation)
	}
	if startTime, ok := filters["start_time"].(time.Time); ok {
		querySQL += " AND timestamp >= ?"
		args = append(args, startTime.Format(time.RFC3339))
	}
	if endTime, ok := filters["end_time"].(time.Time); ok {
		querySQL += " AND timestamp <= ?"
		args = append(args, endTime.Format(time.RFC3339))
	}

	// 添加排序
	querySQL += " ORDER BY timestamp DESC"

	// 添加限制
	if limit, ok := filters["limit"].(int); ok && limit > 0 {
		querySQL += " LIMIT ?"
		args = append(args, limit)
	}

	// 执行查询
	rows, err := s.db.Query(querySQL, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to query operation logs: %v", err)
	}
	defer rows.Close()

	var logs []OperationLog
	for rows.Next() {
		var log OperationLog
		var timestampStr string
		if err := rows.Scan(&log.ID, &log.Operation, &log.Key, &log.User,
			&timestampStr, &log.OldValue, &log.NewValue); err != nil {
			return nil, fmt.Errorf("failed to scan operation log: %v", err)
		}

		// 解析时间戳
		timestamp, err := time.Parse(time.RFC3339, timestampStr)
		if err != nil {
			fmt.Printf("Warning: failed to parse timestamp %s: %v\n", timestampStr, err)
			// 使用当前时间作为回退
			timestamp = time.Now()
		}
		log.Timestamp = timestamp

		logs = append(logs, log)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error during rows iteration: %v", err)
	}

	return logs, nil
}

// DeleteOperationLogs 删除指定条件的操作日志
func (s *SQLiteDB) DeleteOperationLogs(filters map[string]interface{}) (int64, error) {
	deleteSQL := `DELETE FROM operation_logs WHERE 1=1`
	var args []interface{}

	// 应用过滤条件
	if id, ok := filters["id"].(int64); ok && id > 0 {
		deleteSQL += " AND id = ?"
		args = append(args, id)
	}
	if user, ok := filters["user"].(string); ok && user != "" {
		deleteSQL += " AND user = ?"
		args = append(args, user)
	}
	if key, ok := filters["key"].(string); ok && key != "" {
		deleteSQL += " AND key LIKE ?"
		args = append(args, "%"+key+"%")
	}
	if operation, ok := filters["operation"].(string); ok && operation != "" {
		deleteSQL += " AND operation = ?"
		args = append(args, operation)
	}
	if startTime, ok := filters["start_time"].(time.Time); ok {
		deleteSQL += " AND timestamp >= ?"
		args = append(args, startTime.Format(time.RFC3339))
	}
	if endTime, ok := filters["end_time"].(time.Time); ok {
		deleteSQL += " AND timestamp <= ?"
		args = append(args, endTime.Format(time.RFC3339))
	}

	// 执行删除
	res, err := s.db.Exec(deleteSQL, args...)
	if err != nil {
		return 0, fmt.Errorf("failed to delete operation logs: %v", err)
	}

	// 返回删除的记录数
	count, err := res.RowsAffected()
	if err != nil {
		log.Printf("Warning: could not get rows affected: %v", err)
		return 0, nil
	}
	return count, nil
}
