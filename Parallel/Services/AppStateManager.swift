//
//  AppStateManager.swift
//  Parallel
//
//  Created by 黃浚銘 on 2025/7/15.
//

import Foundation
import SwiftUI

class AppStateManager: ObservableObject {
    @Published var isFirstLaunch = true
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var partnerUser: User?
    
    static let shared = AppStateManager()
    
    private init() {
        checkFirstLaunch()
    }
    
    private func checkFirstLaunch() {
        isFirstLaunch = !UserDefaults.standard.bool(forKey: "HasLaunchedBefore")
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
        }
    }
    
    func createDemoUser() {
        let demoUser = User(name: "浚銘", email: "demo@parallel.app")
        demoUser.isAuthenticated = true
        currentUser = demoUser
        isAuthenticated = true
        
        // 創建一個虛擬伴侶
        let partnerUser = User(name: "親愛的", email: "partner@parallel.app")
        partnerUser.isAuthenticated = true
        self.partnerUser = partnerUser
        
        // 設定互相為伴侶（使用簡單的字符串ID）
        demoUser.partnerID = "partner-user"
        partnerUser.partnerID = "current-user"
    }
}