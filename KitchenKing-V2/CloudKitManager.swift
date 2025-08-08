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
    
    // 私有初始化
    private init() {
        container = CKContainer(identifier: "iCloud.com.kitchenking.favorites")
        database = container.privateCloudDatabase
    }
    
    // MARK: - 账户状态检查
    func checkiCloudStatus() async -> Bool {
        do {
            let status = try await container.accountStatus()
            DispatchQueue.main.async {
                switch status {
                case .available:
                    print("✅ iCloud 账户可用")
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
            return status == .available
        } catch {
            DispatchQueue.main.async {
                self.syncError = "检查 iCloud 状态失败: \(error.localizedDescription)"
            }
            print("❌ 检查 iCloud 状态失败: \(error)")
            return false
        }
    }
    
    // MARK: - 收藏菜品同步
    
    // 保存菜品到 iCloud
    func saveFavoriteDish(_ dish: Dish) async -> Bool {
        guard await checkiCloudStatus() else { return false }
        
        DispatchQueue.main.async {
            self.isSyncing = true
            self.syncError = nil
        }
        
        // 创建 CloudKit 记录
        let record = CKRecord(recordType: "FavoriteDish")
        record["dishName"] = dish.dishName
        record["dishId"] = dish.id.uuidString
        
        // 序列化菜品数据
        do {
            let dishData = try JSONEncoder().encode(dish)
            record["dishData"] = dishData
            record["createdAt"] = Date()
            record["modifiedAt"] = Date()
        } catch {
            DispatchQueue.main.async {
                self.isSyncing = false
                self.syncError = "序列化菜品数据失败: \(error.localizedDescription)"
            }
            return false
        }
        
        // 保存到 CloudKit
        do {
            _ = try await database.save(record)
            DispatchQueue.main.async {
                self.isSyncing = false
                self.lastSyncDate = Date()
                print("✅ 菜品已保存到 iCloud: \(dish.dishName)")
            }
            return true
        } catch {
            DispatchQueue.main.async {
                self.isSyncing = false
                self.syncError = "保存到 iCloud 失败: \(error.localizedDescription)"
            }
            print("❌ 保存到 iCloud 失败: \(error)")
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
        
        // 查找要删除的记录
        let query = CKQuery(recordType: "FavoriteDish", predicate: NSPredicate(format: "dishId == %@", dish.id.uuidString))
        
        do {
            let result = try await database.records(matching: query)
            
            for (recordID, recordResult) in result.matchResults {
                switch recordResult {
                case .success(_):
                    // 删除记录
                    try await database.deleteRecord(withID: recordID)
                    print("✅ 已从 iCloud 删除菜品: \(dish.dishName)")
                case .failure(let error):
                    print("❌ 删除菜品时出错: \(error)")
                }
            }
            
            DispatchQueue.main.async {
                self.isSyncing = false
                self.lastSyncDate = Date()
            }
            return true
        } catch {
            DispatchQueue.main.async {
                self.isSyncing = false
                self.syncError = "从 iCloud 删除失败: \(error.localizedDescription)"
            }
            print("❌ 从 iCloud 删除失败: \(error)")
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
        
        let query = CKQuery(recordType: "FavoriteDish", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let result = try await database.records(matching: query)
            var dishes: [Dish] = []
            
            for (_, recordResult) in result.matchResults {
                switch recordResult {
                case .success(let record):
                    if let dishData = record["dishData"] as? Data {
                        do {
                            let dish = try JSONDecoder().decode(Dish.self, from: dishData)
                            dishes.append(dish)
                        } catch {
                            print("❌ 反序列化菜品数据失败: \(error)")
                        }
                    }
                case .failure(let error):
                    print("❌ 获取记录时出错: \(error)")
                }
            }
            
            DispatchQueue.main.async {
                self.isSyncing = false
                self.lastSyncDate = Date()
                print("✅ 从 iCloud 获取到 \(dishes.count) 道收藏菜品")
            }
            
            return dishes
        } catch {
            DispatchQueue.main.async {
                self.isSyncing = false
                self.syncError = "从 iCloud 获取数据失败: \(error.localizedDescription)"
            }
            print("❌ 从 iCloud 获取数据失败: \(error)")
            return []
        }
    }
    
    // 同步本地收藏到 iCloud
    func syncLocalFavoritesToCloud(_ dishes: [Dish]) async {
        guard await checkiCloudStatus() else { return }
        
        DispatchQueue.main.async {
            self.isSyncing = true
            self.syncError = nil
        }
        
        print("🔄 开始同步 \(dishes.count) 道本地收藏菜品到 iCloud")
        
        for dish in dishes {
            let success = await saveFavoriteDish(dish)
            if success {
                print("✅ 同步成功: \(dish.dishName)")
            } else {
                print("❌ 同步失败: \(dish.dishName)")
            }
        }
        
        DispatchQueue.main.async {
            self.isSyncing = false
            self.lastSyncDate = Date()
            print("🔄 本地收藏同步完成")
        }
    }
    
    // 清除同步错误
    func clearSyncError() {
        syncError = nil
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
        default:
            return self.localizedDescription
        }
    }
}