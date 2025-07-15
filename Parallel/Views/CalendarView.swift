//
//  CalendarView.swift
//  Parallel
//
//  Created by 黃浚銘 on 2025/7/15.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var events: [CalendarEvent]
    @State private var selectedDate = Date()
    @State private var showingNewEvent = false
    @State private var showingEventDetail = false
    @State private var selectedEvent: CalendarEvent?
    
    private var eventsForSelectedDate: [CalendarEvent] {
        events.filter { event in
            Calendar.current.isDate(event.startDate, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // 日曆視圖
                CalendarWeekView(selectedDate: $selectedDate, events: events)
                
                // 選中日期的事件
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(formatSelectedDate())
                            .font(.headline)
                        Spacer()
                        Button(action: { showingNewEvent = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    if eventsForSelectedDate.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            Text("這天沒有活動")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button(action: { showingNewEvent = true }) {
                                Text("添加活動")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.blue)
                                    )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(eventsForSelectedDate, id: \.id) { event in
                                    EventCard(event: event) {
                                        selectedEvent = event
                                        showingEventDetail = true
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGray6))
            }
            .navigationTitle("行事曆")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingNewEvent) {
            NewEventView(selectedDate: selectedDate)
        }
        .sheet(isPresented: $showingEventDetail) {
            if let event = selectedEvent {
                EventDetailView(event: event)
            }
        }
    }
    
    private func formatSelectedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: selectedDate)
    }
}

struct CalendarWeekView: View {
    @Binding var selectedDate: Date
    let events: [CalendarEvent]
    @State private var currentWeekOffset = 0
    
    private var weekDays: [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset + (currentWeekOffset * 7), to: startOfWeek)
        }
    }
    
    var body: some View {
        VStack {
            // 週切換
            HStack {
                Button(action: { currentWeekOffset -= 1 }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(weekTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { currentWeekOffset += 1 }) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // 週視圖
            HStack(spacing: 0) {
                ForEach(weekDays, id: \.self) { date in
                    VStack(spacing: 4) {
                        Text(dayOfWeek(date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: { selectedDate = date }) {
                            ZStack {
                                Circle()
                                    .fill(isSelected(date) ? Color.blue : Color.clear)
                                    .frame(width: 32, height: 32)
                                
                                Text(dayOfMonth(date))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(isSelected(date) ? .white : .primary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // 事件指示器
                        if hasEvents(date) {
                            Circle()
                                .fill(Color.pink)
                                .frame(width: 6, height: 6)
                        } else {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 6, height: 6)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
    }
    
    private var weekTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: weekDays.first ?? Date())
    }
    
    private func dayOfWeek(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    private func dayOfMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private func isSelected(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
    private func hasEvents(_ date: Date) -> Bool {
        events.contains { event in
            Calendar.current.isDate(event.startDate, inSameDayAs: date)
        }
    }
}

struct EventCard: View {
    let event: CalendarEvent
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // 時間和類型指示器
                VStack(spacing: 4) {
                    Text(formatTime(event.startDate))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    eventTypeIcon(event.type)
                        .font(.title2)
                        .foregroundColor(eventTypeColor(event.type))
                }
                .frame(width: 60)
                
                // 事件內容
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if !event.description.isEmpty {
                        Text(event.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    if let location = event.location {
                        HStack {
                            Image(systemName: "location.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(location)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(eventTypeColor(event.type).opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
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

struct NewEventView: View {
    let selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title = ""
    @State private var description = ""
    @State private var eventType: EventType = .date
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var isAllDay = false
    @State private var location = ""
    @State private var reminderTime = Date()
    @State private var hasReminder = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本資訊") {
                    TextField("標題", text: $title)
                    TextField("描述", text: $description)
                    
                    Picker("類型", selection: $eventType) {
                        Text("紀念日").tag(EventType.anniversary)
                        Text("約會").tag(EventType.date)
                        Text("旅行").tag(EventType.travel)
                        Text("待辦").tag(EventType.todo)
                        Text("里程碑").tag(EventType.milestone)
                    }
                }
                
                Section("時間") {
                    DatePicker("開始時間", selection: $startDate, displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute])
                    
                    if !isAllDay {
                        DatePicker("結束時間", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    }
                    
                    Toggle("全天", isOn: $isAllDay)
                }
                
                Section("其他") {
                    TextField("地點", text: $location)
                    
                    Toggle("提醒", isOn: $hasReminder)
                    
                    if hasReminder {
                        DatePicker("提醒時間", selection: $reminderTime, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("新增活動")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        saveEvent()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .onAppear {
            startDate = selectedDate
            endDate = selectedDate
        }
    }
    
    private func saveEvent() {
        let currentUserID = "current-user"
        let partnerID = "partner-user"
        
        let event = CalendarEvent(
            title: title,
            description: description,
            type: eventType,
            startDate: startDate,
            endDate: isAllDay ? nil : endDate,
            isAllDay: isAllDay,
            createdBy: currentUserID,
            participantIDs: [currentUserID, partnerID],
            location: location.isEmpty ? nil : location
        )
        
        if hasReminder {
            event.reminderTime = reminderTime
        }
        
        modelContext.insert(event)
        dismiss()
    }
}

struct EventDetailView: View {
    let event: CalendarEvent
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 標題和類型
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            eventTypeIcon(event.type)
                                .font(.title2)
                                .foregroundColor(eventTypeColor(event.type))
                            
                            Text(event.title)
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        
                        Text(eventTypeText(event.type))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // 時間信息
                    VStack(alignment: .leading, spacing: 8) {
                        Label("時間", systemImage: "clock")
                            .font(.headline)
                        
                        Text(formatEventTime())
                            .font(.body)
                    }
                    
                    // 描述
                    if !event.description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("描述", systemImage: "text.alignleft")
                                .font(.headline)
                            
                            Text(event.description)
                                .font(.body)
                        }
                    }
                    
                    // 地點
                    if let location = event.location {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("地點", systemImage: "location")
                                .font(.headline)
                            
                            Text(location)
                                .font(.body)
                        }
                    }
                    
                    // 提醒
                    if let reminderTime = event.reminderTime {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("提醒", systemImage: "bell")
                                .font(.headline)
                            
                            Text(formatReminderTime(reminderTime))
                                .font(.body)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("活動詳情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
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
    
    private func eventTypeText(_ type: EventType) -> String {
        switch type {
        case .anniversary:
            return "紀念日"
        case .date:
            return "約會"
        case .travel:
            return "旅行"
        case .todo:
            return "待辦事項"
        case .milestone:
            return "里程碑"
        }
    }
    
    private func formatEventTime() -> String {
        let formatter = DateFormatter()
        
        if event.isAllDay {
            formatter.dateStyle = .full
            return formatter.string(from: event.startDate)
        } else {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            let startTime = formatter.string(from: event.startDate)
            
            if let endDate = event.endDate {
                let endTime = formatter.string(from: endDate)
                return "\(startTime) - \(endTime)"
            } else {
                return startTime
            }
        }
    }
    
    private func formatReminderTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: CalendarEvent.self, inMemory: true)
}