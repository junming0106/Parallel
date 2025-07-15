//
//  MainTabView.swift
//  Parallel
//
//  Created by 黃浚銘 on 2025/7/15.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ChatView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("聊天")
                }
                .tag(0)
            
            LocationView()
                .tabItem {
                    Image(systemName: "location.fill")
                    Text("位置")
                }
                .tag(1)
            
            HomeView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("首頁")
                }
                .tag(2)
            
            DiaryView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("日記")
                }
                .tag(3)
            
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("行事曆")
                }
                .tag(4)
        }
        .accentColor(.pink)
        .onAppear {
            selectedTab = 2 // 默認選中首頁
        }
    }
}

#Preview {
    MainTabView()
}