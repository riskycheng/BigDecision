//
//  ContentView.swift
//  BigDecision
//
//  Created by Jian Cheng on 2025/3/12.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showWelcome = true
    
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
            }
        }
        .onAppear {
            // 检查是否是首次启动
            let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
            showWelcome = !hasLaunchedBefore
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DecisionStore())
}
