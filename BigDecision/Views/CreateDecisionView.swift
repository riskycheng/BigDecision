import SwiftUI
import UIKit

struct CreateDecisionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var decisionStore: DecisionStore
    
    @State private var currentStep = 1
    @State private var title = ""
    @State private var optionATitle = ""
    @State private var optionBTitle = ""
    @State private var additionalInfo = ""
    @State private var decisionType: Decision.DecisionType = .work
    @State private var importance = 3
    @State private var timeFrame: Decision.TimeFrame = .days
    
    @State private var isAnalyzing = false
    @State private var decision: Decision?
    @State private var showingShareSheet = false
    @State private var isFavorited = false
    @State private var showingExportOptions = false
    @State private var exportImage: UIImage?
    @State private var showingExportedImage = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部导航栏
                HStack {
                    Button(action: {
                        if currentStep > 1 {
                            currentStep -= 1
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.headline)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Text(navigationTitle)
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(currentStep == 3 ? "完成" : "取消")
                            .font(.subheadline)
                    }
                    .padding()
                }
                .padding(.vertical, 5)
                .background(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5)
                
                // 步骤指示器
                StepIndicator(currentStep: currentStep, hasResult: decision != nil)
                    .padding(.vertical)
                
                ScrollView {
                    VStack(spacing: 20) {
                        switch currentStep {
                        case 1:
                            inputOptionsView
                        case 2:
                            additionalInfoView
                        case 3:
                            if let decision = decision {
                                ResultView(decision: decision,
                                          onShare: {
                                              showingShareSheet = true
                                          },
                                          onFavorite: {
                                              toggleFavorite()
                                          },
                                          onReanalyze: {
                                              reanalyze()
                                          },
                                          onExport: {
                                              showingExportOptions = true
                                          })
                                    .sheet(isPresented: $showingShareSheet) {
                                        if let result = decision.result {
                                            let shareText = """
                                            我使用\"大决定\"分析了一个决策:
                                            
                                            决策: \(decision.title)
                                            选项A: \(decision.optionA.title)
                                            选项B: \(decision.optionB.title)
                                            
                                            AI推荐: \(result.recommendation == "A" ? decision.optionA.title : decision.optionB.title)
                                            置信度: \(Int(result.confidence * 100))%
                                            
                                            分析理由: \(result.reasoning)
                                            """
                                            
                                            ShareSheet(items: [shareText])
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
                                            VStack {
                                                Text("决策分析图片")
                                                    .font(.headline)
                                                    .padding()
                                                
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .padding()
                                                
                                                HStack(spacing: 20) {
                                                    Button("保存到相册") {
                                                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                                        let feedbackGenerator = UINotificationFeedbackGenerator()
                                                        feedbackGenerator.notificationOccurred(.success)
                                                    }
                                                    .padding()
                                                    .background(Color("AppPrimary"))
                                                    .foregroundColor(.white)
                                                    .cornerRadius(10)
                                                    
                                                    Button("关闭") {
                                                        showingExportedImage = false
                                                    }
                                                    .padding()
                                                    .background(Color.gray.opacity(0.2))
                                                    .foregroundColor(.primary)
                                                    .cornerRadius(10)
                                                }
                                                .padding(.bottom)
                                            }
                                        }
                                    }
                                    .environmentObject(decisionStore)
                            } else {
                                ProgressView("正在分析中...")
                                    .padding()
                            }
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                }
                
                // 底部按钮
                if currentStep < 3 || (currentStep == 3 && decision == nil) {
                    HStack {
                        if currentStep > 1 {
                            Button(action: {
                                currentStep -= 1
                            }) {
                                Text("上一步")
                                    .font(.headline)
                                    .foregroundColor(Color("AppPrimary"))
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(UIColor.systemBackground))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color("AppPrimary"), lineWidth: 1)
                                    )
                            }
                        } else {
                            Spacer()
                        }
                        
                        Button(action: {
                            nextStep()
                        }) {
                            Text(currentStep == 2 ? "分析决定" : "下一步")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color("AppPrimary"))
                                .cornerRadius(12)
                                .opacity(isNextButtonDisabled ? 0.5 : 1)
                        }
                        .disabled(isNextButtonDisabled)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, y: -5)
                }
            }
            .navigationTitle("")
        }
    }
    
    private var navigationTitle: String {
        switch currentStep {
        case 1:
            return "创建新决定"
        case 2:
            return "补充信息"
        case 3:
            return "分析结果"
        default:
            return ""
        }
    }
    
    private var isNextButtonDisabled: Bool {
        switch currentStep {
        case 1:
            return title.isEmpty || optionATitle.isEmpty || optionBTitle.isEmpty
        case 2:
            return false
        default:
            return false
        }
    }
    
    private var inputOptionsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            FormField(title: "决定标题", placeholder: "例如：是否换工作？", text: $title)
            
            Text("选项 A")
                .font(.headline)
            
            Text("详细描述你的第一个选择")
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextEditor(text: $optionATitle)
                .frame(height: 100)
                .padding(5)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                .overlay(
                    Group {
                        if optionATitle.isEmpty {
                            Text("输入选项A的内容")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 12)
                                .allowsHitTesting(false)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                    }
                )
            
            Divider()
                .padding(.vertical)
                .overlay(
                    Text("VS")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 10)
                        .background(Color(UIColor.systemBackground))
                )
            
            Text("选项 B")
                .font(.headline)
            
            Text("详细描述你的第二个选择")
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextEditor(text: $optionBTitle)
                .frame(height: 100)
                .padding(5)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                .overlay(
                    Group {
                        if optionBTitle.isEmpty {
                            Text("输入选项B的内容")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 12)
                                .allowsHitTesting(false)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                    }
                )
        }
    } 
    
    private var additionalInfoView: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 决定摘要卡片
            VStack(alignment: .leading, spacing: 10) {
                Text("你的决定")
                    .font(.headline)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("选项A: \(optionATitle)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("选项B: \(optionBTitle)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            
            // 决定类型
            VStack(alignment: .leading, spacing: 10) {
                Text("决定类型")
                    .font(.headline)
                
                Text("选择你的决定类型，帮助AI更好地理解")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Decision.DecisionType.allCases, id: \.self) { type in
                            DecisionTypeButton(
                                type: type,
                                isSelected: decisionType == type,
                                action: { decisionType = type }
                            )
                        }
                    }
                }
            }
            
            // 补充信息
            VStack(alignment: .leading, spacing: 10) {
                Text("补充信息")
                    .font(.headline)
                
                Text("提供更多背景信息，帮助AI更准确地分析")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextEditor(text: $additionalInfo)
                    .frame(height: 120)
                    .padding(5)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                    .overlay(
                        Group {
                            if additionalInfo.isEmpty {
                                Text("例如：我在现公司工作了3年，薪资稳定但晋升空间有限。新公司提供的薪资高30%，但工作强度可能更大，且需要搬家...")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 12)
                                    .allowsHitTesting(false)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            }
                        }
                    )
            }
            
            // 决定重要性
            VStack(alignment: .leading, spacing: 10) {
                Text("决定重要性")
                    .font(.headline)
                
                Text("这个决定对你有多重要？")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("不太重要")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Slider(value: .init(get: {
                        Double(importance)
                    }, set: { newValue in
                        importance = Int(newValue)
                    }), in: 1...5, step: 1)
                    
                    Text("非常重要")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 决定时间框架
            VStack(alignment: .leading, spacing: 10) {
                Text("决定时间框架")
                    .font(.headline)
                
                Text("你需要在多长时间内做出决定？")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("时间框架", selection: $timeFrame) {
                    ForEach(Decision.TimeFrame.allCases, id: \.self) { timeFrame in
                        Text(timeFrame.rawValue).tag(timeFrame)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
    
    private func nextStep() {
        if currentStep == 1 {
            currentStep = 2
        } else if currentStep == 2 {
            analyzeDecision()
        }
    }
    
    private func analyzeDecision() {
        isAnalyzing = true
        
        let newDecision = Decision(
            title: title,
            optionA: Decision.Option(title: optionATitle, description: ""),
            optionB: Decision.Option(title: optionBTitle, description: ""),
            additionalInfo: additionalInfo,
            decisionType: decisionType,
            importance: importance,
            timeFrame: timeFrame,
            result: nil,
            createdAt: Date()
        )
        
        AIService.shared.analyzeDecision(decision: newDecision) { result in
            isAnalyzing = false
            
            switch result {
            case .success(let analysisResult):
                var updatedDecision = newDecision
                updatedDecision.result = analysisResult
                self.decision = updatedDecision
                self.decisionStore.addDecision(updatedDecision)
                self.currentStep = 3
            case .failure(let error):
                print("分析失败: \(error.localizedDescription)")
                // 在实际应用中应该显示错误提示
            }
        }
    }
    
    private func toggleFavorite() {
        isFavorited.toggle()
        
        // 更新决策的收藏状态
        if var currentDecision = decision {
            currentDecision.isFavorited = isFavorited
            decision = currentDecision
            decisionStore.updateDecision(currentDecision)
            
            // 显示提示
            let feedbackGenerator = UINotificationFeedbackGenerator()
            feedbackGenerator.notificationOccurred(.success)
        }
    }
    
    private func reanalyze() {
        // 返回到第二步，保留已填写的信息
        currentStep = 2
    }
    
    private func exportDecisionAsImage() -> UIImage? {
        guard let decision = decision, let result = decision.result else { return nil }
        
        // 创建一个简单的渲染视图
        let exportView = VStack(spacing: 15) {
            // 标题
            Text("决策分析报告")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
            // 决策信息
            VStack(alignment: .leading, spacing: 8) {
                Text("决策: \(decision.title)")
                    .font(.headline)
                    .padding(.bottom, 5)
                
                Text("选项A: \(decision.optionA.title)")
                Text("选项B: \(decision.optionB.title)")
                    .padding(.bottom, 5)
                
                Text("AI推荐: \(result.recommendation == "A" ? decision.optionA.title : decision.optionB.title)")
                    .fontWeight(.bold)
                
                Text("置信度: \(Int(result.confidence * 100))%")
                    .padding(.bottom, 5)
                
                Text("分析理由:")
                    .fontWeight(.bold)
                
                Text(result.reasoning)
                    .font(.body)
                    .lineLimit(10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Spacer()
            
            // 底部信息
            Text("由\"大决定\"App生成")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
        .padding()
        .frame(width: 350, height: 500)
        .background(Color.white)
        
        // 使用更简单的方式渲染图片
        let controller = UIHostingController(rootView: exportView)
        controller.view.frame = CGRect(x: 0, y: 0, width: 350, height: 500)
        
        // 确保视图已经布局
        controller.view.layoutIfNeeded()
        
        // 创建图片上下文并渲染
        UIGraphicsBeginImageContextWithOptions(controller.view.bounds.size, false, 0)
        controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

struct StepIndicator: View {
    let currentStep: Int
    let hasResult: Bool
    
    init(currentStep: Int, hasResult: Bool = false) {
        self.currentStep = currentStep
        self.hasResult = hasResult
    }
    
    var body: some View {
        HStack {
            StepCircle(number: 1, isActive: currentStep == 1, isCompleted: currentStep > 1)
            
            StepLine(isCompleted: currentStep > 1)
            
            StepCircle(number: 2, isActive: currentStep == 2, isCompleted: currentStep > 2)
            
            StepLine(isCompleted: currentStep > 2 || (currentStep == 3 && hasResult))
            
            StepCircle(number: 3, isActive: currentStep == 3 && !hasResult, isCompleted: currentStep == 3 && hasResult)
        }
        .padding(.horizontal)
    }
}

struct StepCircle: View {
    let number: Int
    let isActive: Bool
    let isCompleted: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: 30, height: 30)
            
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Text("\(number)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .overlay(
            Circle()
                .stroke(isActive || isCompleted ? Color("AppPrimary") : Color.gray.opacity(0.3), lineWidth: 2)
        )
    }
    
    private var backgroundColor: Color {
        if isCompleted {
            return Color.green
        } else if isActive {
            return Color("AppPrimary")
        } else {
            return Color.gray.opacity(0.3)
        }
    }
}

struct StepLine: View {
    let isCompleted: Bool
    
    var body: some View {
        Rectangle()
            .fill(isCompleted ? Color.green : Color.gray.opacity(0.3))
            .frame(height: 2)
    }
}

struct FormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            TextField(placeholder, text: $text)
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
        }
    }
}

struct DecisionTypeButton: View {
    let type: Decision.DecisionType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: type.icon)
                Text(type.rawValue)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color("AppPrimary") : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// 添加ShareSheet视图用于系统分享
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    CreateDecisionView()
        .environmentObject(DecisionStore())
} 
