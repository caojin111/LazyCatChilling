#!/bin/bash

# 上传构建日志
if [ -f "build.log" ]; then
    echo "Uploading build logs..."
    # 这里可以添加上传日志到云存储的逻辑
fi

# 发送构建通知
if [ "$CI_BUILD_STATUS" == "SUCCESS" ]; then
    echo "Build succeeded!"
    # 这里可以添加发送成功通知的逻辑
else
    echo "Build failed!"
    # 这里可以添加发送失败通知的逻辑
fi

# 清理临时文件
rm -rf ~/Library/Developer/Xcode/DerivedData/* 