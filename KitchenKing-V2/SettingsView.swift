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
            ZStack {
                // 背景
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 用户状态卡片
                        userStatusCard
                        
                        // 功能区域
                        VStack(spacing: 16) {
                            chefRoleCard
                            favoritesCard
                            cloudSyncCard
                            accountInfoCard
                        }
                        
                        // 关于区域
                        aboutSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
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
            .sheet(isPresented: $showingSubscription) {
                SubscriptionView(appState: appState)
            }
        }
    }
    
    // MARK: - 子视图组件
    
    private var userStatusCard: some View {
        VStack(spacing: 16) {
            // 订阅状态
            HStack(spacing: 16) {
                ZStack {
                    Rectangle()
                        .fill(appState.isSubscribed ? Color.yellow.opacity(0.2) : Color.gray.opacity(0))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: appState.isSubscribed ? "crown.fill" : "crown")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(appState.isSubscribed ? .yellow : .gray)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(appState.isSubscribed ? "高级版用户" : "免费用户")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(appState.isSubscribed ? "已解锁所有功能" : "有限制使用")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(appState.isSubscribed ? .green : .orange)
                }
                
                Spacer()
            }
            
            // 升级按钮（非会员用户显示）
            if !appState.isSubscribed {
                Button(action: { showingSubscription = true }) {
                    HStack {
                        Text("获取高级版")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(20)
        .background(.white)
        .overlay(
            Rectangle()
                .stroke(.black, lineWidth: 1)
        )
    }
    
    private var chefRoleCard: some View {
        NavigationLink(destination: ChefRoleManagementView(appState: appState)) {
            settingCard(
                icon: "person.3.fill",
                iconColor: .blue,
                title: "管理厨师角色",
                subtitle: "自定义烹饪风格",
                value: "\(appState.getAvailableChefRoles().count)"
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var favoritesCard: some View {
        NavigationLink(destination: FavoritesView(appState: appState)) {
            settingCard(
                icon: "heart.fill",
                iconColor: .red,
                title: "我的收藏",
                subtitle: "收藏的菜品",
                value: "\(appState.favoriteDishes.count)"
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var cloudSyncCard: some View {
        VStack(spacing: 16) {
            HStack {
                // iCloud 图标
                ZStack {
                    Rectangle()
                        .fill(Color.blue.opacity(0))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "icloud.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("iCloud 同步")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text(appState.isCloudSyncEnabled ? "自动同步收藏数据" : "仅保存到本地")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { appState.isCloudSyncEnabled },
                    set: { _ in appState.toggleCloudSync() }
                ))
                .tint(.blue)
            }
            
            // 同步状态和错误信息
            if appState.isCloudSyncEnabled {
                Rectangle()
                    .fill(.black)
                    .frame(height: 1)
                    .opacity(0.1)
                
                VStack(spacing: 8) {
                    // 同步状态
                    HStack {
                        HStack(spacing: 8) {
                            if CloudKitManager.shared.isSyncing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                    .scaleEffect(0.8)
                                
                                Text("同步中...")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.green)
                                
                                if let lastSync = CloudKitManager.shared.lastSyncDate {
                                    Text("最后同步: \(formatDate(lastSync))")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                } else {
                                    Text("等待同步")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // 手动同步按钮
                        Button("立即同步") {
                            appState.manualSync()
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.blue)
                        .disabled(CloudKitManager.shared.isSyncing)
                    }
                    
                    // 错误信息
                    if let error = CloudKitManager.shared.syncError {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                            
                            Text(error)
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                                .lineLimit(2)
                            
                            Spacer()
                            
                            Button("重试") {
                                CloudKitManager.shared.clearSyncError()
                                appState.manualSync()
                            }
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(.white)
        .overlay(
            Rectangle()
                .stroke(.black, lineWidth: 1)
        )
    }
    
    private var accountInfoCard: some View {
        VStack(spacing: 16) {
            // 剩余生成次数
            HStack {
                HStack(spacing: 12) {
                    ZStack {
                        Rectangle()
                            .fill(Color.green.opacity(0))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.green)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("剩余生成次数")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                        Text("每日可用次数")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Text(appState.isSubscribed ? "∞" : "\(appState.remainingGenerations)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(appState.remainingGenerations <= 1 && !appState.isSubscribed ? .red : .black)
            }
            
            // 订阅类型（会员用户显示）
            if appState.isSubscribed, let subscriptionType = appState.subscriptionType {
                Rectangle()
                    .fill(.black)
                    .frame(height: 1)
                    .opacity(0.1)
                
                HStack {
                    HStack(spacing: 12) {
                        ZStack {
                            Rectangle()
                                .fill(Color.purple.opacity(0.1))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Rectangle()
                                        .stroke(.black, lineWidth: 1)
                                )
                            
                            Image(systemName: "star.circle.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.purple)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("订阅类型")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            Text("当前套餐")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    Text(subscriptionType.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple.opacity(0.1))
                        .overlay(
                            Rectangle()
                                .stroke(Color.purple, lineWidth: 1)
                        )
                }
            }
        }
        .padding(20)
        .background(.white)
        .overlay(
            Rectangle()
                .stroke(.black, lineWidth:1)
        )
    }
    
    private var aboutSection: some View {
        VStack(spacing: 16) {
            // 标题
            HStack {
                Text("关于")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            
            VStack(spacing: 12) {
                // 版本信息
                aboutRow(icon: "info.circle.fill", iconColor: .blue, title: "版本", value: "1.0.0")
                
                Rectangle()
                    .fill(.black)
                    .frame(height: 0.5)
                    .opacity(0.2)
                
                // 隐私政策
                Link(destination: URL(string: "https://example.com/privacy")!) {
                    aboutRow(icon: "lock.shield.fill", iconColor: .green, title: "隐私政策", showArrow: true)
                }
                .buttonStyle(PlainButtonStyle())
                
                Rectangle()
                    .fill(.black)
                    .frame(height: 0.5)
                    .opacity(0.2)
                
                // 用户协议
                Link(destination: URL(string: "https://example.com/terms")!) {
                    aboutRow(icon: "doc.text.fill", iconColor: .orange, title: "用户协议", showArrow: true)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(20)
            .background(.white)
            .overlay(
                Rectangle()
                    .stroke(.black, lineWidth: 1)
            )
        }
    }
    
    private func settingCard(icon: String, iconColor: Color, title: String, subtitle: String, value: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Rectangle()
                    .fill(iconColor.opacity(0))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .padding(20)
        .background(.white)
        .overlay(
            Rectangle()
                .stroke(.black, lineWidth: 1)
        )
    }
    
    private func aboutRow(icon: String, iconColor: Color, title: String, value: String? = nil, showArrow: Bool = false) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(iconColor)
                .frame(width: 20)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
            
            Spacer()
            
            if let value = value {
                Text(value)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            if showArrow {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
    }
    
    // 格式化日期显示
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let now = Date()
        let calendar = Calendar.current
        
        if calendar.isDate(date, inSameDayAs: now) {
            formatter.dateFormat = "HH:mm"
            return "今天 \(formatter.string(from: date))"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .year) {
            formatter.dateFormat = "MM-dd HH:mm"
            return formatter.string(from: date)
        } else {
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            return formatter.string(from: date)
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
            ZStack {
                // 背景
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // 头部区域
                        headerSection
                        
                        // 会员特权卡片
                        featuresCard
                        
                        // 订阅选项
                        subscriptionOptions
                        
                        // 订阅按钮
                        subscribeButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("会员订阅")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Rectangle()
                    .fill(Color.yellow.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Rectangle()
                            .stroke(.black, lineWidth: 3)
                    )
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.yellow)
            }
            
            VStack(spacing: 12) {
                Text("升级到会员")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.black)
                
                Text("解锁无限生成和所有高级功能")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var featuresCard: some View {
        VStack(spacing: 20) {
            HStack {
                Text("会员特权")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            
            VStack(spacing: 16) {
                featureRow(icon: "infinity", iconColor: .blue, title: "无限生成", description: "无限制生成菜品配方")
                featureRow(icon: "crown.fill", iconColor: .yellow, title: "会员角色", description: "使用专属厨师角色")
                featureRow(icon: "star.fill", iconColor: .purple, title: "自定义角色", description: "创建个性化厨师")
                featureRow(icon: "heart.fill", iconColor: .red, title: "无限收藏", description: "收藏喜爱的菜品")
            }
        }
        .padding(24)
        .background(.white)
        .overlay(
            Rectangle()
                .stroke(.black, lineWidth: 2)
        )
    }
    
    private var subscriptionOptions: some View {
        VStack(spacing: 16) {
            HStack {
                Text("选择订阅计划")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(SubscriptionType.allCases, id: \.self) { type in
                    modernSubscriptionOption(type: type)
                }
            }
        }
    }
    
    private var subscribeButton: some View {
        Button(action: subscribe) {
            HStack(spacing: 12) {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "star.fill")
                    Text("立即订阅")
                        .font(.system(size: 18, weight: .bold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isProcessing ? Color.gray : .black)
            .foregroundColor(.white)
            .overlay(
                Rectangle()
                    .stroke(.black, lineWidth: 2)
            )
        }
        .disabled(isProcessing)
        .buttonStyle(ScaleButtonStyle())
    }
    
    private func featureRow(icon: String, iconColor: Color, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Rectangle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Rectangle()
                            .stroke(.black, lineWidth: 1)
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
    
    private func modernSubscriptionOption(type: SubscriptionType) -> some View {
        Button(action: { selectedSubscription = type }) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text(type.rawValue)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        if let firstMonthPrice = type.firstMonthPrice {
                            Text("首月¥\(String(format: "%.0f", firstMonthPrice))")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(.red)
                        }
                    }
                    
                    Text("¥\(String(format: "%.0f", type.price))")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(selectedSubscription == type ? .white : .black)
                    
                    Text(type.savings)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(selectedSubscription == type ? .white : .green)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(selectedSubscription == type ? Color.white : Color.clear)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(selectedSubscription == type ? .white : .black, lineWidth: 2)
                        )
                    
                    if selectedSubscription == type {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
            }
            .padding(20)
            .background(selectedSubscription == type ? .black : .white)
            .overlay(
                Rectangle()
                    .stroke(.black, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
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



#Preview {
    SettingsView(appState: AppState())
}
