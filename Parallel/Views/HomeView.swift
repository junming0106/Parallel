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
        // 設定一個固定的開始日期作為演示
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.month = (components.month ?? 1) - 3 // 3個月前
        return calendar.date(from: components) ?? Date()
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
                    RelationshipDaysCard(daysTogether: daysTogether)
                        .padding(.horizontal)
                    
                    // 下一個紀念日倒數
                    if let anniversary = nextAnniversary {
                        AnniversaryCountdownCard(anniversary: anniversary)
                            .padding(.horizontal)
                    }
                    
                    // 快速操作按鈕
                    QuickActionsSection(sendMissYouMessage: sendMissYouMessage)
                        .padding(.horizontal)
                    
                    // 最近活動
                    UpcomingEventsSection(events: Array(upcomingEvents.prefix(3)))
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

// MARK: - 子視圖組件

struct RelationshipDaysCard: View {
    let daysTogether: Int
    
    var body: some View {
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
    }
}

struct AnniversaryCountdownCard: View {
    let anniversary: CalendarEvent
    
    var body: some View {
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
    }
    
    private func daysUntil(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        return "\(days) 天後"
    }
}

struct QuickActionsSection: View {
    let sendMissYouMessage: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("快速操作")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                // 想你按鈕
                Button(action: sendMissYouMessage) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 20))
                        Text("想你")
                            .font(.headline)
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
                
                HStack(spacing: 12) {
                    // 寫日記按鈕
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "book.fill")
                                .font(.system(size: 18))
                            Text("寫日記")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue)
                        )
                    }
                    
                    // 添加活動按鈕
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18))
                            Text("添加活動")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.green)
                        )
                    }
                }
            }
        }
    }
}

struct UpcomingEventsSection: View {
    let events: [CalendarEvent]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("即將到來")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(events, id: \.title) { event in
                EventRowView(event: event)
            }
        }
    }
}

struct EventRowView: View {
    let event: CalendarEvent
    
    var body: some View {
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
                
                if !event.eventDescription.isEmpty {
                    Text(event.eventDescription)
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
}

#Preview {
    HomeView()
        .modelContainer(for: CalendarEvent.self, inMemory: true)
}