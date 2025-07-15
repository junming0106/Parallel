//
//  User.swift
//  Parallel
//
//  Created by 黃浚銘 on 2025/7/15.
//

import Foundation
import SwiftData

@Model
final class User {
    var name: String
    var email: String
    var profileImageData: Data?
    var createdAt: Date
    var partnerID: String?
    var isAuthenticated: Bool
    
    init(name: String, email: String, profileImageData: Data? = nil) {
        self.name = name
        self.email = email
        self.profileImageData = profileImageData
        self.createdAt = Date()
        self.partnerID = nil
        self.isAuthenticated = false
    }
}