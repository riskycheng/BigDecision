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
    @State private var isEditingTitle = false  // 新增状态控制输入框显示
    @State private var tempTitle = ""          // 新增临时标题存储
    @State private var options: [Option] = []
    @State private var currentOption = ""
    @State private var currentOptionDescription = ""
    @State private var additionalInfo = ""
    @State private var showingAddOption = false
    @State private var decision: Decision?
    @State private var isAnalyzing = false
    @State private var isDescriptionExpanded = false  // 新增状态控制补充说明的展开/折叠
    @State private var isEditingAdditionalInfo = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景色
                Color(.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // 顶部导航栏
                    HStack {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.primary)
                                .frame(width: 32, height: 32)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        // 进度指示器
                        StepProgressBar(currentStep: currentStep)
                            .frame(width: 200)
                        
                        Spacer()
                        
                        // 占位视图保持对称
                        Color.clear
                            .frame(width: 32, height: 32)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
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
                    
                    // 底部按钮区域
                    if shouldShowBottomButton {
                        VStack {
                            Divider()
                            PrimaryButton(title: bottomButtonTitle, action: handleBottomButtonAction)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                        }
                        .background(Color(.systemBackground))
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
            
            Button(action: {
                if title.isEmpty {
                    tempTitle = ""
                } else {
                    tempTitle = title
                }
                withAnimation {
                    isEditingTitle = true
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "FFF5EA"))
                        .frame(width: 240, height: 240)
                        .shadow(color: Color.black.opacity(0.05), radius: 10)
                    
                    VStack(spacing: 8) {
                        if title.isEmpty {
                            Image(systemName: "pencil.circle")
                                .font(.system(size: 30))
                                .foregroundColor(Color(.systemGray2))
                            Text("在这里输入您的困惑...")
                                .font(.system(size: 17))
                                .foregroundColor(Color(.systemGray2))
                                .multilineTextAlignment(.center)
                                .frame(width: 160)
                        } else {
                            Text(title)
                                .font(.system(size: 20, weight: .medium))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .frame(width: 200)
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.top, 20)
        .animation(.easeInOut(duration: 0.3), value: title)
        .sheet(isPresented: $isEditingTitle) {
            InputSheet(
                title: "输入您的困惑",
                text: $tempTitle,
                placeholder: "例如：在深圳还是北京生活？",
                onCancel: {
                    isEditingTitle = false
                },
                onConfirm: {
                    title = tempTitle
                    isEditingTitle = false
                }
            )
        }
    }
    
    private func optionInputView(isFirst: Bool) -> some View {
        VStack(alignment: .center, spacing: 20) {
            if options.isEmpty {
                Text("您的第一个选择是什么？")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    withAnimation {
                        showingAddOption = true
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "FFF5EA"))
                            .frame(width: 240, height: 240)
                            .shadow(color: Color.black.opacity(0.05), radius: 10)
                        
                        VStack(spacing: 8) {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 30))
                                .foregroundColor(Color(.systemGray2))
                            Text("点击添加您的选择...")
                                .font(.system(size: 17))
                                .foregroundColor(Color(.systemGray2))
                                .multilineTextAlignment(.center)
                                .frame(width: 160)
                        }
                    }
                }
                .buttonStyle(ScaleButtonStyle())
            } else {
                Text("是否还有其他选择？")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                
                // 已添加的选项显示
                VStack(spacing: 16) {
                    ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                        OptionCard(option: option, index: index, isFirst: index == 0)
                    }
                }
                .padding(.horizontal, 20)
                
                if !showingAddOption {
                    Button(action: { 
                        withAnimation {
                            showingAddOption = true
                            currentOption = ""
                            currentOptionDescription = ""
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                            Text("添加选择 \(options.count + 1)")
                                .font(.system(size: 17, weight: .medium))
                        }
                        .foregroundColor(Color(hex: "C850C0"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(hex: "C850C0").opacity(0.1))
                        .cornerRadius(25)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
        }
        .padding(.top, 20)
        .sheet(isPresented: $showingAddOption) {
            InputSheet(
                title: options.isEmpty ? "您的第一个选择是什么？" : "添加第\(options.count + 1)个选项",
                text: $currentOption,
                placeholder: "例如：在深圳生活",
                onCancel: {
                    showingAddOption = false
                },
                onConfirm: {
                    addCurrentOption()
                    showingAddOption = false
                }
            )
        }
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
            
            Button(action: {
                withAnimation {
                    isEditingAdditionalInfo = true
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "FFF5EA"))
                        .frame(width: 240, height: 240)
                        .shadow(color: Color.black.opacity(0.05), radius: 10)
                    
                    VStack(spacing: 8) {
                        if additionalInfo.isEmpty {
                            Image(systemName: "text.bubble")
                                .font(.system(size: 30))
                                .foregroundColor(Color(.systemGray2))
                            Text("点击添加补充信息...")
                                .font(.system(size: 17))
                                .foregroundColor(Color(.systemGray2))
                                .multilineTextAlignment(.center)
                                .frame(width: 160)
                        } else {
                            Text(additionalInfo)
                                .font(.system(size: 17))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .frame(width: 200)
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.top, 20)
        .sheet(isPresented: $isEditingAdditionalInfo) {
            InputSheet(
                title: "还有什么补充信息吗？",
                text: $additionalInfo,
                placeholder: "请输入补充信息...",
                onCancel: {
                    isEditingAdditionalInfo = false
                },
                onConfirm: {
                    isEditingAdditionalInfo = false
                }
            )
        }
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
    
    // 控制底部按钮显示的计算属性
    private var shouldShowBottomButton: Bool {
        switch currentStep {
        case .title:
            return !title.isEmpty
        case .options:
            if !currentOption.isEmpty {
                return true // 当前正在输入选项时显示"确定"按钮
            }
            if !options.isEmpty && !showingAddOption {
                return true // 已有选项且不在添加新选项时显示"继续"按钮
            }
            return false
        case .additionalInfo:
            return true
        case .analyzing, .result:
            return false
        }
    }
    
    // 底部按钮文字
    private var bottomButtonTitle: String {
        switch currentStep {
        case .title:
            return "是的"
        case .options:
            if !currentOption.isEmpty {
                return "确定"
            }
            if !options.isEmpty && !showingAddOption {
                return "继续"
            }
            return ""
        case .additionalInfo:
            return "开始分析"
        default:
            return ""
        }
    }
    
    // 底部按钮动作
    private func handleBottomButtonAction() {
        switch currentStep {
        case .title:
            moveToNextStep()
        case .options:
            if !currentOption.isEmpty {
                addCurrentOption()
                showingAddOption = false // 添加选项后关闭输入框
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
    let index: Int
    let isFirst: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("选择 \(index + 1)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: isFirst ? "4158D0" : "C850C0"))
                    .cornerRadius(12)
                
                Spacer()
            }
            
            Text(option.title)
                .font(.system(size: 17, weight: .semibold))
            
            if !option.description.isEmpty {
                Text(option.description)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
    }
}

// 新的分段进度条视图
struct StepProgressBar: View {
    let currentStep: CreateDecisionView.Step
    private let steps = CreateDecisionView.Step.allCases
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(steps, id: \.self) { step in
                Circle()
                    .fill(stepColor(for: step))
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(Color.primary.opacity(currentStep == step ? 0.2 : 0),
                                  lineWidth: 2)
                            .padding(-2)
                    )
                    .scaleEffect(currentStep == step ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3), value: currentStep == step)
                
                if step != .result {
                    Rectangle()
                        .fill(stepLineColor(for: step))
                        .frame(height: 2)
                }
            }
        }
    }
    
    private func stepColor(for step: CreateDecisionView.Step) -> Color {
        if currentStep.rawValue > step.rawValue {
            return .primary
        } else if currentStep == step {
            return .primary
        }
        return Color(.systemGray4)
    }
    
    private func stepLineColor(for step: CreateDecisionView.Step) -> Color {
        if currentStep.rawValue > step.rawValue {
            return .primary
        }
        return Color(.systemGray4)
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

// 添加按钮缩放效果
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// 新增输入表单视图
struct InputSheet: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let onCancel: () -> Void
    let onConfirm: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 标题区域
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    Text("输入后，我们一起慢慢解开它。")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 30)
                .padding(.bottom, 20)
                
                Spacer()
                
                // 输入区域
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "4158D0").opacity(0.05))
                        .frame(height: 150)
                    
                    TextEditor(text: $text)
                        .font(.system(size: 17))
                        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                        .frame(height: 150)
                        .scrollContentBackground(.hidden)
                        .background(
                            ZStack(alignment: .topLeading) {
                                if text.isEmpty {
                                    Text(placeholder)
                                        .font(.system(size: 17))
                                        .foregroundColor(Color(hex: "4158D0").opacity(0.5))
                                        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                                }
                            }
                        )
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // 按钮区域
                VStack(spacing: 12) {
                    // 确认按钮
                    Button(action: onConfirm) {
                        Text("确定")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "4158D0"), Color(hex: "C850C0")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                    }
                    .disabled(text.isEmpty)
                    .opacity(text.isEmpty ? 0.6 : 1.0)
                    
                    // 取消按钮
                    Button(action: onCancel) {
                        Text("取消")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(Color(hex: "4158D0"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 34) // 增加底部间距，避免被圆角遮挡
            }
            .navigationBarHidden(true)
        }
        .presentationDetents([.height(380)])
        .presentationBackground(.regularMaterial)
    }
}

#Preview {
    CreateDecisionView()
        .environmentObject(DecisionStore())
} 
