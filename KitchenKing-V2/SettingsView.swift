//
//  SettingsView.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var appState: AppState
    @State private var showingSubscription = false
    
    var body: some View {
        NavigationView {
            List {
                // 订阅状态
                Section("订阅状态") {
                    SubscriptionStatusView(appState: appState)
                    
                    if !appState.isSubscribed {
                        Button("升级到会员") {
                            showingSubscription = true
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                // 厨师角色
                Section("厨师角色") {
                    NavigationLink(destination: ChefRoleManagementView(appState: appState)) {
                        HStack {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(.blue)
                            Text("管理厨师角色")
                            Spacer()
                            Text("\(appState.getAvailableChefRoles().count)")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // 账户信息
                Section("账户信息") {
                    HStack {
                        Text("剩余生成次数")
                        Spacer()
                        Text(appState.isSubscribed ? "无限" : "\(appState.remainingGenerations)")
                            .foregroundColor(appState.remainingGenerations <= 1 && !appState.isSubscribed ? .red : .primary)
                    }
                    
                    if appState.isSubscribed, let subscriptionType = appState.subscriptionType {
                        HStack {
                            Text("订阅类型")
                            Spacer()
                            Text(subscriptionType.description)
                        }
                    }
                }
                
                // 收藏管理
                Section("收藏管理") {
                    NavigationLink(destination: FavoritesView(appState: appState)) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("我的收藏")
                            Spacer()
                            Text("\(appState.favoriteDishes.count)")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // 关于
                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    
                    Link("隐私政策", destination: URL(string: "https://example.com/privacy")!)
                    Link("用户协议", destination: URL(string: "https://example.com/terms")!)
                }
            }
            .navigationTitle("设置")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingSubscription) {
                SubscriptionView(appState: appState)
            }
        }
    }
}

// MARK: - 订阅状态视图
struct SubscriptionStatusView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        HStack {
            Image(systemName: appState.isSubscribed ? "crown.fill" : "crown")
                .foregroundColor(appState.isSubscribed ? .yellow : .gray)
            
            VStack(alignment: .leading) {
                Text(appState.isSubscribed ? "会员用户" : "免费用户")
                    .font(.headline)
                
                if appState.isSubscribed {
                    Text("已解锁所有功能")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Text("有限制使用")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
        }
    }
}


// MARK: - 订阅视图
struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var appState: AppState
    @State private var selectedSubscription: SubscriptionType = .monthly
    @State private var isProcessing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 头部
                    VStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        Text("升级到会员")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("解锁无限生成和高级功能")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // 会员特权
                    VStack(alignment: .leading, spacing: 16) {
                        Text("会员特权")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            FeatureRow(icon: "infinity", title: "无限生成", description: "无限制生成菜品")
                            FeatureRow(icon: "crown.fill", title: "会员角色", description: "使用专属厨师角色")
                            FeatureRow(icon: "star.fill", title: "自定义角色", description: "创建个性化厨师")
                            FeatureRow(icon: "heart.fill", title: "无限收藏", description: "收藏喜爱的菜品")
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // 订阅选项
                    VStack(spacing: 16) {
                        Text("选择订阅计划")
                            .font(.headline)
                        
                        ForEach(SubscriptionType.allCases, id: \.self) { type in
                            SubscriptionOptionView(
                                type: type,
                                isSelected: selectedSubscription == type,
                                onTap: { selectedSubscription = type }
                            )
                        }
                    }
                    
                    // 订阅按钮
                    Button(action: subscribe) {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("立即订阅")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isProcessing ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isProcessing)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("会员订阅")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func subscribe() {
        isProcessing = true
        
        // 模拟订阅处理
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            appState.subscribe(selectedSubscription)
            isProcessing = false
            dismiss()
        }
    }
}

// MARK: - 功能特性行
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

// MARK: - 订阅选项视图
struct SubscriptionOptionView: View {
    let type: SubscriptionType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(type.rawValue)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        if let firstMonthPrice = type.firstMonthPrice {
                            Text("首月¥\(String(format: "%.2f", firstMonthPrice))")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    Text("¥\(String(format: "%.2f", type.price))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text(type.savings)
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title2)
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


#Preview {
    SettingsView(appState: AppState())
}