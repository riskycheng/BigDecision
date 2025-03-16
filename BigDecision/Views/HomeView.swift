import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject var decisionStore: DecisionStore
    @State private var showingCreateView = false
    @State private var showingRandomDecisionView = false
    @State private var showingFavoritesView = false
    @State private var showingShareSheet = false
    @State private var showingStatsView = false
    @State private var showingResultView = false
    @State private var selectedDecision: Decision? = nil
    @State private var showingHistoryView = false
    
    var body: some View {
        ZStack(alignment: .top) {
            // 背景色
            Color(.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            
            // 主内容
            VStack(spacing: 0) {
                // 顶部渐变背景
                ZStack(alignment: .top) {
                    LinearGradient(
                        gradient: Gradient(colors: [Color("AppPrimary"), Color("AppSecondary")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .edgesIgnoringSafeArea(.top)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        // 减小内部间距
                        Text("你好，用户")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 25) // 减少顶部距离
                        
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
                            .padding(.vertical, 12) // 保持按钮的垂直内边距
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 5)
                        }
                        .padding(.top, 6) // 保持按钮上方的间距
                        .padding(.bottom, 15) // 增加按钮下方的间距
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity) // 确保宽度填满
                }
                .frame(height: 150) // 保持整个顶部区域的高度
                
                ScrollView {
                    VStack(spacing: 20) { // 减小区域之间的间距
                        // 最近的决定区域
                        VStack(spacing: 15) {
                            // 标题区域 - 修改样式与间距
                            HStack {
                                Text("最近的决定")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Button(action: {
                                    showingHistoryView = true
                                }) {
                                    Text("查看全部")
                                        .font(.subheadline)
                                        .foregroundColor(Color("AppPrimary"))
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                            
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
                                .frame(height: 180) // 减小空状态视图的高度
                                .background(Color.clear) // 确保背景透明
                            } else {
                                // 决定卡片列表
                                VStack(spacing: 10) {
                                    ForEach(Array(decisionStore.decisions.prefix(2).enumerated()), id: \.element.id) { index, decision in
                                        Button(action: {
                                            selectedDecision = decision
                                            showingResultView = true
                                        }) {
                                            HistoryItemRow(decision: decision)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.horizontal)
                                    }
                                }
                                .padding(.bottom, 16)
                            }
                        }
                        .background(Color(.systemBackground)) // 使用系统背景色，与卡片形成对比
                        .cornerRadius(15)
                        .padding(.horizontal, 5)
                        
                        // 快速操作区域
                        VStack(spacing: 15) {
                            // 标题 - 修改样式与间距，与"最近的决定"保持一致
                            HStack {
                                Text("快速操作")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                            
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
                            .padding(.bottom, 16)
                        }
                        .background(Color(.systemBackground)) // 使用系统背景色，与卡片形成对比
                        .cornerRadius(15)
                        .padding(.horizontal, 5)
                        
                        // 底部空间
                        Spacer(minLength: 60) // 减小底部空间
                    }
                    .padding(.top, 10)
                }
            }
        }
        .sheet(isPresented: $showingCreateView) {
            CreateDecisionView()
        }
        .sheet(isPresented: $showingRandomDecisionView) {
            if let randomDecision = decisionStore.decisions.randomElement() {
                ResultView(decision: randomDecision)
            } else {
                Text("没有找到决定")
                    .font(.headline)
                    .padding()
            }
        }
        .sheet(isPresented: $showingFavoritesView) {
            HistoryView(initialFilter: .favorites)
        }
        .sheet(isPresented: $showingStatsView) {
            StatsView()
        }
        .sheet(isPresented: $showingResultView) {
            if let decision = selectedDecision {
                ResultView(decision: decision)
            }
        }
        .sheet(isPresented: $showingHistoryView) {
            HistoryView()
        }
    }
    
    func randomDecision() {
        if !decisionStore.decisions.isEmpty {
            // 从已有决定中随机选择
            showingRandomDecisionView = true
        } else {
            // 从预设决定中随机选择
            let presetDecision = PresetDecision.random()
            showingCreateView = true
            // 这里需要通过环境变量或其他方式将预设决定传递给 CreateDecisionView
        }
    }
    
    func shareApp() {
        let text = """
        我正在使用"大决定"App来帮助我做出更明智的选择！
        
        它使用 AI 技术帮助分析决策，考虑多个维度，给出科学的建议。
        
        你也来试试吧！
        """
        
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(DecisionStore())
} 