//
//  ContentView.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    @StateObject private var apiService = APIService()
    @State private var ingredients = ""
    @State private var placeholderIndex = 0
    
    // 预览模式
    #if DEBUG
    private let isPreviewMode = true
    #else
    private let isPreviewMode = false
    #endif
    
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
    
    var body: some View {
        NavigationView {
            ZStack {
                // 简洁的白色背景
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 头部
                        HeaderView()
                        
                        // 输入区域
                        IngredientInputView(
                            ingredients: $ingredients,
                            placeholder: placeholders[placeholderIndex],
                            onGenerate: handleGenerate,
                            onRandom: handleRandom,
                            isLoading: appState.isLoading
                        ).padding(.top,100)
                        
                        // 厨师展示区域
                        ChefGridView(
                            appState: appState,
                            onDishClick: handleDishClick,
                            onReset: handleReset
                        ).padding(.top,100)
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $appState.isModalOpen) {
                if let dish = appState.selectedDish {
                    DishDetailView.modern(dish: dish) {
                        appState.isModalOpen = false
                    }
                }
            }
            .onAppear {
                startPlaceholderRotation()
                if isPreviewMode {
                    setupPreviewData()
                }
            }
        }
    }
    
    private func startPlaceholderRotation() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            placeholderIndex = (placeholderIndex + 1) % placeholders.count
        }
    }
    
    private func handleGenerate() {
        guard !ingredients.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        Task {
            await apiService.callAllChefs(
                ingredients: ingredients,
                apiKey: appState.apiKey,
                appState: appState
            )
        }
    }
    
    private func handleDishClick(_ dish: Dish) {
        appState.selectedDish = dish
        appState.isModalOpen = true
    }
    
    private func handleReset() {
        appState.reset()
        ingredients = ""
    }
    
    private func handleRandom() {
        let randomIngredients = placeholders.randomElement() ?? placeholders[0]
        ingredients = randomIngredients
    }
    
    private func isValidIngredients(_ text: String) -> Bool {
        return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func setupPreviewData() {
        // 初始化厨师
        appState.initializeChefs()
        
        // 设置不同的厨师状态用于展示
        if appState.chefs.count > 0 {
            appState.chefs[0].status = .completed
            appState.chefs[0].completionOrder = 0
            appState.chefs[0].dish = createSampleDish(name: "湘味小炒肉", cuisine: "湘菜")
            
            appState.chefs[1].status = .cooking
            appState.chefs[1].cookingStep = "正在热锅..."
            
            appState.chefs[2].status = .completed
            appState.chefs[2].completionOrder = 1
            appState.chefs[2].dish = createSampleDish(name: "白切鸡", cuisine: "粤菜")
            
            appState.chefs[3].status = .error
            appState.chefs[3].cookingStep = "太难了，做不出来！"
            
            appState.chefs[4].status = .cooking
            appState.chefs[4].cookingStep = "加点蒜..."
            
            appState.chefs[5].status = .idle
        }
        
        // 设置完成顺序
        appState.completionOrder = ["湘菜", "粤菜"]
        
        // 设置示例食材
        ingredients = "鸡肉，土豆，胡萝卜"
    }
    
    private func createSampleDish(name: String, cuisine: String) -> Dish {
        return Dish(
            dishName: name,
            ingredients: Dish.Ingredients(
                main: ["鸡肉", "土豆"],
                auxiliary: ["胡萝卜", "洋葱"],
                seasoning: ["盐", "胡椒粉", "生抽"]
            ),
            steps: [
                CookingStep(step: 1, title: "准备食材", details: ["将鸡肉切块，土豆去皮切块"]),
                CookingStep(step: 2, title: "热锅下油", details: ["锅中倒油，加热至6成热"]),
                CookingStep(step: 3, title: "炒制", details: ["先炒鸡肉至变色，再加入土豆"])
            ],
            tips: ["火候要掌握好", "可以适当加一点水焖煮"],
            flavorProfile: FlavorProfile(taste: "鲜美可口", specialEffect: "营养丰富"),
            disclaimer: "请根据个人口味调整调料用量"
        )
    }
}

#Preview {
    ContentView()
}
