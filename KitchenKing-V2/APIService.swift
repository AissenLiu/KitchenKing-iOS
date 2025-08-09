//
//  APIService.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

import Foundation

class APIService: ObservableObject {
    private let deepseekAPIURL = "https://api.deepseek.com/v1/chat/completions"
    
    // 调用 DeepSeek API
    func callDeepSeekAPI(ingredients: String, cuisine: String, apiKey: String, allergies: String? = nil) async throws -> ApiResponse {
        let prompt = generatePrompt(ingredients: ingredients, cuisine: cuisine, allergies: allergies)
        let requestBody: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": 0.8,
            "max_tokens": 2000
        ]
        
        // 打印 DeepSeek 请求信息
        print("🔍 DeepSeek API 请求信息:")
        print("📍 菜系: \(cuisine)")
        print("🥘 食材: \(ingredients)")
        print("💬 提示词: \(prompt)")
        print("📦 请求体: \(requestBody)")
        print("🌐 API URL: \(deepseekAPIURL)")
        print("🔑 API Key: \(apiKey.prefix(10))...")
        
        guard let url = URL(string: deepseekAPIURL) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 100.0
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw APIError.invalidRequestBody
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // 打印响应信息
        print("📡 DeepSeek API 响应信息:")
        print("📊 状态码: \(httpResponse.statusCode)")
        if let responseText = String(data: data, encoding: .utf8) {
            print("📄 响应内容: \(responseText.prefix(500))...") // 只打印前500字符避免过长
        }
        
        if httpResponse.statusCode != 200 {
            if let errorText = String(data: data, encoding: .utf8) {
                print("❌ API Error: \(errorText)")
            }
            throw APIError.apiError(statusCode: httpResponse.statusCode)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw APIError.invalidResponseFormat
        }
        
        // 提取 JSON 内容
        print("📋 开始解析 JSON 内容...")
        let dish = try parseDishFromContent(content)
        print("✅ JSON 解析成功: \(dish.dishName)")
        
