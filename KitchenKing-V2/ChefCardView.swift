//
//  ChefCardView.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

// 导入SwiftUI框架，用于构建用户界面
import SwiftUI
// 如果是iOS平台，导入UIKit框架
#if os(iOS)
import UIKit
#endif

// 定义厨师卡片视图结构体，遵循View协议
struct ChefCardView: View {
    // 厨师数据模型
    let chef: Chef
    // 完成订单的排名
    let completionOrder: Int
    // 应用状态观察对象
    @ObservedObject var appState: AppState
    // 菜品点击回调函数
    let onDishClick: (Dish) -> Void
    // 当前烹饪步骤的私有状态变量
    @State private var currentStep = ""
    // 是否显示庆祝动画的私有状态变量
    @State private var showCelebration = false
    // 是否正在执行动画的私有状态变量
    @State private var isAnimating = false
    // 系统颜色方案的环境变量
    @Environment(\.colorScheme) private var colorScheme
    
    // 视图主体内容
    var body: some View {
        // ZStack用于堆叠多个视图
        ZStack {
            // 主卡片内容
            mainCardContent
            
            // 外部装饰元素
            externalElementsView
        }
        // 监听厨师状态变化
        .onChange(of: chef.status) { _, newStatus in
            // 处理状态变化
            handleStatusChange(newStatus)
        }
        // 视图出现时执行
        .onAppear {
            // 如果厨师正在烹饪，启动动画
            if chef.status == .cooking {
                isAnimating = true
            }
        }
    }
    
