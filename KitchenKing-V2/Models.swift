//
//  Models.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

import Foundation
import SwiftUI

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
    let emoji: String
    let color: String
    var status: ChefStatus
    var dish: Dish?
    var cookingStep: String?
    var completionOrder: Int?
    
    static func == (lhs: Chef, rhs: Chef) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.cuisine == rhs.cuisine &&
               lhs.emoji == rhs.emoji &&
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
    let emoji: String
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
    
    // 所有支持的菜系
    let cuisines: [Cuisine] = [
        Cuisine(
            name: "湘菜",
            emoji: "🌶️",
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
            emoji: "🥬",
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
            emoji: "🌶️",
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
            emoji: "🍷",
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
            emoji: "🍋",
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
            emoji: "🥔",
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
                emoji: cuisine.emoji,
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
}