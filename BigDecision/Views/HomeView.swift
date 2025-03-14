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
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 顶部渐变背景
                    ZStack(alignment: .bottom) {
                        // 使用GeometryReader确保背景扩展到顶部安全区域之外
                        GeometryReader { geometry in
                            LinearGradient(
                                gradient: Gradient(colors: [Color("AppPrimary"), Color("AppSecondary")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .frame(width: geometry.size.width, height: geometry.frame(in: .global).minY > 0 ? geometry.frame(in: .global).minY + 180 : 180)
                            .offset(y: geometry.frame(in: .global).minY > 0 ? -geometry.frame(in: .global).minY : 0)
                        }
                        .frame(height: 180)
                        
                        VStack(alignment: .leading, spacing: 10) {
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
                            .padding(.top, 10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                    
                    // 最近的决定 - 适当调整间距
                    VStack(alignment: .leading, spacing: 12) {
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
                        .padding(.top, 15)
                        
                        if decisionStore.decisions.isEmpty {
                            EmptyStateView(
                                icon: "list.bullet.clipboard",
                                message: "你还没有做过任何决定",
                                buttonText: "创建第一个决定",
                                action: { showingCreateView = true }
                            )
                            .frame(height: 150) // 增加空状态视图的高度
                        } else {
                            ForEach(decisionStore.decisions.prefix(2)) { decision in
                                DecisionCard(decision: decision)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10) // 增加垂直间距
                    
                    // 快速操作 - 适当调整间距
                    VStack(alignment: .leading, spacing: 12) {
                        Text("快速操作")
                            .font(.headline)
                            .padding(.bottom, 8)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
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
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10) // 增加垂直间距
                    
                    // 添加底部间距，确保内容填充屏幕
                    Spacer()
                        .frame(height: 20)
                }
            }
            .edgesIgnoringSafeArea(.top) // 忽略顶部安全区域，使背景色延伸到顶部
            .navigationTitle("")
            .navigationBarHidden(true) // 隐藏导航栏，让背景色完全显示
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
    
    private func randomDecision() {
        if decisionStore.decisions.isEmpty {
            // 如果没有决定，显示创建新决定视图
            showingCreateView = true
        } else {
            // 随机选择一个决定
            showingRandomDecisionView = true
        }
    }
    
    private func shareApp() {
        // 分享应用
        let items = ["我正在使用「大决定」App帮助我做决策，推荐你也试试！"]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(ac, animated: true)
        }
    }
}

struct DecisionCard: View {
    let decision: Decision
    
    var body: some View {
        NavigationLink(destination: 
            ResultView(decision: decision)
                .navigationBarTitleDisplayMode(.inline)
        ) {
            VStack(alignment: .leading, spacing: 10) {
                Text(decision.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(decision.optionA.title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("vs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 5)
                    
                    Text(decision.optionB.title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(formatDate(decision.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let result = decision.result {
                        Text("推荐：\(result.recommendation == "A" ? decision.optionA.title : decision.optionB.title)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color("AppPrimary"))
                            .cornerRadius(20)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
}

struct ActionCard: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) { // 增加间距
                Image(systemName: icon)
                    .font(.system(size: 26)) // 增加图标尺寸
                    .foregroundColor(Color("AppPrimary"))
                
                Text(title)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15) // 增加垂直内边距
            .padding(.horizontal, 10)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyStateView: View {
    let icon: String
    let message: String
    let buttonText: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 15) { // 增加间距
            Image(systemName: icon)
                .font(.system(size: 45)) // 增加图标尺寸
                .foregroundColor(Color.gray.opacity(0.5))
            
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 5)
            
            Button(action: action) {
                Text(buttonText)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 12) // 增加按钮垂直内边距
                    .frame(maxWidth: .infinity)
                    .background(Color("AppPrimary"))
                    .cornerRadius(12)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeView()
        .environmentObject(DecisionStore())
} 