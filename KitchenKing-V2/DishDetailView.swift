//
//  DishDetailView.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

import SwiftUI

struct DishDetailView: View {
    let dish: Dish
    let onClose: () -> Void
    let theme: DetailTheme = .modern
    
    @State private var scrollOffset: CGFloat = 0
    @State private var showContent = false
    
    enum DetailTheme {
        case modern    // 现代主题：动画效果，现代布局
    }
    
    var body: some View {
        ZStack {
            // 背景蒙层
            backgroundOverlay
            
            // 主内容
            mainContent
        }
        .onAppear {
            showContent = true
        }
    }
    
    // MARK: - 背景蒙层
    private var backgroundOverlay: some View {
        Color.black.opacity(backgroundOpacity)
            .ignoresSafeArea()
            .onTapGesture {
                dismissView()
            }
    }
    
    // MARK: - 主内容
    private var mainContent: some View {
        modernContent
    }
    
    private var modernContent: some View {
        VStack(spacing: 0) {
            // 顶部控制栏
            topControlBar
            
            // 详情内容
            ScrollView {
                detailContent
                    .padding(.horizontal, detailPadding)
                    .padding(.bottom, detailBottomPadding)
            }
        }
        .background(contentBackground)
        .clipShape(Rectangle())
        .padding(contentPadding)
        .scaleEffect(showContent ? 1.0 : 0.8)
        .opacity(showContent ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showContent)
    }
    
