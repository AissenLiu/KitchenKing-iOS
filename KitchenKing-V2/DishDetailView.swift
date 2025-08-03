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
    let onFavorite: (Bool) -> Void
    let isFavorite: Bool
    let theme: DetailTheme = .modern
    
    @State private var scrollOffset: CGFloat = 0
    @State private var showContent = false
    @State private var localIsFavorite: Bool
    
    init(dish: Dish, onClose: @escaping () -> Void, onFavorite: @escaping (Bool) -> Void, isFavorite: Bool) {
        self.dish = dish
        self.onClose = onClose
        self.onFavorite = onFavorite
        self.isFavorite = isFavorite
        self._localIsFavorite = State(initialValue: isFavorite)
    }
    
    enum DetailTheme {
        case modern    // 现代主题：动画效果，现代布局
    }
    
    var body: some View {
        ZStack {
            // 模糊背景
            VisualEffectBlurView()
            
            // 主内容
            mainContent
        }
        .ignoresSafeArea()
        .onAppear {
            showContent = true
        }
    }
    
    // MARK: - 背景蒙层（已移除，使用模糊背景）
    private var backgroundOverlay: some View {
        EmptyView()
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
            .overlay(
                Rectangle()
                    .stroke(.black, lineWidth: 2)
            )
            
        }
        .background(Color.clear)
        .clipShape(Rectangle())
        .padding(contentPadding)
        .scaleEffect(showContent ? 1.0 : 0.8)
        .opacity(showContent ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showContent)
        .padding(.top,30)
        .padding(.bottom,30)
        
    }
    
    private var topControlBar: some View {
        HStack {
            HStack(spacing: 16) {
                // 菜品标题
                dishTitleSection
                
                Spacer()
                // 收藏按钮
                Button(action: toggleFavorite) {
                    ZStack {
                        Rectangle()
                            .fill(.white)
                            .frame(width: closeButtonSize, height: closeButtonSize)
   
                        Image(systemName: localIsFavorite ? "heart.fill" : "heart")
                            .font(.system(size: closeIconSize, weight: .bold))
                            .foregroundColor(localIsFavorite ? .red : .black)
                    }
                }
                .buttonStyle(ScaleButtonStyle())
                
                // 关闭按钮
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
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom,20)
        .overlay(
            Rectangle()
                .stroke(.black, lineWidth: 2)
        )
    }
    
    // MARK: - 详情内容
    private var detailContent: some View {
        VStack(spacing: contentSpacing) {
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
        VStack(alignment: .leading){
            Text(dish.dishName)
                .font(.system(size: 22, weight: .black))
                .foregroundColor(.black)
                .padding(.bottom,2)
            Text("详细制作方法和小贴士")
                .font(.system(size: 12, weight: .light))
                .foregroundColor(.black)
        }
        
    }
    
    private var dishIcon: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.02))
                .frame(width: 100, height: 100)
                .overlay(
                    Rectangle()
                        .stroke(Color.black, lineWidth: 2)
                )
            
            Rectangle()
                .fill(.white)
                .frame(width: 90, height: 90)
                .overlay(
                    Rectangle()
                        .stroke(.black, lineWidth: 2)
                )
            
            Image(systemName: "fork.knife")
                .font(.system(size: 36, weight: .bold))
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
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("食材清单")
            
            VStack(spacing: 12) {
                ingredientCategory("主要食材", ingredients: dish.ingredients.main, color: .black, icon: "")
                ingredientCategory("辅助食材", ingredients: dish.ingredients.auxiliary, color: .black, icon: "")
                ingredientCategory("调料", ingredients: dish.ingredients.seasoning, color: .black, icon: "")
            }
        }
        .padding(.top,20)
    }
    
    private func ingredientCategory(_ title: String, ingredients: [String], color: Color = .black, icon: String) -> some View {
        VStack(alignment: .leading, spacing: categorySpacing) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
            }
            
            if !ingredients.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: gridSpacing) {
                    ForEach(ingredients, id: \.self) { ingredient in
                        ingredientRow(ingredient, color: color)
                    }
                }
            } else {
                Text("暂无食材")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            }
        }
        .padding(categoryPadding)
        .background(
            Rectangle()
                .fill(categoryBackground)
                .overlay(
                    Rectangle()
                        .stroke(.black, lineWidth: 0.5)
                )
        )
    }
    
    private func ingredientRow(_ ingredient: String, color: Color = .black) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: 6, height: 6)
            
            Text(ingredient)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.black)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("制作步骤")
            
            VStack(spacing: 12) {
                ForEach(Array(dish.steps.enumerated()), id: \.element.id) { index, step in
                    stepView(step: step, index: index)
                }
            }
        }
    }
    
    private func stepView(step: CookingStep, index: Int) -> some View {
        HStack(alignment: .top, spacing: stepSpacing) {
            // 步骤序号
            stepNumberView(step.step)
            
            // 步骤内容
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(step.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                }
                
                if !step.details.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(step.details, id: \.self) { detail in
                            stepDetailRow(detail)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(stepPadding)
        .background(
            Rectangle()
                .fill(stepBackground)
                .overlay(
                    Rectangle()
                        .stroke(.black, lineWidth: 0.5)
                )
        )
    }
    
    private func stepNumberView(_ stepNumber: Int) -> some View {
        ZStack {
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 20, height: 20)
                .overlay(
                    Rectangle()
                        .stroke(.black, lineWidth: 0.5)
                )
            
            Text("\(stepNumber)")
                .font(.system(size: 16, weight: .light))
                .foregroundColor(.black)
        }
    }
    
    private func stepDetailRow(_ detail: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.black.opacity(0.3))
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            
            Text(detail)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.black)
                .lineSpacing(2)
        }
        .padding(.vertical, 2)
    }
    
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("制作小贴士")
            
            if dish.tips.isEmpty {
                Text("暂无小贴士")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
                    .background(
                        Rectangle()
                            .fill(Color.black.opacity(0.02))
                            .overlay(
                                Rectangle()
                                    .stroke(.black, lineWidth: 0.5)
                            )
                    )
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(dish.tips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Circle()
                                .fill(Color.black.opacity(0.3))
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)
                            
                            Text(tip)
                                .font(.system(size: 13, weight:.light))
                                .foregroundColor(.black)
                                .lineSpacing(2)
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(12)
                .background(
                    Rectangle()
                        .fill(Color.white.opacity(0.02))
                        .overlay(
                            Rectangle()
                                .stroke(.black, lineWidth: 0.5)
                        )
                )
            }
        }
    }
    
    private var flavorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("风味特点")
            
            VStack(alignment: .leading, spacing: 12) {
                // 口味描述
                HStack {
                    Text("口感：" + dish.flavorProfile.taste)
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.black)
                        .lineSpacing(2)
                    
                    Spacer()
                }
                .padding(12)
                
                
                // 特殊效果
                if let specialEffect = dish.flavorProfile.specialEffect {
                    HStack {
                        Text("特色："+specialEffect)
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(.black)
                            .lineSpacing(2)
                        
                        Spacer()
                    }
                    .padding(12)
                }
            }
            .background(
                Rectangle()
                    .fill(Color.white.opacity(0.02))
                    .overlay(
                        Rectangle()
                            .stroke(.black, lineWidth: 0.5)
                    )
            )
        }
    }
    
    private func disclaimerSection(_ disclaimer: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("免责申明")
            
            HStack {
                Text(disclaimer)
                    .font(.system(size: disclaimerFontSize, weight: .light))
                    .foregroundColor(.black)
                    .lineSpacing(2)
                
                Spacer()
            }
            .padding(16)
            .background(
                Rectangle()
                    .fill(Color.white.opacity(0.02))
                    .overlay(
                        Rectangle()
                            .stroke(.black, lineWidth: 0.5)
                    )
            )
        }
    }
    
    private func sectionTitle(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
        }
    }
    
    // MARK: - 背景样式
    private var contentBackground: some View {
        Color.clear
    }
    
    private var categoryBackground: Color {
        Color.white
    }
    
    private var stepBackground: Color {
        Color.white
    }
    
    // MARK: - 辅助方法
    private func dismissView() {
        showContent = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onClose()
        }
    }
    
    private func toggleFavorite() {
        localIsFavorite.toggle()
        onFavorite(localIsFavorite)
    }
    
    // MARK: - 布局配置
    private var backgroundOpacity: Double {
        0.3
    }
    
    private var closeButtonSize: CGFloat {
        24
    }
    
    private var closeIconSize: CGFloat {
        18
    }
    
    private var contentSpacing: CGFloat {
        32
    }
    
    private var titleSpacing: CGFloat {
        20
    }
    
    private var titleFontSize: CGFloat {
        28
    }
    
    private var detailPadding: CGFloat {
        20
    }
    
    private var detailBottomPadding: CGFloat {
        60
    }
    
    private var contentPadding: EdgeInsets {
        EdgeInsets(top: 60, leading: 24, bottom: 60, trailing: 24)
    }
    
    private var categorySpacing: CGFloat {
        16
    }
    
    private var categoryPadding: EdgeInsets {
        EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
    }
    
    private var gridSpacing: CGFloat {
        12
    }
    
    private var stepSpacing: CGFloat {
        20
    }
    
    private var stepPadding: EdgeInsets {
        EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
    }
    
    private var disclaimerFontSize: CGFloat {
        14
    }
}

// MARK: - 便捷构造器
extension DishDetailView {
    /// 现代主题
    static func modern(
        dish: Dish, 
        onClose: @escaping () -> Void,
        onFavorite: @escaping (Bool) -> Void = { _ in },
        isFavorite: Bool = false
    ) -> DishDetailView {
        DishDetailView(
            dish: dish, 
            onClose: onClose, 
            onFavorite: onFavorite, 
            isFavorite: isFavorite
        )
    }
}

// MARK: - 按钮样式
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - 模糊背景视图
struct VisualEffectBlurView: View {
    var body: some View {
        #if os(iOS)
        VisualEffectBlurViewiOS()
        #elseif os(macOS)
        VisualEffectBlurViewmacOS()
        #endif
    }
}

#if os(iOS)
struct VisualEffectBlurViewiOS: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView()
        view.effect = UIBlurEffect(style: .regular)
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: .regular)
    }
}
#endif

#if os(macOS)
struct VisualEffectBlurViewmacOS: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .hudWindow
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.blendingMode = .behindWindow
        nsView.state = .active
        nsView.material = .hudWindow
    }
}
#endif

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
        onClose: {},
        onFavorite: { _ in },
        isFavorite: false
    )
}
