//
//  CalendarEvent.swift
//  Parallel
//
//  Created by 黃浚銘 on 2025/7/15.
//

import Foundation
import SwiftData

enum EventType: String, CaseIterable, Codable {
    case anniversary
    case date
    case travel
    case todo
    case milestone
}

@Model
final class CalendarEvent {
    var title: String
    var description: String
    var type: EventType
    var startDate: Date
    var endDate: Date?
    var isAllDay: Bool
    var isRecurring: Bool
    var reminderTime: Date?
    var createdBy: String
    var participantIDs: [String]
    var color: String
    var location: String?
    var createdAt: Date
    
    init(title: String, description: String = "", type: EventType, startDate: Date, endDate: Date? = nil, isAllDay: Bool = false, isRecurring: Bool = false, createdBy: String, participantIDs: [String] = [], color: String = "blue", location: String? = nil) {
        self.title = title
        self.description = description
        self.type = type
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.isRecurring = isRecurring
        self.reminderTime = nil
        self.createdBy = createdBy
        self.participantIDs = participantIDs
        self.color = color
        self.location = location
        self.createdAt = Date()
    }
}