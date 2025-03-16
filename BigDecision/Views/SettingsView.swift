import SwiftUI

struct WaveShape: Shape {
    var offset: CGFloat
    var waveHeight: CGFloat
    
    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midHeight = height / 2
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / 50 + offset
            let y = sin(relativeX) * waveHeight + midHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

struct SettingsView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("aiModelType") private var aiModelType = "标准"
    
    @State private var showingResetAlert = false
    @State private var showingAboutSheet = false
    @State private var waveOffset: CGFloat = 0
    @State private var textIndex = 0
    
    private let texts = ["智能决策", "科学分析", "多方权衡"]
    private let gradient = LinearGradient(
        gradient: Gradient(colors: [
            Color("AppPrimary").opacity(0.8),
            Color("AppPrimary").opacity(0.4),
            Color("AppPrimary").opacity(0.2)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    private var filteredSettings: [String: [String]] {
        let allSettings = [
            "个人设置": ["你的名字", "启用通知", "深色模式"],
            "AI设置": ["AI模型", "高级AI设置"],
            "数据管理": ["重置所有决定", "导出数据"],
            "关于": ["关于大决定", "隐私政策", "使用条款"]
        ]
        
        return allSettings
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
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
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("设置")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.top, 25)
                            
                            Text("自定义你的使用体验")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                            
                            // 动画按钮
                            ZStack {
                                // 白色按钮背景
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5)
                                    .frame(height: 50)
                                
                                // 波浪动画层
                                ZStack {
                                    // 第一层波浪
                                    WaveShape(offset: waveOffset, waveHeight: 8)
                                        .fill(gradient)
                                        .opacity(0.3)
                                    
                                    // 第二层波浪（错开相位）
                                    WaveShape(offset: waveOffset + .pi, waveHeight: 6)
                                        .fill(gradient)
                                        .opacity(0.2)
                                }
                                .mask(
                                    RoundedRectangle(cornerRadius: 12)
                                        .frame(height: 50)
                                )
                                
                                // 文字层
                                HStack(spacing: 12) {
                                    Text("AI")
                                        .font(.system(size: 18, weight: .bold))
                                    Text("·")
                                        .font(.system(size: 18))
                                        .opacity(0.5)
                                    Text(texts[textIndex])
                                        .font(.system(size: 18, weight: .medium))
                                        .transition(.move(edge: .top).combined(with: .opacity))
                                        .id(texts[textIndex]) // 确保每次文字改变时触发动画
                                }
                                .foregroundColor(Color("AppPrimary"))
                            }
                            .padding(.top, 6)
                            .padding(.bottom, 15)
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 150)
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(Array(filteredSettings.keys.sorted()), id: \.self) { section in
                                if section == "个人设置" {
                                    SettingsSectionView(title: section) {
                                        VStack(spacing: 0) {
                                            if filteredSettings[section]?.contains("你的名字") ?? false {
                                                CustomTextField(title: "你的名字", text: $userName, icon: "person")
                                                    .padding(.vertical, 12)
                                                
                                                if filteredSettings[section]!.count > 1 {
                                                    Divider()
                                                }
                                            }
                                            
                                            if filteredSettings[section]?.contains("启用通知") ?? false {
                                                Toggle("启用通知", isOn: $notificationsEnabled)
                                                    .padding(.vertical, 12)
                                                
                                                if filteredSettings[section]!.last != "启用通知" {
                                                    Divider()
                                                }
                                            }
                                            
                                            if filteredSettings[section]?.contains("深色模式") ?? false {
                                                Toggle("深色模式", isOn: $darkModeEnabled)
                                                    .padding(.vertical, 12)
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                }
                                
                                // AI设置
                                if section == "AI设置" {
                                    SettingsSectionView(title: section) {
                                        VStack(spacing: 16) {
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("AI模型")
                                                    .font(.system(size: 15, weight: .medium))
                                                
                                                Picker("AI模型", selection: $aiModelType) {
                                                    Text("标准").tag("标准")
                                                    Text("专业").tag("专业")
                                                    Text("高级").tag("高级")
                                                }
                                                .pickerStyle(SegmentedPickerStyle())
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.top, 12)
                                            
                                            NavigationLink(destination: AISettingsDetailView()) {
                                                HStack {
                                                    Text("高级AI设置")
                                                    Spacer()
                                                    Image(systemName: "chevron.right")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(.secondary)
                                                }
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 12)
                                            }
                                        }
                                    }
                                }
                                
                                // 数据管理
                                if section == "数据管理" {
                                    SettingsSectionView(title: section) {
                                        VStack(spacing: 0) {
                                            Button(action: {
                                                showingResetAlert = true
                                            }) {
                                                HStack {
                                                    Image(systemName: "arrow.counterclockwise")
                                                        .foregroundColor(.red)
                                                    Text("重置所有决定")
                                                        .foregroundColor(.red)
                                                    Spacer()
                                                }
                                                .padding(.vertical, 12)
                                            }
                                            
                                            Divider()
                                            
                                            NavigationLink(destination: DataExportView()) {
                                                HStack {
                                                    Image(systemName: "square.and.arrow.up")
                                                        .foregroundColor(Color("AppPrimary"))
                                                    Text("导出数据")
                                                    Spacer()
                                                    Image(systemName: "chevron.right")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(.secondary)
                                                }
                                                .padding(.vertical, 12)
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                }
                                
                                // 关于
                                if section == "关于" {
                                    SettingsSectionView(title: section) {
                                        VStack(spacing: 0) {
                                            Button(action: {
                                                showingAboutSheet = true
                                            }) {
                                                HStack {
                                                    Image(systemName: "info.circle")
                                                        .foregroundColor(Color("AppPrimary"))
                                                    Text("关于大决定")
                                                    Spacer()
                                                    Image(systemName: "chevron.right")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(.secondary)
                                                }
                                                .padding(.vertical, 12)
                                            }
                                            
                                            Divider()
                                            
                                            Link(destination: URL(string: "https://example.com/privacy")!) {
                                                HStack {
                                                    Image(systemName: "hand.raised")
                                                        .foregroundColor(Color("AppPrimary"))
                                                    Text("隐私政策")
                                                    Spacer()
                                                    Image(systemName: "arrow.up.right.square")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                                .padding(.vertical, 12)
                                            }
                                            
                                            Divider()
                                            
                                            Link(destination: URL(string: "https://example.com/terms")!) {
                                                HStack {
                                                    Image(systemName: "doc.text")
                                                        .foregroundColor(Color("AppPrimary"))
                                                    Text("使用条款")
                                                    Spacer()
                                                    Image(systemName: "arrow.up.right.square")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                                .padding(.vertical, 12)
                                            }
                                            
                                            Divider()
                                            
                                            HStack {
                                                Text("版本")
                                                Spacer()
                                                Text("1.0.0")
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding(.vertical, 12)
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                }
                            }
                            
                            // 底部空间
                            Spacer(minLength: 30)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showingResetAlert) {
                Alert(
                    title: Text("重置所有决定"),
                    message: Text("这将删除所有你的决定历史记录。此操作无法撤销。"),
                    primaryButton: .destructive(Text("重置")) {
                        // 重置所有决定
                    },
                    secondaryButton: .cancel(Text("取消"))
                )
            }
            .sheet(isPresented: $showingAboutSheet) {
                AboutView()
            }
            .onAppear {
                // 波浪动画
                withAnimation(
                    Animation
                        .linear(duration: 4)
                        .repeatForever(autoreverses: false)
                ) {
                    waveOffset = .pi * 2
                }
                
                // 文字切换动画
                Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                    withAnimation(.easeInOut(duration: 0.5)) {
                        textIndex = (textIndex + 1) % texts.count
                    }
                }
            }
        }
    }
}

struct SettingsSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .padding(.leading, 16)
            
            content
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
        }
    }
}

struct AISettingsDetailView: View {
    @AppStorage("confidenceThreshold") private var confidenceThreshold = 0.7
    @AppStorage("analysisDepth") private var analysisDepth = 2.0
    
    var body: some View {
        List {
            Section(header: Text("分析设置")) {
                VStack(alignment: .leading) {
                    Text("置信度阈值: \(Int(confidenceThreshold * 100))%")
                    
                    Slider(value: $confidenceThreshold, in: 0.5...0.95, step: 0.05)
                    
                    Text("较高的置信度阈值会使AI更加谨慎地给出建议")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 5)
                
                VStack(alignment: .leading) {
                    Text("分析深度: \(analysisDepthText)")
                    
                    Slider(value: $analysisDepth, in: 1.0...3.0, step: 1.0)
                    
                    Text("更高的分析深度会提供更详细的分析，但可能需要更长的处理时间")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 5)
            }
        }
        .navigationTitle("高级AI设置")
    }
    
    private var analysisDepthText: String {
        switch Int(analysisDepth) {
        case 1:
            return "基础"
        case 2:
            return "标准"
        case 3:
            return "深入"
        default:
            return "标准"
        }
    }
}

struct DataExportView: View {
    @State private var exportFormat = "JSON"
    
    var body: some View {
        List {
            Section(header: Text("导出格式")) {
                Picker("格式", selection: $exportFormat) {
                    Text("JSON").tag("JSON")
                    Text("CSV").tag("CSV")
                    Text("PDF").tag("PDF")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section {
                Button(action: {
                    // 导出数据
                }) {
                    HStack {
                        Spacer()
                        Text("导出数据")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .padding(.vertical, 5)
            }
        }
        .navigationTitle("导出数据")
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "scale.3d")
                .font(.system(size: 60))
                .foregroundColor(Color("AppPrimary"))
            
            Text("大决定")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("版本 1.0.0")
                .foregroundColor(.secondary)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 15) {
                AboutRow(icon: "person.fill", title: "开发者", detail: "大决定团队")
                AboutRow(icon: "envelope.fill", title: "联系我们", detail: "support@bigdecision.app")
                AboutRow(icon: "globe", title: "网站", detail: "www.bigdecision.app")
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
            
            Text("© 2023 大决定. 保留所有权利。")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .navigationTitle("关于")
    }
}

struct AboutRow: View {
    let icon: String
    let title: String
    let detail: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30)
                .foregroundColor(Color("AppPrimary"))
            
            Text(title)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(detail)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    SettingsView()
}