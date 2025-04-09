package validator

import (
	"fmt"
	"strings"
)

// ValidationResult represents the result of a configuration validation
type ValidationResult struct {
	Valid   bool
	Message string
}

// ValidateConfig validates configuration based on its type
func ValidateConfig(configType string, content string) ValidationResult {
	switch strings.ToLower(configType) {
	case "nginx":
		return validateNginx(content)
	case "coredns":
		return validateCoreDNS(content)
	default:
		return ValidationResult{
			Valid:   true,
			Message: "No specific validation for this configuration type",
		}
	}
}

// validateNginx performs basic NGINX configuration validation
func validateNginx(content string) ValidationResult {
	// 检查是否包含log_format指令，这种指令通常会跨多行并包含多个分号
	hasLogFormat := strings.Contains(content, "log_format")
	isMainConfig := strings.Contains(content, "worker_processes") ||
		strings.Contains(content, "error_log") ||
		strings.Contains(content, "pid")

	// 对于所有类型的Nginx配置，检查大括号是否匹配
	openBraces := strings.Count(content, "{")
	closeBraces := strings.Count(content, "}")

	if openBraces != closeBraces {
		return ValidationResult{
			Valid:   false,
			Message: fmt.Sprintf("括号不匹配: 发现 %d 个开括号和 %d 个闭括号", openBraces, closeBraces),
		}
	}

	// 检查是否缺少必要的块结构
	if !strings.Contains(content, "{") && !strings.Contains(content, "}") {
		// 如果完全没有括号，可能是配置错误
		if !strings.Contains(content, ";") {
			return ValidationResult{
				Valid:   false,
				Message: "无效的Nginx配置: 缺少分号和块结构",
			}
		}
	}

	if !strings.Contains(content, "server {") && !hasLogFormat && !isMainConfig {
		return ValidationResult{
			Valid:   false,
			Message: "Invalid NGINX configuration: missing server block",
		}
	}

	// 对于log_format，我们不进行严格的指令检查
	if hasLogFormat {
		return ValidationResult{
			Valid:   true,
			Message: "NGINX log_format configuration appears to be valid",
		}
	}

	// 如果是主配置文件，检查必要的指令
	if isMainConfig {
		if !strings.Contains(content, "events") {
			return ValidationResult{
				Valid:   false,
				Message: "Nginx主配置缺少必要的events块",
			}
		}
	} else {
		// 对于server配置，检查常见指令
		requiredDirectives := []string{"listen", "server_name"}
		missingDirectives := []string{}

		for _, directive := range requiredDirectives {
			if !strings.Contains(content, directive) {
				missingDirectives = append(missingDirectives, directive)
			}
		}

		if len(missingDirectives) > 0 && !strings.Contains(content, "events {") {
			// 如果是主配置，可能不需要listen和server_name
			if !strings.Contains(content, "worker_processes") &&
				!strings.Contains(content, "error_log") &&
				!strings.Contains(content, "pid") {
				return ValidationResult{
					Valid:   false,
					Message: fmt.Sprintf("Missing required directives: %s", strings.Join(missingDirectives, ", ")),
				}
			}
		}
	}

	return ValidationResult{
		Valid:   true,
		Message: "NGINX configuration appears to be valid",
	}
}

// validateCoreDNS performs basic CoreDNS configuration validation
func validateCoreDNS(content string) ValidationResult {
	// 检查是否为hosts文件格式 (IP hostname)
	if strings.Contains(strings.ToLower(content), ".host.") ||
		strings.Contains(strings.ToLower(content), "/hosts/") {
		// 对于hosts格式，只要包含IP地址即可认为有效
		if strings.Contains(content, ".") &&
			(strings.ContainsAny(content, "0123456789")) {
			return ValidationResult{
				Valid:   true,
				Message: "CoreDNS hosts configuration appears to be valid",
			}
		}
	}

	// 检查基本语法
	if !strings.Contains(content, "{") || !strings.Contains(content, "}") {
		// 如果不包含大括号，可能是纯hosts格式，检查是否有IP地址格式的行
		lines := strings.Split(content, "\n")
		for _, line := range lines {
			line = strings.TrimSpace(line)
			// 忽略注释行和空行
			if line == "" || strings.HasPrefix(line, "#") {
				continue
			}
			// 检查是否符合IP地址 hostname 的格式
			fields := strings.Fields(line)
			if len(fields) >= 2 {
				// 至少有两个字段，并且第一个字段是IP格式
				ip := fields[0]
				if strings.Count(ip, ".") == 3 {
					// 简单检查IP格式 (x.x.x.x)
					return ValidationResult{
						Valid:   true,
						Message: "CoreDNS hosts configuration appears to be valid",
					}
				}
			}
		}

		return ValidationResult{
			Valid:   false,
			Message: "Invalid CoreDNS configuration: missing block structure or valid hosts format",
		}
	}

	// 检查常见插件
	commonPlugins := []string{"forward", "cache", "log", "errors", "hosts"}
	foundPlugins := false

	for _, plugin := range commonPlugins {
		if strings.Contains(content, plugin) {
			foundPlugins = true
			break
		}
	}

	if !foundPlugins && !strings.Contains(content, ":") && !strings.Contains(content, "/") {
		// 如果没有常见插件，但包含域名端口格式(:)或路径格式(/)，仍然认为配置有效
		return ValidationResult{
			Valid:   false,
			Message: "No common CoreDNS plugins found in configuration",
		}
	}

	return ValidationResult{
		Valid:   true,
		Message: "CoreDNS configuration appears to be valid",
	}
}
