import SwiftUI
import UIKit

// 决策过滤器枚举
enum DecisionFilter: String, CaseIterable {
    case all = "全部"
    case favorites = "收藏"
    case work = "工作"
    case relationship = "感情"
    case education = "教育"
    case housing = "住房"
    case travel = "旅行"
    case shopping = "购物"
    case investment = "投资"
    case other = "其他"
    
    var title: String {
        return self.rawValue
    }
}

struct HistoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var decisionStore: DecisionStore
    @State private var searchText = ""
    @State private var selectedFilter: DecisionFilter
    @State private var selectedDecision: Decision? = nil
    
    init(initialFilter: DecisionFilter = .all) {
        _selectedFilter = State(initialValue: initialFilter)
    }
    
    var filteredDecisions: [Decision] {
        var decisions = decisionStore.decisions
        
        // 按搜索文本过滤
        if !searchText.isEmpty {
            decisions = decisions.filter { decision in
                decision.title.localizedCaseInsensitiveContains(searchText) ||
                decision.optionA.title.localizedCaseInsensitiveContains(searchText) ||
                decision.optionB.title.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // 按过滤器过滤
        switch selectedFilter {
        case .favorites:
            decisions = decisions.filter { $0.isFavorited }
        case .all:
            break
        default:
            decisions = decisions.filter { $0.decisionType.rawValue == selectedFilter.rawValue }
        }
        
        // 按时间排序（最新的在前面）
        return decisions.sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // 背景色
                Color(.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // 顶部渐变背景
                    ZStack(alignment: .top) {
                        LinearGradient(
                            gradient: Gradient(colors: [Color("AppPrimary"), Color("AppSecondary")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .edgesIgnoringSafeArea(.top)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("决策历史")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.top, 20)
                            
                            Text("查找你的历史决策")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                            
                            // 搜索栏
                            SearchBar(text: $searchText, placeholder: "搜索决策...")
                                .padding(.top, 12)
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 160)
                    
                    // 过滤器
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(DecisionFilter.allCases, id: \.self) { filter in
                                FilterButton(
                                    title: filter.title,
                                    isSelected: selectedFilter == filter,
                                    action: {
                                        selectedFilter = filter
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    
                    // 决策列表
                    List {
                        ForEach(filteredDecisions) { decision in
                            Button(action: {
                                selectedDecision = decision
                            }) {
                                HistoryItemRow(decision: decision)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: deleteDecision)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedDecision) { decision in
                ResultView(decision: decision)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func deleteDecision(at offsets: IndexSet) {
        if let index = offsets.first {
            let decision = filteredDecisions[index]
            decisionStore.deleteDecision(decision)
        }
    }
}

struct HistoryItemRow: View {
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
                }
                
                Spacer()
                
                Text(formatDate(decision.createdAt))
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
                            .background(Color(.systemGray6))
                            .cornerRadius(4)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 13))
                        
                        Text(result.recommendation == "A" ? decision.optionA.title : decision.optionB.title)
                            .font(.system(size: 15, weight: .medium))
                    }
                    
                    // 置信度
                    HStack(spacing: 8) {
                        Text("置信度")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray6))
                            .cornerRadius(4)
                        
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
                        
                        Text("\(Int(result.confidence * 100))%")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color("AppPrimary"))
                            .frame(width: 45, alignment: .trailing)
                    }
                    .frame(height: 24)
                    .alignmentGuide(.firstTextBaseline) { d in
                        d[.bottom] - 8
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
}

struct FilterButton: View {
    let title: String
    var icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                }
                
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color("AppPrimary") : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(DecisionStore())
} 