    // MARK: - 主要内容
    // 主卡片内容的计算属性
    private var mainCardContent: some View {
        // 垂直堆叠视图，指定间距
        VStack(spacing: layoutSpacing) {
            // 水平堆叠视图，指定间距
            HStack(spacing: cardSpacing) {
                // 厨师头像区域
                chefAvatarSection
                
                // 垂直堆叠视图，左对齐，指定间距
                VStack(alignment: .leading, spacing: contentSpacing) {
                    // 厨师信息区域
                    chefInfoSection
                    
                    // 状态或菜品区域
                    statusOrDishSection
                    
                    // 弹性空间填充器
                    Spacer()
                }
                // 设置最大宽度为无限大
                .frame(maxWidth: .infinity)
            }
            // 设置垂直内边距
            .padding(.vertical, verticalPadding)
            
            // 如果厨师已完成且有菜品，显示菜品信息条
            if chef.status == .completed, let dish = chef.dish {
                dishInfoBar(dish: dish)
            }
            
        }
        // 设置内边距
        .padding(paddingValues)
        // 设置垂直内边距，使用响应式尺寸
        .padding(.vertical, responsiveSize(8))
        // 设置卡片背景样式
        .background(cardStyle)
        // 设置庆祝动画的缩放效果
        .scaleEffect(celebrationScale)
        // 添加弹簧动画效果
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showCelebration)
    }
    
    // MARK: - 卡片样式
    // 卡片样式的计算属性
    private var cardStyle: some View {
        // 矩形形状
        Rectangle()
            // 填充背景颜色
            .fill(cardBackgroundColor)
            // 添加覆盖层边框
            .overlay(
                Rectangle()
                    // 描边黑色边框
                    .stroke(.black, lineWidth: 1)
            )
            // 添加阴影效果
            .shadow(color: cardShadowColor, radius: cardShadowRadius, x: cardShadowX, y: cardShadowY)
    }
    
    // MARK: - 子视图组件
    // 厨师头像区域的计算属性
    private var chefAvatarSection: some View {
        // 堆叠视图
        ZStack {
            // 头像图片
            avatarImage
                // 设置头像尺寸
                .frame(width: avatarSize, height: avatarSize)
                // 裁剪为圆角矩形
                .clipShape(RoundedRectangle(cornerRadius: 4))
                // 添加阴影效果
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                // 设置烹饪动画的垂直偏移
                .offset(y: cookingAnimationOffset)
                // 添加烹饪动画
                .animation(cookingAnimation, value: isAnimating)
            
            // 状态徽章
            statusBadge
                // 设置徽章偏移位置
                .offset(x: badgeOffset.width, y: badgeOffset.height)
        }
        // 设置头像区域尺寸
        .frame(width: avatarSize, height: avatarSize)
    }
    
    // 头像图片的计算属性
    private var avatarImage: some View {
        // 从资源中加载图片
        Image(chef.imageName)
            // 设置可调整大小
            .resizable()
            // 保持宽高比
            .aspectRatio(contentMode: .fit)
            // 设置固定尺寸
            .frame(width: 50, height: 50)
            // 裁剪为圆角矩形
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    // 状态徽章的计算属性
    private var statusBadge: some View {
        // 堆叠视图
        ZStack {
            // 圆角矩形背景
            RoundedRectangle(cornerRadius: 4)
                // 填充状态徽章颜色
                .fill(statusBadgeColor)
                // 设置徽章尺寸
                .frame(width: statusBadgeSize, height: statusBadgeSize)
                // 添加白色边框覆盖层
                .overlay(
                    Rectangle()
                        // 描边白色边框
                        .stroke(.white, lineWidth: statusBadgeBorderWidth)
                )
                // 设置烹饪动画的缩放效果
                .scaleEffect(cookingAnimationScale)
                // 添加烹饪动画
                .animation(cookingAnimation, value: isAnimating)
            
            // 系统图标
            Image(systemName: statusBadgeIcon)
                // 设置图标字体
                .font(.system(size: statusBadgeIconSize, weight: .semibold))
                // 设置图标颜色为白色
                .foregroundColor(.white)
        }
        // 添加阴影效果
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // 厨师信息区域的计算属性
    private var chefInfoSection: some View {
        // 水平堆叠视图，居中对齐，指定间距
        HStack(alignment: .center, spacing: 8) {
            // 厨师姓名文本
            chefNameText
            
            // 弹性空间填充器
            Spacer()
            
            // 菜系标签
            cuisineTag
        }
    }
    
    // 厨师姓名文本的计算属性
    private var chefNameText: some View {
        // 显示厨师姓名的文本
        Text(chef.name)
            // 设置字体样式
            .font(.system(size: chefNameFontSize, weight: .bold, design: .rounded))
            // 设置文本颜色为主要颜色
            .foregroundColor(.primary)
            // 限制显示行数为1行
            .lineLimit(1)
    }
    
    // 菜系标签的计算属性
    private var cuisineTag: some View {
        // 显示菜系名称的文本
        Text(chef.cuisine)
            // 设置字体样式
            .font(.system(size: cuisineTagFontSize, weight: .semibold))
            // 设置文本颜色为白色
            .foregroundColor(.white)
            // 设置水平内边距
            .padding(.horizontal, cuisineTagHorizontalPadding)
            // 设置垂直内边距
            .padding(.vertical, cuisineTagVerticalPadding)
            // 设置背景色
            .background(
                Rectangle()
                    // 填充黑色背景
                    .fill(.black)
            )
    }
    
    // 状态或菜品区域的计算属性
    private var statusOrDishSection: some View {
        // 分组视图
        Group {
            // 根据厨师状态显示不同内容
            switch chef.status {
            case .cooking:
                // 制作中：显示cookingSteps
                cookingStepsSection
            case .completed:
                // 已完成：显示completedMessages
                completedMessageSection
            case .error:
                // 失败：显示errorMessages
                errorMessageSection
            case .idle:
                // 待命中：显示状态信息
                statusSection
            }
        }
    }
    
    // 菜品信息区域的函数
    private func dishInfoSection(dish: Dish) -> some View {
        // 垂直堆叠视图，左对齐，指定间距
        VStack(alignment: .leading, spacing: dishInfoSpacing) {
            // 菜品名称文本
            dishNameText(dish: dish)
        }
    }
    
    // 菜品名称文本的函数
    private func dishNameText(dish: Dish) -> some View {
        // 显示菜品名称的文本
        Text(dish.dishName)
            // 设置字体样式
            .font(.system(size: dishNameFontSize, weight: .semibold))
            // 设置文本颜色为主要颜色
            .foregroundColor(.primary)
            // 限制显示行数
            .lineLimit(dishNameLineLimit)
            // 设置多行文本对齐方式为左对齐
            .multilineTextAlignment(.leading)
            // 添加点击手势
            .onTapGesture {
                // 调用菜品点击回调
                onDishClick(dish)
            }
            // 设置内容形状为矩形，用于点击区域
            .contentShape(Rectangle())
    }
    
    // 状态区域的计算属性
    private var statusSection: some View {
        // 垂直堆叠视图，左对齐，指定间距
        VStack(alignment: .leading, spacing: statusSectionSpacing) {
            // 状态文本
            statusText
            
            // 如果有烹饪步骤，显示烹饪步骤文本
            if let cookingStep = chef.cookingStep {
                cookingStepText
            }
        }
    }
    
    // 状态文本的计算属性
    private var statusText: some View {
        // 水平堆叠视图，指定间距
        HStack(spacing: 8) {
            // 显示当前状态文本
            Text(currentStatusText)
                // 设置字体样式
                .font(.system(size: statusFontSize, weight: .semibold))
                // 设置文本颜色为灰色
                .foregroundColor(.secondary)
                // 限制显示行数为1行
                .lineLimit(1)
        }
    }
    
    // 烹饪步骤文本的计算属性
    private var cookingStepText: some View {
        // 显示当前烹饪步骤的文本
        Text(chef.cookingStep ?? "")
            // 设置字体样式
            .font(.system(size: cookingStepFontSize, weight: .medium))
            // 设置文本颜色为次要颜色
            .foregroundColor(.secondary)
            // 限制显示行数
            .lineLimit(cookingStepLineLimit)
            // 设置多行文本对齐方式为左对齐
            .multilineTextAlignment(.leading)
            // 设置固定尺寸，垂直方向可扩展
            .fixedSize(horizontal: false, vertical: true)
    }
    
    // 制作中步骤区域的计算属性
    private var cookingStepsSection: some View {
        // 垂直堆叠视图，左对齐，指定间距
        VStack(alignment: .leading, spacing: statusSectionSpacing) {
            // 状态文本
            statusText
        }
    }
    
    // 完成消息区域的计算属性
    private var completedMessageSection: some View {
        // 垂直堆叠视图，左对齐，指定间距
        VStack(alignment: .leading, spacing: statusSectionSpacing) {
            // 状态文本
            statusText
        }
    }
    
    // 错误消息区域的计算属性
    private var errorMessageSection: some View {
        // 垂直堆叠视图，左对齐，指定间距
        VStack(alignment: .leading, spacing: statusSectionSpacing) {
            // 状态文本
            statusText
            
        }
    }
    
    // 菜品信息条的函数
    private func dishInfoBar(dish: Dish) -> some View {
        // 水平堆叠视图，指定间距
        HStack(spacing: dishBarSpacing) {
            // 菜品名称文本
            Text(dish.dishName)
                // 设置字体样式
                .font(.system(size: dishBarFontSize, weight: .semibold))
                // 设置文本颜色为主要颜色
                .foregroundColor(.primary)
                // 限制显示行数为1行
                .lineLimit(1)
                // 添加点击手势
                .onTapGesture {
                    // 调用菜品点击回调
                    onDishClick(dish)
                }
        }
        // 设置水平内边距
        .padding(.horizontal, dishBarHorizontalPadding)
    }
    
    // MARK: - 外部装饰元素
    // 外部装饰元素的计算属性
    private var externalElementsView: some View {
        // 分组视图
        Group {
            // 奖牌角标 - 如果排名是前三名
            if completionOrder >= 0 && completionOrder < 3 {
                medalBadge
            }
            
            // 排名角标 - 如果排名是第四名及以后
            if completionOrder >= 3 {
                rankBadge(rank: completionOrder + 1)
            }
        }
    }
    
    // 奖牌角标的计算属性
    private var medalBadge: some View {
        // 垂直堆叠视图
        VStack {
            // 水平堆叠视图
            HStack {
                // 弹性空间填充器
                Spacer()
                // 奖牌内容
                medalBadgeContent
                    // 设置右侧内边距
                    .padding(.trailing, medalBadgeTrailingPadding)
            }
            // 弹性空间填充器
            Spacer()
        }
    }
    
    // 奖牌内容的计算属性
    private var medalBadgeContent: some View {
        // 显示奖牌表情符号的文本
        Text(medalEmoji)
            // 设置字体大小
            .font(.system(size: medalEmojiFontSize))
            // 设置庆祝动画的缩放效果
            .scaleEffect(showCelebration ? 1.2 : 1.0)
            // 添加弹簧动画效果
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showCelebration)
            // 添加阴影效果
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // 排名角标的函数
    private func rankBadge(rank: Int) -> some View {
        // 垂直堆叠视图
        VStack {
            // 水平堆叠视图
            HStack {
                // 排名内容
                rankBadgeContent(rank: rank)
                    // 设置左侧内边距
                    .padding(.leading, rankBadgeLeadingPadding)
                // 弹性空间填充器
                Spacer()
            }
            // 弹性空间填充器
            Spacer()
        }
    }
    
    // 排名内容的函数
    private func rankBadgeContent(rank: Int) -> some View {
        // 堆叠视图
        ZStack {
            // 圆角矩形背景
            RoundedRectangle(cornerRadius: rankBadgeCornerRadius)
                // 填充排名徽章背景颜色
                .fill(rankBadgeBackgroundColor)
                // 设置徽章尺寸
                .frame(width: rankBadgeSize.width, height: rankBadgeSize.height)
                // 添加边框覆盖层
                .overlay(
                    RoundedRectangle(cornerRadius: rankBadgeCornerRadius)
                        // 描边排名徽章边框颜色
                        .stroke(rankBadgeBorderColor, lineWidth: rankBadgeBorderWidth)
                )
            
            // 显示排名数字的文本
            Text("\(rank)")
                // 设置字体样式
                .font(.system(size: rankBadgeFontSize, weight: .bold))
                // 设置文本颜色为排名徽章文本颜色
                .foregroundColor(rankBadgeTextColor)
        }
        // 添加阴影效果
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - 辅助方法
    // 处理状态变化的函数
    private func handleStatusChange(_ newStatus: Chef.ChefStatus) {
        // 如果新状态是完成且未显示庆祝动画，触发庆祝动画
        if newStatus == .completed && !showCelebration {
            triggerCelebration()
        }
        
        // 如果新状态是烹饪且未在动画中，启动动画
        if newStatus == .cooking && !isAnimating {
            isAnimating = true
        } else if newStatus != .cooking && isAnimating {
            // 如果新状态不是烹饪且正在动画中，停止动画
            isAnimating = false
        }
    }
    
    // 触发庆祝动画的函数
    private func triggerCelebration() {
        // 设置显示庆祝动画
        showCelebration = true
        
        // 2秒后恢复（使用主队列异步执行）
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // 隐藏庆祝动画
            showCelebration = false
        }
    }
    
    // MARK: - 计算属性
    
    // 状态徽章颜色的计算属性
    private var statusBadgeColor: Color {
        // 根据厨师状态返回对应的徽章颜色
        switch chef.status {
        case .idle: return .gray        // 待命状态：灰色
        case .cooking: return .orange    // 烹饪状态：橙色
        case .completed: return .green   // 完成状态：绿色
        case .error: return .red        // 错误状态：红色
        }
    }
    
    // 状态徽章图标的计算属性
    private var statusBadgeIcon: String {
        // 根据厨师状态返回对应的系统图标名称
        switch chef.status {
        case .idle: return "pause.fill"        // 待命状态：暂停图标
        case .cooking: return "flame.fill"      // 烹饪状态：火焰图标
        case .completed: return "checkmark.fill" // 完成状态：对勾图标
        case .error: return "xmark.fill"        // 错误状态：叉号图标
        }
    }
    
    // 是否应该执行动画的计算属性
    private var shouldAnimate: Bool {
        // 当厨师状态为烹饪时返回true
        chef.status == .cooking
    }
    
    // 烹饪动画的计算属性
    private var cookingAnimation: Animation {
        // 如果应该执行动画，返回缓入缓出重复动画，否则返回默认动画
        shouldAnimate ?
            .easeInOut(duration: 1.0).repeatForever() : .default
    }
    
    // 烹饪动画缩放比例的计算属性
    private var cookingAnimationScale: CGFloat {
        // 如果是烹饪状态，根据动画状态返回不同的缩放比例，否则返回1.0
        chef.status == .cooking ? (isAnimating ? 1.1 : 1.0) : 1.0
    }
    
    // 烹饪动画偏移量的计算属性
    private var cookingAnimationOffset: CGFloat {
        // 如果是烹饪状态，根据动画状态返回不同的垂直偏移量，否则返回0
        chef.status == .cooking ? (isAnimating ? -2 : 2) : 0
    }
    
    // 庆祝动画缩放比例的计算属性
    private var celebrationScale: CGFloat {
        // 如果正在显示庆祝动画，返回1.02的缩放比例，否则返回1.0
        showCelebration ? 1.02 : 1.0
    }
    
    // MARK: - 颜色和样式
    // 卡片背景颜色的计算属性
    private var cardBackgroundColor: Color {
        // 根据颜色方案返回不同的背景颜色
        colorScheme == .dark ? Color.gray.opacity(0.1) : .white
    }
    
    // 卡片阴影颜色的计算属性
    private var cardShadowColor: Color {
        // 返回黑色半透明阴影
        .black.opacity(0.1)
    }
    
    // 菜品信息条背景颜色的计算属性
    private var dishBarBackgroundColor: Color {
        // 根据颜色方案返回不同的菜品信息条背景颜色
        colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1)
    }
    
    // 奖牌表情符号的计算属性
    private var medalEmoji: String {
        // 根据完成排名返回对应的奖牌表情符号
        switch completionOrder {
        case 0: return "🥇"    // 第一名：金牌
        case 1: return "🥈"    // 第二名：银牌
        case 2: return "🥉"    // 第三名：铜牌
        default: return ""      // 其他排名：无奖牌
        }
    }
    
    // 排名徽章背景颜色的计算属性
    private var rankBadgeBackgroundColor: Color {
        // 返回黑色背景
        .black
    }
    
    // 排名徽章边框颜色的计算属性
    private var rankBadgeBorderColor: Color {
        // 返回黑色边框
        .black
    }
    
    // 排名徽章文本颜色的计算属性
    private var rankBadgeTextColor: Color {
        // 返回白色文本
        .white
    }
    
    // MARK: - 响应式尺寸计算
    // 响应式尺寸计算的函数
    private func responsiveSize(_ baseSize: CGFloat, scale: CGFloat = 1.0) -> CGFloat {
        // 如果是iOS平台
        #if os(iOS)
        // 获取屏幕宽度
        let screenWidth = UIScreen.main.bounds.width
        // 根据屏幕宽度计算缩放因子
        let scaleFactor: CGFloat = screenWidth < 375 ? 0.85 : (screenWidth > 414 ? 1.15 : 1.0)
        #else
        // 非iOS平台使用默认缩放因子
        let scaleFactor: CGFloat = 1.0
        #endif
        // 返回计算后的尺寸
        return baseSize * scaleFactor * scale
    }
    
    // MARK: - 布局尺寸
    // 布局间距的计算属性
    private var layoutSpacing: CGFloat { responsiveSize(12) }
    // 卡片间距的计算属性
    private var cardSpacing: CGFloat { responsiveSize(16) }
    // 内容间距的计算属性
    private var contentSpacing: CGFloat { responsiveSize(8) }
    // 菜品信息间距的计算属性
    private var dishInfoSpacing: CGFloat { responsiveSize(4) }
    // 状态区域间距的计算属性
    private var statusSectionSpacing: CGFloat { responsiveSize(4) }
    // 菜品信息条间距的计算属性
    private var dishBarSpacing: CGFloat { responsiveSize(6) }
    
    // MARK: - 内边距
    // 内边距值的计算属性
    private var paddingValues: EdgeInsets {
        // 创建内边距结构体
        EdgeInsets(
            top: responsiveSize(8),         // 顶部内边距
            leading: responsiveSize(16),     // 左侧内边距
            bottom: responsiveSize(8),      // 底部内边距
            trailing: responsiveSize(16)    // 右侧内边距
        )
    }
    
    // 垂直内边距的计算属性
    private var verticalPadding: CGFloat { responsiveSize(12) }
    // 菜品信息条水平内边距的计算属性
    private var dishBarHorizontalPadding: CGFloat { responsiveSize(12) }
    // 菜品信息条垂直内边距的计算属性
    private var dishBarVerticalPadding: CGFloat { responsiveSize(8) }
    // 奖牌徽章右侧内边距的计算属性
    private var medalBadgeTrailingPadding: CGFloat { responsiveSize(12) }
    // 排名徽章左侧内边距的计算属性
    private var rankBadgeLeadingPadding: CGFloat { responsiveSize(12) }
    // 菜系标签水平内边距的计算属性
    private var cuisineTagHorizontalPadding: CGFloat { responsiveSize(8) }
    // 菜系标签垂直内边距的计算属性
    private var cuisineTagVerticalPadding: CGFloat { responsiveSize(4) }
    
    // MARK: - 头像尺寸
    // 头像尺寸的计算属性
    private var avatarSize: CGFloat { responsiveSize(60) }
    
    // MARK: - 状态徽章尺寸
    // 状态徽章尺寸的计算属性
    private var statusBadgeSize: CGFloat { responsiveSize(15) }
    // 状态徽章边框宽度的计算属性
    private var statusBadgeBorderWidth: CGFloat { responsiveSize(1.5) }
    // 状态徽章图标尺寸的计算属性
    private var statusBadgeIconSize: CGFloat { responsiveSize(10) }
    // 徽章偏移量的计算属性
    private var badgeOffset: CGSize {
        // 创建尺寸结构体
        CGSize(
            width: responsiveSize(25),   // 宽度偏移
            height: responsiveSize(25)   // 高度偏移
        )
    }
    
    // MARK: - 字体尺寸
    // 厨师姓名字体尺寸的计算属性
    private var chefNameFontSize: CGFloat { responsiveSize(18) }
    // 菜品名称字体尺寸的计算属性
    private var dishNameFontSize: CGFloat { responsiveSize(16) }
    // 状态字体尺寸的计算属性
    private var statusFontSize: CGFloat { responsiveSize(14) }
    // 烹饪步骤字体尺寸的计算属性
    private var cookingStepFontSize: CGFloat { responsiveSize(12) }
    // 菜品信息条图标尺寸的计算属性
    private var dishBarIconSize: CGFloat { responsiveSize(11) }
    // 菜品信息条字体尺寸的计算属性
    private var dishBarFontSize: CGFloat { responsiveSize(15) }
    // 菜系标签字体尺寸的计算属性
    private var cuisineTagFontSize: CGFloat { responsiveSize(10) }
    
    // MARK: - 加载指示器
    // 加载指示器缩放比例的计算属性
    private var loadingIndicatorScale: CGFloat { responsiveSize(0.6) }
    
    // MARK: - 行限制
    // 菜品名称行限制的计算属性
    private var dishNameLineLimit: Int { 2 }
    // 烹饪步骤行限制的计算属性
    private var cookingStepLineLimit: Int { 2 }
    
    // MARK: - 圆角
    // 菜品信息条圆角半径的计算属性
    private var dishBarCornerRadius: CGFloat { responsiveSize(6) }
    // 排名徽章圆角半径的计算属性
    private var rankBadgeCornerRadius: CGFloat { responsiveSize(4) }
    
    // MARK: - 阴影
    // 卡片阴影半径的计算属性
    private var cardShadowRadius: CGFloat { responsiveSize(4) }
    // 卡片阴影X偏移的计算属性
    private var cardShadowX: CGFloat { responsiveSize(0) }
    // 卡片阴影Y偏移的计算属性
    private var cardShadowY: CGFloat { responsiveSize(2) }
    
    // MARK: - 奖牌尺寸
    // 奖牌表情符号字体尺寸的计算属性
    private var medalEmojiFontSize: CGFloat { responsiveSize(18) }
    
    // 排名徽章尺寸的计算属性
    private var rankBadgeSize: CGSize {
        // 创建尺寸结构体
        CGSize(
            width: responsiveSize(24),   // 宽度
            height: responsiveSize(24)   // 高度
        )
    }
    
    // 排名徽章字体尺寸的计算属性
    private var rankBadgeFontSize: CGFloat { responsiveSize(11) }
    // 排名徽章边框宽度的计算属性
    private var rankBadgeBorderWidth: CGFloat { responsiveSize(1) }
    
    // MARK: - 状态文本
    // 当前状态文本的计算属性
    private var currentStatusText: String {
        // 根据厨师状态返回对应的文本
        switch chef.status {
        case .idle:
            return "待命中..."    // 待命状态文本
        case .cooking:
            // 烹饪状态文本，如果有当前步骤则显示步骤，否则显示默认文本
            return appState.getRandomCookingStep()
        case .completed:
            // 完成状态文本，从应用状态获取对应菜系的完成消息
            return appState.getChefCompletedMessage(cuisine: chef.cuisine)
        case .error:
            // 错误状态文本，从应用状态获取随机错误消息
            return appState.getRandomErrorMessage()
        }
    }
    
    // 开始烹饪动画的函数
    private func startCookingAnimation() {
        // 如果厨师正在烹饪状态
        if chef.status == .cooking {
            // 创建定时器，每1.5秒重复执行
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
                // 从应用状态获取随机烹饪步骤并更新当前步骤
                currentStep = appState.getRandomCookingStep()
            }
        }
    }
}

