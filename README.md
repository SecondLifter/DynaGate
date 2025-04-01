# DynaGate - ETCD Web UI

DynaGate是一个基于Go语言和Gin框架开发的ETCD Web管理界面，提供了友好的用户界面来管理ETCD配置。

## 主要特性

1. 使用Go语言，基于Gin框架开发
2. 所有数据存储在ETCD中
3. 支持ETCD 2.x和3.x版本
4. 支持炫酷的前端页面
   - 支持NGINX、CoreDNS等类型格式的自动校验
   - 所有变更留痕迹，可以查看变更历史
   - 集成LDAP认证，实现安全访问控制

## 系统要求

- Go 1.20或更高版本
- ETCD 2.x或3.x
- LDAP服务器（用于用户认证）

## 安装

1. 克隆仓库：

```bash
git clone https://github.com/yourusername/dynagate.git
cd dynagate
```

2. 安装依赖：

```bash
go mod tidy
```

3. 构建项目：

```bash
go build
```

## 配置

DynaGate支持通过命令行参数进行配置：

- `-h`: 主机名或IP地址（默认：0.0.0.0）
- `-p`: 端口号（默认：8080）
- `-ldap-url`: LDAP服务器URL（默认：ldap://localhost:389）
- `-ldap-base`: LDAP基础DN（默认：dc=example,dc=com）
- `-etcd-endpoints`: ETCD服务器地址，多个地址用逗号分隔（默认：localhost:2379）
- `-etcd-timeout`: ETCD客户端超时时间（默认：5s）

## 运行

```bash
./dynagate -h 0.0.0.0 -p 8080 -ldap-url "ldap://ldap.example.com:389" -ldap-base "dc=example,dc=com"
```

## 功能说明

### 1. LDAP认证

- 用户需要通过LDAP认证才能访问系统
- 支持配置LDAP服务器地址和基础DN

### 2. 配置管理

- 支持查看、添加、修改和删除ETCD中的配置
- 提供树形结构展示配置层级
- 支持配置搜索功能

### 3. 配置验证

- 支持NGINX配置格式验证
- 支持CoreDNS配置格式验证
- 可扩展支持其他配置类型的验证

### 4. 审计日志

- 记录所有配置变更操作
- 支持按时间范围查询
- 支持按用户查询
- 支持按配置键查询

## API接口

### 认证接口

- `POST /login`: 用户登录
  - 请求体：`{"username": "user", "password": "pass"}`

### ETCD操作接口

- `GET /api/etcd/*key`: 获取配置值
- `PUT /api/etcd/*key`: 设置配置值
  - 请求体：`{"value": "配置内容"}`
- `DELETE /api/etcd/*key`: 删除配置

### 审计日志接口

- `GET /api/audit`: 获取审计日志
  - 查询参数：
    - `start`: 开始时间（RFC3339格式）
    - `end`: 结束时间（RFC3339格式）
    - `user`: 用户名（可选）
    - `key`: 配置键（可选）

## 开发说明

### 项目结构

```
dynagate/
├── main.go              # 主程序入口
├── pkg/
│   ├── audit/          # 审计日志包
│   ├── handlers/       # HTTP处理程序
│   └── validator/      # 配置验证器
├── static/             # 静态资源
│   └── js/
│       └── app.js      # 前端Vue应用
├── templates/          # HTML模板
│   └── index.html      # 主页模板
├── go.mod              # Go模块文件
└── README.md          # 项目说明文档
```

### 扩展配置验证

要添加新的配置类型验证，需要：

1. 在`pkg/validator/validator.go`中添加新的验证函数
2. 在`pkg/handlers/handlers.go`中的`SetValue`处理程序中添加新的配置类型判断
3. 在前端`app.js`中添加相应的验证逻辑

## 贡献指南

欢迎提交Pull Request来改进项目。在提交PR之前，请确保：

1. 代码符合Go的代码规范
2. 添加了必要的测试
3. 更新了相关文档

## 许可证

MIT License

Usage of D:\Applications\etcdkeeper\etcdkeeper.exe:
  -auth
        use auth
  -cacert string
        verify certificates of TLS-enabled secure servers using this CA bundle (v3)
  -cert string
        identify secure client using this TLS certificate file (v3)
  -h string
        host name or ip address (default "0.0.0.0")
  -key string
        identify secure client using this TLS key file (v3)
  -p int
        port (default 8080)
  -sendMsgSize int
        ETCD client max send msg size (default 2097152)
  -sep string
        separator (default "/")
  -skiptls
        skip verify tls
  -timeout int
        ETCD client connect timeout (default 5)
  -usetls
        use tls