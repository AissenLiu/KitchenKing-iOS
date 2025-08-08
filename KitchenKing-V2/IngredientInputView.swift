//
//  IngredientInputView.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

// 导入 SwiftUI 框架，用于构建用户界面
import SwiftUI

// 定义食材输入视图结构体，符合 View 协议
struct IngredientInputView: View {
    // 绑定食材字符串，用于双向数据绑定
    @Binding var ingredients: String
    // 占位符文本，显示示例食材
    let placeholder: String
    // 生成菜谱的回调函数
    let onGenerate: () -> Void
    // 随机生成食材的回调函数
    let onRandom: () -> Void
    // 加载状态标志
    let isLoading: Bool
    // 应用状态环境变量
    @EnvironmentObject var appState: AppState
    
    // 视图主体内容
    var body: some View {
        // 垂直堆栈布局，间距 20 点
        VStack(spacing: 20) {
            // 输入区域背景 - 像素风格
            Rectangle()
                // 填充白色背景
                .fill(.white)
                // 添加内容覆盖层
                .overlay(
                    // 垂直堆栈布局，间距 16 点
                    VStack(spacing: 16) {
                        // 剩余次数显示
                        if !appState.isSubscribed {
                            HStack {
                                Image(systemName: "bolt.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                
                                Text("剩余生成次数: \(appState.remainingGenerations)")
                                    .font(.caption)
                                    .foregroundColor(appState.remainingGenerations <= 1 ? .red : .orange)
                                
                                Spacer()
                                
                                if appState.remainingGenerations <= 1 {
                                    Button("升级会员") {
                                        appState.showSubscriptionSheet = true
                                    }
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        
                        // 输入框区域
                        HStack(spacing: 12) {
                            // ZStack 用于层叠显示占位符和输入框
                            ZStack(alignment: .leading) {
                                // 如果食材为空，显示占位符文本
                                if ingredients.isEmpty {
                                    Text("例如：\(placeholder)")
                                        // 设置次要文本颜色（灰色）
                                        .foregroundColor(.secondary)
                                        // 设置字体样式：16 号圆角字体
                                        .font(.system(size: 16, design: .rounded))
                                }
                                
                                // 文本输入框，绑定到 ingredients 变量
                                TextField("", text: $ingredients)
                                    // 使用无样式文本框样式
                                    .textFieldStyle(PlainTextFieldStyle())
                                    // 设置字体样式：16 号圆角字体
                                    .font(.system(size: 16, design: .rounded))
                                    // 根据加载状态禁用输入
                                    .disabled(isLoading)
                            }
                            
                            // 状态指示器 - 显示输入验证状态
                            Rectangle()
                                // 根据验证状态填充绿色或灰色
                                .fill(isValidIngredients ? .green : .gray)
                                // 设置指示器尺寸：8x8 点
                                .frame(width: 8, height: 8)
                        }
                        // 水平内边距 16 点
                        .padding(.horizontal, 16)
                        // 垂直内边距 12 点
                        .padding(.vertical, 12)
                        // 添加输入框背景
                        .background(
                            Rectangle()
                                // 填充浅灰色背景
                                .fill(Color.gray.opacity(0.1))
                                // 添加边框覆盖层
                                .overlay(
                                    Rectangle()
                                        // 绘制黑色边框，线宽 1 点
                                        .stroke(.black, lineWidth: 1)
                                )
                        )
                        
                        
                        
                        // 提示文本区域
                        Text("多个食材请用逗号分隔，如：鸡蛋，番茄，牛肉")
                            // 设置字体样式：14 号圆角字体
                            .font(.system(size: 14, design: .rounded))
                            // 设置次要文本颜色（灰色）
                            .foregroundColor(.secondary)
                            // 设置最大宽度，左对齐
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // 按钮区域
                        VStack(spacing: 12) {
                            // 随机按钮 - 像素风格
                            Button(action: {
                                // 点击时调用随机生成回调函数
                                onRandom()
                            }) {
                                HStack {
                                    Text("随机")
                                        // 设置字体样式：14 号粗体圆角字体
                                        .font(.system(size: 14, weight: .bold))
                                }
                                // 设置文本颜色为黑色
                                .foregroundColor(.black)
                                // 设置最大宽度填充父容器
                                .frame(maxWidth: .infinity)
                                // 垂直内边距 12 点
                                .padding(.vertical, 12)
                                // 按钮背景
                                .background(
                                    Rectangle()
                                        // 填充白色背景
                                        .fill(.white)
                                        // 添加边框覆盖层
                                        .overlay(
                                            Rectangle()
                                                // 绘制黑色边框，线宽 2 点
                                                .stroke(.black, lineWidth: 2)
                                        )
                                )
                            }
                            // 根据加载状态禁用按钮
                            .disabled(isLoading)
                            // 根据加载状态设置透明度
                            .opacity(isLoading ? 0.6 : 1.0)
                            
                            // 生成按钮 - 像素风格
                            Button(action: {
                                // 检查输入有效、不在加载状态且所有厨师未完成制作时执行
                                if isValidIngredients && !isLoading && !appState.allChefsFinished {
                                    // 调用生成菜谱回调函数
                                    onGenerate()
                                }
                            }) {
                                HStack {
                                    // 根据状态显示不同文本
                                    Text(buttonText)
                                        // 设置字体样式：16 号粗体圆角字体
                                        .font(.system(size: 16, weight: .bold))
                                    // 如果正在加载，显示像素加载指示器
                                    if isLoading {
                                        PixelLoadingIndicator().scaleEffect(0.8)
                                    }
                                }
                                // 设置文本颜色为白色
                                .foregroundColor(.white)
                                // 设置最大宽度填充父容器
                                .frame(maxWidth: .infinity)
                                // 垂直内边距 12 点
                                .padding(.vertical, 12)
                                // 设置背景颜色
                                .background(buttonBackgroundColor)
                            }
                            // 根据输入验证、加载状态和所有厨师完成状态禁用按钮
                            .disabled(!isValidIngredients || isLoading || appState.allChefsFinished)
                            
                            
                            // 忌口开关区域
//                            HStack {
//                                Image(systemName: "exclamationmark.triangle.fill")
//                                    .foregroundColor(appState.hasAllergies ? .orange : .gray)
//                                    .font(.system(size: 16))
//                                
//                                Text("是否有忌口")
//                                    .font(.system(size: 14, design: .rounded))
//                                    .foregroundColor(.primary)
//                                
//                                Spacer()
//                                
//                                Toggle("", isOn: $appState.hasAllergies)
//                                    .labelsHidden()
//                                    .scaleEffect(0.8)
//                                    .onChange(of: appState.hasAllergies) { oldValue, newValue in
//                                        if newValue {
//                                            appState.showAllergiesSheet = true
//                                        } else {
//                                            appState.allergiesContent = ""
//                                        }
//                                    }
//                            }
//                            .padding(.horizontal, 4)
                            
                            // 忌口信息显示
//                            if appState.hasAllergies && !appState.allergiesContent.isEmpty {
//                                HStack {
//                                    Image(systemName: "info.circle.fill")
//                                        .foregroundColor(.orange)
//                                        .font(.system(size: 12))
//                                    
//                                    Text("忌口：\(appState.allergiesContent)")
//                                        .font(.system(size: 12, design: .rounded))
//                                        .foregroundColor(.orange)
//                                        .lineLimit(1)
//                                    
//                                    Spacer()
//                                    
//                                    Button("修改") {
//                                        appState.showAllergiesSheet = true
//                                    }
//                                    .font(.caption)
//                                    .foregroundColor(.blue)
//                                }
//                                .padding(.horizontal, 4)
//                            }
                        }
                    }
                    // 设置内边距 20 点
                    .padding(20)
                )
        }
//        .sheet(isPresented: $appState.showAllergiesSheet) {
//            AllergiesInputSheet(appState: appState)
//                .presentationDetents([.fraction(0.4)])
//                .presentationDragIndicator(.visible)
//        }
    }
    
    // 私有计算属性：验证食材输入是否有效
    private var isValidIngredients: Bool {
        // 去除首尾空白字符和换行符后，检查是否不为空
        return !ingredients.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // 私有计算属性：按钮显示文本
    private var buttonText: String {
        if isLoading {
            return "正在制作中"
        } else if appState.allChefsFinished {
            return "制作已完成，请重新开始"
        } else {
            return "开始厨王争霸"
        }
    }
    
    // 私有计算属性：按钮背景颜色
    private var buttonBackgroundColor: Color {
        if appState.allChefsFinished {
            return Color.gray
        } else {
            return Color.black
        }
    }
}

// SwiftUI 预览提供器，用于在 Xcode 中预览视图
#Preview {
    IngredientInputView(
        // 创建常量绑定，用于预览
        ingredients: .constant(""),
        // 设置示例占位符文本
        placeholder: "鸡蛋，番茄，牛肉",
        // 空的生成回调函数
        onGenerate: {},
        // 空的随机回调函数
        onRandom: {},
        // 设置非加载状态
        isLoading: false
    )
    .environmentObject(AppState())
}

// 忌口输入弹窗
struct AllergiesInputSheet: View {
    @ObservedObject var appState: AppState
    @State private var tempAllergies = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // 标题
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("忌口信息")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding(.horizontal)
            
            // 输入框
            VStack(alignment: .leading, spacing: 8) {
                Text("请输入您的忌口食材或过敏原")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
                
                TextField("例如：花生，海鲜，牛肉，香菜", text: $tempAllergies)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(size: 16, design: .rounded))
            }
            .padding(.horizontal)
            
            // 提示文本
            Text("💡 多个忌口食材请用逗号分隔，我们会在制作菜谱时特别注意避免这些食材")
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            // 按钮区域
            HStack(spacing: 16) {
                Button("取消") {
                    tempAllergies = appState.allergiesContent
                    appState.hasAllergies = !appState.allergiesContent.isEmpty
                    appState.showAllergiesSheet = false
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .overlay(
                            Rectangle()
                                .stroke(.gray, lineWidth: 1)
                        )
                )
                
                Button("确定") {
                    appState.allergiesContent = tempAllergies.trimmingCharacters(in: .whitespacesAndNewlines)
                    appState.hasAllergies = !appState.allergiesContent.isEmpty
                    appState.showAllergiesSheet = false
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.orange)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
        .onAppear {
            tempAllergies = appState.allergiesContent
        }
    }
}