#Preview {
    // 预览视图
    ScrollView(.vertical, showsIndicators: false) {
        // 垂直堆叠视图，间距为20
        VStack(spacing: 20) {
            // 标题文本
            Text("ChefCardView 状态预览")
                // 设置标题字体样式
                .font(.system(size: 24, weight: .bold, design: .rounded))
                // 设置顶部内边距
                .padding(.top, 20)
            
            // Idle 状态预览
            VStack(alignment: .leading, spacing: 8) {
                // 状态标签
                Text("待命状态 (Idle)")
                    // 设置标签字体样式
                    .font(.system(size: 16, weight: .semibold))
                    // 设置标签颜色为次要颜色
                    .foregroundColor(.secondary)
                
                // 待命状态的厨师卡片实例
                ChefCardView(
                    // 创建待命状态的厨师实例
                    chef: Chef(
                        name: "辣椒王老张",        // 厨师姓名
                        cuisine: "湘菜",          // 菜系
                        imageName: "湘菜",        // 头像图片名称
                        color: "text-red-600",    // 主题颜色
                        status: .idle             // 状态为待命
                    ),
                    completionOrder: -1,          // 完成排名（-1表示未完成）
                    appState: AppState(),         // 应用状态实例
                    onDishClick: { _ in }          // 空的菜品点击回调
                )
            }
            
            // Cooking 状态预览
            VStack(alignment: .leading, spacing: 8) {
                // 状态标签
                Text("烹饪状态 (Cooking)")
                    // 设置标签字体样式
                    .font(.system(size: 16, weight: .semibold))
                    // 设置标签颜色为次要颜色
                    .foregroundColor(.secondary)
                
                // 烹饪状态的厨师卡片实例
                ChefCardView(
                    // 创建烹饪状态的厨师实例
                    chef: Chef(
                        name: "川菜大师李师傅",    // 厨师姓名
                        cuisine: "川菜",          // 菜系
                        imageName: "川菜",        // 头像图片名称
                        color: "text-red-600",    // 主题颜色
                        status: .cooking,         // 状态为烹饪中
                    ),
                    completionOrder: -1,          // 完成排名（-1表示未完成）
                    appState: AppState(),         // 应用状态实例
                    onDishClick: { _ in }          // 空的菜品点击回调
                )
            }
            
            // Completed 状态 - 第一名预览
            VStack(alignment: .leading, spacing: 8) {
                // 状态标签
                Text("完成状态 - 第一名 (Completed - 1st)")
                    // 设置标签字体样式
                    .font(.system(size: 16, weight: .semibold))
                    // 设置标签颜色为次要颜色
                    .foregroundColor(.secondary)
                
                // 第一名完成状态的厨师卡片实例
                ChefCardView(
                    // 创建完成状态的厨师实例（第一名）
                    chef: Chef(
                        name: "粤菜王陈师傅",      // 厨师姓名
                        cuisine: "粤菜",          // 菜系
                        imageName: "粤菜",        // 头像图片名称
                        color: "text-red-600",    // 主题颜色
                        status: .completed,        // 状态为已完成
                        dish: Dish(               // 创建菜品实例
                            dishName: "白切鸡",     // 菜品名称
                            ingredients: Dish.Ingredients(
                                main: ["鸡肉"],     // 主要食材
                                auxiliary: ["葱姜"], // 辅助食材
                                seasoning: ["盐", "生抽"] // 调料
                            ),
                            steps: [                 // 烹饪步骤
                                CookingStep(step: 1, title: "准备食材", details: ["鸡肉处理干净"]),
                                CookingStep(step: 2, title: "烹饪", details: ["水煮鸡肉"])
                            ],
                            tips: ["火候要掌握好"], // 烹饪小贴士
                            flavorProfile: FlavorProfile(taste: "鲜美", specialEffect: "清爽"), // 风味描述
                            disclaimer: "请按口味调整" // 免责声明
                        ),
                        completionOrder: 0           // 完成排名（第一名）
                    ),
                    completionOrder: 0,               // 完成排名（第一名）
                    appState: AppState(),            // 应用状态实例
                    onDishClick: { _ in }             // 空的菜品点击回调
                )
            }
            
            // Completed 状态 - 第二名预览
            VStack(alignment: .leading, spacing: 8) {
                // 状态标签
                Text("完成状态 - 第二名 (Completed - 2nd)")
                    // 设置标签字体样式
                    .font(.system(size: 16, weight: .semibold))
                    // 设置标签颜色为次要颜色
                    .foregroundColor(.secondary)
                
                // 第二名完成状态的厨师卡片实例
                ChefCardView(
                    // 创建完成状态的厨师实例（第二名）
                    chef: Chef(
                        name: "法国菜皮埃尔",      // 厨师姓名
                        cuisine: "法国菜",        // 菜系
                        imageName: "法国菜",      // 头像图片名称
                        color: "text-red-600",    // 主题颜色
                        status: .completed,        // 状态为已完成
                        dish: Dish(               // 创建菜品实例
                            dishName: "法式洋葱汤", // 菜品名称
                            ingredients: Dish.Ingredients(
                                main: ["洋葱"],         // 主要食材
                                auxiliary: ["面包", "奶酪"], // 辅助食材
                                seasoning: ["盐", "黑胡椒"] // 调料
                            ),
                            steps: [                 // 烹饪步骤
                                CookingStep(step: 1, title: "准备食材", details: ["洋葱切丝"]),
                                CookingStep(step: 2, title: "烹饪", details: ["慢煮洋葱"])
                            ],
                            tips: ["洋葱要炒至焦糖色"], // 烹饪小贴士
                            flavorProfile: FlavorProfile(taste: "浓郁", specialEffect: "温暖"), // 风味描述
                            disclaimer: "正宗法式做法" // 免责声明
                        ),
                        completionOrder: 1           // 完成排名（第二名）
                    ),
                    completionOrder: 1,               // 完成排名（第二名）
                    appState: AppState(),            // 应用状态实例
                    onDishClick: { _ in }             // 空的菜品点击回调
                )
            }
            
            // Completed 状态 - 第三名预览
            VStack(alignment: .leading, spacing: 8) {
                // 状态标签
                Text("完成状态 - 第三名 (Completed - 3rd)")
                    // 设置标签字体样式
                    .font(.system(size: 16, weight: .semibold))
                    // 设置标签颜色为次要颜色
                    .foregroundColor(.secondary)
                
                // 第三名完成状态的厨师卡片实例
                ChefCardView(
                    // 创建完成状态的厨师实例（第三名）
                    chef: Chef(
                        name: "泰国菜阿雅",        // 厨师姓名
                        cuisine: "泰国菜",        // 菜系
                        imageName: "泰国菜",      // 头像图片名称
                        color: "text-red-600",    // 主题颜色
                        status: .completed,        // 状态为已完成
                        dish: Dish(               // 创建菜品实例
                            dishName: "冬阴功汤",   // 菜品名称
                            ingredients: Dish.Ingredients(
                                main: ["虾"],           // 主要食材
                                auxiliary: ["蘑菇", "柠檬草"], // 辅助食材
                                seasoning: ["鱼露", "辣椒"] // 调料
                            ),
                            steps: [                 // 烹饪步骤
                                CookingStep(step: 1, title: "准备食材", details: ["虾处理干净"]),
                                CookingStep(step: 2, title: "煮汤", details: ["加入香料煮制"])
                            ],
                            tips: ["酸辣平衡是关键"], // 烹饪小贴士
                            flavorProfile: FlavorProfile(taste: "酸辣", specialEffect: "开胃"), // 风味描述
                            disclaimer: "传统泰式风味" // 免责声明
                        ),
                        completionOrder: 2           // 完成排名（第三名）
                    ),
                    completionOrder: 2,               // 完成排名（第三名）
                    appState: AppState(),            // 应用状态实例
                    onDishClick: { _ in }             // 空的菜品点击回调
                )
            }
            
            // Completed 状态 - 第四名预览
            VStack(alignment: .leading, spacing: 8) {
                // 状态标签
                Text("完成状态 - 第四名 (Completed - 4th)")
                    // 设置标签字体样式
                    .font(.system(size: 16, weight: .semibold))
                    // 设置标签颜色为次要颜色
                    .foregroundColor(.secondary)
                
                // 第四名完成状态的厨师卡片实例
                ChefCardView(
                    // 创建完成状态的厨师实例（第四名）
                    chef: Chef(
                        name: "俄罗斯菜伊万",      // 厨师姓名
                        cuisine: "俄罗斯菜",      // 菜系
                        imageName: "俄罗斯菜",      // 头像图片名称
                        color: "text-red-600",    // 主题颜色
                        status: .completed,        // 状态为已完成
                        dish: Dish(               // 创建菜品实例
                            dishName: "罗宋汤",     // 菜品名称
                            ingredients: Dish.Ingredients(
                                main: ["牛肉"],         // 主要食材
                                auxiliary: ["卷心菜", "胡萝卜"], // 辅助食材
                                seasoning: ["盐", "胡椒粉"] // 调料
                            ),
                            steps: [                 // 烹饪步骤
                                CookingStep(step: 1, title: "准备食材", details: ["牛肉切块"]),
                                CookingStep(step: 2, title: "炖煮", details: ["慢炖至软烂"])
                            ],
                            tips: ["炖煮时间要充足"], // 烹饪小贴士
                            flavorProfile: FlavorProfile(taste: "浓郁", specialEffect: "温暖"), // 风味描述
                            disclaimer: "经典俄式家常菜" // 免责声明
                        ),
                        completionOrder: 3           // 完成排名（第四名）
                    ),
                    completionOrder: 3,               // 完成排名（第四名）
                    appState: AppState(),            // 应用状态实例
                    onDishClick: { _ in }             // 空的菜品点击回调
                )
            }
            
            // Error 状态预览
            VStack(alignment: .leading, spacing: 8) {
                // 状态标签
                Text("错误状态 (Error)")
                    // 设置标签字体样式
                    .font(.system(size: 16, weight: .semibold))
                    // 设置标签颜色为次要颜色
                    .foregroundColor(.secondary)
                
                // 错误状态的厨师卡片实例
                ChefCardView(
                    // 创建错误状态的厨师实例
                    chef: Chef(
                        name: "新手厨师小王",      // 厨师姓名
                        cuisine: "湘菜",        // 菜系
                        imageName: "湘菜",        // 头像图片名称
                        color: "text-red-600",    // 主题颜色
                        status: .error,           // 状态为错误
                        cookingStep: "太难了，做不出来！" // 错误步骤描述
                    ),
                    completionOrder: -1,          // 完成排名（-1表示未完成）
                    appState: AppState(),         // 应用状态实例
                    onDishClick: { _ in }          // 空的菜品点击回调
                )
            }
            
            // 弹性空间填充器，最小长度为40
            Spacer(minLength: 40)
        }
        // 设置水平内边距
        .padding(.horizontal, 20)
    }
}
