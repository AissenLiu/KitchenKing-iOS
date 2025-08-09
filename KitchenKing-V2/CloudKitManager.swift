//
//  CloudKitManager.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/8.
//

import Foundation
import CloudKit
import SwiftUI

// MARK: - CloudKit 管理器
class CloudKitManager: ObservableObject {
    // 单例模式
    static let shared = CloudKitManager()
    
    // CloudKit 容器
    private let container: CKContainer
    private let database: CKDatabase
    
    // 同步状态
    @Published var isSyncing = false
    @Published var syncError: String?
    @Published var lastSyncDate: Date?
    
    // 账户状态缓存
    private var lastAccountStatusCheck: Date?
    private var cachedAccountStatus: Bool = false
    private let accountStatusCacheInterval: TimeInterval = 60 // 1分钟缓存
    
    // 私有初始化
    private init() {
        container = CKContainer(identifier: "iCloud.com.kitchenking")
        database = container.privateCloudDatabase
    }
    
    // MARK: - 账户状态检查
    func checkiCloudStatus() async -> Bool {
        // 检查缓存
        let now = Date()
        if let lastCheck = lastAccountStatusCheck,
           now.timeIntervalSince(lastCheck) < accountStatusCacheInterval {
            print("🔄 使用缓存的 iCloud 账户状态: \(cachedAccountStatus ? "可用" : "不可用")")
            return cachedAccountStatus
        }
        
        do {
            let status = try await container.accountStatus()
            let isAvailable = status == .available
            
            // 更新缓存
            lastAccountStatusCheck = now
            cachedAccountStatus = isAvailable
            
            DispatchQueue.main.async {
                switch status {
                case .available:
                    print("✅ iCloud 账户可用")
                    // 清除之前的错误
                    if self.syncError?.contains("iCloud") == true {
                        self.syncError = nil
                    }
                case .noAccount:
                    self.syncError = "请在设置中登录 iCloud 账户"
                    print("❌ 未登录 iCloud 账户")
                case .restricted:
                    self.syncError = "iCloud 账户受限制"
                    print("❌ iCloud 账户受限制")
                case .couldNotDetermine:
                    self.syncError = "无法确定 iCloud 账户状态"
                    print("❌ 无法确定 iCloud 账户状态")
                case .temporarilyUnavailable:
                    self.syncError = "iCloud 暂时不可用"
                    print("⚠️ iCloud 暂时不可用")
                @unknown default:
                    self.syncError = "未知的 iCloud 账户状态"
                    print("❓ 未知的 iCloud 账户状态")
                }
            }
            return isAvailable
        } catch {
            // 缓存失败状态更短时间
            lastAccountStatusCheck = now
            cachedAccountStatus = false
            
            DispatchQueue.main.async {
                self.syncError = "检查 iCloud 状态失败: \(error.localizedDescription)"
            }
            print("❌ 检查 iCloud 状态失败: \(error)")
            return false
        }
    }
    
    // 强制刷新账户状态
    func refreshiCloudStatus() async -> Bool {
        lastAccountStatusCheck = nil // 清除缓存
        return await checkiCloudStatus()
    }
    
    // MARK: - 收藏菜品同步
    
