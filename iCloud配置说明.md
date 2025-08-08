# iCloud 同步配置说明

## 🔧 Xcode 项目配置步骤

### 1. 启用 CloudKit 能力
1. 在 Xcode 中打开项目
2. 选择项目 target (KitchenKing-V2)
3. 点击 "Signing & Capabilities" 标签
4. 点击 "+ Capability" 按钮
5. 搜索并添加 "iCloud"
6. 勾选 "CloudKit" 选项

### 2. 配置 iCloud 容器
1. 在刚添加的 iCloud 功能中
2. 点击 "Containers" 右侧的 "+" 按钮
3. 选择 "Use Custom Container"
4. 输入容器标识符: `iCloud.com.kitchenking.favorites`
5. 点击 "OK"

### 3. 添加权限文件
✅ 已自动创建 `KitchenKing-V2.entitlements` 文件
- 确保文件已添加到项目中
- 在 "Build Settings" 中搜索 "Code Signing Entitlements"
- 确保路径设置为: `KitchenKing-V2/KitchenKing-V2.entitlements`

### 4. 开发者账户设置
1. 在 Apple Developer 网站登录
2. 进入 "Certificates, Identifiers & Profiles"
3. 找到应用的 App ID
4. 编辑 App ID，启用 CloudKit 服务
5. 重新生成 Provisioning Profile

## 📱 功能说明

### 自动同步
- ✅ 添加收藏时自动同步到 iCloud
- ✅ 删除收藏时自动从 iCloud 删除  
- ✅ 应用启动时自动合并本地和云端数据
- ✅ 多设备间自动同步收藏数据

### 手动同步
- 在收藏页面点击 iCloud 图标可手动同步
- 在设置页面可以开启/关闭 iCloud 同步
- 在设置页面可以查看同步状态和最后同步时间

### 错误处理
- ✅ 自动检测 iCloud 账户状态
- ✅ 网络错误自动重试
- ✅ 友好的错误提示信息
- ✅ 本地数据备份保护

### UI 指示器
- ✅ 收藏界面显示同步状态
- ✅ 设置页面显示详细同步信息  
- ✅ 同步进度指示器
- ✅ 同步成功/失败状态显示

## 🧪 测试建议

### 基础功能测试
1. 确保 iCloud 账户已登录
2. 添加/删除收藏菜品
3. 观察同步状态指示器
4. 检查设置页面同步信息

### 多设备测试
1. 在设备 A 添加收藏
2. 在设备 B 打开应用
3. 验证收藏数据自动同步

### 网络异常测试
1. 关闭网络连接
2. 添加收藏（应显示离线状态）
3. 开启网络连接
4. 手动触发同步

### 错误恢复测试
1. 登出 iCloud 账户
2. 添加收藏（应显示错误提示）
3. 重新登录 iCloud
4. 手动同步恢复数据

## ⚠️ 注意事项

1. **开发环境**: 需要有效的 Apple Developer 账户
2. **测试环境**: 建议使用真机测试 CloudKit 功能
3. **数据安全**: 本地 UserDefaults 作为备份存储
4. **同步冲突**: 采用合并策略，不会丢失数据
5. **性能优化**: 使用异步操作，不阻塞 UI