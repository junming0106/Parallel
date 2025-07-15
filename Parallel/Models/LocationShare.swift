//
//  LocationShare.swift
//  Parallel
//
//  Created by 黃浚銘 on 2025/7/15.
//

import Foundation
import SwiftData
import CoreLocation

enum LocationSharingDuration: String, CaseIterable, Codable {
    case off
    case oneHour
    case twentyFourHours
    case permanent
}

@Model
final class LocationShare {
    var userID: String
    var partnerID: String
    var latitude: Double
    var longitude: Double
    var accuracy: Double
    var timestamp: Date
    var batteryLevel: Double?
    var sharingDuration: LocationSharingDuration
    var expiresAt: Date?
    var isActive: Bool
    
    init(userID: String, partnerID: String, latitude: Double, longitude: Double, accuracy: Double, batteryLevel: Double? = nil, sharingDuration: LocationSharingDuration = .off) {
        self.userID = userID
        self.partnerID = partnerID
        self.latitude = latitude
        self.longitude = longitude
        self.accuracy = accuracy
        self.timestamp = Date()
        self.batteryLevel = batteryLevel
        self.sharingDuration = sharingDuration
        self.isActive = sharingDuration != .off
        
        // Set expiration based on duration
        switch sharingDuration {
        case .off:
            self.expiresAt = nil
            self.isActive = false
        case .oneHour:
            self.expiresAt = Date().addingTimeInterval(3600)
        case .twentyFourHours:
            self.expiresAt = Date().addingTimeInterval(86400)
        case .permanent:
            self.expiresAt = nil
        }
    }
}