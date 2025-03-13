import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject var decisionStore: DecisionStore
    @State private var showingCreateView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 顶部渐变背景
                    ZStack(alignment: .bottom) {
                        Rectangle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color("AppPrimary"), Color("AppSecondary")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
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
                    
                    // 最近的决定
                    VStack(alignment: .leading, spacing: 15) {
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
                        .padding(.top, 20)
                        
                        if decisionStore.decisions.isEmpty {
                            EmptyStateView(
                                icon: "list.bullet.clipboard",
                                message: "你还没有做过任何决定",
                                buttonText: "创建第一个决定",
                                action: { showingCreateView = true }
                            )
                        } else {
                            ForEach(decisionStore.decisions.prefix(2)) { decision in
                                DecisionCard(decision: decision)
                            }
                        }
                    }
                    .padding()
                    
                    // 快速操作
                    VStack(alignment: .leading) {
                        Text("快速操作")
                            .font(.headline)
                            .padding(.bottom, 10)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ActionCard(icon: "shuffle", title: "随机决定")
                            ActionCard(icon: "star.fill", title: "收藏的决定")
                            ActionCard(icon: "square.and.arrow.up", title: "分享决定")
                            ActionCard(icon: "chart.bar.fill", title: "决定统计")
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("")
            .sheet(isPresented: $showingCreateView) {
                CreateDecisionView()
            }
        }
    }
}

struct DecisionCard: View {
    let decision: Decision
    
    var body: some View {
        NavigationLink(destination: ResultView(decision: decision)) {
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
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(Color("AppPrimary"))
            
            Text(title)
                .font(.subheadline)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
    }
}

struct EmptyStateView: View {
    let icon: String
    let message: String
    let buttonText: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(Color.gray.opacity(0.5))
            
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: action) {
                Text(buttonText)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
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