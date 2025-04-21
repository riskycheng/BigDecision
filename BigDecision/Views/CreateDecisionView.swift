import SwiftUI
import UIKit
import Combine

struct CreateDecisionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var decisionStore: DecisionStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var aiService = AIService()
    
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
    
    // 初始决策数据
    let initialDecision: Decision?
    
    // 状态变量
    @State private var currentStep: Step = .title
    @State private var title: String = ""
    @State private var isEditingTitle = false  // 新增状态控制输入框显示
    @State private var tempTitle = ""          // 新增临时标题存储
    @State private var options: [Option] = []
    @State private var currentOption: String = ""
    @State private var currentOptionDescription = ""
    @State private var additionalInfo: String = ""
    @State private var showingAddOption = false
    @State private var decision: Decision?
    @State private var isAnalyzing = false
    @State private var isDescriptionExpanded = false  // 新增状态控制补充说明的展开/折叠
    @State private var isEditingAdditionalInfo = false
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var retryCount = 0
    private let maxRetries = 2
    @State private var analysisSteps: [String] = []
    @State private var currentAnalysisStep = 0
    @State private var showingThinkingProcess = false
    private let analysisStepMessages = [
        "正在理解您的决策问题...",
        "分析选项A的优缺点...",
        "分析选项B的优缺点...",
        "权衡各个因素...",
        "生成最终建议..."
    ]
    @State private var editingOptionIndex: Int?
    @State private var editingOption: Option?
    @State private var decisionType: Decision.DecisionType = .other
    @State private var importance: Int = 3
    @State private var timeFrame: Decision.TimeFrame = .days
    @State private var selectedDecisionTypeFilter: Decision.DecisionType = .other
    
    init(initialDecision: Decision? = nil) {
        self.initialDecision = initialDecision
        // 初始化所有状态变量
        if let initial = initialDecision {
            _title = State(initialValue: initial.title)
            _options = State(initialValue: initial.options)
            _additionalInfo = State(initialValue: initial.additionalInfo)
            _decisionType = State(initialValue: initial.decisionType)
            _importance = State(initialValue: initial.importance)
            _timeFrame = State(initialValue: initial.timeFrame)
            
            // 如果是重新分析，从选项步骤开始
            _currentStep = State(initialValue: .options)
        } else {
            // 新决策从第一步开始
            _currentStep = State(initialValue: .title)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景色
                #if canImport(UIKit)
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                #else
                Color.white
                    .ignoresSafeArea()
                #endif
                
                VStack(spacing: 0) {
                    // 顶部导航栏
                    HStack {
                        Spacer()
                        
                        // 进度指示器
                        StepProgressBar(currentStep: currentStep)
                            .frame(width: 250)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    
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
                                    VStack {
                                        
                                        ResultView(decision: decision)
                                    }
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
                        #if canImport(UIKit)
                        .background(Color(UIColor.systemBackground))
                        #else
                        .background(Color.white)
                        #endif
                    }
                }
            }
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
        }
        #if os(iOS)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        #endif
        .onAppear {
            setupAnalysisSteps()
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
                    // 外层阴影
                    Circle()
                        .fill(Color.white)
                        .frame(width: 240, height: 240)
                        .shadow(color: Color(hex: "4158D0").opacity(0.1), radius: 15, x: 0, y: 8)
                    
                    // 渐变背景
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        Color(hex: "EEF2FF"),
                                        Color(hex: "F6F0FF")
                                    ]
                                ),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 220, height: 220)
                    
                    // 发光边框
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        Color(hex: "4158D0").opacity(0.3),
                                        Color(hex: "C850C0").opacity(0.3),
                                        Color(hex: "4158D0").opacity(0.3)
                                    ]
                                ),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 220, height: 220)
                        .blur(radius: 1)
                    
                    // 内容
                    VStack(spacing: 12) {
                        if title.isEmpty {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(hex: "4158D0"))
                                .symbolRenderingMode(.hierarchical)
                            
                            Text("在这里输入您的困惑...")
                                .font(.system(size: 17))
                                .foregroundColor(Color(hex: "4158D0").opacity(0.6))
                                .multilineTextAlignment(.center)
                                .frame(width: 160)
                        } else {
                            Text(title)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(hex: "4158D0"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .frame(width: 200)
                        }
                    }
                }
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.top, 20)
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
                        // 外层阴影
                        Circle()
                            .fill(Color.white)
                            .frame(width: 240, height: 240)
                            .shadow(color: Color(hex: "C850C0").opacity(0.1), radius: 15, x: 0, y: 8)
                        
                        // 渐变背景
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(
                                        colors: [
                                            Color(hex: "FFF1F9"),
                                            Color(hex: "FFF0F2")
                                        ]
                                    ),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 220, height: 220)
                        
                        // 发光边框
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(
                                        colors: [
                                            Color(hex: "C850C0").opacity(0.3),
                                            Color(hex: "FFCC70").opacity(0.3),
                                            Color(hex: "C850C0").opacity(0.3)
                                        ]
                                    ),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 220, height: 220)
                            .blur(radius: 1)
                        
                        // 内容
                        VStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(hex: "C850C0"))
                                .symbolRenderingMode(.hierarchical)
                            
                            Text("点击添加您的选择...")
                                .font(.system(size: 17))
                                .foregroundColor(Color(hex: "C850C0").opacity(0.6))
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
                        #if canImport(UIKit)
                        // iOS平台支持左滑删除
                        OptionCard(
                            option: option,
                            index: index,
                            isFirst: index == 0,
                            onEdit: {
                                editingOptionIndex = index
                                editingOption = option
                                showingAddOption = true
                                currentOption = option.title
                                currentOptionDescription = option.description
                            }
                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    deleteOption(at: index)
                                }
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                        #else
                        // macOS平台使用标准视图
                        OptionCard(
                            option: option,
                            index: index,
                            isFirst: index == 0,
                            onEdit: {
                                editingOptionIndex = index
                                editingOption = option
                                showingAddOption = true
                                currentOption = option.title
                                currentOptionDescription = option.description
                            },
                            onDelete: {
                                withAnimation {
                                    deleteOption(at: index)
                                }
                            }
                        )
                        #endif
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
                                .symbolRenderingMode(.hierarchical)
                            Text("添加选择 \(options.count + 1)")
                                .font(.system(size: 17, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: getGradientColorsForOption(index: options.count)),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: getGradientColorsForOption(index: options.count)[0].opacity(0.3), radius: 10, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
        }
        .padding(.top, 20)
        .sheet(isPresented: $showingAddOption) {
            InputSheet(
                title: editingOption != nil ? "编辑选项" : (options.isEmpty ? "您的第一个选择是什么？" : "添加第\(options.count + 1)个选项"),
                text: $currentOption,
                placeholder: "例如：在深圳生活",
                onCancel: {
                    editingOptionIndex = nil
                    editingOption = nil
                    showingAddOption = false
                    currentOption = ""
                    currentOptionDescription = ""
                },
                onConfirm: {
                    if let index = editingOptionIndex {
                        // 更新现有选项
                        var updatedOption = options[index]
                        updatedOption.title = currentOption
                        updatedOption.description = currentOptionDescription
                        options[index] = updatedOption
                    } else {
                        // 添加新选项
                        addCurrentOption()
                    }
                    editingOptionIndex = nil
                    editingOption = nil
                    showingAddOption = false
                    currentOption = ""
                    currentOptionDescription = ""
                },
                onDelete: editingOptionIndex != nil ? {
                    if let index = editingOptionIndex {
                        withAnimation {
                            deleteOption(at: index)
                        }
                    }
                    editingOptionIndex = nil
                    editingOption = nil
                    showingAddOption = false
                    currentOption = ""
                    currentOptionDescription = ""
                } : nil,
                isEditing: editingOptionIndex != nil
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
                
            // 决策类型选择标签
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Decision.DecisionType.allCases, id: \.self) { type in
                        DecisionTypeFilterButton(
                            title: type.rawValue,
                            icon: type.icon,
                            isSelected: selectedDecisionTypeFilter == type,
                            action: {
                                withAnimation {
                                    selectedDecisionTypeFilter = type
                                    decisionType = type
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 5)
            
            Button(action: {
                withAnimation {
                    isEditingAdditionalInfo = true
                }
            }) {
                ZStack {
                    // 外层阴影
                    Circle()
                        .fill(Color.white)
                        .frame(width: 240, height: 240)
                        .shadow(color: Color(hex: "FFCC70").opacity(0.1), radius: 15, x: 0, y: 8)
                    
                    // 渐变背景
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        Color(hex: "FFFAF0"),
                                        Color(hex: "FFF9E6")
                                    ]
                                ),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 220, height: 220)
                    
                    // 发光边框
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        Color(hex: "FFCC70").opacity(0.3),
                                        Color(hex: "FF6B6B").opacity(0.3),
                                        Color(hex: "FFCC70").opacity(0.3)
                                    ]
                                ),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 220, height: 220)
                        .blur(radius: 1)
                    
                    // 内容
                    VStack(spacing: 12) {
                        if additionalInfo.isEmpty {
                            Image(systemName: "text.bubble.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(hex: "FFCC70"))
                                .symbolRenderingMode(.hierarchical)
                            
                            Text("点击添加补充信息...")
                                .font(.system(size: 17))
                                .foregroundColor(Color(hex: "FFCC70").opacity(0.7))
                                .multilineTextAlignment(.center)
                                .frame(width: 160)
                        } else {
                            Text(additionalInfo)
                                .font(.system(size: 17))
                                .foregroundColor(Color(hex: "FF9500"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .frame(width: 200)
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
        ZStack {
            #if canImport(UIKit)
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            #else
            Color.white
                .ignoresSafeArea()
            #endif
            
            VStack(spacing: 25) {
                Spacer()
                
                if showingError {
                    // 错误状态视图
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text(errorMessage ?? "发生未知错误")
                            .font(.system(size: 17))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 40)
                        
                        if retryCount < maxRetries {
                            Button(action: {
                                withAnimation {
                                    showingError = false
                                    retryAnalysis()
                                }
                            }) {
                                Text("重试")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 12)
                                    .background(Color("AppPrimary"))
                                    .cornerRadius(20)
                            }
                        } else {
                            Button(action: {
                                withAnimation {
                                    currentStep = .additionalInfo
                                    showingError = false
                                    retryCount = 0
                                }
                            }) {
                                Text("返回修改")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 12)
                                    .background(Color("AppPrimary"))
                                    .cornerRadius(20)
                            }
                        }
                    }
                } else if let modelType = AIModelType(rawValue: aiService.aiModelType), 
                          modelType == .advanced {
                    // 高级模式 - 思考过程流式显示
                    VStack(spacing: 20) {
                        // 顶部标题
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 20))
                                .foregroundColor(Color("AppPrimary"))
                            
                            Text("AI思考过程")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color("AppPrimary"))
                        }
                        .padding(.top, 10)
                        
                        // 思考过程显示区域
                        ScrollView {
                            VStack(alignment: .leading, spacing: 4) {
                                if aiService.streamedThinkingSteps.isEmpty {
                                    // 显示初始提示消息
                                    Text("正在启动思考分析过程...")
                                        .font(.system(size: 15))
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 8)
                                } else {
                                    // 将所有思考步骤合并为一个文本显示，保持思考过程的连续性
                                    Text(aiService.streamedThinkingSteps.joined())
                                        .font(.system(size: 15))
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 2)
                                        .transition(.opacity)
                                        .id(aiService.streamedThinkingSteps.count) // 确保每次更新时视图都会刷新
                                }
                                
                                if !aiService.streamingComplete {
                                    // 打字指示器
                                    HStack(spacing: 4) {
                                        ForEach(0..<3) { i in
                                            Circle()
                                                .fill(Color("AppPrimary").opacity(0.6))
                                                .frame(width: 6, height: 6)
                                                .scaleEffect(isAnalyzing ? 1.1 : 0.8)
                                                .animation(
                                                    Animation.easeInOut(duration: 0.5)
                                                        .repeatForever()
                                                        .delay(Double(i) * 0.2),
                                                    value: isAnalyzing
                                                )
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // 总结阶段指示器
                        if aiService.isSummarizing {
                            VStack(spacing: 10) {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(0.8)
                                    
                                    Text("正在总结分析结果...")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color(UIColor.tertiarySystemBackground))
                                .cornerRadius(10)
                            }
                            .padding(.top, 10)
                        }
                        
                        // 最终答案显示
                        if aiService.streamingComplete && !aiService.finalAnswer.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("分析完成")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.green)
                                }
                                
                                Divider()
                                    .padding(.vertical, 4)
                                
                                HStack(spacing: 10) {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(Color("AppPrimary"))
                                        .font(.system(size: 16))
                                    
                                    Text("最终建议")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color("AppPrimary"))
                                }
                                
                                Text(aiService.finalAnswer)
                                    .font(.system(size: 17, weight: .medium))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color("AppPrimary").opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .padding()
                            .background(Color(UIColor.tertiarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        }
                    }
                    .padding()
                } else {
                    // 标准分析中状态视图
                    VStack(spacing: 25) {
                        // 分析动画
                        ZStack {
                            // 波浪动画背景
                            ForEach(0..<3) { index in
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color("AppPrimary").opacity(0.2 - Double(index) * 0.05),
                                                Color("AppSecondary").opacity(0.2 - Double(index) * 0.05)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 8
                                    )
                                    .frame(width: 100 + CGFloat(index) * 30,
                                           height: 100 + CGFloat(index) * 30)
                                    .scaleEffect(isAnalyzing ? 1.2 : 0.8)
                                    .opacity(isAnalyzing ? 0.2 : 0.8)
                            }
                            .animation(
                                Animation.easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true),
                                value: isAnalyzing
                            )
                            
                            // 背景圆圈
                            Circle()
                                .stroke(Color("AppPrimary").opacity(0.2), lineWidth: 8)
                                .frame(width: 100, height: 100)
                            
                            // 动画圆圈
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
                                .frame(width: 100, height: 100)
                                .rotationEffect(.degrees(isAnalyzing ? 360 : 0))
                            .animation(
                                Animation.linear(duration: 1)
                                    .repeatForever(autoreverses: false),
                                value: isAnalyzing
                            )
                            
                            // 中心图标
                            Image(systemName: "sparkles")
                                .font(.system(size: 30))
                                .foregroundColor(Color("AppPrimary"))
                                .scaleEffect(isAnalyzing ? 1.1 : 0.9)
                            .animation(
                                Animation.easeInOut(duration: 1)
                                    .repeatForever(autoreverses: true),
                                value: isAnalyzing
                            )
                        }
                        .padding(.bottom, 30)
                        
                        VStack(spacing: 15) {
                            Text("正在分析中...")
                                .font(.system(size: 22, weight: .semibold))
                            
                            // 分析步骤显示
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(analysisSteps.indices, id: \.self) { index in
                                    HStack(alignment: .center, spacing: 8) {
                                        // 步骤完成图标
                                        ZStack {
                                            Circle()
                                                .fill(Color.green.opacity(0.2))
                                                .frame(width: 24, height: 24)
                                            
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                                .opacity(index < currentAnalysisStep ? 1 : 0)
                                        }
                                        
                                        Text(analysisSteps[index])
                                            .font(.system(size: 15))
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        Spacer()
                                    }
                                    .opacity(index <= currentAnalysisStep ? 1 : 0.5)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                        }
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            DispatchQueue.main.async {
                withAnimation {
                    isAnalyzing = true
                    
                    // 检查是否是高级模式，如果是则启用思考过程显示
                    if let modelType = AIModelType(rawValue: aiService.aiModelType),
                       modelType == .advanced {
                        showingThinkingProcess = true
                    } else {
                        showingThinkingProcess = false
                    }
                }
            }
        }
        .onDisappear {
            DispatchQueue.main.async {
                withAnimation {
                    isAnalyzing = false
                    
                    // 取消任何正在进行的流式分析
                    aiService.cancelStreaming()
                }
            }
        }
    }
    
    private func setupAnalysis() {
        // 重置分析状态
        analysisSteps = analysisStepMessages
        currentAnalysisStep = 0
        
        // 在主线程上更新UI状态
        DispatchQueue.main.async {
            withAnimation {
                isAnalyzing = true
                
                // 检查是否是高级模式，如果是则启用思考过程显示
                if let modelType = AIModelType(rawValue: aiService.aiModelType),
                   modelType == .advanced {
                    showingThinkingProcess = true
                    
                    // 清空之前的思考步骤，准备接收新的流式内容
                    aiService.streamedThinkingSteps = []
                } else {
                    showingThinkingProcess = false
                    
                    // 如果不是高级模式，则使用标准分析步骤动画
                    // 模拟分析进度
                    for step in 0..<analysisStepMessages.count {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(step) * 0.8) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentAnalysisStep = step + 1
                            }
                        }
                    }
                }
            }
        }
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
        // 将当前选项添加到选项列表，如果有的话
        if currentStep == .title && !currentOption.isEmpty {
            addCurrentOption()
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
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
    
    private func deleteOption(at index: Int) {
        guard index >= 0 && index < options.count else { return }
        options.remove(at: index)
    }
    
    private func retryAnalysis() {
        retryCount += 1
        startAnalysis()
    }
    
    private func startAnalysis() {
        // 确保至少有两个选项，防止索引越界
        if options.count < 2 {
            while options.count < 2 {
                let option = Option(
                    title: "选项 \(options.count + 1)",
                    description: "自动生成的选项描述"
                )
                options.append(option)
            }
        }
        
        // 创建决策对象
        let newDecision = Decision(
            title: title,
            options: options,
            additionalInfo: additionalInfo,
            decisionType: decisionType,
            importance: importance,
            timeFrame: timeFrame
        )
        
        // 立即转到分析视图
        withAnimation {
            currentStep = .analyzing
        }
        
        // 在控制台打印决策信息
        print("\n[开始分析] 决策标题: \(newDecision.title)")
        print("[选项A] \(newDecision.options[0].title): \(newDecision.options[0].description)")
        print("[选项B] \(newDecision.options[1].title): \(newDecision.options[1].description)")
        print("[补充信息] \(newDecision.additionalInfo.isEmpty ? "无" : newDecision.additionalInfo)")
        print("[模式] \(aiService.aiModelType)\n")
        
        // 设置分析步骤
        setupAnalysis()
        
        // 检查是否是高级模式
        let isAdvancedMode = AIModelType(rawValue: aiService.aiModelType) == .advanced
        
        // 开始分析
        Task {
            do {
                // 调用AI服务进行分析
                let result = try await aiService.analyzeDecision(newDecision)
                
                // 更新决策结果
                var finalDecision = newDecision
                finalDecision.result = result
                
                // 保存决策到存储
                decisionStore.addDecision(finalDecision)
                
                // 更新当前决策
                DispatchQueue.main.async {
                    self.decision = finalDecision
                    withAnimation {
                        self.currentStep = .result
                    }
                }
            } catch {
                // 处理错误
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    withAnimation {
                        self.showingError = true
                        self.retryCount += 1
                    }
                }
            }
        }
    }
    
    // 在视图加载时初始化分析步骤
    private func setupAnalysisSteps() {
        // 实现分析步骤的初始化逻辑
    }
}

