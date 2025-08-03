//
//  ConfettiEffectView.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

import SwiftUI

struct ConfettiEffectView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var animationTimer: Timer?
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink, .cyan]
    
    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .offset(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
            }
        }
        .onAppear {
            startConfetti()
        }
        .onDisappear {
            stopConfetti()
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("TriggerConfetti"))) { _ in
            restartConfetti()
        }
    }
    
    private func startConfetti() {
        // 创建初始粒子
        for i in 0..<50 {
            let particle = ConfettiParticle(
                id: i,
                x: CGFloat.random(in: -100...100),
                y: CGFloat.random(in: -50...50),
                color: colors.randomElement() ?? .red,
                size: CGFloat.random(in: 4...8),
                opacity: 1.0,
                scale: 1.0,
                velocityX: CGFloat.random(in: -2...2),
                velocityY: CGFloat.random(in: -5 ... -2),
                rotation: Double.random(in: 0...360)
            )
            particles.append(particle)
        }
        
        // 开始动画
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateParticles()
        }
        
        // 3秒后停止
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            stopConfetti()
        }
    }
    
    private func updateParticles() {
        for i in particles.indices {
            particles[i].x += particles[i].velocityX
            particles[i].y += particles[i].velocityY
            particles[i].velocityY += 0.2 // 重力效果
            particles[i].opacity -= 0.01
            particles[i].scale *= 0.995
            particles[i].rotation += 5
        }
        
        // 移除透明度为0的粒子
        particles.removeAll { $0.opacity <= 0 }
    }
    
    private func stopConfetti() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func restartConfetti() {
        // 停止当前动画
        stopConfetti()
        // 清空粒子数组
        particles.removeAll()
        // 重新开始动画
        startConfetti()
    }
}

struct ConfettiParticle {
    let id: Int
    var x: CGFloat
    var y: CGFloat
    let color: Color
    let size: CGFloat
    var opacity: Double
    var scale: CGFloat
    let velocityX: CGFloat
    var velocityY: CGFloat
    var rotation: Double
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3)
            .ignoresSafeArea()
        
        ConfettiEffectView()
            .frame(width: 200, height: 200)
    }
}