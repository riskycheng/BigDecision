import SwiftUI
import UIKit

struct ResultView: View {
    let decision: Decision
    var onShare: (() -> Void)?
    var onFavorite: (() -> Void)?
    var onReanalyze: (() -> Void)?
    var onExport: (() -> Void)?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let result = decision.result {
                    // 推荐结果卡片
                    VStack(spacing: 15) {
                        Text("AI推荐你选择")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(result.recommendation == "A" ? decision.optionA.title : decision.optionB.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("推荐置信度")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                            
                            ConfidenceBar(confidence: result.confidence)
                            
                            Text("\(Int(result.confidence * 100))%")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color("AppPrimary"), Color("AppSecondary")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    
                    // 选项对比分析
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Image(systemName: "scale.3d")
                                .foregroundColor(Color("AppPrimary"))
                            
                            Text("选项对比分析")
                                .font(.headline)
                        }
                        
                        // 选项A分析
                        OptionAnalysis(
                            title: "选项A: \(decision.optionA.title)",
                            pros: result.prosA,
                            cons: result.consA
                        )
                        
                        Divider()
                        
                        // 选项B分析
                        OptionAnalysis(
                            title: "选项B: \(decision.optionB.title)",
                            pros: result.prosB,
                            cons: result.consB
                        )
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5)
                    
                    // 分析理由
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "text.magnifyingglass")
                                .foregroundColor(Color("AppPrimary"))
                            
                            Text("分析理由")
                                .font(.headline)
                        }
                        
                        Text(result.reasoning)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(5)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5)
                    
                    // 操作按钮
                    HStack(spacing: 15) {
                        ActionButton(icon: "square.and.arrow.up", title: "分享") {
                            // 分享功能
                            onShare?()
                        }
                        
                        ActionButton(icon: "star", title: "收藏") {
                            // 收藏功能
                            onFavorite?()
                        }
                        
                        ActionButton(icon: "arrow.counterclockwise", title: "重新分析") {
                            // 重新分析功能
                            onReanalyze?()
                        }
                        
                        ActionButton(icon: "doc.text", title: "导出") {
                            // 导出功能
                            onExport?()
                        }
                    }
                    
                    // 添加底部间距，避免与底部标签栏重叠
                    Spacer()
                        .frame(height: 100)
                } else {
                    // 加载中状态
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text("正在分析你的决定...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 100)
                }
            }
            .padding()
        }
    }
}

struct ConfidenceBar: View {
    let confidence: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: geometry.size.width, height: 6)
                    .cornerRadius(3)
                
                Rectangle()
                    .fill(Color.white)
                    .frame(width: geometry.size.width * confidence, height: 6)
                    .cornerRadius(3)
            }
        }
        .frame(height: 6)
    }
}

struct OptionAnalysis: View {
    let title: String
    let pros: [String]
    let cons: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("优势")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ForEach(pros, id: \.self) { pro in
                    HStack(alignment: .top) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 14))
                            .frame(width: 20)
                        
                        Text(pro)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("劣势")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ForEach(cons, id: \.self) { con in
                    HStack(alignment: .top) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                            .frame(width: 20)
                        
                        Text(con)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
        }
        .foregroundColor(.primary)
    }
}

#Preview {
    let sampleDecision = Decision(
        title: "是否换工作？",
        optionA: Decision.Option(title: "留在现公司", description: "稳定但发展有限"),
        optionB: Decision.Option(title: "接受新offer", description: "机会更多但风险更大"),
        additionalInfo: "我在现公司工作了3年，薪资稳定但晋升空间有限。新公司提供的薪资高30%，但工作强度可能更大。",
        decisionType: .work,
        importance: 4,
        timeFrame: .days,
        result: Decision.Result(
            recommendation: "B",
            confidence: 0.75,
            reasoning: "基于您提供的信息，我们进行了全面分析。考虑到您的具体情况和偏好，我们认为接受新offer更符合您的长期利益。虽然可能面临短期的适应挑战，但长期来看，新的工作环境将为您提供更多的发展机会和经济回报。",
            prosA: ["工作环境熟悉，无需适应", "工作稳定，风险低", "同事关系已建立"],
            consA: ["晋升空间有限", "薪资增长缓慢"],
            prosB: ["薪资提升30%", "更多的职业发展机会", "新的工作技能和经验"],
            consB: ["需要适应新环境", "工作强度可能更大"]
        ),
        createdAt: Date()
    )
    
    return ResultView(decision: sampleDecision)
} 