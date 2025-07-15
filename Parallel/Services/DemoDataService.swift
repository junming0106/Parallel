//
//  DemoDataService.swift
//  Parallel
//
//  Created by 黃浚銘 on 2025/7/15.
//

import Foundation
import SwiftData

class DemoDataService {
    static let shared = DemoDataService()
    
    private init() {}
    
    func createDemoData(in context: ModelContext) {
        // 檢查是否已經有數據
        let userDescriptor = FetchDescriptor<User>()
        let existingUsers = try? context.fetch(userDescriptor)
        
        if existingUsers?.isEmpty == false {
            return // 已有數據，不重複創建
        }
        
        // 創建用戶
        let currentUser = User(name: "浚銘", email: "junming@parallel.app")
        let partnerUser = User(name: "親愛的", email: "partner@parallel.app")
        
        currentUser.isAuthenticated = true
        partnerUser.isAuthenticated = true
        currentUser.partnerID = partnerUser.id
        partnerUser.partnerID = currentUser.id
        
        context.insert(currentUser)
        context.insert(partnerUser)
        
        // 創建示例訊息
        let messages = [
            Message(senderID: currentUser.id, recipientID: partnerUser.id, content: "你好！這是心連心的第一則訊息 ❤️", type: .text),
            Message(senderID: partnerUser.id, recipientID: currentUser.id, content: "哇！這個 App 看起來很棒！", type: .text),
            Message(senderID: currentUser.id, recipientID: partnerUser.id, content: "想你 ❤️", type: .missYou),
            Message(senderID: partnerUser.id, recipientID: currentUser.id, content: "我也想你 💕", type: .text)
        ]
        
        for message in messages {
            message.status = .read
            context.insert(message)
        }
        
        // 創建示例日記
        let diary1 = DiaryEntry(
            authorID: currentUser.id,
            recipientID: partnerUser.id,
            title: "第一次約會",
            content: "今天我們一起去了電影院，看了一部很棒的電影。你的笑容讓我覺得整個世界都亮了起來。",
            weather: "☀️ 晴天",
            mood: "😍 戀愛"
        )
        diary1.status = .read
        diary1.sharedAt = Date().addingTimeInterval(-86400)
        diary1.readAt = Date().addingTimeInterval(-86400 + 3600)
        
        let diary2 = DiaryEntry(
            authorID: partnerUser.id,
            recipientID: currentUser.id,
            title: "溫馨的晚餐",
            content: "謝謝你今天為我準備的驚喜晚餐，每一道菜都充滿了愛意。和你在一起的每一刻都是最珍貴的回憶。",
            weather: "🌙 晚上",
            mood: "😊 開心"
        )
        diary2.status = .shared
        diary2.sharedAt = Date().addingTimeInterval(-43200)
        
        context.insert(diary1)
        context.insert(diary2)
        
        // 創建示例行事曆事件
        let events = [
            CalendarEvent(
                title: "週年紀念日",
                description: "我們在一起的第一個週年紀念日",
                type: .anniversary,
                startDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(),
                isAllDay: true,
                createdBy: currentUser.id,
                participantIDs: [currentUser.id, partnerUser.id],
                color: "pink"
            ),
            CalendarEvent(
                title: "情人節晚餐",
                description: "預訂了市中心的浪漫餐廳",
                type: .date,
                startDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())?.addingTimeInterval(7200),
                createdBy: currentUser.id,
                participantIDs: [currentUser.id, partnerUser.id],
                color: "red",
                location: "市中心浪漫餐廳"
            ),
            CalendarEvent(
                title: "週末旅行",
                description: "去台南的兩天一夜小旅行",
                type: .travel,
                startDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 16, to: Date()) ?? Date(),
                isAllDay: true,
                createdBy: partnerUser.id,
                participantIDs: [currentUser.id, partnerUser.id],
                color: "blue",
                location: "台南"
            )
        ]
        
        for event in events {
            context.insert(event)
        }
        
        // 創建示例位置分享
        let locationShare = LocationShare(
            userID: currentUser.id,
            partnerID: partnerUser.id,
            latitude: 25.0330,
            longitude: 121.5654,
            accuracy: 10.0,
            batteryLevel: 0.85,
            sharingDuration: .twentyFourHours
        )
        
        context.insert(locationShare)
        
        // 保存數據
        try? context.save()
    }
}