//
//  ChatView.swift
//  Parallel
//
//  Created by 黃浚銘 on 2025/7/15.
//

import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var messages: [Message]
    @State private var newMessage = ""
    @State private var showingImagePicker = false
    @State private var showingEmojiPicker = false
    
    private var sortedMessages: [Message] {
        messages.sorted { $0.timestamp < $1.timestamp }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // 聊天記錄
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(sortedMessages, id: \.id) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding()
                }
                
                // 輸入區域
                VStack {
                    HStack(spacing: 12) {
                        // 附加按鈕
                        Button(action: { showingImagePicker = true }) {
                            Image(systemName: "photo")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                        }
                        
                        // 文字輸入框
                        TextField("輸入訊息...", text: $newMessage)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                sendMessage()
                            }
                        
                        // 表情符號按鈕
                        Button(action: { showingEmojiPicker = true }) {
                            Image(systemName: "face.smiling")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                        }
                        
                        // 發送按鈕
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.pink)
                        }
                        .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal)
                    
                    // 想你按鈕
                    Button(action: sendMissYouMessage) {
                        HStack {
                            Image(systemName: "heart.fill")
                            Text("想你")
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.pink)
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
            }
            .navigationTitle("聊天")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker()
        }
        .sheet(isPresented: $showingEmojiPicker) {
            EmojiPicker()
        }
    }
    
    private func sendMessage() {
        let trimmedMessage = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        // 這裡應該獲取實際的用戶ID和對方ID
        let currentUserID = UUID() // 暫時使用隨機UUID
        let partnerID = UUID() // 暫時使用隨機UUID
        
        let message = Message(
            senderID: currentUserID,
            recipientID: partnerID,
            content: trimmedMessage,
            type: .text
        )
        
        modelContext.insert(message)
        newMessage = ""
        
        // 這裡應該加入實際的網絡發送邏輯
        updateMessageStatus(message, to: .sent)
    }
    
    private func sendMissYouMessage() {
        let currentUserID = UUID() // 暫時使用隨機UUID
        let partnerID = UUID() // 暫時使用隨機UUID
        
        let message = Message(
            senderID: currentUserID,
            recipientID: partnerID,
            content: "想你 ❤️",
            type: .missYou
        )
        
        modelContext.insert(message)
        updateMessageStatus(message, to: .sent)
    }
    
    private func updateMessageStatus(_ message: Message, to status: MessageStatus) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            message.status = status
            try? modelContext.save()
        }
    }
}

struct MessageBubble: View {
    let message: Message
    private let currentUserID = UUID() // 暫時使用固定UUID
    
    private var isFromCurrentUser: Bool {
        message.senderID == currentUserID
    }
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
                messageBubbleContent
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.pink)
                    )
            } else {
                messageBubbleContent
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray5))
                    )
                Spacer()
            }
        }
        .padding(.horizontal, 4)
    }
    
    private var messageBubbleContent: some View {
        VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
            if message.type == .missYou {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(isFromCurrentUser ? .white : .pink)
                    Text(message.content)
                        .font(.headline)
                        .foregroundColor(isFromCurrentUser ? .white : .primary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            } else {
                Text(message.content)
                    .foregroundColor(isFromCurrentUser ? .white : .primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
            
            HStack(spacing: 4) {
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(isFromCurrentUser ? .white.opacity(0.7) : .secondary)
                
                if isFromCurrentUser {
                    messageStatusIcon
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 4)
        }
    }
    
    private var messageStatusIcon: some View {
        switch message.status {
        case .sending:
            return Image(systemName: "clock")
        case .sent:
            return Image(systemName: "checkmark")
        case .delivered:
            return Image(systemName: "checkmark.circle")
        case .read:
            return Image(systemName: "checkmark.circle.fill")
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// 臨時的圖片選擇器
struct ImagePicker: View {
    var body: some View {
        Text("圖片選擇器")
            .font(.title)
            .padding()
    }
}

// 臨時的表情符號選擇器
struct EmojiPicker: View {
    let emojis = ["😀", "😍", "🥰", "😘", "❤️", "💕", "💖", "🌹", "🎉", "🎊"]
    
    var body: some View {
        NavigationView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                ForEach(emojis, id: \.self) { emoji in
                    Button(action: {
                        // 這裡處理表情符號選擇
                    }) {
                        Text(emoji)
                            .font(.system(size: 30))
                            .frame(width: 50, height: 50)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .navigationTitle("表情符號")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ChatView()
        .modelContainer(for: Message.self, inMemory: true)
}