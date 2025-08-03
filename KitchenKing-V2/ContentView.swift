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
    
    #if DEBUG
    private let isPreviewMode = false
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
    
    private let ingredientPool = [
        "鸡蛋", "番茄", "牛肉", "土豆", "洋葱", "鸡肉", 
        "豆腐", "青菜", "蘑菇", "鱼肉", "生姜", "葱", 
        "猪肉", "白菜", "虾仁", "黄瓜", "玉米", "青豆",
        "胡萝卜", "茄子", "青椒", "豆芽", "豆腐皮", "木耳",
        "菠菜", "芹菜", "韭菜", "黄花菜", "冬瓜", "南瓜",
        "茄子", "豆角", "山药", "莲藕", "竹笋", "百合",
        "西兰花", "菜花", "生菜", "油麦菜", "苋菜", "芥蓝"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                Color.white
                    .ignoresSafeArea()
                
                
                
                VStack(spacing: 24) {
                    HStack {
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Button(action: { 
                                print("设置按钮被点击")
                                appState.showSettingsSheet = true 
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                                    .frame(width: 40, height: 40)
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            
                            Button(action: { 
                                print("收藏按钮被点击")
                                appState.showFavoritesSheet = true 
                            }) {
                                Image(systemName: "heart.fill")
                                    .font(.title2)
                                    .foregroundColor(.red)
                                    .frame(width: 40, height: 40)
                                    .background(Color.red.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.trailing, 20)
                    }
                    
                    Spacer(minLength: appState.hasStarted ? 0 : 30)
                    
                    HeaderView()
                        
                    IngredientInputView(
                        ingredients: $ingredients,
                        placeholder: placeholders[placeholderIndex],
                        onGenerate: handleGenerate,
                        onRandom: handleRandom,
                        isLoading: appState.isLoading
                    )
                    .environmentObject(appState)
                    .padding(.top, 100)
                        
                    if appState.hasStarted {
                        ChefGridView(
                            appState: appState,
                            onDishClick: handleDishClick,
                            onReset: handleReset
                        )
                        .padding(.top, 100)
                    }
                        
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .sheet(isPresented: $appState.isModalOpen) {
                if let dish = appState.selectedDish {
                    DishDetailView.modern(
                        dish: dish,
                        onClose: {
                            appState.isModalOpen = false
                        },
                        onFavorite: { isFavorite in
                            if isFavorite {
                                appState.addToFavorites(dish)
                            } else {
                                appState.removeFromFavorites(dish)
                            }
                        },
                        isFavorite: appState.isFavorite(dish)
                    )
                }
            }
            
            .sheet(isPresented: $appState.showSettingsSheet) {
                SettingsView(appState: appState)
            }
            
            .sheet(isPresented: $appState.showFavoritesSheet) {
                FavoritesView(appState: appState)
            }
            
            .sheet(isPresented: $appState.showSubscriptionSheet) {
                SubscriptionView(appState: appState)
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
            DispatchQueue.main.async {
                self.placeholderIndex = (self.placeholderIndex + 1) % self.placeholders.count
            }
        }
    }
    
    private func handleGenerate() {
        guard !ingredients.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        guard self.appState.canGenerate() else {
            self.appState.showSubscriptionSheet = true
            return
        }
        
        self.appState.hasStarted = true
        self.appState.useGeneration()
        
        Task {
            await self.apiService.callAllChefs(
                ingredients: self.ingredients,
                apiKey: self.appState.apiKey,
                appState: self.appState
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
        appState.hasStarted = false
        // 停止背景音乐
        appState.audioManager.stopBackgroundMusic()
    }
    
    private func handleRandom() {
        let shuffled = ingredientPool.shuffled()
        let selectedIngredients = Array(shuffled.prefix(3))
        ingredients = selectedIngredients.joined(separator: "，")
    }
    
    private func isValidIngredients(_ text: String) -> Bool {
        return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func setupPreviewData() {
        appState.initializeChefs()
        
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
        
        appState.completionOrder = ["湘菜", "粤菜"]
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
