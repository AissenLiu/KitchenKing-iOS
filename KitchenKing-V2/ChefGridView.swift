//
//  ChefGridView.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

// 导入 SwiftUI 框架，用于构建用户界面
import SwiftUI

// 定义厨师网格视图结构体，遵循 View 协议
struct ChefGridView: View {
    // 观察应用状态对象，当状态变化时自动更新视图
    @ObservedObject var appState: AppState
    // 菜品点击回调函数，接收一个 Dish 对象作为参数
    let onDishClick: (Dish) -> Void
    // 重置按钮回调函数，无参数无返回值
    let onReset: () -> Void
    
    // 视图主体内容
    var body: some View {
        // 垂直堆栈布局，间距为 16 点
        VStack(spacing: 16) {
            // 状态统计和重置按钮的水平布局
            HStack {
                // 状态统计的水平布局，间距为 16 点
                HStack(spacing: 16) {
                    // 制作中状态统计项
                    StatItemView(
                        color: .yellow, // 黄色表示制作中状态
                        count: appState.chefs.filter { $0.status == .cooking }.count, // 统计状态为制作中的厨师数量
                        label: "制作中" // 显示标签文本
                    )
                    
                    // 已完成状态统计项
                    StatItemView(
                        color: .green, // 绿色表示已完成状态
                        count: appState.chefs.filter { $0.status == .completed }.count, // 统计状态为已完成的厨师数量
                        label: "已完成" // 显示标签文本
                    )
                    
                    // 失败状态统计项
                    StatItemView(
                        color: .red, // 红色表示失败状态
                        count: appState.chefs.filter { $0.status == .error }.count, // 统计状态为失败的厨师数量
                        label: "失败" // 显示标签文本
                    )
                }
                
                // 弹性空间，将内容推到两侧
                Spacer()
                
                // 音频控制按钮
                Button(action: {
                    appState.audioManager.toggleMute()
                }) {
                    HStack {
                        Image(systemName: appState.audioManager.isMuted ? "speaker.slash.fill" : "speaker.fill")
                            .font(.system(size: 14))
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
                
                // 重置按钮 - 像素风格设计
                Button(action: onReset) {
                    // 按钮内容的水平布局
                    HStack {
                        // 重置图标
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 12)) // 设置图标大小为 12 点
                    }
                    .foregroundColor(.black) // 设置文本颜色为黑色
                    .padding(.horizontal, 12) // 水平内边距 12 点
                    .padding(.vertical, 6) // 垂直内边距 6 点
                    .background(
                        // 白色背景矩形
                        Rectangle()
                            .fill(.white) // 填充白色
                            .overlay(
                                // 黑色边框叠加层
                                Rectangle()
                                    .stroke(.black, lineWidth: 2) // 2 点宽的黑色边框
                            )
                    )
                }
                // 禁用条件：正在加载或有厨师正在制作时
                .disabled(appState.isLoading || appState.chefs.contains { $0.status == .cooking })
                // 透明度设置：禁用时降低透明度
                .opacity(appState.isLoading || appState.chefs.contains { $0.status == .cooking } ? 0.6 : 1.0)
            }
            
            // 获取排序后的厨师列表
            let sortedChefs = getSortedChefs()
            
            // 懒加载垂直堆栈，间距为 16 点，优化性能
            LazyVStack(spacing: 16) {
                // 遍历排序后的厨师数组
                ForEach(sortedChefs) { chef in
                    // 厨师卡片视图
                    ChefCardView(
                        chef: chef, // 传入厨师对象
                        completionOrder: appState.completionOrder.firstIndex(of: chef.cuisine) ?? -1, // 获取完成顺序索引
                        appState: appState, // 传入应用状态
                        onDishClick: onDishClick // 传入菜品点击回调
                    )
                    .frame(maxWidth: .infinity) // 设置最大宽度为无限大
                }
            }
        }
    }
    
    // 私有方法：获取排序后的厨师列表
    private func getSortedChefs() -> [Chef] {
        // 返回按完成顺序排序的厨师数组
        return appState.chefs.sorted { chef1, chef2 in
            // 获取第一个厨师的菜系在完成顺序中的索引，找不到则设为最大值
            let index1 = appState.completionOrder.firstIndex(of: chef1.cuisine) ?? Int.max
            // 获取第二个厨师的菜系在完成顺序中的索引，找不到则设为最大值
            let index2 = appState.completionOrder.firstIndex(of: chef2.cuisine) ?? Int.max
            // 按索引升序排序，已完成的排在前面
            return index1 < index2
        }
    }
}

// 状态统计项视图结构体
struct StatItemView: View {
    // 颜色属性，用于显示状态的颜色标识
    let color: Color
    // 数量属性，显示该状态的统计数量
    let count: Int
    // 标签属性，显示状态的文本描述
    let label: String
    
    // 视图主体内容
    var body: some View {
        // 水平布局，间距为 8 点
        HStack(spacing: 8) {
            // 颜色标识矩形
            Rectangle()
                .fill(color) // 填充指定颜色
                .frame(width: 8, height: 8) // 设置矩形大小为 8x8 点
            
            // 数量和标签文本
            Text("\(count) \(label)") // 格式化显示数量和标签
                .font(.system(size: 12, weight: .bold)) // 设置字体大小和粗体
                .foregroundColor(.black) // 设置文本颜色为黑色
        }
        .padding(.horizontal, 8) // 水平内边距 8 点
        .padding(.vertical, 4) // 垂直内边距 4 点
    }
}

// 预览提供者，用于在 Xcode 中预览视图效果
#Preview {
    // 创建厨师网格视图的预览实例
    ChefGridView(
        appState: AppState(), // 使用默认的应用状态
        onDishClick: { _ in }, // 空的菜品点击回调
        onReset: {} // 空的重置回调
    )
}
