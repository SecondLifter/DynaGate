#!/bin/bash

# 确保脚本在出错时退出
set -e

# 设置Go环境变量
export GOOS=linux
export GOARCH=amd64
export CGO_ENABLED=1
export CC=x86_64-linux-gnu-gcc

# 检查交叉编译工具链
if ! command -v $CC &> /dev/null; then
    echo "Error: Linux cross-compilation toolchain not found"
    echo "Please install cross-compilation toolchain:"
    echo "  brew install FiloSottile/musl-cross/musl-cross"
    exit 1
fi

# 编译
echo "Building for Linux (amd64)..."
go build -o dynagate-linux-amd64 .

echo "Build completed successfully" 