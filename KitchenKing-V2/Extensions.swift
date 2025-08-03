//
//  Extensions.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension Color {
    static let appYellow = Color(red: 255/255, green: 204/255, blue: 0/255)
    static let appGreen = Color(red: 76/255, green: 175/255, blue: 80/255)
    static let appBlue = Color(red: 33/255, green: 150/255, blue: 243/255)
    static let appOrange = Color(red: 255/255, green: 152/255, blue: 0/255)
    static let appRed = Color(red: 244/255, green: 67/255, blue: 54/255)
    static let appPurple = Color(red: 156/255, green: 39/255, blue: 176/255)
    static let appIndigo = Color(red: 63/255, green: 81/255, blue: 181/255)
}

#if os(iOS)
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
#endif

extension Task where Success == [Void] {
    static func whenAll(_ tasks: [Task]) async {
        await withTaskGroup(of: Void.self) { group in
            for task in tasks {
                group.addTask {
                    _ = try? await task.value
                }
            }
            
            for await _ in group {
                // 等待所有任务完成
            }
        }
    }
}

extension String {
    func containsEmoji() -> Bool {
        for scalar in unicodeScalars {
            if scalar.properties.isEmoji {
                return true
            }
        }
        return false
    }
}