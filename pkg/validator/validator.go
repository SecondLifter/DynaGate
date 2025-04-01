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
	if !strings.Contains(content, "server {") {
		return ValidationResult{
			Valid:   false,
			Message: "Invalid NGINX configuration: missing server block",
		}
	}

	// 检查基本语法
	if !strings.Contains(content, "}") {
		return ValidationResult{
			Valid:   false,
			Message: "Invalid NGINX configuration: missing closing brace",
		}
	}

	// 检查常见指令
	requiredDirectives := []string{"listen", "server_name"}
	missingDirectives := []string{}

	for _, directive := range requiredDirectives {
		if !strings.Contains(content, directive) {
			missingDirectives = append(missingDirectives, directive)
		}
	}

	if len(missingDirectives) > 0 {
		return ValidationResult{
			Valid:   false,
			Message: fmt.Sprintf("Missing required directives: %s", strings.Join(missingDirectives, ", ")),
		}
	}

	return ValidationResult{
		Valid:   true,
		Message: "NGINX configuration appears to be valid",
	}
}

// validateCoreDNS performs basic CoreDNS configuration validation
func validateCoreDNS(content string) ValidationResult {
	// 检查基本语法
	if !strings.Contains(content, "{") || !strings.Contains(content, "}") {
		return ValidationResult{
			Valid:   false,
			Message: "Invalid CoreDNS configuration: missing block structure",
		}
	}

	// 检查常见插件
	commonPlugins := []string{"forward", "cache", "log", "errors"}
	foundPlugins := false

	for _, plugin := range commonPlugins {
		if strings.Contains(content, plugin) {
			foundPlugins = true
			break
		}
	}

	if !foundPlugins {
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
