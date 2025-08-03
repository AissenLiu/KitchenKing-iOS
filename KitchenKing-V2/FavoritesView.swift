//
//  FavoritesView.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var appState: AppState
    @State private var selectedDish: Dish?
    @State private var showingDetail = false
    
    var body: some View {
        NavigationView {
            VStack {
                if appState.favoriteDishes.isEmpty {
                    EmptyFavoritesView()
                } else {
                    List {
                        ForEach(appState.favoriteDishes) { dish in
                            FavoriteDishRow(
                                dish: dish,
                                onTap: {
                                    selectedDish = dish
                                    showingDetail = true
                                },
                                onRemove: {
                                    appState.removeFromFavorites(dish)
                                }
                            )
                        }
                        .onDelete(perform: deleteFavorites)
                    }
                }
            }
            .navigationTitle("我的收藏")
            .sheet(isPresented: $showingDetail) {
                if let dish = selectedDish {
                    DishDetailView.modern(dish: dish) {
                        showingDetail = false
                    }
                }
            }
        }
    }
    
    private func deleteFavorites(at offsets: IndexSet) {
        let dishesToDelete = offsets.map { appState.favoriteDishes[$0] }
        for dish in dishesToDelete {
            appState.removeFromFavorites(dish)
        }
    }
}

// MARK: - 空收藏视图
struct EmptyFavoritesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("暂无收藏")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Text("点击菜品详情中的心形图标来收藏喜欢的菜品")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.05))
    }
}

// MARK: - 收藏菜品行
struct FavoriteDishRow: View {
    let dish: Dish
    let onTap: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // 菜品图标（使用第一个食材作为代表）
                VStack {
                    Image(systemName: "fork.knife")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 50, height: 50)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(dish.dishName)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text("主要食材: \(dish.ingredients.main.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    HStack {
                        Text(dish.flavorProfile.taste)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(4)
                        
                        Spacer()
                        
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onRemove()
            } label: {
                Label("删除", systemImage: "trash")
            }
        }
    }
}

#Preview {
    FavoritesView(appState: AppState())
}