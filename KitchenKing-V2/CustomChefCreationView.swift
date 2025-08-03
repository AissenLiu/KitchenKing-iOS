//
//  CustomChefCreationView.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

import SwiftUI

struct CustomChefCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var appState: AppState
    @Binding var name: String
    @Binding var title: String
    @Binding var specialty: String
    @Binding var personality: String
    @Binding var style: String
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本信息") {
                    TextField("厨师姓名", text: $name)
                    TextField("职位头衔", text: $title)
                }
                
                Section("专业技能") {
                    TextField("擅长菜系", text: $specialty)
                    TextField("烹饪风格", text: $style)
                }
                
                Section("性格特点") {
                    TextField("性格描述", text: $personality)
                }
                
                Section {
                    Button("创建角色") {
                        createCustomChef()
                    }
                    .disabled(name.isEmpty || title.isEmpty || specialty.isEmpty)
                }
            }
            .navigationTitle("创建自定义角色")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func createCustomChef() {
        let customChef = ChefRole(
            name: name,
            title: title,
            specialty: specialty,
            personality: personality,
            cookingStyle: style,
            imageName: "头像",
            isPremium: true,
            isCustom: true
        )
        
        appState.addCustomChefRole(customChef)
        clearForm()
        dismiss()
    }
    
    private func clearForm() {
        name = ""
        title = ""
        specialty = ""
        personality = ""
        style = ""
    }
}

#Preview {
    CustomChefCreationView(
        appState: AppState(),
        name: .constant(""),
        title: .constant(""),
        specialty: .constant(""),
        personality: .constant(""),
        style: .constant(""),
        isPresented: .constant(false)
    )
}