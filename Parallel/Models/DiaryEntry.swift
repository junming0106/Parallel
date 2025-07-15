//
//  DiaryEntry.swift
//  Parallel
//
//  Created by 黃浚銘 on 2025/7/15.
//

import Foundation
import SwiftData

enum DiaryStatus: String, CaseIterable, Codable {
    case writing
    case locked
    case shared
    case read
}

@Model
final class DiaryEntry {
    var authorID: String
    var recipientID: String
    var title: String
    var content: String
    var status: DiaryStatus
    var createdAt: Date
    var sharedAt: Date?
    var readAt: Date?
    var weather: String?
    var mood: String?
    var coverStyle: String
    var images: [Data]
    
    init(authorID: String, recipientID: String, title: String, content: String, weather: String? = nil, mood: String? = nil, coverStyle: String = "default") {
        self.authorID = authorID
        self.recipientID = recipientID
        self.title = title
        self.content = content
        self.status = .writing
        self.createdAt = Date()
        self.sharedAt = nil
        self.readAt = nil
        self.weather = weather
        self.mood = mood
        self.coverStyle = coverStyle
        self.images = []
    }
}