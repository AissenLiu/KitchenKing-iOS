//
//  Models.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

import Foundation
import SwiftUI

// MARK: - 订阅相关模型

enum SubscriptionType: String, CaseIterable, Codable {
    case monthly = "月度"
    case quarterly = "季度"
    case yearly = "年度"
    
    var price: Double {
        switch self {
        case .monthly: return 6.9
        case .quarterly: return 19.9
        case .yearly: return 69.0
        }
    }
    
    var firstMonthPrice: Double? {
        switch self {
        case .monthly: return 1.9
        case .quarterly: return nil
        case .yearly: return nil
        }
    }
    
    var description: String {
        switch self {
        case .monthly:
            return "月度订阅 - 首月\(String(format: "%.2f", firstMonthPrice ?? 0))元，续费\(String(format: "%.2f", price))元"
        case .quarterly:
            return "季度订阅 - \(String(format: "%.2f", price))元/季度"
        case .yearly:
            return "年度订阅 - \(String(format: "%.2f", price))元/年"
        }
    }
    
    var savings: String {
        switch self {
        case .monthly:
            return "灵活订阅"
        case .quarterly:
            return "节省5%"
        case .yearly:
            return "节省17%"
        }
    }
}

struct ChefRole: Identifiable, Codable {
    let id = UUID()
    let name: String
    let title: String
    let specialty: String
    let personality: String
    let cookingStyle: String
    let imageName: String
    let isPremium: Bool
    let isCustom: Bool
    
    static let defaultChef = ChefRole(
        name: "默认厨师",
        title: "全能厨师",
        specialty: "各国料理",
        personality: "专业耐心",
        cookingStyle: "融合创新",
        imageName: "头像",
        isPremium: false,
        isCustom: false
    )
    
    static let freeRoles: [ChefRole] = [
        ChefRole(
            name: "默认厨师",
            title: "全能厨师",
            specialty: "各国料理",
            personality: "专业耐心",
            cookingStyle: "融合创新",
            imageName: "头像",
            isPremium: false,
            isCustom: false
        ),
        ChefRole(
            name: "湘菜师傅",
            title: "湘菜专家",
            specialty: "湘菜川菜",
            personality: "热情豪爽",
            cookingStyle: "香辣浓郁",
            imageName: "湘菜",
            isPremium: false,
            isCustom: false
        ),
        ChefRole(
            name: "粤菜大厨",
            title: "粤菜师傅",
            specialty: "粤菜海鲜",
            personality: "细致严谨",
            cookingStyle: "清淡鲜美",
            imageName: "粤菜",
            isPremium: false,
            isCustom: false
        ),
        ChefRole(
            name: "川菜大师",
            title: "川菜专家",
            specialty: "川菜火锅",
            personality: "麻辣爽快",
            cookingStyle: "麻辣鲜香",
            imageName: "川菜",
            isPremium: false,
            isCustom: false
        ),
        ChefRole(
            name: "法餐厨师",
            title: "法餐师傅",
            specialty: "法式料理",
            personality: "优雅浪漫",
            cookingStyle: "精致考究",
            imageName: "法国菜",
            isPremium: false,
            isCustom: false
        ),
        ChefRole(
            name: "泰餐师傅",
            title: "泰餐专家",
            specialty: "泰式料理",
            personality: "温和友善",
            cookingStyle: "酸甜香辣",
            imageName: "泰国菜",
            isPremium: false,
            isCustom: false
        )
    ]
    
    static let premiumRoles: [ChefRole] = [
        ChefRole(
            name: "米其林大厨",
            title: "米其林三星主厨",
            specialty: "高端法餐",
            personality: "追求完美",
            cookingStyle: "精致优雅",
            imageName: "法国菜",
            isPremium: true,
            isCustom: false
        ),
        ChefRole(
            name: "家常菜专家",
            title: "家常菜大师",
            specialty: "家常小炒",
            personality: "亲切温暖",
            cookingStyle: "传统地道",
            imageName: "川菜",
            isPremium: true,
            isCustom: false
        ),
        ChefRole(
            name: "营养师",
            title: "高级营养师",
            specialty: "健康饮食",
            personality: "科学严谨",
            cookingStyle: "营养均衡",
            imageName: "粤菜",
            isPremium: true,
            isCustom: false
        ),
        ChefRole(
            name: "创意料理师",
            title: "创意料理达人",
            specialty: "融合创新",
            personality: "天马行空",
            cookingStyle: "新潮独特",
            imageName: "泰国菜",
            isPremium: true,
            isCustom: false
        )
    ]
}

