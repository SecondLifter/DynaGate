package models

import (
	"time"

	"gorm.io/gorm"
)

// OperationLog 操作日志模型
type OperationLog struct {
	gorm.Model
	Operation string    `json:"operation" gorm:"size:255;not null"`
	Key       string    `json:"key" gorm:"size:1024;not null"`
	User      string    `json:"user" gorm:"size:255;not null"`
	Value     string    `json:"value" gorm:"type:text"`
	OldValue  string    `json:"old_value" gorm:"column:old_value;type:text"`
	NewValue  string    `json:"new_value" gorm:"column:new_value;type:text"`
	Timestamp time.Time `json:"timestamp" gorm:"not null;index"`
}