struct OptionCard: View {
    let option: Option
    let index: Int
    let isFirst: Bool
    let onEdit: () -> Void
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        Button(action: onEdit) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("选择 \(index + 1)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(getOptionBadgeColor(index: index))
                        .cornerRadius(12)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        #if os(macOS)
                        if let onDelete = onDelete {
                            Button(action: onDelete) {
                                Image(systemName: "trash.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.red.opacity(0.7))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        #endif
                        
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(getOptionBadgeColor(index: index).opacity(0.6))
                    }
                }
                
                Text(option.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                
                if !option.description.isEmpty {
                    Text(option.description)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            #if canImport(UIKit)
            .background(Color(UIColor.systemBackground))
            #else
            .background(Color.white)
            #endif
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getOptionBadgeColor(index: Int) -> Color {
        switch index {
        case 0:
            return Color(hex: "4158D0")  // 深蓝色
        case 1:
            return Color(hex: "C850C0")  // 紫色
        case 2:
            return Color(hex: "FFCC70")  // 金色
        case 3:
            return Color(hex: "FF6B6B")  // 珊瑚红
        default:
            return Color(hex: "4ECDC4")  // 青绿色
        }
    }
}

// 新的分段进度条视图
struct StepProgressBar: View {
    let currentStep: CreateDecisionView.Step
    private let steps = CreateDecisionView.Step.allCases
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<steps.count, id: \.self) { index in
                let step = steps[index]
                stepView(for: step, index: index)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
    }
    
    private func stepView(for step: CreateDecisionView.Step, index: Int) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 0) {
                // 圆点
                stepCircle(for: step)
                
                // 连接线
                if index < steps.count - 1 {
                    stepConnector(from: step, to: steps[index + 1])
                }
            }
            
            // 步骤名称
            Text(step.title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(currentStep == step ? step.color.0 : .secondary)
                .fixedSize()
        }
        .frame(maxWidth: .infinity)
    }
    
    private func stepCircle(for step: CreateDecisionView.Step) -> some View {
        Circle()
            .fill(currentStep.rawValue >= step.rawValue ? 
                LinearGradient(
                    gradient: Gradient(colors: [step.color.0, step.color.1]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) : LinearGradient(
                    gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            .frame(width: 26, height: 26)
            .overlay(
                Group {
                    if currentStep.rawValue > step.rawValue {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    } else if currentStep == step {
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .frame(width: 12, height: 12)
                    }
                }
            )
    }
    
    private func stepConnector(from: CreateDecisionView.Step, to: CreateDecisionView.Step) -> some View {
        Rectangle()
            .fill(from.rawValue < currentStep.rawValue ?
                LinearGradient(
                    gradient: Gradient(colors: [from.color.0, to.color.0]),
                    startPoint: .leading, 
                    endPoint: .trailing
                ) : LinearGradient(
                    gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))
            .frame(height: 4)
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

// 新增输入表单视图
struct InputSheet: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let onCancel: () -> Void
    let onConfirm: () -> Void
    var onDelete: (() -> Void)? = nil
    var isEditing: Bool = false
    @State private var showingDeleteConfirmation = false
    
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
                .padding(.top, 60) // 增加顶部间距，避免与导航图标重叠
                .padding(.bottom, 20)
                
                Spacer()
                
                // 输入区域
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "F8F9FF"))
                        .frame(height: 150)
                        .shadow(color: Color(hex: "4158D0").opacity(0.05), radius: 10, y: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "4158D0").opacity(0.3),
                                            Color(hex: "C850C0").opacity(0.1),
                                            Color(hex: "4158D0").opacity(0.1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                    
                    TextEditor(text: $text)
                        .font(.system(size: 17))
                        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                        .frame(height: 150)
                        .scrollContentBackground(.hidden)
                        .background(
                            ZStack(alignment: .topLeading) {
                                if text.isEmpty {
                                    HStack {
                                        Image(systemName: "pencil.line")
                                            .foregroundColor(Color(hex: "4158D0").opacity(0.5))
                                            .font(.system(size: 15))
                                        
                                        Text(placeholder)
                                            .font(.system(size: 17))
                                            .foregroundColor(Color(hex: "4158D0").opacity(0.5))
                                    }
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
                            .shadow(color: Color(hex: "4158D0").opacity(0.3), radius: 8, y: 4)
                    }
                    .disabled(text.isEmpty)
                    .opacity(text.isEmpty ? 0.6 : 1.0)
                    
                    // 删除按钮 - 仅在编辑现有选项时显示
                    if isEditing, let deleteAction = onDelete {
                        Button(action: {
                            // 显示确认对话框
                            showingDeleteConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("删除此选项")
                            }
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red)
                            .cornerRadius(25)
                            .shadow(color: Color.red.opacity(0.3), radius: 8, y: 4)
                        }
                        .confirmationDialog("确认删除", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                            Button("删除", role: .destructive, action: deleteAction)
                            Button("取消", role: .cancel) { }
                        } message: {
                            Text("确定要删除这个选项吗？")
                        }
                    }
                    
                    // 取消按钮已移除 - 用户可以下拉来取消
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
        }
        #if os(iOS)
        .presentationDetents([.height(400)])
        .presentationDragIndicator(.visible)
        #endif
    }
}

#Preview {
    CreateDecisionView()
        .environmentObject(DecisionStore())
}

// 决策类型过滤按钮
struct DecisionTypeFilterButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color("AppPrimary") : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// 添加获取渐变色的函数
extension CreateDecisionView {
    func getGradientColorsForOption(index: Int) -> [Color] {
        switch index {
        case 0:
            return [Color(hex: "4158D0"), Color(hex: "C850C0")]  // 深蓝到紫色渐变
        case 1:
            return [Color(hex: "C850C0"), Color(hex: "FFCC70")]  // 紫色到金色渐变
        case 2:
            return [Color(hex: "FFCC70"), Color(hex: "FF6B6B")]  // 金色到珊瑚红渐变
        case 3:
            return [Color(hex: "FF6B6B"), Color(hex: "4ECDC4")]  // 珊瑚红到青绿渐变
        default:
            return [Color(hex: "4ECDC4"), Color(hex: "2ECC71")]  // 青绿到翠绿渐变
        }
    }
} 
