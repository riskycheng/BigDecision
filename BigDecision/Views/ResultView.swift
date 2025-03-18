import SwiftUI
import UIKit

struct ResultView: View {
    let decision: Decision
    @State private var isFavorited: Bool
    @State private var showingShareSheet = false
    @State private var showingExportOptions = false
    @State private var exportImage: UIImage?
    @State private var showingExportedImage = false
    @EnvironmentObject var decisionStore: DecisionStore
    
    init(decision: Decision) {
        self.decision = decision
        self._isFavorited = State(initialValue: decision.isFavorited)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // 决策标题
                Text(decision.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                if let result = decision.result {
                    // AI推荐结果卡片
                    VStack(spacing: 15) {
                        Text("AI推荐")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(getRecommendedOption(result.recommendation).title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color("AppPrimary"))
                        
                        Text("置信度: \(Int(result.confidence * 100))%")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("AppPrimary").opacity(0.1))
                    .cornerRadius(15)
                    
                    // 分析理由
                    VStack(alignment: .leading, spacing: 12) {
                        Text("分析理由")
                            .font(.headline)
                        
                        Text(result.reasoning)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    
                    // 选项对比
                    VStack(spacing: 20) {
                        ForEach(decision.options) { option in
                            OptionAnalysisCard(
                                option: option,
                                pros: option.id == decision.options[0].id ? result.prosA : result.prosB,
                                cons: option.id == decision.options[0].id ? result.consA : result.consB
                            )
                        }
                    }
                    
                    // 底部操作按钮栏
                    VStack(spacing: 15) {
                        Divider()
                        
                        HStack(spacing: 20) {
                            // 收藏按钮
                            Button(action: toggleFavorite) {
                                VStack(spacing: 8) {
                                    Image(systemName: isFavorited ? "star.fill" : "star")
                                        .font(.system(size: 24))
                                        .foregroundColor(isFavorited ? .yellow : .gray)
                                    Text("收藏")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // 导出按钮
                            Button(action: { showingExportOptions = true }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.down")
                                        .font(.system(size: 24))
                                        .foregroundColor(.gray)
                                    Text("导出")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // 分享按钮
                            Button(action: { showingShareSheet = true }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 24))
                                        .foregroundColor(.gray)
                                    Text("分享")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // 重新分析按钮
                            Button(action: {
                                var updatedDecision = decision
                                updatedDecision.result = nil
                                decisionStore.updateDecision(updatedDecision)
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 24))
                                        .foregroundColor(.gray)
                                    Text("重新分析")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 15) {
                    Button(action: toggleFavorite) {
                        Image(systemName: isFavorited ? "star.fill" : "star")
                            .foregroundColor(isFavorited ? .yellow : .gray)
                    }
                    
                    Button(action: { showingShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: { showingExportOptions = true }) {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [generateShareText()])
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
    
    private func getRecommendedOption(_ recommendation: String) -> Option {
        recommendation == "A" ? decision.options[0] : decision.options[1]
    }
    
    private func toggleFavorite() {
        isFavorited.toggle()
        var updatedDecision = decision
        updatedDecision.isFavorited = isFavorited
        decisionStore.updateDecision(updatedDecision)
        
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.success)
    }
    
    private func generateShareText() -> String {
        guard let result = decision.result else { return "" }
        
        let recommendedOption = getRecommendedOption(result.recommendation)
        
        return """
        我使用"大决定"分析了一个决策:
        
        决策: \(decision.title)
        选项: \(decision.options.map { $0.title }.joined(separator: " vs "))
        
        AI推荐: \(recommendedOption.title)
        置信度: \(Int(result.confidence * 100))%
        
        分析理由: \(result.reasoning)
        """
    }
    
    private func exportDecisionAsImage() -> UIImage? {
        guard let result = decision.result else { return nil }
        let recommendedOption = getRecommendedOption(result.recommendation)
        let exportView = ExportReportView(
            title: decision.title,
            options: decision.options,
            recommendedOption: recommendedOption,
            confidence: result.confidence,
            reasoning: result.reasoning
        )
        
        let controller = UIHostingController(rootView: exportView)
        controller.view.frame = CGRect(x: 0, y: 0, width: 350, height: 500)
        controller.view.layoutIfNeeded()
        
        UIGraphicsBeginImageContextWithOptions(controller.view.bounds.size, false, 0)
        controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

struct ExportReportView: View {
    let title: String
    let options: [Option]
    let recommendedOption: Option
    let confidence: Double
    let reasoning: String
    
    var body: some View {
        VStack(spacing: 15) {
            Text("决策分析报告")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("决策: \(title)")
                    .font(.headline)
                    .padding(.bottom, 5)
                
                ForEach(options) { option in
                    Text("选项\(option.id == options[0].id ? "A" : "B"): \(option.title)")
                }
                .padding(.bottom, 5)
                
                Text("AI推荐: \(recommendedOption.title)")
                    .fontWeight(.bold)
                
                Text("置信度: \(Int(confidence * 100))%")
                    .padding(.bottom, 5)
                
                Text("分析理由:")
                    .fontWeight(.bold)
                
                Text(reasoning)
                    .font(.body)
                    .lineLimit(10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Spacer()
            
            Text("由\"大决定\"App生成")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
        .padding()
        .frame(width: 350, height: 500)
        .background(Color.white)
    }
}

struct OptionAnalysisCard: View {
    let option: Option
    let pros: [String]
    let cons: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(option.title)
                .font(.headline)
            
            if !option.description.isEmpty {
                Text(option.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                if !pros.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("优点")
                            .font(.subheadline)
                            .foregroundColor(.green)
                        
                        ForEach(pros, id: \.self) { pro in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14))
                                
                                Text(pro)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                if !cons.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("缺点")
                            .font(.subheadline)
                            .foregroundColor(.red)
                        
                        ForEach(cons, id: \.self) { con in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 14))
                                
                                Text(con)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(15)
    }
}

// 系统分享视图
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// 导出图片预览视图
struct ExportImageView: View {
    let image: UIImage
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("决策分析图片")
                .font(.system(size: 17, weight: .semibold))
                .padding(.top)
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding()
            
            HStack(spacing: 20) {
                Button(action: {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    let feedbackGenerator = UINotificationFeedbackGenerator()
                    feedbackGenerator.notificationOccurred(.success)
                }) {
                    Text("保存到相册")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 12)
                        .background(Color("AppPrimary"))
                        .cornerRadius(10)
                }
                
                Button(action: onDismiss) {
                    Text("关闭")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
            }
            .padding(.bottom)
        }
    }
}

#Preview {
    let sampleDecision = Decision(
        title: "是否换工作？",
        options: [
            Option(title: "留在现公司", description: "稳定但发展有限"),
            Option(title: "接受新offer", description: "机会更多但风险更大")
        ],
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
    
    ResultView(decision: sampleDecision)
} 