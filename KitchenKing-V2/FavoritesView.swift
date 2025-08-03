//
//  FavoritesView.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

// 导入SwiftUI框架，用于构建用户界面
import SwiftUI

// 定义收藏视图结构体，遵循View协议
struct FavoritesView: View {
    // 观察应用状态对象，用于数据绑定
    @ObservedObject var appState: AppState
    // 状态属性：存储用户选择的菜品
    @State private var selectedDish: Dish?
    // 状态属性：控制是否显示详情页面
    @State private var showingDetail = false
    // 状态属性：标记数据是否已加载完成
    @State private var hasLoaded = false
    
    // 计算属性：定义视图的主体内容
    var body: some View {
        // 创建导航视图容器
        NavigationView {
            // 创建垂直堆栈布局
            VStack {
                // 条件判断：如果数据未加载完成
                if !hasLoaded {
                    // 显示加载进度指示器
                    ProgressView("加载中...")
                        // 设置最大宽度和高度，占满可用空间
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } 
                // 条件判断：如果收藏菜品列表为空
                else if appState.favoriteDishes.isEmpty {
                    // 显示空收藏提示视图
                    EmptyFavoritesView()
                } 
                // 其他情况：有收藏菜品
                else {
                    // 创建列表视图
                    List {
                        // 遍历收藏菜品数组
                        ForEach(appState.favoriteDishes) { dish in
                            // 创建收藏菜品行视图
                            FavoriteDishRow(
                                dish: dish,
                                // 点击回调：设置选中的菜品并显示详情
                                onTap: {
                                    selectedDish = dish
                                    showingDetail = true
                                },
                                // 删除回调：从收藏中移除菜品
                                onRemove: {
                                    appState.removeFromFavorites(dish)
                                }
                            )
                        }
                        // 添加删除功能，调用删除方法
                        .onDelete(perform: deleteFavorites)
                    }
                }
            }
            // 设置导航栏标题
            .navigationTitle("喜欢的菜")
            // 添加模态页面，显示菜品详情
            .sheet(isPresented: $showingDetail) {
                // 条件绑定：确保有选中的菜品
                if let dish = selectedDish {
                    // 显示菜品详情视图，现代风格
                    DishDetailView.modern(dish: dish) {
                        // 关闭回调：隐藏详情页面
                        showingDetail = false
                    }
                }
            }
            // 视图出现时的回调
            .onAppear {
                // 如果数据还未加载
                if !hasLoaded {
                    // 确保数据已加载
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        // 延迟设置加载完成标志
                        hasLoaded = true
                    }
                }
            }
        }
    }
    
    // 私有方法：删除收藏的菜品
    private func deleteFavorites(at offsets: IndexSet) {
        // 根据索引集合获取要删除的菜品数组
        let dishesToDelete = offsets.map { appState.favoriteDishes[$0] }
        // 遍历要删除的菜品
        for dish in dishesToDelete {
            // 从收藏中移除菜品
            appState.removeFromFavorites(dish)
        }
    }
}

// MARK: - 空收藏视图
// 定义空收藏提示视图结构体，遵循View协议
struct EmptyFavoritesView: View {
    // 计算属性：定义视图的主体内容
    var body: some View {
        // 创建垂直堆栈布局，间距20点
        VStack(spacing: 20) {
            // 显示心形斜杠图标，表示无收藏
            Image(systemName: "heart.slash")
                // 设置系统字体大小为60点
                .font(.system(size: 60))
                // 设置文字颜色为黑色
                .foregroundColor(.black)
                // 设置透明度为0.3
                .opacity(0.3)
            
            // 显示"暂无收藏"文本
            Text("暂无收藏")
                // 设置字体为二级标题
                .font(.title2)
                // 设置字重为中等
                .fontWeight(.medium)
                // 设置文字颜色为黑色
                .foregroundColor(.black)
                // 设置透明度为0.6
                .opacity(0.6)
            
            // 显示操作提示文本
            Text("点击菜品详情中的心形图标来收藏喜欢的菜品")
                // 设置字体为副标题
                .font(.subheadline)
                // 设置文字颜色为黑色
                .foregroundColor(.black)
                // 设置透明度为0.5
                .opacity(0.5)
                // 设置多行文本居中对齐
                .multilineTextAlignment(.center)
                // 设置水平内边距
                .padding(.horizontal)
        }
        // 设置最大宽度和高度，占满可用空间
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // 设置背景颜色为白色
        .background(Color.white)
    }
}

// MARK: - 收藏菜品行
// 定义收藏菜品行视图结构体，遵循View协议
struct FavoriteDishRow: View {
    // 常量属性：菜品数据
    let dish: Dish
    // 常量属性：点击回调闭包
    let onTap: () -> Void
    // 常量属性：删除回调闭包
    let onRemove: () -> Void
    