// MARK: - 数据模型

struct Ingredient: Identifiable, Codable {
    let id = UUID()
    let name: String
    let category: Category
    
    enum Category: String, Codable {
        case main = "主要食材"
        case auxiliary = "辅助食材"
        case seasoning = "调料"
    }
}

struct CookingStep: Identifiable, Codable {
    let id = UUID()
    let step: Int
    let title: String
    let details: [String]
}

struct FlavorProfile: Codable {
    let taste: String
    let specialEffect: String?
}

struct Dish: Identifiable, Codable {
    let id = UUID()
    let dishName: String
    let ingredients: Ingredients
    let steps: [CookingStep]
    let tips: [String]
    let flavorProfile: FlavorProfile
    let disclaimer: String?
    
    struct Ingredients: Codable {
        let main: [String]
        let auxiliary: [String]
        let seasoning: [String]
    }
    
    enum CodingKeys: String, CodingKey {
        case dishName = "dish_name"
        case ingredients, steps, tips, flavorProfile = "flavor_profile", disclaimer
    }
}

struct Chef: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let cuisine: String
    let imageName: String
    let color: String
    var status: ChefStatus
    var dish: Dish?
    var cookingStep: String?
    var completionOrder: Int?
    
    static func == (lhs: Chef, rhs: Chef) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.cuisine == rhs.cuisine &&
               lhs.imageName == rhs.imageName &&
               lhs.color == rhs.color &&
               lhs.status == rhs.status
    }
    
    enum ChefStatus: String, CaseIterable {
        case idle = "待命"
        case cooking = "制作中"
        case completed = "完成"
        case error = "错误"
        
        var color: Color {
            switch self {
            case .idle: return .gray
            case .cooking: return .yellow
            case .completed: return .green
            case .error: return .red
            }
        }
    }
}

struct Cuisine: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let color: String
    let chefName: String
    let completedMessages: [String]
}

// MARK: - API 相关

struct ApiResponse: Codable {
    let success: Bool
    let data: Dish?
    let error: String?
}

// MARK: - 应用状态

class AppState: ObservableObject {
    @Published var chefs: [Chef] = []
    @Published var completionOrder: [String] = []
    @Published var isLoading = false
    @Published var selectedDish: Dish?
    @Published var isModalOpen = false
    @Published var apiKey = "sk-26801bf0212a4cbeb0dc4ecc14e5e7b5"
    @Published var hasStarted = false
    
    // 卡片动画相关
    @Published var isAnimatingCards = false
    @Published var visibleCardCount = 0
    
    // 音频管理器
    let audioManager = AudioManager.shared
    
    // 订阅相关
    @Published var isSubscribed = false
    @Published var subscriptionType: SubscriptionType?
    @Published var remainingGenerations = 3 // 免费用户剩余生成次数
    @Published var showSubscriptionSheet = false
    @Published var showSettingsSheet = false
    
    // 收藏相关
    @Published var favoriteDishes: [Dish] = []
    @Published var showFavoritesSheet = false
    
    // 用户偏好
    @Published var selectedChefRole: ChefRole = .defaultChef
    @Published var customChefRoles: [ChefRole] = []
    
