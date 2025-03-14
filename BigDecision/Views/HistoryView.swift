import SwiftUI
import UIKit

// 决策过滤器枚举
enum DecisionFilter: String, CaseIterable {
    case all = "全部"
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
    @EnvironmentObject var decisionStore: DecisionStore
    @State private var searchText = ""
    @State private var showingFilterOptions = false
    @State private var showingResetAlert = false
    @State private var selectedFilter: DecisionFilter = .all
    
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
        if selectedFilter != .all {
            decisions = decisions.filter { decision in
                switch selectedFilter {
                case .work:
                    return decision.decisionType == .work
                case .relationship:
                    return decision.decisionType == .relationship
                case .education:
                    return decision.decisionType == .education
                case .housing:
                    return decision.decisionType == .housing
                case .travel:
                    return decision.decisionType == .travel
                case .shopping:
                    return decision.decisionType == .shopping
                case .investment:
                    return decision.decisionType == .investment
                case .other:
                    return decision.decisionType == .other
                default:
                    return true
                }
            }
        }
        
        // 按时间排序（最新的在前面）
        return decisions.sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                SearchBar(text: $searchText, placeholder: "搜索决策...")
                    .padding(.horizontal)
                    .padding(.top, 10)
                
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
                    .padding(.vertical, 10)
                }
                
                // 决策列表
                List {
                    ForEach(filteredDecisions) { decision in
                        NavigationLink(destination: 
                            ResultView(decision: decision)
                                .navigationBarTitleDisplayMode(.inline)
                        ) {
                            HistoryItemRow(decision: decision)
                        }
                        .listRowInsets(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
                    }
                    .onDelete(perform: deleteDecision)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("决策历史")
            .navigationBarItems(
                trailing: EditButton()
                    .foregroundColor(Color("AppPrimary"))
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingResetAlert = true
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
            }
            .alert(isPresented: $showingResetAlert) {
                Alert(
                    title: Text("重置"),
                    message: Text("确定要重置所有数据吗？"),
                    primaryButton: .destructive(Text("重置")) {
                        withAnimation {
                            self.decisionStore.resetData()
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: decision.decisionType.icon)
                    .foregroundColor(Color("AppPrimary"))
                    .font(.system(size: 14))
                    .frame(width: 20, height: 20)
                    .background(Color("AppPrimary").opacity(0.1))
                    .clipShape(Circle())
                
                Text(decision.title)
                    .font(.headline)
                
                Spacer()
                
                Text(formatDate(decision.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
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
            
            if let result = decision.result {
                HStack {
                    Spacer()
                    
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
        .padding(.vertical, 5)
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