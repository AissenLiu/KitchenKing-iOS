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
    @State private var showingPurchase = false
    
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
                            //chefRoleCard
                            favoritesCard
                            cloudSyncCard
                            accountInfoCard
                        }
                        
                        // 版本信息区域
                        versionInfoSection
                        
                        // 后续计划区域
                        futurePlansSection
                        
                        // 关于我们区域
                        aboutUsSection
                        
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
            .sheet(isPresented: $showingPurchase) {
                PurchaseView(appState: appState)
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
                        .fill(appState.isPurchased ? Color.yellow.opacity(0) : Color.gray.opacity(0))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: appState.isPurchased ? "cup.and.saucer.fill" : "cup.and.saucer.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(appState.isPurchased ? .yellow : .gray)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(appState.isPurchased ? "高级版用户" : "免费用户")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(appState.isPurchased ? "已解锁所有功能" : "获取高级版解锁全部功能")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            // 升级按钮（非会员用户显示）
            if !appState.isPurchased {
                Button(action: { showingPurchase = true }) {
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
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("剩余生成次数")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                        if appState.isPurchased, let purchaseType = appState.purchaseType {
                            Text("无限次数使用")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        } else {
                            Text("免费用户可以体验 3 次")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
                
                Text(appState.isPurchased ? "∞" : "\(appState.remainingGenerations)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(appState.remainingGenerations <= 1 && !appState.isPurchased ? .red : .black)
            }
        }
        .padding(20)
        .background(.white)
        .overlay(
            Rectangle()
                .stroke(.black, lineWidth:1)
        )
    }
    
    private var versionInfoSection: some View {
        VStack(spacing: 16) {
            // 标题
            HStack {
                Text("最新版本 1.0.0")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.black)
                Spacer()
            }
            
            HStack(spacing: 12) {
                VStack(){
                    HStack(){
                        ZStack {
                            Rectangle()
                                .fill(Color.green.opacity(0))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.green)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            
                            Text("内测期间享受早鸟价")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            Text("后续增加功能后陆续恢复到原价")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }

                    Rectangle()
                        .fill(.black)
                        .frame(height: 0.5)
                        .opacity(0.2)
                    
                    HStack(){
                        ZStack {
                            Rectangle()
                                .fill(Color.green.opacity(0))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.green)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            
                            Text("不用等，首版直接上线女厨师")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            Text("增加日本料理，意大利菜系的女厨师")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)

                        }
                        Spacer()
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
    }
    
    private var aboutUsSection: some View {
        VStack(spacing: 16) {
            // 标题
            HStack {
                Text("关于我们")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.black)
                Spacer()
            }
            
            // 横向两个信息布局
            HStack(spacing: 12) {
                // Redbook 链接
                Button(action: {
                    if let url = URL(string: "https://www.xiaohongshu.com/user/profile/5e4576a6000000000100a83f?xsec_token=YBmIZjb-UvgzZquoEv3v5AZA6oGlJfSjO8YBepdpjjJ3Q=&xsec_source=app_share&xhsshare=CopyLink&appuid=5e4576a6000000000100a83f&apptime=1754708486&share_id=5130f88621a14a0392fb63c293186180") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: 12) {
                        ZStack {
                            Image(systemName: "book.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.red)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Redbook")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(.white)
                
                // Feedback 链接
                Button(action: {
                    if let url = URL(string: "http://xhslink.com/m/Z4hb0TqYb4") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: 12) {
                        ZStack {
                            Image(systemName: "message.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Feedback")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(.white)
            }
            .overlay(
                Rectangle()
                    .stroke(.black, lineWidth: 1)
            )
        }
    }
    
    private var futurePlansSection: some View {
        VStack(spacing: 16) {
            // 标题
            HStack {
                Text("后续计划")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.black)
                Spacer()
            }
            
            VStack(spacing: 12) {
                // 计划项目列表
                planItem(
                    icon: "star.fill",
                    iconColor: .purple,
                    title: "增加自定义角色功能",
                    number: "1"
                )
                
                planItem(
                    icon: "crown.fill", 
                    iconColor: .yellow,
                    title: "增加一些会员限定角色",
                    number: "2"
                )
                
                planItem(
                    icon: "xmark.circle.fill",
                    iconColor: .orange,
                    title: "增加忌口功能",
                    number: "3"
                )
                
                planItem(
                    icon: "basket.fill",
                    iconColor: .green,
                    title: "增加调料柜功能", 
                    number: "4"
                )
                
                planItem(
                    icon: "basket.fill",
                    iconColor: .green,
                    title: "推出点心烘焙版本",
                    number: "5"
                )
                
                planItem(
                    icon: "basket.fill",
                    iconColor: .green,
                    title: "增加减脂餐功能",
                    number: "6"
                )
            }
            .padding(20)
            .background(.white)
            .overlay(
                Rectangle()
                    .stroke(.black, lineWidth: 1)
            )
        }
    }
    
    private func planItem(icon: String, iconColor: Color, title: String, number: String) -> some View {
        HStack(spacing: 12) {
            // 序号
            Text(number)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 24, height: 24)
                .background(Color.white)
                .overlay(
                    Rectangle()
                        .stroke(.black, lineWidth: 1)
                )
            
            
            // 标题
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
            
            Spacer()
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



// MARK: - 购买视图
struct PurchaseView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var appState: AppState
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
                        
                        // 购买选项和按钮合并
                        combinedPurchaseSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
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
                    .fill(Color.yellow.opacity(0))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.black)
            }
            
            VStack(spacing: 12) {
                Text("升级到高级版")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.black)
                
                Text("一次性购买，永久享受所有功能")
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
//                featureRow(icon: "star.fill", iconColor: .purple, title: "自定义角色", description: "创建个性化厨师")
                featureRow(icon: "heart.fill", iconColor: .red, title: "无限收藏", description: "收藏喜爱的菜品")
            }
        }
        .padding(24)
        .background(.white)
        .overlay(
            Rectangle()
                .stroke(.black, lineWidth: 1)
        )
    }
    
    
    private var combinedPurchaseSection: some View {
        VStack(spacing: 20) {
            
            // 价格信息
            VStack(spacing: 8) {
                HStack {
                    Text("原价")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("¥98")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .strikethrough(true, color: .gray)
                    
                    Spacer()
                }
                
                HStack {
                    Text("早鸟价")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    
                    Text("¥39.00")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(.black)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            
            // 购买按钮
            Button(action: subscribe) {
                HStack(spacing: 12) {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    } else {
                        Text("立即获取")
                            .font(.system(size: 18, weight: .bold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: isProcessing ? [Color.gray, Color.gray] : [Color.black, Color.gray.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundColor(.white)
            }
            .disabled(isProcessing)
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(24)
        .background(.white)
        .overlay(
            Rectangle()
                .stroke(.black, lineWidth: 1)
        )
    }
    
    
    private func featureRow(icon: String, iconColor: Color, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Rectangle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 40, height: 40)
   
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
    
    
    private func subscribe() {
        purchase()
    }
    
    private func purchase() {
        isProcessing = true
        
        // 模拟购买处理
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            appState.purchase(.premium)
            isProcessing = false
            dismiss()
        }
    }
}



#Preview {
    SettingsView(appState: AppState())
}