        return ApiResponse(success: true, data: dish, error: nil)
    }
    
    // 生成提示词
    private func generatePrompt(ingredients: String, cuisine: String, allergies: String? = nil) -> String {
        var allergyText = ""
        if let allergies = allergies, !allergies.isEmpty {
            allergyText = """
            
            ⚠️ 忌口/过敏信息：\(allergies)
            请特别注意避免使用上述忌口食材，并在制作过程中确保不会引入过敏原。
            """
        }
        
        return """
        你是一名精通\(cuisine)的五星级大厨，根据用户提供的食材创作菜谱。
        
        食材：\(ingredients)\(allergyText)
        
        **重要指示**：
        请根据食材的特性智能判断创作风格：
        - 如果是正常食材（如蔬菜、肉类、调料等），请提供专业的烹饪指导
        - 如果是非食用物品或奇特组合（如电子产品、办公用品等），请用幽默夸张的方式创作，添加娱乐性质的内容
        
        **通用要求**：
        1. **智能判断风格**：根据食材特性决定是专业模式还是幽默模式
        2. **\(cuisine)特色**：充分体现\(cuisine)的烹饪特点
        3. **详细步骤**：提供完整详细的制作流程
        4. **技术要点**：包含调料的多少、火候控制、时间的控制、预处理技巧等专业指导
        5. **除了菜品名称外的所有文字都配上Emoji
        
        **幽默模式额外要求**（当判断为幽默模式时）：
        - 用夸张和网络梗的风格描述
        - 保持专业感但内容荒诞有趣
        - 添加安全警告和冷笑话
        - 必填免责声明提醒这只是娱乐
        
        输出格式（严格JSON）：
        ```json
        {
          "dish_name": "创意菜名",
          "ingredients": {
            "main": ["主要食材"],
            "auxiliary": ["辅助食材"],
            "seasoning": ["调料"]
          },
          "steps": [
            {
              "step": 1,
              "title": "步骤名称",
              "details": ["详细说明1", "详细说明2"]
            }
          ],
          "tips": ["小贴士1", "小贴士2"],
          "flavor_profile": {
            "taste": "口感描述",
            "special_effect": "特殊效果（可选）"
          },
          "disclaimer": "免责声明（幽默模式时必填）"
        }
        ```
        """
    }
    
    // 解析菜品内容
    private func parseDishFromContent(_ content: String) throws -> Dish {
        // 提取 JSON 内容
        let jsonMatch = content.range(of: #"```json\n([\s\S]*?)\n```"#, options: .regularExpression) ??
                       content.range(of: #"\{[\s\S]*\}"#, options: .regularExpression)
        
        guard let matchRange = jsonMatch else {
            print("❌ JSON 解析失败: 无法找到 JSON 内容")
            print("📄 原始内容: \(content.prefix(200))...")
            throw APIError.jsonParseError
        }
        
        let jsonString = String(content[matchRange])
        let cleanJsonString = jsonString.replacingOccurrences(of: "```json\n", with: "")
                                    .replacingOccurrences(of: "\n```", with: "")
        
        print("🔍 提取的 JSON 字符串: \(cleanJsonString)")
        
        guard let jsonData = cleanJsonString.data(using: .utf8) else {
            print("❌ JSON 解析失败: 无法转换为 Data")
            throw APIError.jsonParseError
        }
        
        let decoder = JSONDecoder()
        
        do {
            let dish = try decoder.decode(Dish.self, from: jsonData)
            print("✅ JSON 解析成功: \(dish.dishName)")
            return dish
        } catch {
            print("❌ JSON 解析失败: \(error)")
            print("📄 JSON 字符串: \(cleanJsonString)")
            throw APIError.jsonParseError
        }
    }
    
    // 调用单个厨师
    func callChef(ingredients: String, cuisine: String, apiKey: String, allergies: String? = nil) async -> (cuisine: String, result: ApiResponse) {
        do {
            let result = try await callDeepSeekAPI(ingredients: ingredients, cuisine: cuisine, apiKey: apiKey, allergies: allergies)
            return (cuisine, result)
        } catch {
            return (cuisine, ApiResponse(success: false, data: nil, error: error.localizedDescription))
        }
    }
    
    // 并行调用所有厨师
    func callAllChefs(ingredients: String, apiKey: String, appState: AppState) async {
        appState.isLoading = true
        appState.initializeChefs()
        
        // 设置所有厨师为制作状态
        appState.chefs = appState.chefs.map { chef in
            var updatedChef = chef
            updatedChef.status = .cooking
            return updatedChef
        }
        
        // 开始播放背景音乐
        DispatchQueue.main.async {
            appState.audioManager.playBackgroundMusic()
        }
        
        // 启动卡片显示动画（只设置状态，让 ChefGridView 控制动画）
        DispatchQueue.main.async {
            appState.isAnimatingCards = true
            appState.visibleCardCount = 0
        }
        
        let allergies = appState.hasAllergies ? appState.allergiesContent : nil
        let availableCuisines = appState.getAvailableCuisines()
        let tasks = availableCuisines.map { cuisine in
            Task {
                let result = await callChef(ingredients: ingredients, cuisine: cuisine.name, apiKey: apiKey, allergies: allergies)
                
                await MainActor.run {
                    // 更新完成顺序
                    if result.result.success && result.result.data != nil {
                        if !appState.completionOrder.contains(result.cuisine) {
                            appState.completionOrder.append(result.cuisine)
                        }
                    }
                    
                    // 更新厨师状态
                    appState.chefs = appState.chefs.map { chef in
                        if chef.cuisine == result.cuisine {
                            var updatedChef = chef
                            if result.result.success, let dish = result.result.data {
                                updatedChef.status = .completed
                                updatedChef.dish = dish
                            } else {
                                updatedChef.status = .error
                            }
                            return updatedChef
                        }
                        return chef
                    }
                    
                    // 检查是否所有厨师都完成了任务
                    checkAllChefsCompleted(appState: appState)
                }
                
                return result
            }
        }
        
  await withTaskGroup(of: Void.self) { group in
            for task in tasks {
                group.addTask {
                    _ = await task.value
                }
            }
        }
        appState.isLoading = false
    }
    
    // 检查是否所有厨师都完成了任务
    private func checkAllChefsCompleted(appState: AppState) {
        let allCompleted = appState.chefs.allSatisfy { chef in
            chef.status == .completed || chef.status == .error
        }
        
        // 更新 AppState 中的完成状态
        appState.checkAllChefsFinished()
        
        if allCompleted {
            // 所有厨师都完成了任务，停止背景音乐
            DispatchQueue.main.async {
                appState.audioManager.stopBackgroundMusic()
            }
        }
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidRequestBody
    case invalidResponse
    case apiError(statusCode: Int)
    case invalidResponseFormat
    case jsonParseError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .invalidRequestBody:
            return "无效的请求体"
        case .invalidResponse:
            return "无效的响应"
        case .apiError(let statusCode):
            return "API错误，状态码：\(statusCode)"
        case .invalidResponseFormat:
            return "无效的响应格式"
        case .jsonParseError:
            return "JSON解析错误"
        }
    }
}
