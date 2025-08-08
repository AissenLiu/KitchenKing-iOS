//
//  ChefRoleManagementView.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

import SwiftUI

struct ChefRoleManagementView: View {
    @ObservedObject var appState: AppState
    @State private var showingCustomChef = false
    @State private var showingAddPremium = false
    @State private var customChefName = ""
    @State private var customChefTitle = ""
    @State private var customChefSpecialty = ""
    @State private var customChefPersonality = ""
    @State private var customChefStyle = ""
    @State private var selectedPremiumRole: ChefRole?
    
    var body: some View {
        NavigationView {
            List {
                freeRolesSection
                premiumRolesSection
                customRolesSection
            }
            .navigationTitle("厨师角色管理")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("完成") {
                        // 关闭界面
                    }
                }
            }
            .sheet(isPresented: $showingCustomChef) {
                CustomChefCreationView(
                    appState: appState,
                    name: $customChefName,
                    title: $customChefTitle,
                    specialty: $customChefSpecialty,
                    personality: $customChefPersonality,
                    style: $customChefStyle,
                    isPresented: $showingCustomChef
                )
            }
            .sheet(isPresented: $showingAddPremium) {
                PremiumRoleAddView(
                    appState: appState,
                    isPresented: $showingAddPremium
                )
            }
        }
    }
    
    private var freeRolesSection: some View {
        Section("免费角色") {
            ForEach(ChefRole.freeRoles, id: \.id) { role in
                ChefRoleCardView(
                    role: role,
                    isSelected: role.id == appState.selectedChefRole.id,
                    canRemove: false,
                    onTap: {
                        appState.selectedChefRole = role
                    },
                    onRemove: nil
                )
            }
        }
    }
    
    private var premiumRolesSection: some View {
        Group {
            if appState.isPurchased {
                subscribedPremiumRolesSection
            } else {
                unsubscribedPremiumRolesSection
            }
        }
    }
    
    private var subscribedPremiumRolesSection: some View {
        Section("会员角色") {
            ForEach(ChefRole.premiumRoles, id: \.id) { role in
                ChefRoleCardView(
                    role: role,
                    isSelected: role.id == appState.selectedChefRole.id,
                    canRemove: false,
                    onTap: {
                        appState.selectedChefRole = role
                    },
                    onRemove: nil
                )
            }
            
            // 由于目前只有2个会员角色，暂时不显示添加按钮
            // if ChefRole.premiumRoles.count < 2 {
            //     addPremiumRoleButton
            // }
        }
    }
    
    private var unsubscribedPremiumRolesSection: some View {
        Section("会员角色 (需订阅)") {
            ForEach(ChefRole.premiumRoles, id: \.id) { role in
                ChefRoleCardView(
                    role: role,
                    isSelected: false,
                    canRemove: false,
                    onTap: {
                        showingAddPremium = true
                    },
                    onRemove: nil
                )
            }
            
            upgradeToPremiumButton
        }
    }
    
    private var customRolesSection: some View {
        Group {
            if appState.isPurchased {
                Section("自定义角色") {
                    ForEach(appState.customChefRoles, id: \.id) { role in
                        ChefRoleCardView(
                            role: role,
                            isSelected: role.id == appState.selectedChefRole.id,
                            canRemove: true,
                            onTap: {
                                appState.selectedChefRole = role
                            },
                            onRemove: {
                                appState.removeRole(role)
                            }
                        )
                    }
                    
                    addCustomRoleButton
                }
            }
        }
    }
    
    private var addPremiumRoleButton: some View {
        Button(action: {
            showingAddPremium = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
                Text("添加会员角色")
                    .foregroundColor(.blue)
            }
        }
    }
    
    private var upgradeToPremiumButton: some View {
        Button(action: {
            showingAddPremium = true
        }) {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                Text("升级会员解锁更多角色")
                    .foregroundColor(.blue)
            }
        }
    }
    
    private var addCustomRoleButton: some View {
        Button(action: {
            showingCustomChef = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
                Text("创建自定义角色")
                    .foregroundColor(.blue)
            }
        }
    }
}

// MARK: - 厨师角色卡片视图
struct ChefRoleCardView: View {
    let role: ChefRole
    let isSelected: Bool
    let canRemove: Bool
    let onTap: () -> Void
    let onRemove: (() -> Void)?
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(role.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(role.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if role.isPremium {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }
                        
                        if role.isCustom {
                            Image(systemName: "star.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                    }
                    
                    Text(role.title)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(role.specialty)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
                
                if canRemove {
                    Button(action: {
                        onRemove?()
                    }) {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 会员角色添加视图
struct PremiumRoleAddView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var appState: AppState
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if appState.isPurchased {
                    // 已订阅，显示添加角色选项
                    VStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                        
                        Text("会员专享角色")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("您已经拥有所有会员角色")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("当前已解锁 \(ChefRole.premiumRoles.count) 个会员角色")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    Button("确定") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Spacer()
                } else {
                    // 未订阅，显示订阅选项
                    VStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                        
                        Text("升级会员")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("解锁更多专业厨师角色")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            FeatureText(icon: "crown.fill", text: "2个会员专属角色")
                            FeatureText(icon: "star.fill", text: "自定义角色创建")
                            FeatureText(icon: "infinity", text: "无限生成菜品")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding()
                    
                    Button("立即订阅") {
                        dismiss()
                        // 这里可以跳转到订阅页面
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("稍后") {
                        dismiss()
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("会员角色")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 功能特性文本
struct FeatureText: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.caption)
            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

#Preview {
    ChefRoleManagementView(appState: AppState())
}