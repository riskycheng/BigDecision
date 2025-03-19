import SwiftUI
import Charts

struct StatsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var decisionStore: DecisionStore
    @State private var selectedTimeRange = TimeRange.all
    
    enum TimeRange: String, CaseIterable {
        case week = "本周"
        case month = "本月"
        case year = "今年"
        case all = "全部"
    }
    
    private var filteredDecisions: [Decision] {
        let calendar = Calendar.current
        let now = Date()
        
        return decisionStore.decisions.filter { decision in
            switch selectedTimeRange {
            case .week:
                return calendar.isDate(decision.createdAt, equalTo: now, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(decision.createdAt, equalTo: now, toGranularity: .month)
            case .year:
                return calendar.isDate(decision.createdAt, equalTo: now, toGranularity: .year)
            case .all:
                return true
            }
        }
    }
    
    private var typeDistribution: [(type: Decision.DecisionType, count: Int)] {
        var distribution: [Decision.DecisionType: Int] = [:]
        Decision.DecisionType.allCases.forEach { distribution[$0] = 0 }
        
        filteredDecisions.forEach { decision in
            distribution[decision.decisionType, default: 0] += 1
        }
        
        return distribution.sorted { $0.value > $1.value }
            .map { (type: $0.key, count: $0.value) }
    }
    
    private var confidenceDistribution: [(range: String, count: Int)] {
        var ranges = [
            "90-100%": 0,
            "80-90%": 0,
            "70-80%": 0,
            "60-70%": 0,
            "< 60%": 0
        ]
        
        filteredDecisions.forEach { decision in
            if let confidence = decision.result?.confidence {
                let percentage = confidence * 100
                switch percentage {
                case 90...100:
                    ranges["90-100%"]! += 1
                case 80..<90:
                    ranges["80-90%"]! += 1
                case 70..<80:
                    ranges["70-80%"]! += 1
                case 60..<70:
                    ranges["60-70%"]! += 1
                default:
                    ranges["< 60%"]! += 1
                }
            }
        }
        
        return ranges.map { (range: $0.key, count: $0.value) }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // 背景色
                #if canImport(UIKit)
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                #else
                Color.gray.opacity(0.1)
                    .ignoresSafeArea()
                #endif
                
                VStack(spacing: 0) {
                    // 顶部渐变背景
                    ZStack(alignment: .top) {
                        LinearGradient(
                            gradient: Gradient(colors: [Color("AppPrimary"), Color("AppSecondary")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("决策统计")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.top, 25)
                            
                            Text("了解你的决策模式")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                            
                            // 时间范围选择器
                            Picker("时间范围", selection: $selectedTimeRange) {
                                ForEach(TimeRange.allCases, id: \.self) { range in
                                    Text(range.rawValue).tag(range)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.top, 12)
                            .padding(.bottom, 15)
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 150)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // 总览卡片
                            StatsOverviewCard(decisions: filteredDecisions)
                                .padding(.top, 20)
                            
                            // 决策类型分布
                            StatsCard(title: "决策类型分布") {
                                Chart(typeDistribution, id: \.type) { item in
                                    BarMark(
                                        x: .value("数量", item.count),
                                        y: .value("类型", item.type.rawValue)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color("AppPrimary"), Color("AppSecondary")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                }
                                .frame(height: CGFloat(typeDistribution.count * 40))
                                .padding(.vertical)
                            }
                            
                            // 置信度分布
                            StatsCard(title: "置信度分布") {
                                Chart(confidenceDistribution, id: \.range) { item in
                                    BarMark(
                                        x: .value("范围", item.range),
                                        y: .value("数量", item.count)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color("AppPrimary"), Color("AppSecondary")],
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                    )
                                }
                                .frame(height: 200)
                                .padding(.vertical)
                            }
                            
                            // 决策时间分布
                            StatsCard(title: "决策时间分布") {
                                TimeDistributionChart(decisions: filteredDecisions)
                                    .frame(height: 200)
                                    .padding(.vertical)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct StatsOverviewCard: View {
    let decisions: [Decision]
    
    private var totalDecisions: Int {
        decisions.count
    }
    
    private var averageConfidence: Double {
        let confidences = decisions.compactMap { $0.result?.confidence }
        return confidences.isEmpty ? 0 : confidences.reduce(0, +) / Double(confidences.count)
    }
    
    private var favoriteDecisions: Int {
        decisions.filter { $0.isFavorited }.count
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text("总览")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                StatItem(
                    title: "总决策数",
                    value: "\(totalDecisions)",
                    icon: "list.bullet",
                    color: .blue
                )
                
                StatItem(
                    title: "平均置信度",
                    value: String(format: "%.0f%%", averageConfidence * 100),
                    icon: "chart.bar.fill",
                    color: .green
                )
                
                StatItem(
                    title: "收藏数",
                    value: "\(favoriteDecisions)",
                    icon: "star.fill",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatsCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            content
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
    }
}

struct TimeDistributionChart: View {
    let decisions: [Decision]
    
    private var timeData: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        var dayData: [Date: Int] = [:]
        calendar.enumerateDates(startingAfter: startOfMonth, matching: DateComponents(hour: 0), matchingPolicy: .nextTime) { date, _, stop in
            if let date = date {
                if date > endOfMonth {
                    stop = true
                } else {
                    dayData[date] = 0
                }
            }
        }
        
        decisions.forEach { decision in
            let day = calendar.startOfDay(for: decision.createdAt)
            dayData[day, default: 0] += 1
        }
        
        return dayData.sorted { $0.key < $1.key }
            .map { (date: $0.key, count: $0.value) }
    }
    
    var body: some View {
        Chart(timeData, id: \.date) { item in
            LineMark(
                x: .value("日期", item.date),
                y: .value("数量", item.count)
            )
            .foregroundStyle(Color("AppPrimary"))
            
            AreaMark(
                x: .value("日期", item.date),
                y: .value("数量", item.count)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [Color("AppPrimary").opacity(0.3), Color("AppPrimary").opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.day())
            }
        }
    }
}

#Preview {
    StatsView()
        .environmentObject(DecisionStore())
} 