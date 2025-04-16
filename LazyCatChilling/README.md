# 懒猫摸鱼 (LazyCatChilling)

一款提醒上班族适当休息、活动身体的iOS应用，旨在帮助用户养成健康的工作习惯。

## 功能特点

- **科学的工作-休息安排**：基于用户工作类型和习惯提供个性化时间建议
- **卡通猫咪动画**：可爱的猫咪随状态变化展示不同动画，增加趣味性
- **多样提醒方式**：声音、震动和通知多种提醒方式
- **简洁友好的界面**：清晰明了的界面设计，简单易用
- **完全免费**：无内购，无广告，无需登录

## 技术规格

- iOS 14.0+
- SwiftUI
- 纯本地应用，不需要网络

## 项目结构

```
LazyCatChilling/
├── LazyCatChillingApp.swift        # 应用入口
├── Views/                           # 视图文件
│   ├── ContentView.swift           # 主视图容器
│   ├── MainView.swift              # 主界面
│   ├── OnboardingView.swift        # 引导页视图
│   └── SettingsView.swift          # 设置页面
├── ViewModels/
│   └── AppStateManager.swift       # 应用状态管理
├── Models/
│   └── UserSettings.swift          # 数据模型
├── Utilities/
│   └── TimeFormatter.swift         # 工具函数
└── Resources/                       # 资源文件
    ├── Animations/                 # 动画资源
    └── Sounds/                     # 音效资源
```

## 开发和运行

1. 克隆仓库到本地
2. 使用Xcode 12.0+打开项目
3. 构建并运行项目（Command+R）

## 注意事项

- 本项目中的动画资源还未完成，当前使用临时图标代替
- 音效资源暂时使用系统声音代替
- 实际开发中需要替换为自定义动画和音效

## 未来计划

- 添加猫咪的完整动画
- 增加自定义背景音乐选择
- 添加更多主题色选项
- 支持Apple Watch应用
