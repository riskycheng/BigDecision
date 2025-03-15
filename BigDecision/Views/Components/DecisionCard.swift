import SwiftUI

struct DecisionCard: View {
    var decision: Decision
    
    var body: some View {
        NavigationLink(destination: ResultView(decision: decision)) {
            VStack(alignment: .leading, spacing: 0) {
                // 标题和日期
                HStack(alignment: .center) {
                    Text(decision.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(formattedDate(decision.createdAt))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)
                
                // 选项和结果
                HStack(spacing: 12) {
                    // 选项部分
                    VStack(alignment: .leading, spacing: 6) {
                        Text("选项")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(4)
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color("AppPrimary").opacity(0.7))
                                .frame(width: 6, height: 6)
                            
                            Text(decision.optionA.title)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color("AppSecondary").opacity(0.7))
                                .frame(width: 6, height: 6)
                            
                            Text(decision.optionB.title)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 分隔线
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 1)
                        .padding(.vertical, 4)
                    
                    // 结果部分
                    VStack(alignment: .leading, spacing: 6) {
                        Text("结果")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(4)
                        
                        if let result = decision.result {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color.green)
                                    .font(.system(size: 12))
                                
                                Text(result.recommendation == "A" ? decision.optionA.title : decision.optionB.title)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                            }
                            
                            HStack {
                                Text("置信度:")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                // 置信度条
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 4)
                                        .cornerRadius(2)
                                    
                                    Rectangle()
                                        .fill(Color("AppPrimary"))
                                        .frame(width: 50 * CGFloat(result.confidence), height: 4)
                                        .cornerRadius(2)
                                }
                            }
                        } else {
                            HStack(spacing: 4) {
                                Image(systemName: "questionmark.circle")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 12))
                                
                                Text("未决定")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle()) // 使NavigationLink不显示默认的蓝色样式
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
}

struct DecisionCard_Previews: PreviewProvider {
    static var previews: some View {
        DecisionCard(decision: Decision(
            title: "午餐吃什么",
            optionA: Decision.Option(title: "麻辣烫", description: ""),
            optionB: Decision.Option(title: "汉堡", description: ""),
            additionalInfo: "",
            decisionType: .other,
            importance: 3,
            timeFrame: .immediate,
            result: Decision.Result(
                recommendation: "A",
                confidence: 0.8,
                reasoning: "麻辣烫更符合今天的心情",
                prosA: ["美味", "暖胃"],
                consA: ["可能辣"],
                prosB: ["快捷", "方便"],
                consB: ["不够健康"]
            ),
            createdAt: Date()
        ))
        .previewLayout(.sizeThatFits)
        .padding()
        
        DecisionCard(decision: Decision(
            title: "午餐吃什么",
            optionA: Decision.Option(title: "麻辣烫", description: ""),
            optionB: Decision.Option(title: "汉堡", description: ""),
            additionalInfo: "",
            decisionType: .other,
            importance: 3,
            timeFrame: .immediate,
            result: nil,
            createdAt: Date()
        ))
        .previewLayout(.sizeThatFits)
        .padding()
    }
} 