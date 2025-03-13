import SwiftUI
import UIKit

struct HistoryView: View {
    @EnvironmentObject var decisionStore: DecisionStore
    @State private var searchText = ""
    @State private var showingFilterOptions = false
    @State private var selectedType: Decision.DecisionType?
    @State private var showingResetAlert = false
    
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
        
        // 按类型过滤
        if let type = selectedType {
            decisions = decisions.filter { $0.decisionType == type }
        }
        
        // 按时间排序（最新的在前面）
        return decisions.sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("搜索决定", text: $searchText)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        showingFilterOptions.toggle()
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle\(selectedType != nil ? ".fill" : "")")
                            .foregroundColor(selectedType != nil ? Color("AppPrimary") : .secondary)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top)
                
                // 过滤选项
                if showingFilterOptions {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            FilterButton(title: "全部", isSelected: selectedType == nil) {
                                selectedType = nil
                            }
                            
                            ForEach(Decision.DecisionType.allCases, id: \.self) { type in
                                FilterButton(
                                    title: type.rawValue,
                                    icon: type.icon,
                                    isSelected: selectedType == type
                                ) {
                                    selectedType = type
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 10)
                }
                
                // 决策列表
                if filteredDecisions.isEmpty {
                    EmptyStateView(
                        icon: "clock",
                        message: searchText.isEmpty && selectedType == nil ?
                            "你还没有做过任何决定" : "没有找到匹配的决定",
                        buttonText: "创建新决定",
                        action: {}
                    )
                } else {
                    List {
                        ForEach(filteredDecisions) { decision in
                            NavigationLink(destination: ResultView(decision: decision)) {
                                HistoryItemRow(decision: decision)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    decisionStore.deleteDecision(decision)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("历史决定")
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