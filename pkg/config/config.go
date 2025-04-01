package config

import (
	"fmt"
	"io/ioutil"

	"gopkg.in/yaml.v3"
)

// Config 应用配置结构
type Config struct {
	Server ServerConfig `yaml:"server"`
	MySQL  MySQLConfig  `yaml:"mysql"`
	LDAP   LDAPConfig   `yaml:"ldap"`
	ETCD   ETCDConfig   `yaml:"etcd"`
}

// ServerConfig 服务器配置
type ServerConfig struct {
	Host string `yaml:"host"`
	Port int    `yaml:"port"`
}

// MySQLConfig MySQL配置
type MySQLConfig struct {
	Host     string `yaml:"host"`
	Port     int    `yaml:"port"`
	User     string `yaml:"user"`
	Password string `yaml:"password"`
	Database string `yaml:"database"`
}

// LDAPConfig LDAP配置
type LDAPConfig struct {
	URL      string `yaml:"url"`
	BaseDN   string `yaml:"base_dn"`
	BindDN   string `yaml:"bind_dn"`
	BindPass string `yaml:"bind_password"`
	UserDN   string `yaml:"user_dn"`
	GroupDN  string `yaml:"group_dn"`
}

// ETCDConfig ETCD配置
type ETCDConfig struct {
	Endpoints []string `yaml:"endpoints"`
	Timeout   int      `yaml:"timeout"`
	Username  string   `yaml:"username"`
	Password  string   `yaml:"password"`
	CACert    string   `yaml:"ca_cert"`
	Cert      string   `yaml:"cert"`
	Key       string   `yaml:"key"`
}

// LoadConfig 从文件加载配置
func LoadConfig(filename string) (*Config, error) {
	data, err := ioutil.ReadFile(filename)
	if err != nil {
		return nil, fmt.Errorf("failed to read config file: %v", err)
	}

	config := &Config{}
	err = yaml.Unmarshal(data, config)
	if err != nil {
		return nil, fmt.Errorf("failed to parse config file: %v", err)
	}

	return config, nil
}
