import SwiftUI

struct SettingsView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("aiModelType") private var aiModelType = "标准"
    
    @State private var showingResetAlert = false
    @State private var showingAboutSheet = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("个人设置")) {
                    TextField("你的名字", text: $userName)
                    
                    Toggle("启用通知", isOn: $notificationsEnabled)
                    
                    Toggle("深色模式", isOn: $darkModeEnabled)
                }
                
                Section(header: Text("AI设置")) {
                    Picker("AI模型", selection: $aiModelType) {
                        Text("标准").tag("标准")
                        Text("专业").tag("专业")
                        Text("高级").tag("高级")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    NavigationLink(destination: AISettingsDetailView()) {
                        Text("高级AI设置")
                    }
                }
                
                Section(header: Text("数据管理")) {
                    Button(action: {
                        showingResetAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.red)
                            Text("重置所有决定")
                                .foregroundColor(.red)
                        }
                    }
                    
                    NavigationLink(destination: DataExportView()) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("导出数据")
                        }
                    }
                }
                
                Section(header: Text("关于")) {
                    Button(action: {
                        showingAboutSheet = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                            Text("关于大决定")
                        }
                    }
                    
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        HStack {
                            Image(systemName: "hand.raised")
                            Text("隐私政策")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                        }
                    }
                    
                    Link(destination: URL(string: "https://example.com/terms")!) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("使用条款")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                        }
                    }
                    
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("设置")
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