    // 所有支持的菜系
    let cuisines: [Cuisine] = [
        Cuisine(
            name: "湘菜",
            imageName: "湘菜",
            color: "text-red-600",
            chefName: "辣椒王老张",
            completedMessages: [
                "小心烫手，赶紧尝尝！",
                "辣椒够劲，正宗湘味！",
                "火辣出锅，趁热享用！",
                "这个辣度刚刚好！",
                "湘菜精髓，一尝便知！",
                "麻辣鲜香，回味无穷！",
                "老张出品，必属精品！",
                "够辣够味，就是巴适！",
                "湖南风味，地道正宗！",
                "辣到心坎里，爽！"
            ]
        ),
        Cuisine(
            name: "粤菜",
            imageName: "粤菜",
            color: "text-green-600",
            chefName: "阿华师傅",
            completedMessages: [
                "请您品鉴，越吃越香！",
                "广式做法，原汁原味！",
                "清淡鲜美，营养丰富！",
                "火候刚好，嫩滑爽口！",
                "粤菜精髓，尽在其中！",
                "色香味俱全，请慢用！",
                "师傅手艺，值得信赖！",
                "岭南风味，独具特色！",
                "清香淡雅，回味甘甜！",
                "粤式经典，传统工艺！"
            ]
        ),
        Cuisine(
            name: "川菜",
            imageName: "川菜",
            color: "text-orange-600",
            chefName: "麻辣刘大厨",
            completedMessages: [
                "辣得巴适，赶紧吃起！",
                "川味十足，麻辣过瘾！",
                "正宗川菜，香辣开胃！",
                "麻婆豆腐般的感觉！",
                "四川火锅的味道！",
                "巴蜀风味，地道正宗！",
                "麻辣鲜香，层次丰富！",
                "刘师傅出品，必须安逸！",
                "川菜之魂，尽在此菜！",
                "辣椒花椒，双重享受！"
            ]
        ),
        Cuisine(
            name: "法国菜",
            imageName: "法国菜",
            color: "text-blue-600",
            chefName: "Pierre大师",
            completedMessages: [
                "Bon appétit，慢慢品尝！",
                "C'est magnifique，太棒了！",
                "法式浪漫，尽在盘中！",
                "Très délicieux，非常美味！",
                "米其林级别的享受！",
                "Voilà，完美呈现！",
                "法国大厨的骄傲！",
                "Exquis，精致绝伦！",
                "巴黎风味，浪漫满溢！",
                "Chef Pierre签名菜！"
            ]
        ),
        Cuisine(
            name: "泰国菜",
            imageName: "泰国菜",
            color: "text-purple-600",
            chefName: "Somchai师傅",
            completedMessages: [
                "酸辣开胃，请享用！",
                "Sawasdee，泰式风味！",
                "椰浆香浓，回味无穷！",
                "冬阴功般的酸爽！",
                "泰式经典，正宗口味！",
                "香茅柠檬，清香怡人！",
                "曼谷街头的味道！",
                "酸甜辣咸，层次分明！",
                "Very good，非常棒！",
                "泰国师傅亲手制作！"
            ]
        ),
        Cuisine(
            name: "俄罗斯菜",
            imageName: "俄罗斯菜",
            color: "text-indigo-600",
            chefName: "Ivan大叔",
            completedMessages: [
                "热乎乎出锅，快吃吧！",
                "Очень вкусно，太好吃了！",
                "俄式大餐，分量十足！",
                "西伯利亚的温暖！",
                "伏特加配菜，绝配！",
                "莫斯科风味，正宗地道！",
                "战斗民族的手艺！",
                "红菜汤般的浓郁！",
                "大叔秘制，独家配方！",
                "俄罗斯传统，世代传承！"
            ]
        )
    ]
    
    // 炒菜步骤
    let cookingSteps: [String] = [
        "正在热锅...",
        "加点盐...",
        "加点水...",
        "搅拌中...",
        "翻炒中...",
        "加点蒜...",
        "撒点辣椒...",
        "淋点酱油...",
        "切配菜...",
        "挤点柠檬...",
        "撒点香菜...",
        "大火爆炒..."
    ]
    
    // 错误消息
    let errorMessages: [String] = [
        "太难了，做不出来！",
        "臣妾做不到呀！",
        "翻车了，下次再来！",
        "这道菜太护心了！",
        "技术不过关，告辞！",
        "实在搭不出来！",
        "我的天，太复杂了！",
        "打败，重新来过！",
        "这个难度超纲了！",
        "做砸了，换个试试！"
    ]
    
