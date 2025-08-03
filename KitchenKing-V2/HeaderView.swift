//
//  HeaderView.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

// 导入SwiftUI框架，用于构建用户界面
import SwiftUI

// 定义HeaderView结构体，遵循View协议，用于显示应用头部信息
struct HeaderView: View {
    // 计算属性，返回视图的主体内容
    var body: some View {
        // 创建垂直堆栈视图，子视图间距为16点
        VStack(spacing: 16) {
            // 应用头像容器，居中显示
            ZStack {
                // 创建白色背景矩形作为头像的背景板
                Rectangle()
                    .fill(.white) // 填充白色
                    .frame(width: 80, height: 80) // 设置背景尺寸为80x80点
                
                // 加载并显示应用头像图片
                Image("头像")
                    .resizable() // 使图片可调整大小
                    .aspectRatio(contentMode: .fit) // 保持图片原始宽高比，适应框架
                    .frame(width: 70, height: 70) // 设置图片显示尺寸为70x70点
            }
            
            // 标题文本区域，使用垂直堆栈组织主标题和副标题
            VStack(spacing: 8) {
                // 主标题文本
                Text("厨王争霸")
                    .font(.system(size: 32, weight: .black, design: .rounded)) // 设置字体：32号，超粗体，圆体设计
                    .foregroundColor(.black) // 设置文字颜色为黑色
                
                // 副标题文本
                Text("你是故意的，还是不小心")
                    .font(.system(size: 14, weight: .medium, design: .rounded)) // 设置字体：14号，中等字重，圆体设计
                    .foregroundColor(.secondary) // 设置文字颜色为次要颜色（通常是灰色）
                    .multilineTextAlignment(.center) // 多行文本居中对齐
                    .padding(.horizontal, 20) // 水平方向添加20点内边距
            }
        }
        .padding(.top, 20) // 整个头部视图顶部添加20点外边距
    }
}

#Preview {
    HeaderView()
}
