import SwiftUI
import UIKit

struct ResultView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var decisionStore: DecisionStore
    let decision: Decision
    @State private var isFavorited: Bool
    @State private var showingShareSheet = false
    @State private var showingExportOptions = false
    @State private var exportImage: UIImage?
    @State private var showingExportedImage = false
    
    init(decision: Decision) {
        self.decision = decision
        self._isFavorited = State(initialValue: decision.isFavorited)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let result = decision.result {
                    // AI推荐结果卡片
                    VStack(spacing: 15) {
                        Text("AI推荐你选择")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(result.recommendation == "A" ? decision.optionA.title : decision.optionB.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        HStack(spacing: 8) {
                            Text("推荐置信度")
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.9))
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // 背景条
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.white.opacity(0.3))
                                        .frame(height: 4)
                                    
                                    // 进度条
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.white)
                                        .frame(width: geometry.size.width * result.confidence, height: 4)
                                }
                            }
                            .frame(height: 4)
                            .frame(width: 100)
                            
                            Text("\(Int(result.confidence * 100))%")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 5)
                    }
                    .padding(.vertical, 25)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color("AppPrimary"), Color("AppSecondary")]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    
                    // 选项A分析
                    VStack(alignment: .leading, spacing: 15) {
                        Text("选项A: \(decision.optionA.title)")
                            .font(.system(size: 16, weight: .medium))
                        
                        Text("优势")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        ForEach(result.prosA.indices, id: \.self) { index in
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                                Text(result.prosA[index])
                                    .font(.system(size: 15))
                            }
                        }
                        
                        Text("劣势")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                        
                        ForEach(result.consA.indices, id: \.self) { index in
                            HStack(spacing: 8) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                                Text(result.consA[index])
                                    .font(.system(size: 15))
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // 选项B分析
                    VStack(alignment: .leading, spacing: 15) {
                        Text("选项B: \(decision.optionB.title)")
                            .font(.system(size: 16, weight: .medium))
                        
                        Text("优势")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        ForEach(result.prosB.indices, id: \.self) { index in
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                                Text(result.prosB[index])
                                    .font(.system(size: 15))
                            }
                        }
                        
                        Text("劣势")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                        
                        ForEach(result.consB.indices, id: \.self) { index in
                            HStack(spacing: 8) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                                Text(result.consB[index])
                                    .font(.system(size: 15))
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // 分析理由
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "magnifyingglass.circle.fill")
                                .foregroundColor(Color("AppPrimary"))
                            Text("分析理由")
                                .font(.headline)
                        }
                        
                        Text(result.reasoning)
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(4)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            // 底部操作按钮
            VStack {
                HStack(spacing: 30) {
                    ActionButton(icon: "square.and.arrow.up", title: "分享") {
                        shareDecision()
                    }
                    
                    ActionButton(icon: isFavorited ? "star.fill" : "star", title: "收藏") {
                        toggleFavorite()
                    }
                    
                    ActionButton(icon: "arrow.clockwise", title: "重新分析") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                    ActionButton(icon: "doc.text", title: "导出") {
                        showingExportOptions = true
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background(
                    Color.white
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: -4)
                )
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let result = decision.result {
                ShareSheet(items: [generateShareText(decision: decision, result: result)])
            }
        }
        .alert(isPresented: $showingExportOptions) {
            Alert(
                title: Text("导出决策"),
                message: Text("生成决策分析图片"),
                primaryButton: .default(Text("预览图片")) {
                    if let image = exportDecisionAsImage() {
                        exportImage = image
                        showingExportedImage = true
                    }
                },
                secondaryButton: .cancel(Text("取消"))
            )
        }
        .sheet(isPresented: $showingExportedImage) {
            if let image = exportImage {
                ExportImageView(image: image, onDismiss: { showingExportedImage = false })
            }
        }
    }
    
    private func toggleFavorite() {
        isFavorited.toggle()
        var updatedDecision = decision
        updatedDecision.isFavorited = isFavorited
        decisionStore.updateDecision(updatedDecision)
        
        // 添加触觉反馈
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func shareDecision() {
        guard let result = decision.result else { return }
        
        let text = """
        决策: \(decision.title)
        
        选项A: \(decision.optionA.title)
        选项B: \(decision.optionB.title)
        
        AI推荐: \(result.recommendation == "A" ? decision.optionA.title : decision.optionB.title)
        置信度: \(Int(result.confidence * 100))%
        
        分析理由: \(result.reasoning)
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
    
    private func generateShareText(decision: Decision, result: Decision.Result) -> String {
        let text = """
        决策: \(decision.title)
        
        选项A: \(decision.optionA.title)
        选项B: \(decision.optionB.title)
        
        AI推荐: \(result.recommendation == "A" ? decision.optionA.title : decision.optionB.title)
        置信度: \(Int(result.confidence * 100))%
        
        分析理由: \(result.reasoning)
        """
        return text
    }
    
    private func exportDecisionAsImage() -> UIImage? {
        // Implementation of exportDecisionAsImage method
        return nil // Placeholder return, actual implementation needed
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
                    .font(.system(size: 22))
                Text(title)
                    .font(.system(size: 12))
            }
            .foregroundColor(Color("AppPrimary"))
            .frame(maxWidth: .infinity)
        }
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