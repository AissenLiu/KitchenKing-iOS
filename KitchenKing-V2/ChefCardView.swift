//
//  ChefCardView.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct ChefCardView: View {
    let chef: Chef
    let completionOrder: Int
    @ObservedObject var appState: AppState
    let onDishClick: (Dish) -> Void
    @State private var currentStep = ""
    @State private var showCelebration = false
    @State private var isAnimating = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // 主卡片内容
            mainCardContent
            
            // 外部装饰元素
            externalElementsView
        }
        .onChange(of: chef.status) { _, newStatus in
            handleStatusChange(newStatus)
        }
        .onAppear {
            if chef.status == .cooking {
                isAnimating = true
            }
        }
    }
    
    // MARK: - 主要内容
    private var mainCardContent: some View {
        VStack(spacing: layoutSpacing) {
            HStack(spacing: cardSpacing) {
                chefAvatarSection
                
                VStack(alignment: .leading, spacing: contentSpacing) {
                    chefInfoSection
                    
                    statusOrDishSection
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, verticalPadding)
            .overlay(alignment: .bottom) {
                if chef.status == .completed, let dish = chef.dish {
                    dishInfoBar(dish: dish)
                }
            }
        }
        .padding(paddingValues)
        .padding(.vertical, responsiveSize(8))
        .background(cardStyle)
        .scaleEffect(celebrationScale)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showCelebration)
    }
    
    // MARK: - 卡片样式
    private var cardStyle: some View {
        Rectangle()
            .fill(cardBackgroundColor)
            .overlay(
                Rectangle()
                    .stroke(.black, lineWidth: 1)
            )
            .shadow(color: cardShadowColor, radius: cardShadowRadius, x: cardShadowX, y: cardShadowY)
    }
    
    // MARK: - 子视图组件
    private var chefAvatarSection: some View {
        ZStack {
            avatarImage
                .frame(width: avatarSize, height: avatarSize)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                .offset(y: cookingAnimationOffset)
                .animation(cookingAnimation, value: isAnimating)
            
            statusBadge
                .offset(x: badgeOffset.width, y: badgeOffset.height)
        }
        .frame(width: avatarSize, height: avatarSize)
    }
    
    private var avatarImage: some View {
        Text(chef.emoji)
            .font(.system(size: 32))
    }
    
    private var statusBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(statusBadgeColor)
                .frame(width: statusBadgeSize, height: statusBadgeSize)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.white, lineWidth: statusBadgeBorderWidth)
                )
                .scaleEffect(cookingAnimationScale)
                .animation(cookingAnimation, value: isAnimating)
            
            Image(systemName: statusBadgeIcon)
                .font(.system(size: statusBadgeIconSize, weight: .semibold))
                .foregroundColor(.white)
        }
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var chefInfoSection: some View {
        HStack(alignment: .center, spacing: 8) {
            chefNameText
            
            Spacer()
            
            cuisineTag
        }
    }
    
    private var chefNameText: some View {
        Text(chef.name)
            .font(.system(size: chefNameFontSize, weight: .bold, design: .rounded))
            .foregroundColor(.primary)
            .lineLimit(1)
    }
    
    private var cuisineTag: some View {
        Text(chef.cuisine)
            .font(.system(size: cuisineTagFontSize, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, cuisineTagHorizontalPadding)
            .padding(.vertical, cuisineTagVerticalPadding)
            .background(
                Rectangle()
                    .fill(.black)
            )
    }
    
    private var statusOrDishSection: some View {
        Group {
            if chef.status == .completed, let dish = chef.dish {
                dishInfoSection(dish: dish)
            } else {
                statusSection
            }
        }
    }
    
    private func dishInfoSection(dish: Dish) -> some View {
        VStack(alignment: .leading, spacing: dishInfoSpacing) {
            dishNameText(dish: dish)
        }
    }
    
    private func dishNameText(dish: Dish) -> some View {
        Text(dish.dishName)
            .font(.system(size: dishNameFontSize, weight: .semibold))
            .foregroundColor(.primary)
            .lineLimit(dishNameLineLimit)
            .multilineTextAlignment(.leading)
            .onTapGesture {
                onDishClick(dish)
            }
            .contentShape(Rectangle())
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: statusSectionSpacing) {
            statusText
            
            if let cookingStep = chef.cookingStep {
                cookingStepText
            }
        }
    }
    
    private var statusText: some View {
        HStack(spacing: 8) {
            Text(currentStatusText)
                .font(.system(size: statusFontSize, weight: .semibold))
                .foregroundColor(statusColor)
                .lineLimit(1)
            
            if chef.status == .cooking {
                PixelLoadingIndicator()
                    .scaleEffect(loadingIndicatorScale)
            }
        }
    }
    
    private var cookingStepText: some View {
        Text(chef.cookingStep ?? "")
            .font(.system(size: cookingStepFontSize, weight: .medium))
            .foregroundColor(.secondary)
            .lineLimit(cookingStepLineLimit)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    private func dishInfoBar(dish: Dish) -> some View {
        HStack(spacing: dishBarSpacing) {
            Image(systemName: "fork.knife")
                .font(.system(size: dishBarIconSize))
                .foregroundColor(.secondary)
            
            Text(dish.dishName)
                .font(.system(size: dishBarFontSize, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .onTapGesture {
                    onDishClick(dish)
                }
            
            Spacer()
        }
        .padding(.horizontal, dishBarHorizontalPadding)
        .padding(.vertical, dishBarVerticalPadding)
        .background(
            RoundedRectangle(cornerRadius: dishBarCornerRadius)
                .fill(dishBarBackgroundColor)
        )
    }
    
    // MARK: - 外部装饰元素
    private var externalElementsView: some View {
        Group {
            // 奖牌角标
            if completionOrder >= 0 && completionOrder < 3 {
                medalBadge
            }
            
            // 排名角标
            if completionOrder >= 3 {
                rankBadge(rank: completionOrder + 1)
            }
        }
    }
    
    private var medalBadge: some View {
        VStack {
            HStack {
                Spacer()
                medalBadgeContent
                    .padding(.trailing, medalBadgeTrailingPadding)
            }
            Spacer()
        }
    }
    
    private var medalBadgeContent: some View {
        Text(medalEmoji)
            .font(.system(size: medalEmojiFontSize))
            .scaleEffect(showCelebration ? 1.2 : 1.0)
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showCelebration)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func rankBadge(rank: Int) -> some View {
        VStack {
            HStack {
                rankBadgeContent(rank: rank)
                    .padding(.leading, rankBadgeLeadingPadding)
                Spacer()
            }
            Spacer()
        }
    }
    
    private func rankBadgeContent(rank: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: rankBadgeCornerRadius)
                .fill(rankBadgeBackgroundColor)
                .frame(width: rankBadgeSize.width, height: rankBadgeSize.height)
                .overlay(
                    RoundedRectangle(cornerRadius: rankBadgeCornerRadius)
                        .stroke(rankBadgeBorderColor, lineWidth: rankBadgeBorderWidth)
                )
            
            Text("\(rank)")
                .font(.system(size: rankBadgeFontSize, weight: .bold))
                .foregroundColor(rankBadgeTextColor)
        }
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - 辅助方法
    private func handleStatusChange(_ newStatus: Chef.ChefStatus) {
        if newStatus == .completed && !showCelebration {
            triggerCelebration()
        }
        
        if newStatus == .cooking && !isAnimating {
            isAnimating = true
        } else if newStatus != .cooking && isAnimating {
            isAnimating = false
        }
    }
    
    private func triggerCelebration() {
        showCelebration = true
        
        // 2秒后恢复
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showCelebration = false
        }
    }
    
    // MARK: - 计算属性
    private var statusColor: Color {
        switch chef.status {
        case .idle: return .secondary
        case .cooking: return .orange
        case .completed: return .green
        case .error: return .red
        }
    }
    
    private var statusBadgeColor: Color {
        switch chef.status {
        case .idle: return .gray
        case .cooking: return .orange
        case .completed: return .green
        case .error: return .red
        }
    }
    
    private var statusBadgeIcon: String {
        switch chef.status {
        case .idle: return "pause.fill"
        case .cooking: return "flame.fill"
        case .completed: return "checkmark.fill"
        case .error: return "xmark.fill"
        }
    }
    
    private var shouldAnimate: Bool {
        chef.status == .cooking
    }
    
    private var cookingAnimation: Animation {
        shouldAnimate ?
            .easeInOut(duration: 1.0).repeatForever() : .default
    }
    
    private var cookingAnimationScale: CGFloat {
        chef.status == .cooking ? (isAnimating ? 1.1 : 1.0) : 1.0
    }
    
    private var cookingAnimationOffset: CGFloat {
        chef.status == .cooking ? (isAnimating ? -2 : 2) : 0
    }
    
    private var celebrationScale: CGFloat {
        showCelebration ? 1.02 : 1.0
    }
    
    // MARK: - 颜色和样式
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color.gray.opacity(0.1) : .white
    }
    
    private var cardShadowColor: Color {
        .black.opacity(0.1)
    }
    
    private var dishBarBackgroundColor: Color {
        colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1)
    }
    
    private var medalEmoji: String {
        switch completionOrder {
        case 0: return "🥇"
        case 1: return "🥈"
        case 2: return "🥉"
        default: return ""
        }
    }
    
    private var rankBadgeBackgroundColor: Color {
        .black
    }
    
    private var rankBadgeBorderColor: Color {
        .black
    }
    
    private var rankBadgeTextColor: Color {
        .white
    }
    
    // MARK: - 响应式尺寸计算
    private func responsiveSize(_ baseSize: CGFloat, scale: CGFloat = 1.0) -> CGFloat {
        #if os(iOS)
        let screenWidth = UIScreen.main.bounds.width
        let scaleFactor: CGFloat = screenWidth < 375 ? 0.85 : (screenWidth > 414 ? 1.15 : 1.0)
        #else
        let scaleFactor: CGFloat = 1.0
        #endif
        return baseSize * scaleFactor * scale
    }
    
    // MARK: - 布局尺寸
    private var layoutSpacing: CGFloat { responsiveSize(12) }
    private var cardSpacing: CGFloat { responsiveSize(16) }
    private var contentSpacing: CGFloat { responsiveSize(8) }
    private var dishInfoSpacing: CGFloat { responsiveSize(4) }
    private var statusSectionSpacing: CGFloat { responsiveSize(4) }
    private var dishBarSpacing: CGFloat { responsiveSize(6) }
    
    // MARK: - 内边距
    private var paddingValues: EdgeInsets {
        EdgeInsets(
            top: responsiveSize(8),
            leading: responsiveSize(16),
            bottom: responsiveSize(8),
            trailing: responsiveSize(16)
        )
    }
    
    private var verticalPadding: CGFloat { responsiveSize(12) }
    private var dishBarHorizontalPadding: CGFloat { responsiveSize(12) }
    private var dishBarVerticalPadding: CGFloat { responsiveSize(8) }
    private var medalBadgeTrailingPadding: CGFloat { responsiveSize(12) }
    private var rankBadgeLeadingPadding: CGFloat { responsiveSize(12) }
    private var cuisineTagHorizontalPadding: CGFloat { responsiveSize(8) }
    private var cuisineTagVerticalPadding: CGFloat { responsiveSize(4) }
    
    // MARK: - 头像尺寸
    private var avatarSize: CGFloat { responsiveSize(60) }
    
    // MARK: - 状态徽章尺寸
    private var statusBadgeSize: CGFloat { responsiveSize(20) }
    private var statusBadgeBorderWidth: CGFloat { responsiveSize(1.5) }
    private var statusBadgeIconSize: CGFloat { responsiveSize(10) }
    private var badgeOffset: CGSize {
        CGSize(
            width: responsiveSize(25),
            height: responsiveSize(25)
        )
    }
    
    // MARK: - 字体尺寸
    private var chefNameFontSize: CGFloat { responsiveSize(18) }
    private var dishNameFontSize: CGFloat { responsiveSize(16) }
    private var statusFontSize: CGFloat { responsiveSize(14) }
    private var cookingStepFontSize: CGFloat { responsiveSize(12) }
    private var dishBarIconSize: CGFloat { responsiveSize(11) }
    private var dishBarFontSize: CGFloat { responsiveSize(13) }
    private var cuisineTagFontSize: CGFloat { responsiveSize(10) }
    
    // MARK: - 加载指示器
    private var loadingIndicatorScale: CGFloat { responsiveSize(0.6) }
    
    // MARK: - 行限制
    private var dishNameLineLimit: Int { 2 }
    private var cookingStepLineLimit: Int { 2 }
    
    // MARK: - 圆角
    private var dishBarCornerRadius: CGFloat { responsiveSize(6) }
    private var rankBadgeCornerRadius: CGFloat { responsiveSize(4) }
    
    // MARK: - 阴影
    private var cardShadowRadius: CGFloat { responsiveSize(4) }
    private var cardShadowX: CGFloat { responsiveSize(0) }
    private var cardShadowY: CGFloat { responsiveSize(2) }
    
    // MARK: - 奖牌尺寸
    private var medalEmojiFontSize: CGFloat { responsiveSize(18) }
    
    private var rankBadgeSize: CGSize {
        CGSize(
            width: responsiveSize(24),
            height: responsiveSize(24)
        )
    }
    
    private var rankBadgeFontSize: CGFloat { responsiveSize(11) }
    private var rankBadgeBorderWidth: CGFloat { responsiveSize(1) }
    
    // MARK: - 状态文本
    private var currentStatusText: String {
        switch chef.status {
        case .idle:
            return "待命中..."
        case .cooking:
            return currentStep.isEmpty ? "正在努力炒菜中..." : currentStep
        case .completed:
            return appState.getChefCompletedMessage(cuisine: chef.cuisine)
        case .error:
            return appState.getRandomErrorMessage()
        }
    }
    
    private func startCookingAnimation() {
        if chef.status == .cooking {
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
                currentStep = appState.getRandomCookingStep()
            }
        }
    }
}

#Preview {
    ChefCardView(
        chef: Chef(
            name: "辣椒王老张",
            cuisine: "湘菜",
            emoji: "🌶️",
            color: "text-red-600",
            status: .cooking
        ),
        completionOrder: -1,
        appState: AppState(),
        onDishClick: { _ in }
    )
}
