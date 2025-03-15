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
                
                // 结果部分
                if let result = decision.result {
                    VStack(alignment: .leading, spacing: 8) {
                        // 结果和选项在同一行
                        HStack(alignment: .center, spacing: 8) {
                            Text("结果")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(4)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color.green)
                                .font(.system(size: 12))
                            
                            Text(result.recommendation == "A" ? decision.optionA.title : decision.optionB.title)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        
                        // 置信度显示 - 所有元素在同一行
                        HStack(alignment: .center, spacing: 8) {
                            // 置信度标签 - 与结果标签相同风格
                            Text("置信度")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(4)
                            
                            // 进度条
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // 背景条
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 6)
                                    
                                    // 进度条
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color("AppPrimary"), Color("AppSecondary")]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * CGFloat(result.confidence), height: 6)
                                }
                            }
                            .frame(height: 6)
                            
                            // 百分比
                            Text("\(Int(result.confidence * 100))%")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(Color("AppPrimary"))
                        }
                    }
                } else {
                    // 未决定状态
                    HStack(spacing: 8) {
                        Text("结果")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(4)
                        
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
            .padding(12)
            .background(Color.white)
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
            optionA: Decision.Option(title: "麻辣烫", description: "辣味十足，暖胃"),
            optionB: Decision.Option(title: "汉堡", description: "方便快捷，但不太健康"),
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