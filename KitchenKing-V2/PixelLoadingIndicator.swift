//
//  PixelLoadingIndicator.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

import SwiftUI

/// 像素风格的加载指示器
struct PixelLoadingIndicator: View {
    @State private var animationPhase = 0
    private let dotCount = 4
    private let animationDuration = 0.2
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<dotCount, id: \.self) { index in
                Rectangle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(
                        index == animationPhase ? Color.white : 
                        index == (animationPhase + 1) % dotCount ? Color.white.opacity(0.6) :
                        index == (animationPhase + 2) % dotCount ? Color.white.opacity(0.3) :
                        Color.white.opacity(0.1)
                    )
                    .scaleEffect(
                        index == animationPhase ? 1.3 :
                        index == (animationPhase + 1) % dotCount ? 1.1 :
                        1.0
                    )
                    .animation(
                        Animation.easeInOut(duration: animationDuration / 4).delay(Double(index) * 0.05),
                        value: animationPhase
                    )
                    .cornerRadius(1)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: true) { _ in
                withAnimation(.easeInOut(duration: animationDuration / 2)) {
                    animationPhase = (animationPhase + 1) % dotCount
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("像素风格加载指示器")
            .font(.headline)
        
        PixelLoadingIndicator()
            .scaleEffect(2)
        
        Text("正在加载中...")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    .padding()
}
