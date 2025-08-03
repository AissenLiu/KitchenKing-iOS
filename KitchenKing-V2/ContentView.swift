//
//  ContentView.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

// 导入 SwiftUI 框架，用于构建用户界面
import SwiftUI

// 定义主视图结构体，遵循 View 协议
struct ContentView: View {
    // 创建应用状态对象，使用 @StateObject 进行状态管理
    @StateObject private var appState = AppState()
    // 创建 API 服务对象，用于网络请求
    @StateObject private var apiService = APIService()
    // 存储用户输入的食材字符串
    @State private var ingredients = ""
    // 存储当前占位符文本的索引
    @State private var placeholderIndex = 0
    
    // 预览模式标记，用于在 Xcode 预览中显示示例数据
    #if DEBUG
    private let isPreviewMode = false
    #else
    private let isPreviewMode = false
    #endif
    
    // 占位符文本数组，用于在输入框中循环显示示例
    private let placeholders = [
        "鸡蛋，番茄，牛肉",
        "土豆，洋葱，鸡肉",
        "豆腐，青菜，蘑菇",
        "鱼肉，生姜，葱",
        "猪肉，白菜，豆腐",
        "虾仁，黄瓜，鸡蛋",
        "牛肉，胡萝卜，土豆",
        "鸡肉，玉米，青豆"
    ]
    
    // 单个配料库，包含所有可用的食材，用于随机生成功能
    private let ingredientPool = [
        "鸡蛋", "番茄", "牛肉", "土豆", "洋葱", "鸡肉", 
        "豆腐", "青菜", "蘑菇", "鱼肉", "生姜", "葱", 
        "猪肉", "白菜", "虾仁", "黄瓜", "玉米", "青豆",
        "胡萝卜", "茄子", "青椒", "豆芽", "豆腐皮", "木耳",
        "菠菜", "芹菜", "韭菜", "黄花菜", "冬瓜", "南瓜",
        "茄子", "豆角", "山药", "莲藕", "竹笋", "百合",
        "西兰花", "菜花", "生菜", "油麦菜", "苋菜", "芥蓝"
    ]
    
    // 视图主体，定义 UI 的结构和布局
    var body: some View {
        // 创建导航视图容器
        NavigationView {
            // 创建 ZStack 叠加布局
            ZStack {
                // 设置白色背景色
                Color.white
                    // 忽略安全区域，使背景充满整个屏幕
                    .ignoresSafeArea()
                
                // 创建滚动视图，用于支持内容滚动
                ScrollView {
                    // 根据应用状态动态调整间距，初始状态居中，开始后靠上
                    Spacer(minLength: appState.hasStarted ? 0 : 150)
                    
                    // 创建垂直堆栈视图，设置间距为 24
                    VStack(spacing: 24) {
                        // 显示头部标题视图
                        HeaderView()
                        
                        // 创建食材输入视图
                        IngredientInputView(
                            // 绑定食材输入状态
                            ingredients: $ingredients,
                            // 传递当前占位符文本
                            placeholder: placeholders[placeholderIndex],
                            // 设置生成按钮点击回调
                            onGenerate: handleGenerate,
                            // 设置随机按钮点击回调
                            onRandom: handleRandom,
                            // 传递加载状态
                            isLoading: appState.isLoading
                        )
                        // 添加顶部内边距 100
                        .padding(.top,100)
                        
                        // 创建厨师网格展示视图
                        if appState.hasStarted {
                            ChefGridView(
                                // 传递应用状态对象
                                appState: appState,
                                // 设置菜品点击回调
                                onDishClick: handleDishClick,
                                // 设置重置按钮回调
                                onReset: handleReset
                            )
                            // 添加顶部内边距 100
                            .padding(.top,100)
                        }
                        
                        // 创建弹性空间，最小高度为 50
                        Spacer(minLength: 50)
                    }
                    // 为 VStack 添加默认内边距
                    .padding()
                }
            }
            // 添加工作表（模态视图），根据 appState.isModalOpen 状态显示
            .sheet(isPresented: $appState.isModalOpen) {
                // 检查是否有选中的菜品
                if let dish = appState.selectedDish {
                    // 显示菜品详情视图
                    DishDetailView.modern(dish: dish) {
                        // 关闭模态视图
                        appState.isModalOpen = false
                    }
                }
            }
            // 视图出现时执行的回调
            .onAppear {
                // 启动占位符文本轮换
                startPlaceholderRotation()
                // 如果是预览模式，设置预览数据
                if isPreviewMode {
                    setupPreviewData()
                }
            }
        }
    }
    
