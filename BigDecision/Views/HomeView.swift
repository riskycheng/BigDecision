import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject var decisionStore: DecisionStore
    @State private var showingCreateView = false
    @State private var showingRandomDecisionView = false
    @State private var showingFavoritesView = false
    @State private var showingShareSheet = false
    @State private var showingStatsView = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // 背景色
                Color(.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                // 主内容
                VStack(spacing: 0) {
                    // 顶部渐变背景
                    ZStack(alignment: .bottom) {
                        LinearGradient(
                            gradient: Gradient(colors: [Color("AppPrimary"), Color("AppSecondary")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .edgesIgnoringSafeArea(.top)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("你好，用户")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("需要帮你做决定吗？")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Button(action: {
                                showingCreateView = true
                            }) {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("创建新决定")
                                }
                                .font(.headline)
                                .foregroundColor(Color("AppPrimary"))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 5)
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 15)
                    }
                    .frame(height: 180)
                    
                    ScrollView {
                        VStack(spacing: 30) {
                            // 最近的决定区域
                            VStack(spacing: 15) {
                                // 标题区域
                                HStack {
                                    Text("最近的决定")
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    NavigationLink(destination: HistoryView()) {
                                        Text("查看全部")
                                            .font(.subheadline)
                                            .foregroundColor(Color("AppPrimary"))
                                    }
                                }
                                .padding(.horizontal)
                                
                                // 内容区域
                                if decisionStore.decisions.isEmpty {
                                    // 空状态视图 - 移除背景色，使用外部容器的背景色
                                    EmptyStateView(
                                        icon: "list.bullet.clipboard",
                                        message: "你还没有做过任何决定",
                                        buttonText: "创建第一个决定",
                                        action: { showingCreateView = true }
                                    )
                                    .padding(.horizontal)
                                    .frame(height: 200)
                                    .background(Color.clear) // 确保背景透明
                                } else {
                                    // 决定卡片列表
                                    VStack(spacing: 10) {
                                        ForEach(Array(decisionStore.decisions.prefix(2).enumerated()), id: \.element.id) { index, decision in
                                            DecisionCard(decision: decision)
                                                .padding(.horizontal)
                                        }
                                    }
                                }
                            }
                            .padding(.top, 20)
                            .padding(.bottom, 15)
                            .background(Color.white) // 使用纯白色背景
                            .cornerRadius(15)
                            .padding(.horizontal, 5)
                            
                            // 快速操作区域
                            VStack(spacing: 15) {
                                // 标题
                                HStack {
                                    Text("快速操作")
                                        .font(.headline)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.top, 10)
                                .padding(.bottom, 10)
                                
                                // 操作卡片 - 匹配附图中的样式
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    ActionCard(icon: "shuffle", title: "随机决定", action: {
                                        randomDecision()
                                    })
                                    ActionCard(icon: "star.fill", title: "收藏的决定", action: {
                                        showingFavoritesView = true
                                    })
                                    ActionCard(icon: "square.and.arrow.up", title: "分享决定", action: {
                                        shareApp()
                                    })
                                    ActionCard(icon: "chart.bar.fill", title: "决定统计", action: {
                                        showingStatsView = true
                                    })
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 15)
                            }
                            .background(Color(.systemGroupedBackground)) // 使用系统分组背景色
                            .cornerRadius(15)
                            .padding(.horizontal, 5)
                            
                            // 底部空间
                            Spacer(minLength: 80)
                        }
                        .padding(.top, 10)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingCreateView) {
                CreateDecisionView()
            }
            .sheet(isPresented: $showingRandomDecisionView) {
                // 随机决定视图
                if let randomDecision = decisionStore.decisions.randomElement() {
                    ResultView(decision: randomDecision)
                } else {
                    Text("没有找到决定")
                        .font(.headline)
                        .padding()
                }
            }
            .sheet(isPresented: $showingFavoritesView) {
                // 收藏的决定视图
                Text("收藏功能即将上线")
                    .font(.headline)
                    .padding()
            }
            .sheet(isPresented: $showingStatsView) {
                // 决定统计视图
                Text("统计功能即将上线")
                    .font(.headline)
                    .padding()
            }
        }
    }
    
    func randomDecision() {
        if !decisionStore.decisions.isEmpty {
            showingRandomDecisionView = true
        } else {
            // 如果没有决定，提示用户创建一个
            showingCreateView = true
        }
    }
    
    func shareApp() {
        showingShareSheet = true
        
        // 在实际应用中，这里应该实现分享功能
        // 由于这是一个示例，我们只是显示一个提示
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showingShareSheet = false
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(DecisionStore())
} 