//
//  PixelLoadingIndicator.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

import SwiftUI

/// 像素风格的加载指示器
struct PixelLoadingIndicator: View {
    @State private var isAnimating = false
    private let frames = ["⬜", "⬛", "⬜", "⬛"]
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<frames.count, id: \.self) { index in
                Text(frames[index])
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.black)
                    .scaleEffect(isAnimating && index == getCurrentFrame() ? 1.2 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 0.3).repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    private func getCurrentFrame() -> Int {
        let time = Date().timeIntervalSince1970
        return Int(time * 2) % frames.count
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