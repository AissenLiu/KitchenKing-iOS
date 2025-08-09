//
//  StoreKitManager.swift
//  KitchenKing-V2
//
//  Created by Claude on 2025/8/9.
//

import Foundation
import StoreKit
import SwiftUI

@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()
    
    @Published var products: [Product] = []
    @Published var purchasedProducts: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // 产品ID - 需要在App Store Connect中配置
    private let productIDs = ["com.kitchenking.premium"]
    
    private var updateListenerTask: Task<Void, Error>? = nil
    
    private init() {
        print("🏪 初始化StoreKitManager...")
        
        // 启动交易监听
        updateListenerTask = listenForTransactions()
        print("👂 交易监听已启动")
        
        Task {
            print("🔄 开始初始化流程...")
            await requestProducts()
            await updateCustomerProductStatus()
            print("✅ StoreKitManager初始化完成")
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - 产品相关
    
    func requestProducts() async {
        isLoading = true
        errorMessage = nil
        
        print("🔍 开始获取产品信息...")
        print("📋 请求的产品ID列表: \(productIDs)")
        
        do {
            let storeProducts = try await Product.products(for: productIDs)
            products = storeProducts
            
            print("✅ 成功获取产品: \(storeProducts.count) 个")
            for product in storeProducts {
                print("📦 产品详情:")
                print("   - ID: \(product.id)")
                print("   - 显示名称: \(product.displayName)")
                print("   - 描述: \(product.description)")
                print("   - 价格: \(product.displayPrice)")
                print("   - 类型: \(product.type)")
                print("   - 是否可用: \(product.id == "com.kitchenking.premium")")
            }
            
            if storeProducts.isEmpty {
                print("⚠️ 警告: 没有获取到任何产品")
                print("   可能原因:")
                print("   1. App Store Connect中未配置产品")
                print("   2. 产品ID不匹配")
                print("   3. 产品未通过审核")
                print("   4. 网络连接问题")
            }
            
        } catch {
            errorMessage = "获取产品信息失败: \(error.localizedDescription)"
            print("❌ 获取产品失败:")
            print("   - 错误类型: \(type(of: error))")
            print("   - 错误: \(error)")
            print("   - 本地化描述: \(error.localizedDescription)")
            
            if let nsError = error as NSError? {
                print("   - NSError详情:")
                print("     - Domain: \(nsError.domain)")
                print("     - Code: \(nsError.code)")
                print("     - UserInfo: \(nsError.userInfo)")
            }
        }
        
        isLoading = false
    }
    
    // MARK: - 购买功能
    
    func purchase(_ product: Product) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        print("🛒 开始购买产品: \(product.id)")
        print("📦 产品信息:")
        print("   - ID: \(product.id)")
        print("   - 显示名称: \(product.displayName)")
        print("   - 价格: \(product.displayPrice)")
        print("   - 类型: \(product.type)")
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                print("✅ 购买请求成功，开始验证交易...")
                
                do {
                    let transaction = try await checkVerified(verification)
                    
                    print("✅ 交易验证成功:")
                    print("   - 交易ID: \(transaction.id)")
                    print("   - 产品ID: \(transaction.productID)")
                    print("   - 购买日期: \(transaction.purchaseDate)")
                    print("   - 原始交易ID: \(transaction.originalID)")
                    
                    // 更新用户状态
                    _ = await MainActor.run {
                        self.purchasedProducts.insert(transaction.productID)
                        print("✅ 已更新本地购买状态: \(self.purchasedProducts)")
                    }
                    
                    // 完成交易
                    await transaction.finish()
                    print("✅ 交易已完成")
                    
                    isLoading = false
                    return true
                    
                } catch {
                    errorMessage = "交易验证失败: \(error.localizedDescription)"
                    print("❌ 交易验证失败:")
                    print("   - 错误: \(error)")
                    print("   - 错误详情: \(error.localizedDescription)")
                    if let storeError = error as? StoreError {
                        print("   - StoreKit错误类型: \(storeError)")
                    }
                    isLoading = false
                    return false
                }
                
            case .userCancelled:
                print("🚫 用户取消购买")
                errorMessage = "用户取消了购买"
                isLoading = false
                return false
                
            case .pending:
                print("⏳ 购买待处理 - 可能需要家长同意或其他授权")
                errorMessage = "购买正在处理中，请稍后查看购买状态"
                isLoading = false
                return false
                
            @unknown default:
                print("❓ 未知购买结果: \(result)")
                errorMessage = "购买状态未知，请稍后重试"
                isLoading = false
                return false
            }
            
        } catch StoreKitError.userCancelled {
            print("🚫 用户在App Store界面取消了购买")
            errorMessage = "用户取消了购买"
            isLoading = false
            return false
            
        } catch StoreKitError.networkError(let underlyingError) {
            print("🌐 网络错误:")
            print("   - 基础错误: \(underlyingError)")
            print("   - 错误描述: \(underlyingError.localizedDescription)")
            errorMessage = "网络连接失败，请检查网络后重试"
            isLoading = false
            return false
            
        } catch StoreKitError.systemError(let underlyingError) {
            print("⚙️ 系统错误:")
            print("   - 基础错误: \(underlyingError)")
            print("   - 错误描述: \(underlyingError.localizedDescription)")
            errorMessage = "系统错误，请稍后重试"
            isLoading = false
            return false
            
        } catch StoreKitError.notAvailableInStorefront {
            print("🏪 产品在当前地区不可用")
            errorMessage = "该产品在您的地区暂不可用"
            isLoading = false
            return false
            
        } catch StoreKitError.notEntitled {
            print("🔒 用户无权限购买此产品")
            errorMessage = "您没有权限购买此产品"
            isLoading = false
            return false
            
        } catch {
            print("❌ 购买过程中发生未知错误:")
            print("   - 错误类型: \(type(of: error))")
            print("   - 错误: \(error)")
            print("   - 本地化描述: \(error.localizedDescription)")
            
            // 尝试获取更多错误信息
            if let nsError = error as NSError? {
                print("   - NSError详情:")
                print("     - Domain: \(nsError.domain)")
                print("     - Code: \(nsError.code)")
                print("     - UserInfo: \(nsError.userInfo)")
            }
            
            errorMessage = "购买失败: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    // MARK: - 恢复购买功能
    
    func restorePurchases() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        print("🔄 开始恢复购买...")
        print("📋 恢复前的购买状态: \(purchasedProducts)")
        
        do {
            print("🔄 正在与App Store同步...")
            try await AppStore.sync()
            print("✅ App Store同步完成")
            
            print("🔄 正在更新客户产品状态...")
            await updateCustomerProductStatus()
            print("✅ 产品状态更新完成")
            
            print("📋 恢复后的购买状态: \(purchasedProducts)")
            
            if !purchasedProducts.isEmpty {
                print("✅ 恢复购买成功，找到以下产品:")
                for productID in purchasedProducts {
                    print("   - \(productID)")
                }
                isLoading = false
                return true
            } else {
                errorMessage = "未找到购买记录"
                print("❌ 未找到购买记录")
                print("   可能原因:")
                print("   1. 用户从未购买过任何产品")
                print("   2. 使用的Apple ID与购买时不同")
                print("   3. 产品配置问题")
                print("   4. 网络连接问题")
                isLoading = false
                return false
            }
            
        } catch {
            errorMessage = "恢复购买失败: \(error.localizedDescription)"
            print("❌ 恢复购买失败:")
            print("   - 错误类型: \(type(of: error))")
            print("   - 错误: \(error)")
            print("   - 本地化描述: \(error.localizedDescription)")
            
            if let nsError = error as NSError? {
                print("   - NSError详情:")
                print("     - Domain: \(nsError.domain)")
                print("     - Code: \(nsError.code)")
                print("     - UserInfo: \(nsError.userInfo)")
            }
            
            isLoading = false
            return false
        }
    }
    
    // MARK: - 兑换优惠码功能
    
    func presentCodeRedemptionSheet() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        // 记录兑换前的购买状态
        let previousPurchasedProducts = purchasedProducts
        
        // 使用经典StoreKit API进行兑换
        _ = await MainActor.run {
            if #available(iOS 14.0, *) {
                SKPaymentQueue.default().presentCodeRedemptionSheet()
            }
        }
        
        // 等待一段时间让用户完成兑换操作
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 等待1秒
        
        // 兑换后更新状态
        await updateCustomerProductStatus()
        
        // 检查是否有新的购买产品（即兑换是否成功）
        let hasNewPurchases = !purchasedProducts.isSubset(of: previousPurchasedProducts)
        
        isLoading = false
        
        if hasNewPurchases {
            print("✅ 兑换成功，检测到新的购买产品: \(purchasedProducts)")
            return true
        } else {
            print("❌ 兑换失败或被取消，购买状态未改变")
            return false
        }
    }
    
    // MARK: - 私有方法
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            print("👂 开始监听交易更新...")
            
            for await result in Transaction.updates {
                print("📨 收到交易更新通知")
                
                do {
                    let transaction = try await self.checkVerified(result)
                    
                    print("✅ 交易监听验证成功:")
                    print("   - 交易ID: \(transaction.id)")
                    print("   - 产品ID: \(transaction.productID)")
                    print("   - 购买日期: \(transaction.purchaseDate)")
                    
                    _ = await MainActor.run {
                        self.purchasedProducts.insert(transaction.productID)
                        print("✅ 交易监听更新本地状态: \(self.purchasedProducts)")
                    }
                    
                    await transaction.finish()
                    print("✅ 交易监听完成交易")
                    
                } catch {
                    print("❌ 交易监听验证失败:")
                    print("   - 错误: \(error)")
                    print("   - 错误详情: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateCustomerProductStatus() async {
        print("🔄 开始更新客户产品状态...")
        var purchasedProducts: Set<String> = []
        var transactionCount = 0
        
        for await result in Transaction.currentEntitlements {
            transactionCount += 1
            print("📄 处理权限交易 #\(transactionCount)")
            
            do {
                let transaction = try await checkVerified(result)
                purchasedProducts.insert(transaction.productID)
                
                print("✅ 权限交易验证成功:")
                print("   - 交易ID: \(transaction.id)")
                print("   - 产品ID: \(transaction.productID)")
                print("   - 购买日期: \(transaction.purchaseDate)")
                print("   - 原始交易ID: \(transaction.originalID)")
                print("   - 撤销日期: \(transaction.revocationDate?.description ?? "无")")
                print("   - 过期日期: \(transaction.expirationDate?.description ?? "永久")")
                
            } catch {
                print("❌ 权限交易验证失败:")
                print("   - 错误: \(error)")
                print("   - 错误详情: \(error.localizedDescription)")
            }
        }
        
        print("📊 权限更新统计:")
        print("   - 处理的交易数量: \(transactionCount)")
        print("   - 有效的购买产品: \(purchasedProducts)")
        
        _ = await MainActor.run {
            let oldPurchasedProducts = self.purchasedProducts
            self.purchasedProducts = purchasedProducts
            
            if oldPurchasedProducts != purchasedProducts {
                print("🔄 购买状态发生变化:")
                print("   - 原状态: \(oldPurchasedProducts)")
                print("   - 新状态: \(purchasedProducts)")
            } else {
                print("📝 购买状态无变化: \(purchasedProducts)")
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) async throws -> T {
        switch result {
        case .unverified:
            print("❌ 交易验证失败: 交易未通过Apple的验证")
            print("   - 可能原因: 交易被篡改或来源不可信")
            throw StoreError.failedVerification
        case .verified(let safe):
            print("✅ 交易验证通过: 交易已通过Apple验证")
            return safe
        }
    }
    
    // MARK: - 辅助方法
    
    func isPurchased(_ productID: String) -> Bool {
        return purchasedProducts.contains(productID)
    }
    
    func getProduct(for id: String) -> Product? {
        return products.first { $0.id == id }
    }
}

// MARK: - 错误类型

enum StoreError: Error {
    case failedVerification
}

extension StoreError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "用户或应用无法验证"
        }
    }
}