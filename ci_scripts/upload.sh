#!/bin/bash

# 设置环境变量
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

# 验证构建
echo "Validating build..."
xcrun altool --validate-app -f "LazyCatChilling.ipa" \
    -t ios \
    -u "$APP_STORE_USERNAME" \
    -p "$APP_STORE_PASSWORD"

# 上传到 App Store
echo "Uploading to App Store..."
xcrun altool --upload-app -f "LazyCatChilling.ipa" \
    -t ios \
    -u "$APP_STORE_USERNAME" \
    -p "$APP_STORE_PASSWORD"

# 检查上传状态
if [ $? -eq 0 ]; then
    echo "Upload successful!"
else
    echo "Upload failed!"
    exit 1
fi 