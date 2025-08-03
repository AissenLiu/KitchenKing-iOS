//
//  IngredientInputView.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

import SwiftUI

struct IngredientInputView: View {
    @Binding var ingredients: String
    let placeholder: String
    let onGenerate: () -> Void
    let onRandom: () -> Void
    let isLoading: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // 输入区域背景 - 像素风格
            Rectangle()
                .fill(.white)
                .overlay(
                    VStack(spacing: 16) {
                        // 标签
                        HStack {
                            Text("🥬 输入你的食材")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                            Spacer()
                        }
                        
                        // 输入框
                        HStack(spacing: 12) {
                            ZStack(alignment: .leading) {
                                if ingredients.isEmpty {
                                    Text("例如：\(placeholder)")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 16, design: .rounded))
                                }
                                
                                TextField("", text: $ingredients)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .font(.system(size: 16, design: .rounded))
                                    .disabled(isLoading)
                            }
                            
                            // 状态指示器
                            Rectangle()
                                .fill(isValidIngredients ? .black : .gray)
                                .frame(width: 8, height: 8)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .overlay(
                                    Rectangle()
                                        .stroke(.black, lineWidth: 1)
                                )
                        )
                        
                        // 提示文本
                        Text("多个食材请用逗号分隔，如：鸡蛋，番茄，牛肉")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // 按钮区域
                        VStack(spacing: 12) {
                            // 随机按钮 - 像素风格
                            Button(action: {
                                onRandom()
                            }) {
                                HStack {
                                    Text("随机")
                                        .font(.system(size: 14, weight: .bold))
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    Rectangle()
                                        .fill(.white)
                                        .overlay(
                                            Rectangle()
                                                .stroke(.black, lineWidth: 2)
                                        )
                                )
                            }
                            .disabled(isLoading)
                            .opacity(isLoading ? 0.6 : 1.0)
                            
                            // 生成按钮 - 像素风格
                            Button(action: {
                                if isValidIngredients && !isLoading {
                                    onGenerate()
                                }
                            }) {
                                HStack {
                                    Text(isLoading ? "厨师们正在制作中..." : "开始厨王争霸")
                                        .font(.system(size: 16, weight: .bold))
                                    if isLoading {
                                        PixelLoadingIndicator()
                                            .scaleEffect(1.2)
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.black)
                            }
                            .disabled(!isValidIngredients || isLoading)
                            .opacity(isValidIngredients && !isLoading ? 1.0 : 0.6)
                            
                            
                        }
                    }
                    .padding(20)
                )
        }
    }
    
    private var isValidIngredients: Bool {
        return !ingredients.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview {
    IngredientInputView(
        ingredients: .constant(""),
        placeholder: "鸡蛋，番茄，牛肉",
        onGenerate: {},
        onRandom: {},
        isLoading: false
    )
}
