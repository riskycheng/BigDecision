//
//  ContentView.swift
//  BigDecision
//
//  Created by Jian Cheng on 2025/3/12.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import Foundation

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showWelcome = true
    @StateObject private var reanalysisCoordinator = ReanalysisCoordinator.shared
    @EnvironmentObject private var decisionStore: DecisionStore
    
    var body: some View {
        Group {
            if showWelcome {
                WelcomeView(showWelcome: $showWelcome)
            } else {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Label("首页", systemImage: "house.fill")
                        }
                        .tag(0)
                    
                    HistoryView()
                        .tabItem {
                            Label("历史", systemImage: "clock.fill")
                        }
                        .tag(1)
                    
                    SettingsView()
                        .tabItem {
                            Label("设置", systemImage: "gear")
                        }
                        .tag(2)
                }
                .accentColor(Color("AppPrimary"))
                #if canImport(UIKit)
                .onAppear {
                    let tabBarAppearance = UITabBarAppearance()
                    tabBarAppearance.configureWithOpaqueBackground()
                    
                    let normalAppearance = UITabBarItemAppearance()
                    tabBarAppearance.stackedLayoutAppearance = normalAppearance
                    
                    UITabBar.appearance().standardAppearance = tabBarAppearance
                    if #available(iOS 15.0, *) {
                        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                    }
                }
                #endif
            }
        }
        .onAppear {
            // 检查是否是首次启动
            let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
            showWelcome = !hasLaunchedBefore
        }
        // 监听重新分析请求并从底部弹出新的分析视图
        .sheet(isPresented: $reanalysisCoordinator.isShowingReanalysis, onDismiss: {
            // 当sheet被关闭时确保清理状态
            reanalysisCoordinator.endReanalysis()
        }) {
            if let decisionToReanalyze = reanalysisCoordinator.decisionToReanalyze {
                CreateDecisionView(initialDecision: decisionToReanalyze)
                    .environmentObject(decisionStore) // 使用现有的DecisionStore实例
                    .environmentObject(reanalysisCoordinator) // 传递ReanalysisCoordinator
                    .interactiveDismissDisabled(false)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DecisionStore())
}
