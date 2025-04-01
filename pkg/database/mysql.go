package database

import (
	"fmt"
	"log"

	"dynagate/pkg/models"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

var DB *gorm.DB

// Config MySQL配置
type Config struct {
	Host     string
	Port     int
	User     string
	Password string
	DBName   string
}

// Initialize 初始化数据库连接
func Initialize(config *Config) error {
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=utf8mb4&parseTime=True&loc=Local",
		config.User,
		config.Password,
		config.Host,
		config.Port,
		config.DBName,
	)

	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		return fmt.Errorf("failed to connect to database: %v", err)
	}

	// 设置连接池
	sqlDB, err := db.DB()
	if err != nil {
		return fmt.Errorf("failed to get database instance: %v", err)
	}

	sqlDB.SetMaxIdleConns(10)
	sqlDB.SetMaxOpenConns(100)

	// 自动迁移数据库结构
	err = db.AutoMigrate(&models.OperationLog{})
	if err != nil {
		return fmt.Errorf("failed to migrate database: %v", err)
	}

	DB = db
	log.Println("Database connection established")
	return nil
}

// GetDB 获取数据库连接
func GetDB() *gorm.DB {
	return DB
}
