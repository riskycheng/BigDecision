//
//  BigDecisionApp.swift
//  BigDecision
//
//  Created by Jian Cheng on 2025/3/12.
//

import SwiftUI

@main
struct BigDecisionApp: App {
    @StateObject private var decisionStore = DecisionStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(decisionStore)
        }
    }
}
