import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

private struct TextHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ExpandableText: View {
    let text: String
    let maxLines: Int
    @State private var isExpanded = false
    @State private var isTruncated = false
    @State private var showingDetailDialog = false
    @State private var intrinsicHeight: CGFloat = 0
    @State private var truncatedHeight: CGFloat = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .bottom, spacing: 4) {
                Text(text)
                    .font(.system(size: 17))
                    .lineLimit(isExpanded ? nil : maxLines)
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : Color.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: TextHeightPreferenceKey.self,
                                value: geometry.size.height
                            )
                        }
                    )
                    .onPreferenceChange(TextHeightPreferenceKey.self) { height in
                        if truncatedHeight == 0 {
                            truncatedHeight = height
                        }
                    }
                
                if isTruncated && !isExpanded {
                    Button(action: { showingDetailDialog = true }) {
                        HStack(spacing: 2) {
                            Text("查看详情")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : Color("AppPrimary").opacity(0.9))
                            Image(systemName: "chevron.forward")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color("AppPrimary").opacity(0.6))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color("AppPrimary").opacity(0.1))
                        )
                    }
                }
            }
            
            ZStack {
                // 用于测量完整文本高度的隐藏文本
                Text(text)
                    .font(.system(size: 17))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .hidden()
                    .background(
                        GeometryReader { geometry in
                            Color.clear.onAppear {
                                intrinsicHeight = geometry.size.height
                                isTruncated = intrinsicHeight > truncatedHeight
                            }
                        }
                    )
            }
            .frame(height: 0)
        }
        .sheet(isPresented: $showingDetailDialog) {
            DetailDialog(title: "详细内容", content: text)
                .interactiveDismissDisabled(false)
        }
    }
}

struct DetailDialog: View {
    let title: String
    let content: String
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @State private var showContent = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // 顶部标题
                    HStack(spacing: 6) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 15))
                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : Color.primary.opacity(0.9))
                        Text(title)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : Color.primary.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // 内容区域
                    Text(content)
                        .font(.system(size: 17))
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : .primary)
                        .lineSpacing(6)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colorScheme == .dark ? Color(red: 0.25, green: 0.25, blue: 0.3) : Color.white)
                                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 10, y: 5)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                }
                .padding(.bottom, 30)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color.white,
                        colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.18) : Color.white.opacity(0.95)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("完成")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color("AppPrimary"))
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
                showContent = true
            }
        }
    }
}

struct CardView<Content: View>: View {
    let content: Content
    var backgroundColor: Color = Color(UIColor.systemBackground)
    var topIcon: (name: String, color: Color)? = nil
    @Environment(\.colorScheme) var colorScheme
    