    private var topControlBar: some View {
        HStack {
            Spacer()
            Button(action: dismissView) {
                ZStack {
                    Rectangle()
                        .fill(.white)
                        .frame(width: closeButtonSize, height: closeButtonSize)
                        .overlay(
                            Rectangle()
                                .stroke(.black, lineWidth: 2)
                        )
                    
                    Image(systemName: "xmark")
                        .font(.system(size: closeIconSize, weight: .bold))
                        .foregroundColor(.black)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
    
    // MARK: - 详情内容
    private var detailContent: some View {
        VStack(spacing: contentSpacing) {
            // 菜品标题
            dishTitleSection
            
            // 食材清单
            ingredientsSection
            
            // 制作步骤
            stepsSection
            
            // 烹饪技巧
            tipsSection
            
            // 口味描述
            flavorSection
            
            // 免责声明
            if let disclaimer = dish.disclaimer {
                disclaimerSection(disclaimer)
            }
        }
    }
    
    // MARK: - 子视图组件
    private var dishTitleSection: some View {
        VStack(spacing: titleSpacing) {
            // 菜品图标
            dishIcon
            
            Text(dish.dishName)
                .font(.system(size: titleFontSize, weight: .black))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var dishIcon: some View {
        ZStack {
            Rectangle()
                .fill(.white)
                .frame(width: 80, height: 80)
                .overlay(
                    Rectangle()
                        .stroke(.black, lineWidth: 3)
                )
            
            Image(systemName: "fork.knife")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
        }
    }
    
    private var dividerView: some View {
        Rectangle()
            .fill(Color.black)
            .frame(height: 2)
            .frame(maxWidth: 80)
    }
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("🥘 食材清单")
            
            VStack(spacing: 6) {
                ingredientCategory("主要食材", ingredients: dish.ingredients.main, color: .red)
                ingredientCategory("辅助食材", ingredients: dish.ingredients.auxiliary, color: .blue)
                ingredientCategory("调料", ingredients: dish.ingredients.seasoning, color: .green)
            }
        }
    }
    
    private func ingredientCategory(_ title: String, ingredients: [String], color: Color = .black) -> some View {
        VStack(alignment: .leading, spacing: categorySpacing) {
            HStack {
                Rectangle()
                    .fill(.black)
                    .frame(width: 8, height: 8)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: gridSpacing) {
                ForEach(ingredients, id: \.self) { ingredient in
                    ingredientRow(ingredient)
                }
            }
        }
        .padding(categoryPadding)
        .background(categoryBackground)
    }
    
    private func ingredientRow(_ ingredient: String) -> some View {
        HStack {
            Text("• \(ingredient)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            Spacer()
        }
    }
    
    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("👨‍🍳 制作步骤")
            
            VStack(spacing: 8) {
                ForEach(dish.steps, id: \.id) { step in
                    stepView(step: step)
                }
            }
        }
    }
    
    private func stepView(step: CookingStep) -> some View {
        HStack(alignment: .top, spacing: stepSpacing) {
            // 步骤序号
            stepNumberView(step.step)
            
            // 步骤内容
            VStack(alignment: .leading, spacing: 8) {
                Text(step.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(step.details, id: \.self) { detail in
                        stepDetailRow(detail)
                    }
                }
            }
            
            Spacer()
        }
        .padding(stepPadding)
        .background(stepBackground)
    }
    
    private func stepNumberView(_ stepNumber: Int) -> some View {
        ZStack {
            Rectangle()
                .fill(.black)
                .frame(width: 32, height: 32)
                .overlay(
                    Rectangle()
                        .stroke(.black, lineWidth: 2)
                )
            
            Text("\(stepNumber)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    private func stepDetailRow(_ detail: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Rectangle()
                .fill(.black)
                .frame(width: 4, height: 4)
                .padding(.top, 6)
            
            Text(detail)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
    
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("💡 烹饪技巧")
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(dish.tips, id: \.self) { tip in
                    HStack(alignment: .top, spacing: 6) {
                        Text("•")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Text(tip)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                }
            }
            .padding(8)
            .background(
                Rectangle()
                    .fill(Color.yellow.opacity(0.1))
                    .overlay(
                        Rectangle()
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    private var flavorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("🎯 口味特色")
            
            VStack(alignment: .leading, spacing: 6) {
                Text(dish.flavorProfile.taste)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                    .padding(8)
                    .background(
                        Rectangle()
                            .fill(Color.purple.opacity(0.1))
                            .overlay(
                                Rectangle()
                                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                            )
                    )
                
                if let specialEffect = dish.flavorProfile.specialEffect {
                    HStack {
                        Text("✨")
                        Text(specialEffect)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.purple)
                    }
                    .padding(6)
                    .background(
                        Rectangle()
                            .fill(Color.purple.opacity(0.05))
                            .overlay(
                                Rectangle()
                                    .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
    
    private func disclaimerSection(_ disclaimer: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("温馨提示")
            
            Text(disclaimer)
                .font(.system(size: disclaimerFontSize, weight: .medium))
                .foregroundColor(.primary)
                .padding(16)
                .background(
                    Rectangle()
                        .fill(.white)
                        .overlay(
                            Rectangle()
                                .stroke(.black, lineWidth: 1)
                        )
                )
        }
    }
    
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.black)
    }
    
    // MARK: - 背景样式
    private var contentBackground: some View {
        Rectangle()
            .fill(.white)
            .overlay(
                Rectangle()
                    .stroke(.black, lineWidth: 3)
            )
    }
    
    private var categoryBackground: some View {
        Rectangle()
            .fill(.white)
            .overlay(
                Rectangle()
                    .stroke(.black, lineWidth: 1)
            )
    }
    
    private var stepBackground: some View {
        Rectangle()
            .fill(.white)
            .overlay(
                Rectangle()
                    .stroke(.black.opacity(0.3), lineWidth: 1)
            )
    }
    
    // MARK: - 辅助方法
    private func dismissView() {
        showContent = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onClose()
        }
    }
    
    // MARK: - 布局配置
    private var backgroundOpacity: Double {
        0.4
    }
    
    private var closeButtonSize: CGFloat {
        40
    }
    
    private var closeIconSize: CGFloat {
        16
    }
    
    private var contentSpacing: CGFloat {
        24
    }
    
    private var titleSpacing: CGFloat {
        16
    }
    
    private var titleFontSize: CGFloat {
        24
    }
    
    private var detailPadding: CGFloat {
        24
    }
    
    private var detailBottomPadding: CGFloat {
        40
    }
    
    private var contentPadding: EdgeInsets {
        EdgeInsets(top: 80, leading: 20, bottom: 80, trailing: 20)
    }
    
    private var categorySpacing: CGFloat {
        12
    }
    
    private var categoryPadding: EdgeInsets {
        EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    }
    
    private var gridSpacing: CGFloat {
        8
    }
    
    private var stepSpacing: CGFloat {
        16
    }
    
    private var stepPadding: EdgeInsets {
        EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    }
    
    private var disclaimerFontSize: CGFloat {
        14
    }
}

// MARK: - 便捷构造器
extension DishDetailView {
    /// 现代主题
    static func modern(dish: Dish, onClose: @escaping () -> Void) -> DishDetailView {
        DishDetailView(dish: dish, onClose: onClose)
    }
}

#Preview {
    DishDetailView(
        dish: Dish(
            dishName: "测试菜品",
            ingredients: Dish.Ingredients(
                main: ["鸡蛋", "番茄"],
                auxiliary: ["葱", "姜"],
                seasoning: ["盐", "生抽"]
            ),
            steps: [
                CookingStep(step: 1, title: "准备食材", details: ["将鸡蛋打散", "番茄切块"]),
                CookingStep(step: 2, title: "炒制", details: ["热锅下油", "先炒鸡蛋", "再加入番茄"])
            ],
            tips: ["火候要掌握好", "可以加少许糖提鲜"],
            flavorProfile: FlavorProfile(taste: "酸甜可口", specialEffect: "营养丰富"),
            disclaimer: "这只是示例"
        ),
        onClose: {}
    )
}