    // 计算属性：定义视图的主体内容
    var body: some View {
        // 创建按钮，点击时执行onTap回调
        Button(action: onTap) {
            // 创建水平堆栈布局，间距12点
            HStack(spacing: 12) {
                // 显示填充的心形图标，表示已收藏
                Image(systemName: "heart.fill")
                    // 设置图标颜色为红色
                    .foregroundColor(.red)
                    // 设置透明度为0.6
                    .opacity(0.6)
                    // 设置字体为说明文字大小
                    .font(.caption)
                
                // 创建垂直堆栈布局，左对齐，间距4点
                VStack(alignment: .leading, spacing: 4) {
                    // 显示菜品名称
                    Text(dish.dishName)
                        // 设置字体为标题样式
                        .font(.headline)
                        // 设置文字颜色为黑色
                        .foregroundColor(.black)
                        // 限制行数为1行
                        .lineLimit(1)
                    
                    // 显示主要食材信息
                    Text("主要食材: \(dish.ingredients.main.joined(separator: ", "))")
                        // 设置字体为说明文字大小
                        .font(.caption)
                        // 设置文字颜色为黑色
                        .foregroundColor(.black)
                        // 设置透明度为0.5
                        .opacity(0.5)
                        // 限制行数为1行
                        .lineLimit(1)
                }
                
                // 创建弹性空间，将内容推向两侧
                Spacer()
                
                // 显示右箭头图标
                Image(systemName: "chevron.right")
                    // 设置图标颜色为黑色
                    .foregroundColor(.black)
                    // 设置透明度为0.4
                    .opacity(0.4)
                    // 设置字体为说明文字大小
                    .font(.caption)
            }
            // 设置垂直内边距为8点
            .padding(.vertical, 8)
        }
        // 设置按钮样式为无样式按钮
        .buttonStyle(PlainButtonStyle())
        // 添加滑动操作功能
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            // 创建删除按钮，破坏性角色
            Button(role: .destructive) {
                // 执行删除回调
                onRemove()
            } label: {
                // 按钮标签：删除图标和文字
                Label("删除", systemImage: "trash")
            }
        }
    }
}

// 预览提供者：用于Xcode预览功能
#Preview {
    // 创建测试应用状态
    let testAppState = createTestAppState()
    // 返回收藏视图实例用于预览
    return FavoritesView(appState: testAppState)
}

// MARK: - 测试数据创建
// 私有函数：创建测试用的应用状态
private func createTestAppState() -> AppState {
    // 创建应用状态实例
    let appState = AppState()
    
    // 添加测试菜品到收藏
    let testDishes = [
        // 创建宫保鸡丁菜品实例
        Dish(
            dishName: "宫保鸡丁",
            ingredients: Dish.Ingredients(
                main: ["鸡胸肉", "花生米", "干辣椒"],
                auxiliary: ["葱", "姜", "蒜"],
                seasoning: ["生抽", "老抽", "料酒", "糖", "醋", "盐"]
            ),
            steps: [
                CookingStep(step: 1, title: "准备食材", details: ["鸡胸肉切丁", "花生米炒香", "干辣椒切段"]),
                CookingStep(step: 2, title: "调制酱汁", details: ["生抽、老抽、料酒、糖、醋、盐调匀"]),
                CookingStep(step: 3, title: "炒制鸡肉", details: ["热锅下油", "爆香葱姜蒜", "下鸡丁炒至变色"])
            ],
            tips: ["火候要大，动作要快", "花生米要最后放保持脆感"],
            flavorProfile: FlavorProfile(taste: "酸甜微辣，口感丰富", specialEffect: "川菜经典"),
            disclaimer: "请根据个人口味调整辣度"
        ),
        // 创建红烧肉菜品实例
        Dish(
            dishName: "红烧肉",
            ingredients: Dish.Ingredients(
                main: ["五花肉", "冰糖"],
                auxiliary: ["葱", "姜", "八角", "桂皮"],
                seasoning: ["生抽", "老抽", "料酒", "盐"]
            ),
            steps: [
                CookingStep(step: 1, title: "处理五花肉", details: ["五花肉切块", "冷水下锅焯水", "捞出洗净"]),
                CookingStep(step: 2, title: "炒糖色", details: ["小火炒冰糖", "炒至焦糖色", "下肉块炒上色"])
            ],
            tips: ["炒糖色要用小火，避免炒糊", "慢火炖煮更入味"],
            flavorProfile: FlavorProfile(taste: "肥而不腻，甜咸适中", specialEffect: "色泽红亮"),
            disclaimer: "制作时间较长，请耐心等待"
        ),
        // 创建番茄鸡蛋菜品实例
        Dish(
            dishName: "番茄鸡蛋",
            ingredients: Dish.Ingredients(
                main: ["鸡蛋", "番茄"],
                auxiliary: ["葱"],
                seasoning: ["盐", "糖", "生抽"]
            ),
            steps: [
                CookingStep(step: 1, title: "准备食材", details: ["鸡蛋打散", "番茄切块", "葱切花"]),
                CookingStep(step: 2, title: "炒鸡蛋", details: ["热锅下油", "倒入蛋液", "炒成块状盛出"])
            ],
            tips: ["可以加少许糖提鲜", "番茄要熟透才出味"],
            flavorProfile: FlavorProfile(taste: "酸甜可口，营养丰富", specialEffect: "家常经典"),
            disclaimer: "简单易学，适合新手"
        )
    ]
    
    // 将测试菜品数组赋值给应用状态的收藏菜品属性
    appState.favoriteDishes = testDishes
    // 返回配置好的应用状态
    return appState
}
