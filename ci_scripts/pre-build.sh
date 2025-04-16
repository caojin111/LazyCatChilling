#!/bin/bash

# 设置环境变量
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

# 安装依赖
brew install swiftlint

# 运行 SwiftLint
swiftlint lint --strict

# 检查代码格式
swiftformat --lint .

# 确保所有文件都有正确的权限
find . -type f -name "*.sh" -exec chmod +x {} \; 