    // 初始化厨师
    func initializeChefs() {
        chefs = cuisines.map { cuisine in
            Chef(
                name: cuisine.chefName,
                cuisine: cuisine.name,
                imageName: cuisine.imageName,
                color: cuisine.color,
                status: .idle
            )
        }
    }
    
    // 重置状态
    func reset() {
        chefs = []
        completionOrder = []
        isLoading = false
        selectedDish = nil
        isModalOpen = false
        hasStarted = false
        isAnimatingCards = false
        visibleCardCount = 0
        // 停止背景音乐
        audioManager.stopBackgroundMusic()
    }
    
    // 获取随机错误消息
    func getRandomErrorMessage() -> String {
        return errorMessages.randomElement() ?? "制作失败！"
    }
    
    // 获取厨师完成消息
    func getChefCompletedMessage(cuisine: String) -> String {
        guard let cuisineConfig = cuisines.first(where: { $0.name == cuisine }) else {
            return "菜品完成！"
        }
        return cuisineConfig.completedMessages.randomElement() ?? "菜品完成！"
    }
    
    // 获取随机炒菜步骤
    func getRandomCookingStep() -> String {
        return cookingSteps.randomElement() ?? "正在制作..."
    }
    
    // MARK: - 订阅相关方法
    
    func subscribe(_ type: SubscriptionType) {
        isSubscribed = true
        subscriptionType = type
        remainingGenerations = -1 // 无限生成
    }
    
    func unsubscribe() {
        isSubscribed = false
        subscriptionType = nil
        remainingGenerations = 3 // 重置为免费用户额度
    }
    
    func canGenerate() -> Bool {
        return isSubscribed || remainingGenerations > 0
    }
    
    func useGeneration() {
        if !isSubscribed && remainingGenerations > 0 {
            remainingGenerations -= 1
        }
    }
    
    // MARK: - 收藏相关方法
    
    private let favoritesKey = "FavoriteDishes"
    
    init() {
        loadFavorites()
    }
    
    func addToFavorites(_ dish: Dish) {
        if !favoriteDishes.contains(where: { $0.dishName == dish.dishName }) {
            favoriteDishes.append(dish)
            saveFavorites()
        }
    }
    
    func removeFromFavorites(_ dish: Dish) {
        favoriteDishes.removeAll(where: { $0.dishName == dish.dishName })
        saveFavorites()
    }
    
    func isFavorite(_ dish: Dish) -> Bool {
        return favoriteDishes.contains(where: { $0.dishName == dish.dishName })
    }
    
    private func saveFavorites() {
        do {
            let data = try JSONEncoder().encode(favoriteDishes)
            UserDefaults.standard.set(data, forKey: favoritesKey)
        } catch {
            print("❌ 保存收藏数据失败: \(error)")
        }
    }
    
    private func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey) else {
            favoriteDishes = []
            return
        }
        
        do {
            favoriteDishes = try JSONDecoder().decode([Dish].self, from: data)
        } catch {
            print("❌ 加载收藏数据失败: \(error)")
            favoriteDishes = []
        }
    }
    
    // MARK: - 厨师角色相关方法
    
    func getAvailableChefRoles() -> [ChefRole] {
        var roles: [ChefRole] = ChefRole.freeRoles
        if isSubscribed {
            roles.append(contentsOf: ChefRole.premiumRoles)
            roles.append(contentsOf: customChefRoles)
        }
        return roles
    }
    
    func addCustomChefRole(_ role: ChefRole) {
        customChefRoles.append(role)
    }
    
    func removeCustomChefRole(_ role: ChefRole) {
        customChefRoles.removeAll(where: { $0.id == role.id })
    }
    
    func canRemoveRole(_ role: ChefRole) -> Bool {
        return role.isCustom || role.isPremium
    }
    
    func removeRole(_ role: ChefRole) {
        if role.isCustom {
            customChefRoles.removeAll(where: { $0.id == role.id })
        }
    }
}