//
//  HeaderView.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            // 像素风格皇冠图标
            ZStack {
                Rectangle()
                    .fill(.white)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Rectangle()
                            .stroke(.black, lineWidth: 3)
                    )
                
                Text("👑")
                    .font(.system(size: 40))
            }
            
            // 标题
            VStack(spacing: 8) {
                Text("厨王争霸")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.black)
                
                Text("输入你的食材，让各大菜系的名厨为你创造独特菜谱")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .padding(.top, 20)
    }
}

#Preview {
    HeaderView()
}