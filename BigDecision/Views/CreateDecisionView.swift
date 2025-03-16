import SwiftUI
import UIKit

struct CreateDecisionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var decisionStore: DecisionStore
    
    @State private var currentStep = 1
    @State private var title = ""
    @State private var optionATitle = ""
    @State private var optionBTitle = ""
    @State private var optionADescription = ""
    @State private var optionBDescription = ""
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
            ZStack(alignment: .top) {
                // 背景色
                Color(.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // 顶部导航栏 - 更现代的设计
                    ZStack {
                        HStack {
                            Button(action: {
                                if currentStep > 1 {
                                    currentStep -= 1
                                } else {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                            .padding()
                            
                            Spacer()
                            
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text(currentStep == 3 ? "完成" : "取消")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color("AppPrimary"))
                            }
                            .padding()
                        }
                        
                        Text(navigationTitle)
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .frame(height: 44)
                    .background(
                        Color(.systemBackground)
                            .shadow(color: Color.black.opacity(0.03), radius: 10, y: 2)
                    )
                    
                    // 步骤指示器 - 更优雅的设计
                    StepIndicator(currentStep: currentStep, hasResult: decision != nil, isAnalyzing: isAnalyzing)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 30)
                    
                    ScrollView {
                        VStack(spacing: 25) {
                            switch currentStep {
                            case 1:
                                inputOptionsView
                            case 2:
                                additionalInfoView
                            case 3:
                                if let decision = decision {
                                    VStack {
                                        ResultView(decision: decision)
                                    }
                                    .background(Color(.systemGroupedBackground))
                                } else {
                                    // 加载动画视图
                                    VStack(spacing: 25) {
                                        ProgressView()
                                            .scaleEffect(1.5)
                                        
                                        VStack(spacing: 12) {
                                            Text("正在分析中...")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(.primary)
                                            
                                            Text("AI正在分析您的决策，这可能需要几秒钟时间")
                                                .font(.system(size: 15))
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal, 30)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 60)
                                }
                            default:
                                EmptyView()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                    
                    // 底部按钮 - 更现代的设计
                    if currentStep < 3 || (currentStep == 3 && decision == nil) {
                        HStack(spacing: 15) {
                            if currentStep > 1 {
                                Button(action: {
                                    currentStep -= 1
                                }) {
                                    Text("上一步")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(Color("AppPrimary"))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color("AppPrimary"), lineWidth: 1)
                                        )
                                }
                            }
                            
                            Button(action: {
                                nextStep()
                            }) {
                                Text(currentStep == 2 ? "分析决定" : "下一步")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color("AppPrimary"), Color("AppSecondary")]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .cornerRadius(12)
                                    )
                                    .opacity(isNextButtonDisabled ? 0.5 : 1)
                            }
                            .disabled(isNextButtonDisabled)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                        .background(
                            Color(.systemBackground)
                                .shadow(color: Color.black.opacity(0.05), radius: 15, y: -5)
                        )
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingShareSheet) {
                if let result = decision?.result {
                    ShareSheet(items: [generateShareText(decision: decision!, result: result)])
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
            // 决定标题输入
            FormField(
                title: "决定标题",
                placeholder: "例如：是否换工作？",
                text: $title,
                icon: "text.alignleft"
            )
            
            // 选项A
            VStack(alignment: .leading, spacing: 12) {
                Text("选项 A")
                    .font(.system(size: 17, weight: .semibold))
                
                CustomTextField(
                    title: "选项A标题",
                    text: $optionATitle,
                    icon: "a.circle.fill"
                )
                
                CustomTextEditor(
                    placeholder: "输入选项A的详细描述",
                    text: $optionADescription,
                    height: 80
                )
            }
            
            // 分隔符
            HStack {
                Line()
                Text("VS")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
                Line()
            }
            .padding(.vertical, 3)
            
            // 选项B
            VStack(alignment: .leading, spacing: 12) {
                Text("选项 B")
                    .font(.system(size: 17, weight: .semibold))
                
                CustomTextField(
                    title: "选项B标题",
                    text: $optionBTitle,
                    icon: "b.circle.fill"
                )
                
                CustomTextEditor(
                    placeholder: "输入选项B的详细描述",
                    text: $optionBDescription,
                    height: 80
                )
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    private var additionalInfoView: some View {
        VStack(alignment: .leading, spacing: 25) {
            // 决定摘要卡片
            VStack(alignment: .leading, spacing: 15) {
                Text("你的决定")
                    .font(.system(size: 17, weight: .semibold))
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 20) {
                        Label {
                            Text(optionATitle)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        } icon: {
                            Image(systemName: "a.circle.fill")
                                .foregroundColor(Color("AppPrimary"))
                        }
                        
                        Label {
                            Text(optionBTitle)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        } icon: {
                            Image(systemName: "b.circle.fill")
                                .foregroundColor(Color("AppPrimary"))
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
            }
            
            // 决定类型
            VStack(alignment: .leading, spacing: 12) {
                Text("决定类型")
                    .font(.system(size: 17, weight: .semibold))
                
                Text("选择你的决定类型，帮助AI更好地理解")
                    .font(.system(size: 14))
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
                    .padding(.horizontal, 2)
                }
            }
            
            // 补充信息
            VStack(alignment: .leading, spacing: 12) {
                Text("补充信息")
                    .font(.system(size: 17, weight: .semibold))
                
                Text("提供更多背景信息，帮助AI更准确地分析")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                CustomTextEditor(
                    placeholder: "例如：我在现公司工作了3年，薪资稳定但晋升空间有限。新公司提供的薪资高30%，但工作强度可能更大，且需要搬家...",
                    text: $additionalInfo,
                    height: 120
                )
            }
            
            // 决定重要性
            VStack(alignment: .leading, spacing: 12) {
                Text("决定重要性")
                    .font(.system(size: 17, weight: .semibold))
                
                Text("这个决定对你有多重要？")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("不太重要")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    CustomSlider(value: .init(
                        get: { Double(importance) },
                        set: { importance = Int($0) }
                    ), in: 1...5, step: 1)
                    
                    Text("非常重要")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            // 决定时间框架
            VStack(alignment: .leading, spacing: 12) {
                Text("决定时间框架")
                    .font(.system(size: 17, weight: .semibold))
                
                Text("你需要在多长时间内做出决定？")
                    .font(.system(size: 14))
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
        currentStep = 3  // 立即更新到第3步
        
        let newDecision = Decision(
            title: title,
            optionA: Decision.Option(title: optionATitle, description: optionADescription),
            optionB: Decision.Option(title: optionBTitle, description: optionBDescription),
            additionalInfo: additionalInfo,
            decisionType: decisionType,
            importance: importance,
            timeFrame: timeFrame,
            result: nil,
            createdAt: Date()
        )
        
        // 模拟网络延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            AIService.shared.analyzeDecision(decision: newDecision) { result in
                self.isAnalyzing = false
                
                switch result {
                case .success(let analysisResult):
                    var updatedDecision = newDecision
                    updatedDecision.result = analysisResult
                    self.decision = updatedDecision
                    self.decisionStore.addDecision(updatedDecision)
                case .failure(let error):
                    print("分析失败: \(error.localizedDescription)")
                    // 在实际应用中应该显示错误提示
                    self.currentStep = 2  // 如果分析失败，回到第2步
                }
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
    
    private func generateShareText(decision: Decision, result: Decision.Result) -> String {
        """
        我使用"大决定"分析了一个决策:
        
        决策: \(decision.title)
        选项A: \(decision.optionA.title)
        选项B: \(decision.optionB.title)
        
        AI推荐: \(result.recommendation == "A" ? decision.optionA.title : decision.optionB.title)
        置信度: \(Int(result.confidence * 100))%
        
        分析理由: \(result.reasoning)
        """
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
    let isAnalyzing: Bool
    
    init(currentStep: Int, hasResult: Bool = false, isAnalyzing: Bool = false) {
        self.currentStep = currentStep
        self.hasResult = hasResult
        self.isAnalyzing = isAnalyzing
    }
    
    var body: some View {
        HStack {
            StepCircle(number: 1, isActive: currentStep == 1, isCompleted: currentStep > 1)
            
            StepLine(isCompleted: currentStep > 1)
            
            StepCircle(number: 2, isActive: currentStep == 2 && !isAnalyzing, isCompleted: currentStep > 2 || (currentStep == 2 && isAnalyzing))
            
            StepLine(isCompleted: currentStep > 2 || (currentStep == 3 && (hasResult || isAnalyzing)))
            
            StepCircle(number: 3, isActive: currentStep == 3 && !hasResult && !isAnalyzing, isCompleted: currentStep == 3 && hasResult, isLoading: currentStep == 3 && isAnalyzing)
        }
        .padding(.horizontal)
    }
}

struct StepCircle: View {
    let number: Int
    let isActive: Bool
    let isCompleted: Bool
    let isLoading: Bool
    
    init(number: Int, isActive: Bool, isCompleted: Bool, isLoading: Bool = false) {
        self.number = number
        self.isActive = isActive
        self.isCompleted = isCompleted
        self.isLoading = isLoading
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: 30, height: 30)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.7)
            } else if isCompleted {
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
                .stroke(isActive || isCompleted || isLoading ? Color("AppPrimary") : Color.gray.opacity(0.3), lineWidth: 2)
        )
    }
    
    private var backgroundColor: Color {
        if isCompleted {
            return Color.green
        } else if isActive {
            return Color("AppPrimary")
        } else if isLoading {
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
    var icon: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(Color("AppPrimary"))
                        .frame(width: 20)
                }
                
                TextField(placeholder, text: $text)
            }
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

// 自定义组件

struct CustomTextEditor: View {
    let placeholder: String
    @Binding var text: String
    var height: CGFloat = 80
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 8)
                    .allowsHitTesting(false)
            }
            
            TextEditor(text: $text)
                .frame(height: height)
                .padding(5)
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
    }
}

struct Line: View {
    var body: some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.2))
            .frame(height: 1)
    }
}

struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    
    init(value: Binding<Double>, in range: ClosedRange<Double>, step: Double) {
        self._value = value
        self.range = range
        self.step = step
    }
    
    var body: some View {
        Slider(value: $value, in: range, step: step)
            .accentColor(Color("AppPrimary"))
    }
}

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
    CreateDecisionView()
        .environmentObject(DecisionStore())
} 