    init(backgroundColor: Color = Color(UIColor.systemBackground),
         topIcon: (name: String, color: Color)? = nil,
         @ViewBuilder content: () -> Content) {
        self.content = content()
        self.backgroundColor = backgroundColor
        self.topIcon = topIcon
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let icon = topIcon {
                HStack {
                    Image(systemName: icon.name)
                        .font(.system(size: 14))
                        .foregroundColor(icon.color)
                    Spacer()
                }
                .padding(.bottom, 12)
            }
            
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .shadow(color: colorScheme == .dark ? Color.black.opacity(0.2) : Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

struct ResultView: View {
    let decision: Decision
    @Environment(\.dismiss) private var dismiss
    @State private var isFavorited: Bool
    @State private var showingShareSheet = false
    @State private var showingExportOptions = false
    @State private var showingExportImage = false
    @State private var exportedImage: UIImage?
    @State private var showingDeleteConfirmation = false
    @State private var showingExportReport = false
    @State private var showingReasoningDialog = false
    @State private var showingThinkingProcessDialog = false
    @State private var showingReanalyzeConfirmation = false
    @State private var selectedShareContentType: ShareContentType = .summary
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var decisionStore: DecisionStore
    @EnvironmentObject var reanalysisCoordinator: ReanalysisCoordinator
    
    enum ShareContentType {
        case summary, detailed, image
    }
    
    init(decision: Decision) {
        self.decision = decision
        self._isFavorited = State(initialValue: decision.isFavorited)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 决策标题
                CardView(backgroundColor: Color("AppPrimary").opacity(0.08)) {
                    ExpandableText(text: decision.title, maxLines: 3)
                        .font(.title2)
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : Color.primary)
                        .fontWeight(.bold)
                }
                
                if let result = decision.result {
                    // AI推荐结果卡片
                    CardView(backgroundColor: Color("AppPrimary").opacity(0.1)) {
                        VStack(spacing: 12) {
                            // 标题栏
                            HStack {
                                HStack(spacing: 6) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color("AppPrimary"))
                                    Text("AI推荐")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : Color("AppPrimary"))
                                }
                                
                                Spacer()
                                
                                // 置信度标签
                                HStack(spacing: 4) {
                                    Text("置信度")
                                        .font(.system(size: 14))
                                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : .primary)
                                    Text("\(Int(result.confidence * 100))%")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : .primary)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color("AppPrimary").opacity(0.8))
                                .cornerRadius(6)
                            }
                            
                            // 推荐选项
                            ExpandableText(text: getRecommendedOption(result.recommendation).title, maxLines: 2)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : Color.primary)
                        }
                    }
                    
                    // 分析理由
                    CardView(backgroundColor: Color(UIColor.systemBackground)) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color("AppPrimary"))
                                Text("分析理由")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : Color("AppPrimary"))
                                
                                Spacer()
                            }
                            
                            Button(action: { 
                                // 显示分析理由对话框
                                showingReasoningDialog = true
                            }) {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(result.reasoning)
                                        .font(.system(size: 17))
                                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : .primary.opacity(0.9))
                                        .lineLimit(4)
                                        .multilineTextAlignment(.leading)
                                        .padding(.horizontal, 12)
                                        .padding(.top, 12)
                                        .padding(.bottom, 8)  // 大幅减小底部空间
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    // 查看详情按钮
                                    HStack {
                                        Spacer()
                                        Text("查看详情")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : Color("AppPrimary").opacity(0.9))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)  // 减小垂直内边距
                                            .background(
                                                Capsule()
                                                    .fill(Color("AppPrimary").opacity(0.1))
                                            )
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.bottom, 8)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("AppPrimary").opacity(0.08))
                                )
                            }
                        }
                    }
                    
                    // 详情分析
                    CardView(backgroundColor: Color(UIColor.systemBackground)) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "list.bullet.clipboard")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color("AppPrimary"))
                                Text("详情分析")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : Color("AppPrimary"))
                            }
                            
                            // 选项对比
                            if decision.options.count >= 2 {
                                VStack(spacing: 16) {
                                    ForEach(decision.options) { option in
                                        OptionAnalysisCard(
                                            option: option,
                                            pros: option.id == decision.options[0].id ? result.prosA : result.prosB,
                                            cons: option.id == decision.options[0].id ? result.consA : result.consB
                                        )
                                    }
                                }
                            }
                        }
                    }
                    
                    // 分析过程卡片 - 显示AI思考链
                    if let thinkingProcess = result.thinkingProcess, !thinkingProcess.isEmpty {
                        CardView(backgroundColor: Color(UIColor.systemBackground)) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 8) {
                                    Image(systemName: "brain.head.profile")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color("AppPrimary"))
                                    Text("分析过程")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : Color("AppPrimary"))
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        // 直接显示分析过程对话框
                                        showingThinkingProcessDialog = true
                                    }) {
                                        Text("查看全部")
                                            .font(.system(size: 14))
                                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : Color("AppPrimary").opacity(0.9))
                                    }
                                }
                                
                                // 思考过程预览
                                Text(thinkingProcess.prefix(300) + (thinkingProcess.count > 300 ? "..." : ""))
                                    .font(.system(size: 15))
                                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : .primary.opacity(0.9))
                                    .lineLimit(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(12)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(8)
                            }
                        }
                        .onTapGesture {
                            // 直接显示分析过程对话框
                            showingThinkingProcessDialog = true
                        }

                    }
                    
                    // 底部操作按钮栏
                    CardView(backgroundColor: Color(UIColor.secondarySystemBackground)) {
                        HStack(spacing: 24) {
                            // 收藏按钮
                            ActionButton(
                                icon: isFavorited ? "star.fill" : "star",
                                label: "收藏",
                                iconColor: isFavorited ? .yellow : .gray,
                                action: toggleFavorite
                            )
                            
                            // 导出按钮
                            #if canImport(UIKit)
                            ActionButton(
                                icon: "square.and.arrow.down",
                                label: "导出",
                                action: { showingExportOptions = true }
                            )
                            #endif
                            
                            // 分享按钮
                            ActionButton(
                                icon: "square.and.arrow.up",
                                label: "分享",
                                action: { showingShareSheet = true }
                            )
                            
                            // 重新分析按钮
                            ActionButton(
                                icon: "arrow.clockwise",
                                label: "重新分析",
                                action: { showingReanalyzeConfirmation = true }
                            )
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, {
                        #if canImport(UIKit)
                        if #available(iOS 15.0, *) {
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let keyWindow = windowScene.windows.first {
                                return keyWindow.safeAreaInsets.bottom
                            }
                        } else {
                            return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
                        }
                        #endif
                        return 0
                    }())
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
                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : isFavorited ? .yellow : .gray)
                    }
                    
                    #if canImport(UIKit)
                    Button(action: { showingShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : .gray)
                    }
                    
                    Button(action: { showingExportOptions = true }) {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : .gray)
                    }
                    #endif
                }
            }
        }
        #if canImport(UIKit)
        .actionSheet(isPresented: $showingExportOptions) {
            ActionSheet(
                title: Text("选择导出格式"),
                buttons: [
                    .default(Text("图片")) {
                        if let image = exportDecisionAsImage() {
                            exportedImage = image
                            showingExportImage = true
                        }
                    },
                    .default(Text("PDF")) {
                        exportAsPDF()
                    },
                    .default(Text("文本")) {
                        exportAsText()
                    },
                    .cancel(Text("取消"))
                ]
            )
        }
        .actionSheet(isPresented: $showingShareSheet) {
            ActionSheet(
                title: Text("选择分享内容"),
                buttons: [
                    .default(Text("简要总结")) {
                        selectedShareContentType = .summary
                        shareContent()
                    },
                    .default(Text("详细报告")) {
                        selectedShareContentType = .detailed
                        shareContent()
                    },
                    .default(Text("分享图片")) {
                        selectedShareContentType = .image
                        shareContent()
                    },
                    .cancel(Text("取消"))
                ]
            )
        }
        .alert(isPresented: $showingReanalyzeConfirmation) {
            Alert(
                title: Text("确认重新分析"),
                message: Text("是否要使用当前的选项重新进行分析？您可以在分析前修改相关信息。"),
                primaryButton: .default(Text("确定")) {
                    // 先启动重新分析过程
                    reanalysisCoordinator.startReanalysis(with: decision)
                    
                    // 等待短暂时间再关闭当前视图，确保协调器有足够时间准备
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        dismiss()
                    }
                },
                secondaryButton: .cancel(Text("取消"))
            )
        }
        .sheet(isPresented: $showingExportImage) {
            if let image = exportedImage {
                ExportImageView(image: image, onDismiss: { showingExportImage = false })
            }
        }
        #endif

        // 分析理由对话框
        .sheet(isPresented: $showingReasoningDialog) {
            if let result = decision.result {
                DetailDialog(title: "分析理由", content: result.reasoning)
            }
        }
        
        // 分析过程对话框
        .sheet(isPresented: $showingThinkingProcessDialog) {
            if let result = decision.result, let thinkingProcess = result.thinkingProcess {
                DetailDialog(title: "分析过程", content: thinkingProcess)
            }
        }
    }
    
    private func getRecommendedOption(_ recommendation: String) -> Option {
        // 确保数组有足够的元素
        guard decision.options.count >= 2 else {
            return decision.options.first ?? Option(title: "未知选项", description: "")
        }
        
        return recommendation == "A" ? decision.options[0] : decision.options[1]
    }
    
    private func toggleFavorite() {
        isFavorited.toggle()
        var updatedDecision = decision
        updatedDecision.isFavorited = isFavorited
        decisionStore.updateDecision(updatedDecision)
        
        #if canImport(UIKit)
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.success)
        #endif
    }
    
    private func generateShareContent(type: ShareContentType) -> Any {
        switch type {
        case .summary:
            return generateShareText()
        case .detailed:
            return generateDetailedReport()
        case .image:
            #if canImport(UIKit)
            return exportDecisionAsImage() ?? UIImage()
            #else
            return generateShareText()
            #endif
        }
    }

    private func generateDetailedReport() -> String {
        guard let result = decision.result else { return "" }
        
        let recommendedOption = getRecommendedOption(result.recommendation)
        
        return """
        详细决策分析报告
        
        决策标题: \(decision.title)
        
        选项比较:
        \(decision.options.map { option in
            """
            
            \(option.title):
            描述: \(option.description)
            优点:
            \(option.id == decision.options[0].id ? result.prosA : result.prosB)
            缺点:
            \(option.id == decision.options[0].id ? result.consA : result.consB)
            """
        }.joined(separator: "\n\n"))
        
        AI推荐: \(recommendedOption.title)
        置信度: \(Int(result.confidence * 100))%
        
        分析理由:
        \(result.reasoning)
        
        决策时间: \(decision.createdAt.formatted())
        """
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
    
    #if canImport(UIKit)
    private func exportDecisionAsImage() -> UIImage? {
        guard let result = decision.result, decision.options.count >= 2 else { return nil }
        
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

    private func exportAsPDF() {
        // 实现 PDF 导出逻辑
        let pdfData = generatePDFData()
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let pdfURL = temporaryDirectoryURL.appendingPathComponent("\(decision.title)_分析报告.pdf")
        
        do {
            try pdfData.write(to: pdfURL)
            let activityVC = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        } catch {
            print("PDF导出失败: \(error)")
        }
    }

    private func exportAsText() {
        let text = generateDetailedReport()
        // 实现文本导出逻辑
        #if canImport(UIKit)
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let textURL = temporaryDirectoryURL.appendingPathComponent("\(decision.title)_分析报告.txt")
        
        do {
            try text.write(to: textURL, atomically: true, encoding: .utf8)
            let activityVC = UIActivityViewController(activityItems: [textURL], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        } catch {
            print("文本导出失败: \(error)")
        }
        #endif
    }

    private func generatePDFData() -> Data {
        let format = UIGraphicsPDFRendererFormat()
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4 尺寸
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            let text = generateDetailedReport()
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]
            
            text.draw(with: CGRect(x: 50, y: 50, width: pageRect.width - 100, height: pageRect.height - 100),
                     options: .usesLineFragmentOrigin,
                     attributes: attributes,
                     context: nil)
        }
        
        return data
    }
    #endif

    private func shareContent() {
        let content = generateShareContent(type: selectedShareContentType)
        #if canImport(UIKit)
        let activityVC = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
        #endif
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
                
                ForEach(0..<options.count, id: \.self) { index in
                    Text("选项\(index == 0 ? "A" : "B"): \(options[index].title)")
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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 选项标题区域
            HStack(spacing: 8) {
                Text("选项")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : .primary.opacity(0.9))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.primary.opacity(0.1))
                    .cornerRadius(6)
                
                Text(option.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : .primary)
            }
            
            if !option.description.isEmpty {
                Text(option.description)
                    .font(.system(size: 15))
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : .primary.opacity(0.9))
            }
            
            VStack(alignment: .leading, spacing: 12) {
                if !pros.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("优点")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.green)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(6)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(pros, id: \.self) { pro in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 14))
                                    
                                    Text(pro)
                                        .font(.system(size: 15))
                                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : .primary.opacity(0.9))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if !cons.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("缺点")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.red)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(6)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(cons, id: \.self) { con in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.system(size: 14))
                                    
                                    Text(con)
                                        .font(.system(size: 15))
                                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : .primary.opacity(0.9))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
    }
}

#if canImport(UIKit)
struct ExportImageView: View {
    let image: UIImage
    let onDismiss: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            Text("决策分析图片")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : .primary)
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
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : .primary)
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
#endif

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