    // 保存菜品到 iCloud
    func saveFavoriteDish(_ dish: Dish) async -> Bool {
        guard await checkiCloudStatus() else { return false }
        
        DispatchQueue.main.async {
            self.isSyncing = true
            self.syncError = nil
        }
        
        // 使用菜品 ID 作为 recordName 来创建 CloudKit 记录
        let recordID = CKRecord.ID(recordName: dish.id.uuidString)
        let record = CKRecord(recordType: "FavoriteDish", recordID: recordID)
        record["dishName"] = dish.dishName
        
        print("💾 准备保存菜品到 iCloud:")
        print("  📝 菜品名: \(dish.dishName)")
        print("  🆔 记录ID: \(recordID.recordName)")
        print("  🏷️ 记录类型: FavoriteDish")
        
        // 序列化菜品数据
        do {
            let dishData = try JSONEncoder().encode(dish)
            record["dishData"] = dishData
            record["createdAt"] = Date()
            record["modifiedAt"] = Date()
            
            print("  💾 菜品数据大小: \(dishData.count) bytes")
            print("  📅 创建时间: \(record["createdAt"] as? Date ?? Date())")
            
        } catch {
            DispatchQueue.main.async {
                self.isSyncing = false
                self.syncError = "序列化菜品数据失败: \(error.localizedDescription)"
            }
            print("❌ 序列化菜品数据失败: \(error)")
            return false
        }
        
        // 保存到 CloudKit（使用 save policy 处理重复记录）
        do {
            let savePolicy = CKModifyRecordsOperation.RecordSavePolicy.changedKeys
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            operation.savePolicy = savePolicy
            operation.qualityOfService = .userInitiated
            
            let savedRecord = try await database.save(record)
            DispatchQueue.main.async {
                self.isSyncing = false
                self.lastSyncDate = Date()
            }
            
            print("✅ 菜品已保存到 iCloud: \(dish.dishName)")
            print("  📄 保存后的记录ID: \(savedRecord.recordID.recordName)")
            print("  🔄 修改时间: \(savedRecord.modificationDate ?? Date())")
            
            return true
        } catch let error as CKError where error.code == .serverRecordChanged {
            // 处理服务器记录已更改的情况
            print("⚠️ 服务器记录已更改，尝试更新: \(dish.dishName)")
            DispatchQueue.main.async {
                self.isSyncing = false
                self.lastSyncDate = Date()
            }
            return true
        } catch {
            DispatchQueue.main.async {
                self.isSyncing = false
                self.syncError = "保存到 iCloud 失败: \(error.localizedDescription)"
            }
            print("❌ 保存到 iCloud 失败: \(error)")
            
            if let ckError = error as? CKError {
                print("❌ CloudKit 错误代码: \(ckError.code.rawValue)")
                print("❌ CloudKit 错误详情: \(ckError.userInfo)")
            }
            
            return false
        }
    }
    
    // 从 iCloud 删除菜品
    func deleteFavoriteDish(_ dish: Dish) async -> Bool {
        guard await checkiCloudStatus() else { return false }
        
        DispatchQueue.main.async {
            self.isSyncing = true
            self.syncError = nil
        }
        
        let recordID = CKRecord.ID(recordName: dish.id.uuidString)
        print("🔍 准备删除记录: \(recordID.recordName), 菜品: \(dish.dishName)")
        
        do {
            try await database.deleteRecord(withID: recordID)
            DispatchQueue.main.async {
                self.isSyncing = false
                self.lastSyncDate = Date()
            }
            print("✅ 已从 iCloud 删除菜品: \(dish.dishName)")
            return true
        } catch let error as CKError {
            DispatchQueue.main.async {
                self.isSyncing = false
                if error.code == .unknownItem {
                    print("ℹ️ 记录不存在，删除操作完成: \(dish.dishName)")
                    self.lastSyncDate = Date()
                } else {
                    self.syncError = "从 iCloud 删除失败: \(error.localizedDescription)"
                    print("❌ 从 iCloud 删除失败: \(error)")
                    print("❌ 错误代码: \(error.code.rawValue)")
                    print("❌ 错误详情: \(error.userInfo)")
                }
            }
            // 记录不存在时返回 true，因为删除目标已经达成
            return error.code == .unknownItem
        } catch {
            DispatchQueue.main.async {
                self.isSyncing = false
                self.syncError = "从 iCloud 删除失败: \(error.localizedDescription)"
            }
            print("❌ 从 iCloud 删除失败: \(error)")
            return false
        }
    }
    
