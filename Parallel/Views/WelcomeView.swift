//
//  WelcomeView.swift
//  Parallel
//
//  Created by 黃浚銘 on 2025/7/15.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var appState = AppStateManager.shared
    @State private var currentPage = 0
    
    let pages = [
        WelcomePage(
            title: "歡迎來到心連心",
            subtitle: "專為情侶設計的溫馨數位空間",
            imageName: "heart.fill",
            color: .pink
        ),
        WelcomePage(
            title: "私密聊天",
            subtitle: "端對端加密的專屬聊天空間",
            imageName: "message.fill",
            color: .blue
        ),
        WelcomePage(
            title: "位置分享",
            subtitle: "安全地分享位置，讓彼此更安心",
            imageName: "location.fill",
            color: .green
        ),
        WelcomePage(
            title: "交換日記",
            subtitle: "記錄每天的美好回憶",
            imageName: "book.fill",
            color: .orange
        ),
        WelcomePage(
            title: "共享行事曆",
            subtitle: "一起規劃美好的未來",
            imageName: "calendar",
            color: .purple
        )
    ]
    
    var body: some View {
        VStack {
            // 頁面內容
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    WelcomePageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(maxHeight: .infinity)
            
            // 頁面指示器
            HStack {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(currentPage == index ? Color.pink : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(currentPage == index ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: currentPage)
                }
            }
            .padding(.vertical, 20)
            
            // 開始按鈕
            VStack(spacing: 16) {
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage += 1
                        }
                    } else {
                        startApp()
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "下一步" : "開始體驗")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.pink)
                        )
                }
                
                if currentPage > 0 {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage -= 1
                        }
                    }) {
                        Text("上一步")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .background(Color(.systemBackground))
    }
    
    private func startApp() {
        appState.createDemoUser()
        withAnimation(.easeInOut(duration: 0.5)) {
            appState.isFirstLaunch = false
        }
    }
}

struct WelcomePage {
    let title: String
    let subtitle: String
    let imageName: String
    let color: Color
}

struct WelcomePageView: View {
    let page: WelcomePage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // 圖標
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: page.imageName)
                    .font(.system(size: 50))
                    .foregroundColor(page.color)
            }
            
            // 文字內容
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    WelcomeView()
}