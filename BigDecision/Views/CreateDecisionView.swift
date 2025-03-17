import SwiftUI
import UIKit

struct CreateDecisionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var decisionStore: DecisionStore
    
    // 步骤状态
    enum Step: Int, CaseIterable {
        case title           // 添加主题
        case options        // 添加选项
        case additionalInfo // 补充信息
        case analyzing      // 分析中
        case result        // 分析完成
        
        var title: String {
            switch self {
            case .title: return "主题"
            case .options: return "选项"
            case .additionalInfo: return "补充"
            case .analyzing: return "分析"
            case .result: return "完成"
            }
        }
        
        var color: (Color, Color) {
            switch self {
            case .title:
                return (Color(hex: "4158D0"), Color(hex: "C850C0")) // 深蓝到紫色渐变
            case .options:
                return (Color(hex: "C850C0"), Color(hex: "FFCC70")) // 紫色到金色渐变
            case .additionalInfo:
                return (Color(hex: "FFCC70"), Color(hex: "FF6B6B")) // 金色到珊瑚红渐变
            case .analyzing:
                return (Color(hex: "FF6B6B"), Color(hex: "4ECDC4")) // 珊瑚红到青绿渐变
            case .result:
                return (Color(hex: "4ECDC4"), Color(hex: "2ECC71")) // 青绿到翠绿渐变
            }
        }
    }
    
    @State private var currentStep = Step.title
    @State private var title = ""
    @State private var options: [Option] = []
    @State private var currentOption = ""
    @State private var currentOptionDescription = ""
    @State private var additionalInfo = ""
    @State private var showingAddOption = false
    @State private var decision: Decision?
    @State private var isAnalyzing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景色
                Color(.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // 顶部渐变背景
                    ZStack(alignment: .top) {
                        LinearGradient(
                            gradient: Gradient(colors: [Color("AppPrimary"), Color("AppSecondary")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .edgesIgnoringSafeArea(.top)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            // 标题和取消按钮
                            HStack {
                                Text(navigationTitle)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                                    Text(currentStep == .result ? "完成" : "取消")
                                        .foregroundColor(.white)
                                        .fontWeight(currentStep == .result ? .semibold : .regular)
                                }
                            }
                            .padding(.top, 20)
                            
                            Text(navigationSubtitle)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                            
                            // 进度指示器
                            StepProgressBar(currentStep: currentStep)
                                .padding(.top, 12)
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 180)
                    
                    ScrollView {
                        VStack(spacing: 25) {
                            switch currentStep {
                            case .title:
                                titleInputView
                            case .options:
                                optionInputView(isFirst: true)
                            case .additionalInfo:
                                additionalInfoView
                            case .analyzing:
                                analyzingView
                            case .result:
                                if let decision = decision {
                                    ResultView(decision: decision)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    if shouldShowNextButton {
                        bottomButton
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var navigationTitle: String {
        switch currentStep {
        case .title: return "创建新决定"
        case .options: return "选项"
        case .additionalInfo: return "补充信息"
        case .analyzing: return "分析中"
        case .result: return "分析结果"
        }
    }
    
    private var navigationSubtitle: String {
        switch currentStep {
        case .title: return "让我们开始做一个新的决定"
        case .options: return "添加选项"
        case .additionalInfo: return "补充一些背景信息"
        case .analyzing: return "AI正在分析你的决定"
        case .result: return "这是AI的分析结果"
        }
    }
    
    private var titleInputView: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("这是你现在的困惑吗？")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text("确认后，我们一起慢慢解开它。")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 240, height: 240)
                
                Text(title.isEmpty ? "请输入你的困扰" : title)
                    .font(.system(size: 20, weight: .medium))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .frame(width: 200)
            }
            .padding(.vertical, 30)
            
            if !title.isEmpty {
                VStack(spacing: 12) {
                    Button(action: { moveToNextStep() }) {
                        Text("是的")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "9B9B9B"))
                            .cornerRadius(25)
                    }
                    
                    Button(action: { title = "" }) {
                        Text("修改输入")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(.systemBackground))
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 20)
            } else {
                CustomTextEditor(
                    placeholder: "例如：在深圳还是北京生活？",
                    text: $title,
                    minHeight: 100,
                    maxHeight: 150
                )
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 20)
    }
    
    private func optionInputView(isFirst: Bool) -> some View {
        VStack(alignment: .center, spacing: 20) {
            if options.isEmpty {
                Text("您的第一个选择是什么？")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                
                CustomTextEditor(
                    placeholder: "例如：在深圳生活",
                    text: $currentOption,
                    minHeight: 80,
                    maxHeight: 120
                )
                .padding(.horizontal, 20)
                
                if !currentOption.isEmpty {
                    Text("补充说明（可选）")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    CustomTextEditor(
                        placeholder: "添加一些细节...",
                        text: $currentOptionDescription,
                        minHeight: 100,
                        maxHeight: 150
                    )
                    .padding(.horizontal, 20)
                }
            } else {
                Text("是否还有其他选择？")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                
                ForEach(options) { option in
                    OptionCard(option: option)
                        .padding(.horizontal, 20)
                }
                
                if showingAddOption {
                    CustomTextEditor(
                        placeholder: "输入另一个选择",
                        text: $currentOption,
                        minHeight: 80,
                        maxHeight: 120
                    )
                    .padding(.horizontal, 20)
                    
                    if !currentOption.isEmpty {
                        Text("补充说明（可选）")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                        
                        CustomTextEditor(
                            placeholder: "添加一些细节...",
                            text: $currentOptionDescription,
                            minHeight: 100,
                            maxHeight: 150
                        )
                        .padding(.horizontal, 20)
                    }
                } else {
                    HStack(spacing: 15) {
                        Button(action: { showingAddOption = true }) {
                            Text("添加选项")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(.systemBackground))
                                .cornerRadius(25)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        }
                        
                        Button(action: { moveToNextStep() }) {
                            Text("没有了")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(hex: "9B9B9B"))
                                .cornerRadius(25)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            if !currentOption.isEmpty {
                Button(action: {
                    if options.isEmpty {
                        addCurrentOption()
                    } else {
                        addCurrentOption()
                        showingAddOption = false
                    }
                }) {
                    Text("确定")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(hex: "9B9B9B"))
                        .cornerRadius(25)
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 20)
    }
    
    private var additionalInfoView: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("还有什么补充信息吗？")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text("可以补充一些背景信息，帮助AI更好地分析")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            CustomTextEditor(
                placeholder: "请输入补充信息...",
                text: $additionalInfo,
                minHeight: 150,
                maxHeight: 300
            )
            .padding(.horizontal, 20)
            
            Button(action: startAnalysis) {
                Text("开始分析")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(hex: "9B9B9B"))
                    .cornerRadius(25)
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
    
    private var analyzingView: some View {
        VStack(spacing: 25) {
            // 分析动画
            ZStack {
                Circle()
                    .stroke(Color("AppPrimary").opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color("AppPrimary"), Color("AppSecondary")]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(isAnalyzing ? 360 : 0))
                    .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnalyzing)
                    .onAppear { isAnalyzing = true }
            }
            
            VStack(spacing: 12) {
                Text("正在分析中...")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("AI正在分析您的决策，这可能需要几秒钟时间")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
    }
    
    private var shouldShowNextButton: Bool {
        switch currentStep {
        case .title:
            return !title.isEmpty
        case .options:
            return !currentOption.isEmpty || !options.isEmpty
        case .additionalInfo:
            return true
        case .analyzing, .result:
            return false
        }
    }
    
    private var nextButtonTitle: String {
        switch currentStep {
        case .title: return "下一步"
        case .options: 
            if options.isEmpty {
                return "添加选项"
            } else if currentOption.isEmpty {
                return "继续"
            } else {
                return "添加选项"
            }
        case .additionalInfo: return "开始分析"
        default: return ""
        }
    }
    
    private var bottomButton: some View {
        VStack(spacing: 0) {
            Divider()
            
            Button(action: handleNextButton) {
                HStack {
                    Text(nextButtonTitle)
                        .font(.system(size: 17, weight: .semibold))
                    
                    if currentStep != .options || options.isEmpty {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
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
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
        }
        .background(Color(.systemBackground))
    }
    
    private func handleBackButton() {
        switch currentStep {
        case .title:
            presentationMode.wrappedValue.dismiss()
        case .options:
            currentStep = .title
        case .additionalInfo:
            currentStep = .options
        case .analyzing:
            currentStep = .additionalInfo
        case .result:
            break
        }
    }
    
    private func handleNextButton() {
        switch currentStep {
        case .title:
            moveToNextStep()
        case .options:
            if !currentOption.isEmpty {
                addCurrentOption()
            } else if !options.isEmpty {
                moveToNextStep()
            }
        case .additionalInfo:
            startAnalysis()
        default:
            break
        }
    }
    
    private func moveToNextStep() {
        withAnimation {
            switch currentStep {
            case .title:
                currentStep = .options
            case .options:
                currentStep = .additionalInfo
            case .additionalInfo:
                currentStep = .analyzing
            default:
                break
            }
        }
    }
    
    private func addCurrentOption() {
        let option = Option(
            title: currentOption,
            description: currentOptionDescription
        )
        options.append(option)
        currentOption = ""
        currentOptionDescription = ""
    }
    
    private func startAnalysis() {
        currentStep = .analyzing
        
        let newDecision = Decision(
            title: title,
            options: options,
            additionalInfo: additionalInfo,
            decisionType: .other, // 默认为其他类型
            importance: 3, // 默认重要性
            timeFrame: .days, // 默认时间框架
            createdAt: Date()
        )
        
        // 模拟网络延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            AIService.shared.analyzeDecision(decision: newDecision) { result in
                switch result {
                case .success(let analysisResult):
                    var updatedDecision = newDecision
                    updatedDecision.result = analysisResult
                    self.decision = updatedDecision
                    self.decisionStore.addDecision(updatedDecision)
                    withAnimation {
                        self.currentStep = .result
                    }
                case .failure(let error):
                    print("分析失败: \(error.localizedDescription)")
                    self.currentStep = .additionalInfo
                }
            }
        }
    }
}

struct OptionCard: View {
    let option: Option
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(option.title)
                .font(.headline)
            
            if !option.description.isEmpty {
                Text(option.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// 新的分段进度条视图
struct StepProgressBar: View {
    let currentStep: CreateDecisionView.Step
    private let steps = CreateDecisionView.Step.allCases
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 进度条
            HStack(spacing: 3) {
                ForEach(steps, id: \.self) { step in
                    StepProgressSegment(
                        step: step,
                        currentStep: currentStep
                    )
                    
                    if step != .result {
                        Spacer()
                    }
                }
            }
            .frame(height: 8)
            
            // 步骤文字提示
            HStack(spacing: 3) {
                ForEach(steps, id: \.self) { step in
                    HStack(spacing: 4) {
                        // 步骤图标
                        Image(systemName: stepIcon(for: step))
                            .font(.system(size: 10))
                            .foregroundColor(stepIconColor(for: step))
                        
                        Text(step.title)
                            .font(.caption2)
                            .foregroundColor(stepTextColor(for: step))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    private func stepIcon(for step: CreateDecisionView.Step) -> String {
        if currentStep.rawValue > step.rawValue {
            return "checkmark.circle.fill"
        } else if currentStep == step {
            switch step {
            case .title: return "pencil.circle.fill"
            case .options: return "list.bullet.circle.fill"
            case .additionalInfo: return "info.circle.fill"
            case .analyzing: return "gear.circle.fill"
            case .result: return "checkmark.circle.fill"
            }
        } else {
            switch step {
            case .title: return "1.circle"
            case .options: return "2.circle"
            case .additionalInfo: return "3.circle"
            case .analyzing: return "4.circle"
            case .result: return "5.circle"
            }
        }
    }
    
    private func stepIconColor(for step: CreateDecisionView.Step) -> Color {
        if currentStep.rawValue >= step.rawValue {
            return .white
        }
        return .white.opacity(0.6)
    }
    
    private func stepTextColor(for step: CreateDecisionView.Step) -> Color {
        if currentStep.rawValue >= step.rawValue {
            return .white
        }
        return .white.opacity(0.6)
    }
}

// 进度条段视图
struct StepProgressSegment: View {
    let step: CreateDecisionView.Step
    let currentStep: CreateDecisionView.Step
    
    private var isActive: Bool {
        currentStep.rawValue >= step.rawValue
    }
    
    private var isCurrentStep: Bool {
        currentStep == step
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        isActive ? step.color.0 : Color.white.opacity(0.2),
                        isActive ? step.color.1 : Color.white.opacity(0.2)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(maxWidth: .infinity)
            .frame(height: 8)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.white.opacity(0.6), lineWidth: isCurrentStep ? 2 : 0)
            )
            .shadow(color: isActive ? step.color.0.opacity(0.3) : .clear, radius: isCurrentStep ? 4 : 0)
            .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}

// 添加 Color 扩展
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    CreateDecisionView()
        .environmentObject(DecisionStore())
} 
