//
//  ChefGridView.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

import SwiftUI

struct ChefGridView: View {
    @ObservedObject var appState: AppState
    let onDishClick: (Dish) -> Void
    let onReset: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // 状态统计和重置按钮
            HStack {
                // 状态统计
                HStack(spacing: 16) {
                    StatItemView(
                        color: .yellow,
                        count: appState.chefs.filter { $0.status == .cooking }.count,
                        label: "制作中"
                    )
                    
                    StatItemView(
                        color: .green,
                        count: appState.chefs.filter { $0.status == .completed }.count,
                        label: "已完成"
                    )
                    
                    StatItemView(
                        color: .red,
                        count: appState.chefs.filter { $0.status == .error }.count,
                        label: "失败"
                    )
                }
                
                Spacer()
                
                // 重置按钮 - 像素风格
                Button(action: onReset) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 12))
                        Text("重新开始")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Rectangle()
                            .fill(.white)
                            .overlay(
                                Rectangle()
                                    .stroke(.black, lineWidth: 2)
                            )
                    )
                }
                .disabled(appState.isLoading || appState.chefs.contains { $0.status == .cooking })
                .opacity(appState.isLoading || appState.chefs.contains { $0.status == .cooking } ? 0.6 : 1.0)
            }
            
            // 厨师列表
            let sortedChefs = getSortedChefs()
            
            LazyVStack(spacing: 16) {
                ForEach(sortedChefs) { chef in
                    ChefCardView(
                        chef: chef,
                        completionOrder: appState.completionOrder.firstIndex(of: chef.cuisine) ?? -1,
                        appState: appState,
                        onDishClick: onDishClick
                    )
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    private func getSortedChefs() -> [Chef] {
        return appState.chefs.sorted { chef1, chef2 in
            let index1 = appState.completionOrder.firstIndex(of: chef1.cuisine) ?? Int.max
            let index2 = appState.completionOrder.firstIndex(of: chef2.cuisine) ?? Int.max
            return index1 < index2
        }
    }
}

struct StatItemView: View {
    let color: Color
    let count: Int
    let label: String
    
    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(color)
                .frame(width: 8, height: 8)
                .overlay(
                    Rectangle()
                        .stroke(.black, lineWidth: 1)
                )
            
            Text("\(count) \(label)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.black)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
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

#Preview {
    ChefGridView(
        appState: AppState(),
        onDishClick: { _ in },
        onReset: {}
    )
}