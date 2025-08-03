# KitchenKing-iOS

[![Swift](https://img.shields.io/badge/Swift-6-orange?style=for-the-badge&logo=swift)](https://swift.org/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS-blue?style=for-the-badge&logo=apple)](https://developer.apple.com/xcode/swiftui/)
[![iOS](https://img.shields.io/badge/iOS-17%2B-green?style=for-the-badge&logo=apple)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-purple?style=for-the-badge)](LICENSE)

👑 一个基于 SwiftUI 的 iOS 智能菜谱生成应用，让用户输入食材后，由不同菜系的名厨同时为其创造独特菜谱。融合游戏化体验与实用烹饪功能，让厨房变得有趣又美味！

<!-- 
![KitchenKing Demo](https://via.placeholder.com/800x400?text=KitchenKing+iOS+App+Screenshot)
*应用界面截图 - 展示厨师创作过程和菜谱详情*
-->

## 🌟 功能特性

### 🍳 核心功能
- **智能食材识别**：用户输入拥有的食材，AI 智能分析搭配
- **多菜系同时创作**：6大菜系（湘菜、粤菜、川菜、法国菜、泰国菜、俄罗斯菜）厨师同时竞技
- **实时制作过程**：观察厨师们的制作步骤和进度更新
- **详细菜谱展示**：完整的制作步骤、食材搭配、营养贴士
- **菜谱收藏系统**：收藏喜欢的菜谱，随时查看

### 🎮 游戏化体验
- **厨王争霸赛**：厨师们同时创作，比拼完成速度
- **实时状态追踪**：空闲中 → 制作中 → 完成/失败的状态转换
- **完成排名系统**：显示厨师们的完成顺序和用时
- **庆祝动画效果**：完成时的礼花庆祝和音效反馈
- **卡片选中交互**：点击卡片查看详细信息，支持选中状态

### 🎨 用户体验
- **精美动画效果**：卡片逐个显示、滚动定位、状态转换动画
- **音频反馈系统**：背景音乐和音效增强沉浸感
- **响应式设计**：完美适配 iPhone 和 iPad 设备
- **直观操作界面**：简洁易懂的操作流程
- **个性化设置**：支持自定义厨师角色和偏好设置

## 🎨 设计特色

### 视觉风格
- **现代化设计**：简洁优雅的界面设计，符合 Apple Human Interface Guidelines
- **SF Symbols**：使用苹果官方图标库，确保视觉一致性
- **SwiftUI**：采用现代化声明式 UI 框架，原生性能体验
- **精美动画**：流畅的状态转换、卡片显示和交互反馈动画

### 核心界面组件
- **HeaderView**：应用标题、皇冠图标和功能按钮
- **IngredientInputView**：智能食材输入和随机生成功能
- **ChefGridView**：厨师网格展示，支持自动滚动和动画
- **ChefCardView**：交互式厨师卡片，支持选中状态和详细展示
- **DishDetailView**：现代化菜谱详情展示，包含制作步骤和小贴士
- **FavoritesView**：收藏管理界面，支持本地存储
- **SettingsView**：个性化设置和订阅管理

### 交互特性
- **卡片动画**：逐个显示的卡片动画效果
- **自动滚动**：智能滚动到最新完成的厨师
- **选中反馈**：点击卡片的视觉和动画反馈
- **音效系统**：背景音乐和交互音效
- **礼花效果**：完成时的庆祝动画

## 🛠 技术栈

### 开发环境
- **Xcode 15.0+**：最新 iOS 开发 IDE
- **Swift 6**：使用最新 Swift 语言特性和并发编程
- **SwiftUI**：现代化声明式 UI 框架
- **Combine**：响应式编程框架
- **iOS 17.0+**：目标系统版本，使用最新 API

### 架构设计
- **MVVM 架构**：Model-View-ViewModel 设计模式
- **状态管理**：@StateObject、@ObservedObject、@EnvironmentObject
- **异步编程**：async/await 并发处理，Task 管理
- **数据持久化**：UserDefaults 本地存储收藏数据
- **音频管理**：AVFoundation 音频播放和管理

### 核心技术特性
- **并发处理**：多厨师同时创作的异步处理
- **动画系统**：SwiftUI 动画和自定义转场效果
- **响应式布局**：自适应不同屏幕尺寸和方向
- **内存管理**：优化的对象生命周期管理
- **错误处理**：完善的错误处理和用户反馈机制

## 📱 项目结构

```
KitchenKing-V2/
├── KitchenKing_V2App.swift          # 应用入口和主配置
├── ContentView.swift                # 主界面容器
├── Models.swift                     # 数据模型和应用状态
├── Views/
│   ├── HeaderView.swift            # 头部导航视图
│   ├── IngredientInputView.swift   # 食材输入视图
│   ├── ChefGridView.swift          # 厨师网格展示
│   ├── ChefCardView.swift          # 厨师卡片组件
│   ├── DishDetailView.swift        # 菜品详情展示
│   ├── FavoritesView.swift        # 收藏管理界面
│   └── SettingsView.swift         # 设置和订阅管理
├── Components/
│   ├── ConfettiEffectView.swift    # 礼花动画效果
│   ├── PixelLoadingIndicator.swift # 加载指示器
│   ├── CustomChefCreationView.swift # 自定义厨师创建
│   └── ChefRoleManagementView.swift # 厨师角色管理
├── Services/
│   ├── APIService.swift           # API 网络服务
│   └── AudioManager.swift         # 音频管理服务
└── Extensions.swift                # 工具扩展和辅助函数
```

## 🚀 快速开始

### 环境要求
- **macOS 14.0+**：最新 macOS 系统
- **Xcode 15.0+**：最新 iOS 开发工具
- **iOS 17.0+**：目标系统版本
- **iPhone 16 模拟器**：推荐开发和测试环境

### 安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/AissenLiu/KitchenKing-iOS.git
   cd KitchenKing-iOS
   ```

2. **打开项目**
   ```bash
   open KitchenKing-V2.xcodeproj
   ```

3. **配置开发环境**
   - 选择 iPhone 16 模拟器作为目标设备
   - 确保网络连接正常（API 调用需要）
   - 检查 Bundle Identifier 和签名配置

4. **构建运行**
   - 点击运行按钮 (⌘+R)
   - 或使用命令行：`xcodebuild -scheme KitchenKing-V2 -destination 'platform=iOS Simulator,name=iPhone 16' build`

## 🎯 使用方法

### 🎮 基本操作流程

1. **输入食材**
   - 在食材输入框中输入拥有的食材
   - 支持多个食材，用逗号分隔
   - 点击"随机食材"按钮获取灵感

2. **开始厨王争霸**
   - 点击"开始厨王争霸"按钮启动比赛
   - 6大菜系厨师同时开始创作
   - 观看卡片逐个显示的动画效果

3. **观察创作过程**
   - 实时查看厨师们的制作进度
   - 系统自动滚动到最新完成的厨师
   - 享受背景音乐和动画效果

4. **查看菜谱详情**
   - 点击完成的厨师卡片查看详细菜谱
   - 包含制作步骤、食材搭配、小贴士
   - 支持收藏喜欢的菜谱

### 🔧 高级功能

- **收藏管理**：点击心形图标收藏喜欢的菜谱
- **个性化设置**：自定义厨师角色和偏好设置
- **音频控制**：开启/关闭背景音乐和音效
- **重置功能**：一键清空当前状态，重新开始
- **订阅服务**：解锁高级厨师角色和无限生成次数

## 👨‍🍳 厨师角色系统

### 菜系特色
- **湘菜**：辣椒王老张 - 香辣浓郁，麻辣过瘾
- **粤菜**：阿华师傅 - 清淡鲜美，原汁原味
- **川菜**：麻辣刘大厨 - 麻辣鲜香，层次丰富
- **法国菜**：Pierre大师 - 精致考究，法式浪漫
- **泰国菜**：Somchai师傅 - 酸辣开胃，椰浆香浓
- **俄罗斯菜**：Ivan大叔 - 分量十足，俄式传统

### 厨师状态系统
- **空闲中 (Idle)**：等待食材输入，准备就绪
- **制作中 (Cooking)**：正在创作菜谱，显示实时进度
- **已完成 (Completed)**：成功创作完成，展示庆祝动画
- **失败 (Error)**：创作遇到困难，显示错误信息

### 完成排名机制
- 实时记录厨师完成顺序
- 显示完成时间和用时统计
- 支持滚动到最新完成的厨师

## 🔄 数据流架构

### 状态管理
- **AppState**：全局应用状态管理
- **Chef**：厨师个体状态和进度
- **Dish**：菜品数据模型和详情
- **API Service**：网络请求和数据处理
- **Audio Manager**：音频播放和管理

### 并发处理
- **多厨师并行创作**：使用 async/await 实现并发
- **实时状态更新**：Combine 响应式数据流
- **动画同步**：协调多个动画和视觉效果
- **错误处理**：完善的异常处理和用户反馈

## 🎨 设计原则

### 用户体验
- **简洁直观**：易于理解和操作，符合用户直觉
- **视觉反馈**：清晰的状态指示和动画反馈
- **响应式设计**：完美适配 iPhone 和 iPad 设备
- **无障碍支持**：符合 Apple 无障碍设计标准
- **沉浸式体验**：游戏化元素与实用功能的完美结合

### 技术标准
- **Swift 6**：使用最新语言特性和并发编程
- **现代 API**：严格遵循 Apple Human Interface Guidelines
- **性能优化**：60fps 流畅动画和快速响应
- **内存管理**：智能对象生命周期管理，避免内存泄漏
- **代码质量**：模块化设计，易于维护和扩展

## 🔒 隐私与安全

### 数据保护
- **本地处理**：所有收藏数据本地存储，保护用户隐私
- **最小权限**：只请求必要的系统权限
- **加密传输**：API 通信使用 HTTPS 加密
- **匿名使用**：无需注册即可使用核心功能

### 用户隐私
- **透明政策**：清晰的数据使用说明
- **用户控制**：用户完全掌控个人数据
- **无追踪**：不收集用户行为数据
- **合规性**：符合 GDPR 和相关隐私法规

## 📈 更新计划

### ✅ 已完成功能
- [x] 基础菜谱生成功能
- [x] 多菜系厨师系统
- [x] 实时动画效果
- [x] 菜谱收藏功能
- [x] 音效系统
- [x] 个性化设置

### 🚧 开发中功能
- [ ] 用户账户系统
- [ ] 菜谱分享功能
- [ ] 营养成分分析
- [ ] 烹饪计时器

### 📋 未来规划
- [ ] 多语言支持
- [ ] Apple Watch 应用
- [ ] 离线模式
- [ ] 社区分享功能
- [ ] 个性化推荐算法

## 🤝 贡献指南

### 开发规范
- **Swift 编码规范**：遵循官方 Swift 编码风格指南
- **SwiftUI 最佳实践**：使用现代化 SwiftUI 开发模式
- **代码注释**：添加清晰的文档注释和代码说明
- **测试覆盖**：为核心功能编写单元测试
- **性能考虑**：注意内存使用和性能优化

### 提交规范
- **清晰的提交信息**：使用描述性的提交信息
- **Git Flow 工作流**：遵循分支管理最佳实践
- **代码审查**：通过代码审查确保代码质量
- **文档更新**：及时更新相关文档
- **Issue 管理**：使用 GitHub Issues 进行问题跟踪

### 环境配置
- **开发工具**：Xcode 15.0+ 和 Swift 6
- **模拟器**：推荐使用 iPhone 16 模拟器
- **依赖管理**：使用 Swift Package Manager
- **代码格式化**：建议使用 SwiftFormat

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 联系方式

- **项目地址**：https://github.com/AissenLiu/KitchenKing-iOS
- **问题反馈**：[GitHub Issues](https://github.com/AissenLiu/KitchenKing-iOS/issues)
- **功能建议**：[GitHub Discussions](https://github.com/AissenLiu/KitchenKing-iOS/discussions)
- **邮件联系**：[提交 Issue](https://github.com/AissenLiu/KitchenKing-iOS/issues/new)

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者、设计师和测试人员。特别感谢：

- **SwiftUI 社区**：提供的技术支持和灵感
- **Apple Developer**：提供优秀的开发工具和文档
- **开源项目**：为项目提供基础组件和思路
- **测试用户**：提供宝贵的反馈和建议

---

## 📊 项目统计

[![GitHub stars](https://img.shields.io/github/stars/AissenLiu/KitchenKing-iOS?style=social)](https://github.com/AissenLiu/KitchenKing-iOS)
[![GitHub forks](https://img.shields.io/github/forks/AissenLiu/KitchenKing-iOS?style=social)](https://github.com/AissenLiu/KitchenKing-iOS)
[![GitHub issues](https://img.shields.io/github/issues/AissenLiu/KitchenKing-iOS)](https://github.com/AissenLiu/KitchenKing-iOS/issues)
[![GitHub last commit](https://img.shields.io/github/last-commit/AissenLiu/KitchenKing-iOS)](https://github.com/AissenLiu/KitchenKing-iOS/commits/main)

## 🔗 快速链接

- **[下载项目](https://github.com/AissenLiu/KitchenKing-iOS/archive/refs/heads/main.zip)** - 直接下载源码
- **[报告问题](https://github.com/AissenLiu/KitchenKing-iOS/issues/new)** - 提交 Bug 或功能建议
- **[功能讨论](https://github.com/AissenLiu/KitchenKing-iOS/discussions)** - 参与功能讨论
- **[更新日志](https://github.com/AissenLiu/KitchenKing-iOS/commits/main)** - 查看更新历史

---

**KitchenKing-iOS** - 让每个人都能成为厨房的王者！👑🍳

*用科技让烹饪变得更有趣，让美食触手可及。*

Made with ❤️ by [Aissen Liu](https://github.com/AissenLiu) and contributors