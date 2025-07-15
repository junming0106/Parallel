//
//  DiaryView.swift
//  Parallel
//
//  Created by 黃浚銘 on 2025/7/15.
//

import SwiftUI
import SwiftData

struct DiaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var diaryEntries: [DiaryEntry]
    @State private var showingNewDiary = false
    @State private var showingDiaryDetail = false
    @State private var selectedDiary: DiaryEntry?
    
    private var sortedEntries: [DiaryEntry] {
        diaryEntries.sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // 頂部狀態卡片
                    diaryStatusCard
                    
                    // 日記列表
                    LazyVStack(spacing: 12) {
                        ForEach(sortedEntries, id: \.id) { entry in
                            DiaryCard(entry: entry) {
                                selectedDiary = entry
                                showingDiaryDetail = true
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    if sortedEntries.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "book.closed")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("還沒有日記")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("開始寫下你們的第一個回憶吧！")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 40)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("交換日記")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewDiary = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingNewDiary) {
            NewDiaryView()
        }
        .sheet(isPresented: $showingDiaryDetail) {
            if let diary = selectedDiary {
                DiaryDetailView(diary: diary)
            }
        }
    }
    
    private var diaryStatusCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "book.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text("交換日記")
                        .font(.headline)
                    
                    Text(getCurrentStatusText())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if canWriteToday() {
                    Button(action: { showingNewDiary = true }) {
                        Text("寫日記")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue)
                            )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.1))
        )
        .padding(.horizontal)
    }
    
    private func getCurrentStatusText() -> String {
        // 這裡應該根據實際狀態來決定顯示文字
        if let latestEntry = sortedEntries.first {
            if latestEntry.status == .writing {
                return "正在寫日記中..."
            } else if latestEntry.status == .locked {
                return "等待對方回覆..."
            } else {
                return "輪到你寫日記了"
            }
        }
        return "開始寫第一篇日記吧"
    }
    
    private func canWriteToday() -> Bool {
        // 簡化的邏輯：如果今天還沒寫日記就可以寫
        let today = Calendar.current.startOfDay(for: Date())
        return !sortedEntries.contains { entry in
            Calendar.current.isDate(entry.createdAt, inSameDayAs: today)
        }
    }
}

struct DiaryCard: View {
    let entry: DiaryEntry
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(formatDate(entry.createdAt))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    statusBadge(for: entry.status)
                }
                
                Text(entry.content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    if let weather = entry.weather {
                        Label(weather, systemImage: "cloud.sun.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let mood = entry.mood {
                        Label(mood, systemImage: "face.smiling")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func statusBadge(for status: DiaryStatus) -> some View {
        Group {
            switch status {
            case .writing:
                Label("撰寫中", systemImage: "pencil")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.1))
                    )
            case .locked:
                Label("已鎖定", systemImage: "lock.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange.opacity(0.1))
                    )
            case .shared:
                Label("已分享", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green.opacity(0.1))
                    )
            case .read:
                Label("已讀", systemImage: "eye.fill")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                    )
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct NewDiaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var title = ""
    @State private var content = ""
    @State private var weather = ""
    @State private var mood = ""
    @State private var selectedCoverStyle = "default"
    
    let weatherOptions = ["☀️ 晴天", "☁️ 陰天", "🌧️ 雨天", "⛈️ 雷雨", "🌈 彩虹"]
    let moodOptions = ["😊 開心", "😍 戀愛", "😴 疲累", "🤔 思考", "😌 平靜"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 標題輸入
                    VStack(alignment: .leading, spacing: 8) {
                        Text("標題")
                            .font(.headline)
                        TextField("今天發生了什麼特別的事？", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // 內容輸入
                    VStack(alignment: .leading, spacing: 8) {
                        Text("內容")
                            .font(.headline)
                        TextEditor(text: $content)
                            .frame(minHeight: 200)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // 天氣選擇
                    VStack(alignment: .leading, spacing: 8) {
                        Text("天氣")
                            .font(.headline)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(weatherOptions, id: \.self) { option in
                                    Button(action: { weather = option }) {
                                        Text(option)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(weather == option ? Color.blue : Color(.systemGray5))
                                            )
                                            .foregroundColor(weather == option ? .white : .primary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // 心情選擇
                    VStack(alignment: .leading, spacing: 8) {
                        Text("心情")
                            .font(.headline)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(moodOptions, id: \.self) { option in
                                    Button(action: { mood = option }) {
                                        Text(option)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(mood == option ? Color.pink : Color(.systemGray5))
                                            )
                                            .foregroundColor(mood == option ? .white : .primary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("寫日記")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        saveDiary()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }
    
    private func saveDiary() {
        let currentUserID = UUID() // 暫時使用隨機UUID
        let partnerID = UUID() // 暫時使用隨機UUID
        
        let diary = DiaryEntry(
            authorID: currentUserID,
            recipientID: partnerID,
            title: title,
            content: content,
            weather: weather.isEmpty ? nil : weather,
            mood: mood.isEmpty ? nil : mood,
            coverStyle: selectedCoverStyle
        )
        
        modelContext.insert(diary)
        dismiss()
    }
}

struct DiaryDetailView: View {
    let diary: DiaryEntry
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 標題和日期
                    VStack(alignment: .leading, spacing: 8) {
                        Text(diary.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(formatDate(diary.createdAt))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // 天氣和心情
                    HStack {
                        if let weather = diary.weather {
                            Label(weather, systemImage: "cloud.sun.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let mood = diary.mood {
                            Label(mood, systemImage: "face.smiling")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // 內容
                    Text(diary.content)
                        .font(.body)
                        .lineSpacing(4)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("日記詳情")
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    DiaryView()
        .modelContainer(for: DiaryEntry.self, inMemory: true)
}