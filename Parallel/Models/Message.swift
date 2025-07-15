//
//  Message.swift
//  Parallel
//
//  Created by 黃浚銘 on 2025/7/15.
//

import Foundation
import SwiftData

enum MessageType: String, CaseIterable, Codable {
    case text
    case image
    case voice
    case video
    case missYou
    case emoji
}

enum MessageStatus: String, CaseIterable, Codable {
    case sending
    case sent
    case delivered
    case read
}

@Model
final class Message {
    var id: UUID
    var senderID: UUID
    var recipientID: UUID
    var content: String
    var type: MessageType
    var status: MessageStatus
    var timestamp: Date
    var mediaData: Data?
    var mediaURL: String?
    var isEncrypted: Bool
    
    init(senderID: UUID, recipientID: UUID, content: String, type: MessageType = .text, mediaData: Data? = nil) {
        self.id = UUID()
        self.senderID = senderID
        self.recipientID = recipientID
        self.content = content
        self.type = type
        self.status = .sending
        self.timestamp = Date()
        self.mediaData = mediaData
        self.mediaURL = nil
        self.isEncrypted = true
    }
}