    // 启动占位符文本轮换的定时器
    private func startPlaceholderRotation() {
        // 创建定时器，每 2 秒执行一次
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            // 循环更新占位符索引
            placeholderIndex = (placeholderIndex + 1) % placeholders.count
        }
    }
    
    // 处理生成菜品请求
    private func handleGenerate() {
        // 检查食材输入是否为空，如果为空则直接返回
        guard !ingredients.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // 设置已开始状态
        appState.hasStarted = true
        
        // 创建异步任务执行 API 调用
        Task {
            // 调用所有厨师的 API 服务
            await apiService.callAllChefs(
                // 传递用户输入的食材
                ingredients: ingredients,
                // 传递 API 密钥
                apiKey: appState.apiKey,
                // 传递应用状态对象
                appState: appState
            )
        }
    }
    
    // 处理菜品点击事件
    private func handleDishClick(_ dish: Dish) {
        // 设置选中的菜品
        appState.selectedDish = dish
        // 打开模态视图
        appState.isModalOpen = true
    }
    
    // 处理重置操作
    private func handleReset() {
        // 重置应用状态
        appState.reset()
        // 清空食材输入
        ingredients = ""
        // 设置已开始状态
        appState.hasStarted = false
    }
    
    // 处理随机食材生成
    private func handleRandom() {
        // 从配料库中随机选择3个不同的配料
        let shuffled = ingredientPool.shuffled()
        let selectedIngredients = Array(shuffled.prefix(3))
        // 将选中的配料用逗号连接成字符串
        ingredients = selectedIngredients.joined(separator: "，")
    }
    
    // 验证食材输入是否有效
    private func isValidIngredients(_ text: String) -> Bool {
        // 检查文本去除空白字符后是否为空
        return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // 设置预览数据，用于 Xcode 预览模式
    private func setupPreviewData() {
        // 初始化厨师数据
        appState.initializeChefs()
        
        // 设置不同的厨师状态用于展示
        if appState.chefs.count > 0 {
            // 设置第一个厨师为完成状态
            appState.chefs[0].status = .completed
            appState.chefs[0].completionOrder = 0
            appState.chefs[0].dish = createSampleDish(name: "湘味小炒肉", cuisine: "湘菜")
            
            // 设置第二个厨师为烹饪状态
            appState.chefs[1].status = .cooking
            appState.chefs[1].cookingStep = "正在热锅..."
            
            // 设置第三个厨师为完成状态
            appState.chefs[2].status = .completed
            appState.chefs[2].completionOrder = 1
            appState.chefs[2].dish = createSampleDish(name: "白切鸡", cuisine: "粤菜")
            
            // 设置第四个厨师为错误状态
            appState.chefs[3].status = .error
            appState.chefs[3].cookingStep = "太难了，做不出来！"
            
            // 设置第五个厨师为烹饪状态
            appState.chefs[4].status = .cooking
            appState.chefs[4].cookingStep = "加点蒜..."
            
            // 设置第六个厨师为空闲状态
            appState.chefs[5].status = .idle
        }
        
        // 设置完成顺序数组
        appState.completionOrder = ["湘菜", "粤菜"]
        
        // 设置示例食材输入
        ingredients = "鸡肉，土豆，胡萝卜"
    }
    
    // 创建示例菜品数据
    private func createSampleDish(name: String, cuisine: String) -> Dish {
        // 返回一个示例菜品对象
        return Dish(
            // 菜品名称
            dishName: name,
            // 菜品食材信息
            ingredients: Dish.Ingredients(
                // 主要食材
                main: ["鸡肉", "土豆"],
                // 辅助食材
                auxiliary: ["胡萝卜", "洋葱"],
                // 调料
                seasoning: ["盐", "胡椒粉", "生抽"]
            ),
            // 烹饪步骤
            steps: [
                CookingStep(step: 1, title: "准备食材", details: ["将鸡肉切块，土豆去皮切块"]),
                CookingStep(step: 2, title: "热锅下油", details: ["锅中倒油，加热至6成热"]),
                CookingStep(step: 3, title: "炒制", details: ["先炒鸡肉至变色，再加入土豆"])
            ],
            // 烹饪小贴士
            tips: ["火候要掌握好", "可以适当加一点水焖煮"],
            // 口味特征
            flavorProfile: FlavorProfile(taste: "鲜美可口", specialEffect: "营养丰富"),
            // 免责声明
            disclaimer: "请根据个人口味调整调料用量"
        )
    }
}

// Xcode 预览提供者
#Preview {
    ContentView()
}
