import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

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
            #if canImport(UIKit)
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            #else
            Color.gray.opacity(0.1)
                .ignoresSafeArea()
            #endif
            
            // 主内容
            VStack(spacing: 0) {
                // 顶部渐变背景
                ZStack(alignment: .top) {
                    LinearGradient(
                        gradient: Gradient(colors: [Color("AppPrimary"), Color("AppSecondary")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("你好，用户")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
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
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 5)
                        }
                        .padding(.top, 12)
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 160)
                
                ScrollView {
                    VStack(spacing: 15) { // 减小区域之间的间距
                        // 最近的决定区域
                        VStack(spacing: 12) { // 减小内部间距
                            // 标题区域
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
                            .padding(.top, 12) // 减少顶部内边距
                            .padding(.bottom, 6) // 减少底部内边距
                            
                            // 内容区域
                            if decisionStore.decisions.filter({ $0.result != nil }).isEmpty {
                                // 空状态视图 - 移除背景色，使用外部容器的背景色
                                EmptyStateView(
                                    icon: "list.bullet.clipboard",
                                    message: "你还没有完成任何决定",
                                    buttonText: "创建第一个决定",
                                    action: { showingCreateView = true }
                                )
                                .padding(.horizontal)
                                .frame(height: 180) // 减小空状态视图的高度
                                .background(Color.clear) // 确保背景透明
                            } else {
                                // 决定卡片列表
                                VStack(spacing: 10) {
                                    ForEach(Array(decisionStore.decisions
                                        .filter { $0.result != nil }
                                        .sorted(by: { $0.createdAt > $1.createdAt })
                                        .prefix(2)
                                        .enumerated()), id: \.element.id) { index, decision in
                                        Button(action: {
                                            selectedDecision = decision
                                            showingResultView = true
                                        }) {
                                            CompactHistoryItemRow(decision: decision)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.horizontal)
                                    }
                                }
                                .padding(.bottom, 16)
                            }
                        }
                        #if canImport(UIKit)
                        .background(Color(UIColor.systemBackground))
                        #else
                        .background(Color.white)
                        #endif
                        .cornerRadius(15)
                        .padding(.horizontal, 5)
                        
                        // 快速操作区域
                        VStack(spacing: 12) { // 减小间距
                            HStack {
                                Text("快速操作")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 12) // 减少顶部内边距
                            .padding(.bottom, 6) // 减少底部内边距
                            
                            // 操作卡片
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) { // 减小网格间距
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
                            .padding(.bottom, 12) // 减少底部内边距
                        }
                        #if canImport(UIKit)
                        .background(Color(UIColor.systemBackground))
                        #else
                        .background(Color.white)
                        #endif
                        .cornerRadius(15)
                        .padding(.horizontal, 5)
                        
                        // 底部空间
                        Spacer(minLength: 20) // 减小底部空间
                    }
                    .padding(.top, 8) // 减少顶部间距
                }
            }
        }
        .sheet(item: $selectedDecision) { decision in
            ResultView(decision: decision)
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
            if let randomPreset = PresetDecision.presets.randomElement() {
                let newDecision = randomPreset.toDecision()
                decisionStore.addDecision(newDecision)
                selectedDecision = newDecision
                showingResultView = true
            }
        }
    }
    
    #if canImport(UIKit)
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
    #else
    func shareApp() {
        // 非iOS平台分享功能的替代实现
        print("在非iOS平台上分享功能尚未实现")
    }
    #endif
}

struct CompactHistoryItemRow: View {
    let decision: Decision
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题和日期
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: decision.decisionType.icon)
                        .foregroundColor(Color("AppPrimary"))
                        .font(.system(size: 16))
                        .frame(width: 24, height: 24)
                        .background(Color("AppPrimary").opacity(0.1))
                        .clipShape(Circle())
                    
                    Text(decision.title)
                        .font(.system(size: 17, weight: .semibold))
                        .lineLimit(1)
                    
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(decision.createdAt.formatRelativeDate())
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            if let result = decision.result {
                // 结果和置信度
                VStack(alignment: .leading, spacing: 8) {
                    // 结果
                    HStack(spacing: 8) {
                        Text("结果")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            #if canImport(UIKit)
                            .background(Color(UIColor.systemGray6))
                            #else
                            .background(Color.gray.opacity(0.1))
                            #endif
                            .cornerRadius(4)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 13))
                        
                        Text(result.recommendation == "A" ? decision.options[0].title : decision.options[1].title)
                            .font(.system(size: 15, weight: .medium))
                            .lineLimit(1)
                        
                        Image(systemName: "info.circle")
                            .font(.system(size: 12))
                            .foregroundColor(Color("AppPrimary").opacity(0.6))
                    }
                    
                    // 置信度
                    HStack(spacing: 8) {
                        Text("\(Int(result.confidence * 100))%")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color("AppPrimary"))
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color("AppPrimary").opacity(0.2))
                                    .frame(width: geometry.size.width, height: 6)
                                    .cornerRadius(3)
                                
                                Rectangle()
                                    .fill(Color("AppPrimary"))
                                    .frame(width: geometry.size.width * result.confidence, height: 6)
                                    .cornerRadius(3)
                            }
                        }
                        .frame(height: 6)
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
    }
}

#Preview {
    HomeView()
        .environmentObject(DecisionStore())
} 