    // 批量删除收藏菜品
    func deleteFavoriteDishes(_ dishes: [Dish]) async -> Bool {
        guard await checkiCloudStatus() else { return false }
        
        DispatchQueue.main.async {
            self.isSyncing = true
            self.syncError = nil
        }
        
        let recordIDs = dishes.map { CKRecord.ID(recordName: $0.id.uuidString) }
        
        do {
            let results = try await database.modifyRecords(saving: [], deleting: recordIDs)
            
            var successCount = 0
            var failureCount = 0
            
            for (recordID, result) in results.deleteResults {
                switch result {
                case .success:
                    successCount += 1
                    print("✅ 删除成功: \(recordID.recordName)")
                case .failure(let error):
                    if let ckError = error as? CKError, ckError.code == .unknownItem {
                        successCount += 1 // 记录不存在也算成功
                        print("ℹ️ 记录不存在: \(recordID.recordName)")
                    } else {
                        failureCount += 1
                        print("❌ 删除失败: \(recordID.recordName), 错误: \(error)")
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.isSyncing = false
                self.lastSyncDate = Date()
                print("🔄 批量删除完成: 成功 \(successCount), 失败 \(failureCount)")
            }
            
            return failureCount == 0
        } catch {
            DispatchQueue.main.async {
                self.isSyncing = false
                self.syncError = "批量删除失败: \(error.localizedDescription)"
            }
            print("❌ 批量删除失败: \(error)")
            return false
        }
    }
    
    // 从 iCloud 获取所有收藏菜品
    func fetchFavoriteDishes() async -> [Dish] {
        guard await checkiCloudStatus() else { return [] }
        
        DispatchQueue.main.async {
            self.isSyncing = true
            self.syncError = nil
        }
        
        print("🔄 开始从 iCloud 获取收藏菜品...")
        let query = CKQuery(recordType: "FavoriteDish", predicate: NSPredicate(value: true))
        
        do {
            let result = try await database.records(matching: query)
            var dishes: [Dish] = []
            
            print("📋 CloudKit 查询结果: 找到 \(result.matchResults.count) 条记录")
            
            for (recordID, recordResult) in result.matchResults {
                switch recordResult {
                case .success(let record):
                    print("📄 处理记录: \(recordID.recordName)")
                    
                    // 打印记录的基本信息
                    if let dishName = record["dishName"] as? String {
                        print("  📝 菜品名: \(dishName)")
                    }
                    if let createdAt = record["createdAt"] as? Date {
                        print("  📅 创建时间: \(createdAt)")
                    }
                    if let modifiedAt = record["modifiedAt"] as? Date {
                        print("  🔄 修改时间: \(modifiedAt)")
                    }
                    
                    // 处理菜品数据
                    if let dishData = record["dishData"] as? Data {
                        print("  💾 菜品数据大小: \(dishData.count) bytes")
                        do {
                            let originalDish = try JSONDecoder().decode(Dish.self, from: dishData)
                            
                            // 🔧 修复ID不匹配问题：创建新的菜品对象，使用CloudKit记录ID
                            let correctedDish = Dish(
                                id: UUID(uuidString: recordID.recordName) ?? originalDish.id,
                                dishName: originalDish.dishName,
                                ingredients: originalDish.ingredients,
                                steps: originalDish.steps,
                                tips: originalDish.tips,
                                flavorProfile: originalDish.flavorProfile,
                                disclaimer: originalDish.disclaimer
                            )
                            
                            dishes.append(correctedDish)
                            print("  🔧 修正菜品ID: \(correctedDish.id) (使用CloudKit记录ID)")
                            print("  ✅ 成功解析菜品: \(correctedDish.dishName)")
                            print("  🆔 最终菜品ID: \(correctedDish.id)")
                        } catch {
                            print("  ❌ 反序列化菜品数据失败: \(error)")
                            print("  🔍 原始数据: \(String(data: dishData, encoding: .utf8) ?? "无法解析")")
                        }
                    } else {
                        print("  ⚠️ 记录中没有 dishData 字段")
                        // 打印记录中的所有字段
                        print("  🔧 记录中的所有字段:")
                        for (key, value) in record {
                            print("    - \(key): \(value)")
                        }
                    }
                    
                case .failure(let error):
                    print("  ❌ 获取记录时出错: \(recordID.recordName) - \(error)")
                }
            }
            
            DispatchQueue.main.async {
                self.isSyncing = false
                self.lastSyncDate = Date()
            }
            
            print("✅ 从 iCloud 获取完成: 总记录数 \(result.matchResults.count), 成功解析 \(dishes.count) 道菜品")
            
            // 打印成功获取的菜品列表
            if !dishes.isEmpty {
                print("📋 成功获取的菜品列表:")
                for (index, dish) in dishes.enumerated() {
                    print("  \(index + 1). \(dish.dishName) (ID: \(dish.id))")
                }
            } else {
                print("📭 没有成功解析任何菜品")
            }
            
            return dishes
        } catch {
            DispatchQueue.main.async {
                self.isSyncing = false
                self.syncError = "从 iCloud 获取数据失败: \(error.localizedDescription)"
            }
            print("❌ 从 iCloud 获取数据失败: \(error)")
            if let ckError = error as? CKError {
                print("❌ CloudKit 错误代码: \(ckError.code.rawValue)")
                print("❌ CloudKit 错误详情: \(ckError.userInfo)")
            }
            return []
        }
    }
    
    // 检查记录是否存在
    private func recordExists(dishId: String) async -> Bool {
        let recordID = CKRecord.ID(recordName: dishId)
        do {
            _ = try await database.record(for: recordID)
            return true
        } catch {
            return false
        }
    }
    
    // 批量同步本地收藏到 iCloud
    func syncLocalFavoritesToCloud(_ dishes: [Dish]) async {
        guard await checkiCloudStatus() else { return }
        
        DispatchQueue.main.async {
            self.isSyncing = true
            self.syncError = nil
        }
        
        print("🔄 开始批量同步 \(dishes.count) 道本地收藏菜品到 iCloud")
        
        // 准备批量保存的记录
        var recordsToSave: [CKRecord] = []
        
        for dish in dishes {
            let recordID = CKRecord.ID(recordName: dish.id.uuidString)
            let record = CKRecord(recordType: "FavoriteDish", recordID: recordID)
            record["dishName"] = dish.dishName
            
            do {
                let dishData = try JSONEncoder().encode(dish)
                record["dishData"] = dishData
                record["createdAt"] = Date()
                record["modifiedAt"] = Date()
                recordsToSave.append(record)
            } catch {
                print("❌ 序列化菜品数据失败: \(dish.dishName) - \(error)")
            }
        }
        
        // 批量保存到 CloudKit
        do {
            let results = try await database.modifyRecords(saving: recordsToSave, deleting: [])
            
            var successCount = 0
            var failureCount = 0
            
            for (recordID, result) in results.saveResults {
                switch result {
                case .success:
                    successCount += 1
                    print("✅ 同步成功: \(recordID.recordName)")
                case .failure(let error):
                    if let ckError = error as? CKError, ckError.code == .serverRecordChanged {
                        successCount += 1 // 服务器记录已更改也算成功
                        print("ℹ️ 服务器记录已存在: \(recordID.recordName)")
                    } else {
                        failureCount += 1
                        print("❌ 同步失败: \(recordID.recordName) - \(error)")
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.isSyncing = false
                self.lastSyncDate = Date()
            }
            
            print("🔄 批量同步完成: 成功 \(successCount), 失败 \(failureCount)")
            
        } catch {
            DispatchQueue.main.async {
                self.isSyncing = false
                self.syncError = "批量同步失败: \(error.localizedDescription)"
            }
            print("❌ 批量同步失败: \(error)")
        }
    }
    
    // 清除同步错误
    func clearSyncError() {
        syncError = nil
    }
    
    // 调试：检查 CloudKit 配置和连接
    func debugCloudKitConfiguration() async {
        print("🔧 CloudKit 配置调试信息:")
        print("📦 容器标识符: \(container.containerIdentifier)")
        print("🗄️ 数据库类型: 私有数据库")
        
        // 检查账户状态
        let isAvailable = await checkiCloudStatus()
        print("👤 iCloud 账户状态: \(isAvailable ? "可用" : "不可用")")
        
        // 检查容器配置
        do {
            let _ = try await container.accountStatus()
            print("✅ 容器连接正常")
        } catch {
            print("❌ 容器连接失败: \(error)")
        }
        
        // 尝试查询一条记录来测试数据库连接
        let testQuery = CKQuery(recordType: "FavoriteDish", predicate: NSPredicate(value: true))
        do {
            let result = try await database.records(matching: testQuery, resultsLimit: 1)
            print("✅ 数据库连接正常，找到 \(result.matchResults.count) 条记录")
        } catch {
            print("❌ 数据库查询失败: \(error)")
        }
    }
    
    // 调试：列出所有 CloudKit 记录
    func debugListAllRecords() async {
        guard await checkiCloudStatus() else { return }
        
        let query = CKQuery(recordType: "FavoriteDish", predicate: NSPredicate(value: true))
        
        do {
            let result = try await database.records(matching: query)
            print("📋 CloudKit 中的所有记录:")
            
            for (recordID, recordResult) in result.matchResults {
                switch recordResult {
                case .success(let record):
                    if let dishName = record["dishName"] as? String {
                        print("  📄 \(recordID.recordName): \(dishName)")
                    } else {
                        print("  📄 \(recordID.recordName): (无菜品名)")
                    }
                case .failure(let error):
                    print("  ❌ \(recordID.recordName): \(error)")
                }
            }
            
            if result.matchResults.isEmpty {
                print("  📭 CloudKit 中没有记录")
            }
        } catch {
            print("❌ 获取记录列表失败: \(error)")
        }
    }
}

// MARK: - CloudKit 错误扩展
extension CKError {
    var localizedDescription: String {
        switch self.code {
        case .networkUnavailable:
            return "网络连接不可用"
        case .networkFailure:
            return "网络连接失败"
        case .accountTemporarilyUnavailable:
            return "iCloud 账户暂时不可用"
        case .quotaExceeded:
            return "iCloud 存储空间不足"
        case .operationCancelled:
            return "操作已取消"
        case .invalidArguments:
            return "CloudKit 配置错误，请检查容器设置"
        case .badContainer:
            return "CloudKit 容器配置错误"
        case .unknownItem:
            return "记录不存在"
        default:
            return "CloudKit 未知错误: \(self.code.rawValue)"
        }
    }
}
