//
//  HomeView.swift
//  Parallel
//
//  Created by 黃浚銘 on 2025/7/15.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var events: [CalendarEvent]
    @State private var showingMissYouAnimation = false
    
    private var nextAnniversary: CalendarEvent? {
        events
            .filter { $0.type == .anniversary && $0.startDate > Date() }
            .sorted { $0.startDate < $1.startDate }
            .first
    }
    
    private var relationshipStartDate: Date {
        // 這裡應該從用戶設定或首次配對日期獲取
        Calendar.current.date(byAdding: .day, value: -100, to: Date()) ?? Date()
    }
    
    private var daysTogether: Int {
        Calendar.current.dateComponents([.day], from: relationshipStartDate, to: Date()).day ?? 0
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 問候語
                    VStack(alignment: .leading, spacing: 8) {
                        Text("❤️ 心連心")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("讓愛在每個瞬間連結")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // 交往天數卡片
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("我們在一起")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("\(daysTogether) 天")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.pink)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "heart.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.pink)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.pink.opacity(0.1))
                    )
                    .padding(.horizontal)
                    
                    // 下一個紀念日倒數
                    if let anniversary = nextAnniversary {
                        VStack {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("下一個紀念日")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    Text(anniversary.title)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text(daysUntil(anniversary.startDate))
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.orange)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .font(.system(size: 30))
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.orange.opacity(0.1))
                        )
                        .padding(.horizontal)
                    }
                    
                    // 快速操作按鈕
                    VStack(spacing: 16) {
                        Text("快速操作")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 16) {
                            // 想你按鈕
                            Button(action: sendMissYouMessage) {
                                VStack {
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 24))
                                    Text("想你")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.pink)
                                )
                            }
                            
                            // 寫日記按鈕
                            Button(action: {}) {
                                VStack {
                                    Image(systemName: "book.fill")
                                        .font(.system(size: 24))
                                    Text("寫日記")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue)
                                )
                            }
                            
                            // 添加活動按鈕
                            Button(action: {}) {
                                VStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 24))
                                    Text("添加活動")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green)
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // 最近活動
                    VStack(alignment: .leading, spacing: 12) {
                        Text("即將到來")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ForEach(upcomingEvents.prefix(3), id: \.id) { event in
                            HStack {
                                VStack {
                                    Text(dayOfMonth(event.startDate))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Text(monthAbbreviation(event.startDate))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: 50)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(event.title)
                                        .font(.headline)
                                    
                                    if !event.description.isEmpty {
                                        Text(event.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                eventTypeIcon(event.type)
                                    .foregroundColor(eventTypeColor(event.type))
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
        }
        .overlay(
            // 想你動畫覆蓋層
            MissYouAnimationView(isShowing: $showingMissYouAnimation)
        )
    }
    
    private var upcomingEvents: [CalendarEvent] {
        events
            .filter { $0.startDate > Date() }
            .sorted { $0.startDate < $1.startDate }
    }
    
    private func daysUntil(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        return "\(days) 天後"
    }
    
    private func dayOfMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }
    
    private func monthAbbreviation(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
    
    private func eventTypeIcon(_ type: EventType) -> Image {
        switch type {
        case .anniversary:
            return Image(systemName: "heart.fill")
        case .date:
            return Image(systemName: "fork.knife")
        case .travel:
            return Image(systemName: "airplane")
        case .todo:
            return Image(systemName: "checkmark.circle")
        case .milestone:
            return Image(systemName: "star.fill")
        }
    }
    
    private func eventTypeColor(_ type: EventType) -> Color {
        switch type {
        case .anniversary:
            return .pink
        case .date:
            return .orange
        case .travel:
            return .blue
        case .todo:
            return .green
        case .milestone:
            return .purple
        }
    }
    
    private func sendMissYouMessage() {
        showingMissYouAnimation = true
        
        // 這裡應該發送想你消息到對方
        // 暫時只顯示動畫
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showingMissYouAnimation = false
        }
    }
}

// 想你動畫視圖
struct MissYouAnimationView: View {
    @Binding var isShowing: Bool
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    
    var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.pink)
                        .scaleEffect(scale)
                        .opacity(opacity)
                    
                    Text("想你 ❤️")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(opacity)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5)) {
                    scale = 1.0
                    opacity = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        scale = 1.2
                        opacity = 0
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: CalendarEvent.self, inMemory: true)
}