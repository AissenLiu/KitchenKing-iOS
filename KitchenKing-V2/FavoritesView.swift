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
    // 环境变量：用于关闭视图
    @Environment(\.dismiss) private var dismiss
    // 状态属性：存储用户选择的菜品
    @State private var selectedDish: Dish?
    // 状态属性：用于强制刷新视图
    @State private var refreshTrigger = false
    // 计算属性：定义视图的主体内容
    var body: some View {
        // 创建导航视图容器
        NavigationView {
            ZStack {
                // 背景
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 头部统计信息
                    if !appState.favoriteDishes.isEmpty {
                        headerStatsView
                    }
                    
                    // 条件判断：如果收藏菜品列表为空
                    if appState.favoriteDishes.isEmpty {
                        // 显示空收藏提示视图
                        EmptyFavoritesView()
                    } else {
                        // 创建滚动视图
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                // 遍历收藏菜品数组
                                ForEach(appState.favoriteDishes) { dish in
                                    // 创建收藏菜品卡片视图
                                    FavoriteDishCard(
                                        dish: dish,
                                        // 点击回调：设置选中的菜品（自动触发详情页面显示）
                                        onTap: {
                                            selectedDish = dish
                                        },
                                        // 删除回调：从收藏中移除菜品
                                        onRemove: {
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                appState.removeFromFavorites(dish)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            // 设置导航栏标题
            .navigationTitle("喜欢的菜")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("返回") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                }
            }
            // 添加模态页面，显示菜品详情
            .sheet(item: $selectedDish) { dish in
                // 直接使用选中的菜品显示详情视图
                DishDetailView.modern(
                    dish: dish,
                    onClose: {
                        // 关闭回调：清空选中的菜品
                        selectedDish = nil
                    },
                    showFavoriteButton: false
                )
            }
            .onAppear {
                // 强制刷新收藏数据，解决第一次显示时的状态同步问题
                refreshTrigger.toggle()
                // 重新加载收藏数据以确保数据是最新的
                appState.loadFavorites()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // 头部统计信息视图
    private var headerStatsView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("收藏菜品")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("\(appState.favoriteDishes.count) 道菜")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                // iCloud 同步状态
                cloudSyncIndicator
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.red)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // 同步状态消息
            if let status = appState.cloudSyncStatus {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                    
                    Text(status)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.green)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .animation(.easeInOut(duration: 0.3), value: appState.cloudSyncStatus)
            }
            
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal, 20)
        }
        .background(Color.white)
    }
    
    // iCloud 同步指示器
    private var cloudSyncIndicator: some View {
        HStack(spacing: 8) {
            if CloudKitManager.shared.isSyncing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(0.8)
                
                Text("同步中")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.blue)
            } else {
                Button(action: {
                    appState.manualSync()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: appState.isCloudSyncEnabled ? "icloud.fill" : "icloud.slash")
                            .font(.system(size: 16))
                            .foregroundColor(appState.isCloudSyncEnabled ? .blue : .gray)
                        
                        Text(appState.isCloudSyncEnabled ? "iCloud" : "离线")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(appState.isCloudSyncEnabled ? .blue : .gray)
                    }
                }
                .buttonStyle(PlainButtonStyle())
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
        VStack(spacing: 32) {
            // 图标区域
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "heart")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(.red.opacity(0.6))
            }
            
            VStack(spacing: 16) {
                Text("还没有收藏的菜品")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.black)
                
                Text("在菜品详情页点击心形图标\n就能将喜欢的菜品添加到这里")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            // 装饰性小图标
            HStack(spacing: 20) {
                ForEach(0..<3) { _ in
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.red.opacity(0.3))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .padding(.horizontal, 40)
    }
}

// MARK: - 收藏菜品卡片
// 定义收藏菜品卡片视图结构体，遵循View协议
struct FavoriteDishCard: View {
    // 常量属性：菜品数据
    let dish: Dish
    // 常量属性：点击回调闭包
    let onTap: () -> Void
    // 常量属性：删除回调闭包
    let onRemove: () -> Void
    // 状态属性：控制删除确认对话框
    @State private var showingDeleteAlert = false
    
    // 计算属性：定义视图的主体内容
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // 头部区域
                HStack(spacing: 12) {
                    
                    // 菜品信息
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dish.dishName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                        
                        Text(dish.flavorProfile.taste)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    // 删除按钮
                    Button(action: { showingDeleteAlert = true }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.gray.opacity(0.6))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // 分隔线
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)
                
                // 食材信息
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("主要食材")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        
                        Text(dish.ingredients.main.prefix(3).joined(separator: "、"))
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                }
            }
            .padding(20)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .stroke(.black, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: showingDeleteAlert)
        .alert("确认删除", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                onRemove()
            }
        } message: {
            Text("确定要从收藏中移除「\(dish.dishName)」吗？")
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

// 卡片预览
#Preview("收藏卡片") {
    let testDish = Dish(
        dishName: "宫保鸡丁",
        ingredients: Dish.Ingredients(
            main: ["鸡胸肉", "花生米", "干辣椒"],
            auxiliary: ["葱", "姜", "蒜"],
            seasoning: ["生抽", "老抽", "料酒"]
        ),
        steps: [],
        tips: [],
        flavorProfile: FlavorProfile(taste: "酸甜微辣，口感丰富", specialEffect: "川菜经典"),
        disclaimer: ""
    )
    
    FavoriteDishCard(dish: testDish, onTap: {}, onRemove: {})
        .padding()
        .background(Color.gray.opacity(0.1))
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
