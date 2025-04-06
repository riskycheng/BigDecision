import SwiftUI

struct AboutDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 增加顶部间距，确保图标不被顶部标题栏遮挡
                Spacer()
                    .frame(height: 60)
                
                // App Logo
                VStack(spacing: 16) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 60))
                        .foregroundColor(Color("AppPrimary"))
                        .padding()
                        .background(
                            Circle()
                                .fill(Color("AppPrimary").opacity(0.1))
                                .frame(width: 120, height: 120)
                        )
                    
                    Text("大决定")
                        .font(.system(size: 28, weight: .bold))
                    
                    Text("版本 1.0.0")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                // App Description
                VStack(alignment: .leading, spacing: 16) {
                    Text("关于大决定")
                        .font(.system(size: 20, weight: .semibold))
                        .padding(.bottom, 4)
                    
                    Text("大决定是一款基于人工智能的决策辅助应用，旨在帮助用户在面临选择时做出更明智的决定。")
                        .lineSpacing(4)
                    
                    Text("应用特点：")
                        .font(.system(size: 17, weight: .medium))
                        .padding(.top, 8)
                    
                    AppFeatureRow(icon: "brain", text: "AI驱动的决策分析")
                    AppFeatureRow(icon: "scale.3d", text: "全面权衡多种因素")
                    AppFeatureRow(icon: "chart.bar", text: "科学量化决策依据")
                    AppFeatureRow(icon: "clock", text: "记录并追踪历史决策")
                    AppFeatureRow(icon: "person.2", text: "个性化决策建议")
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
                
                // Team Info
                VStack(alignment: .leading, spacing: 16) {
                    Text("开发团队")
                        .font(.system(size: 20, weight: .semibold))
                        .padding(.bottom, 4)
                    
                    Text("大决定由一支热爱创新的团队开发，团队成员拥有丰富的人工智能和用户体验设计经验。我们致力于将先进的AI技术应用到日常生活中，帮助用户做出更好的决策。")
                        .lineSpacing(4)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
                
                // Contact Info
                VStack(alignment: .leading, spacing: 16) {
                    Text("联系我们")
                        .font(.system(size: 20, weight: .semibold))
                        .padding(.bottom, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    AppContactRow(icon: "envelope", text: "email@example.com")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    AppContactRow(icon: "globe", text: "www.example.com")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    AppContactRow(icon: "location", text: "北京市海淀区")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .padding(.bottom, 30)
        }
        .overlay(alignment: .top) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(Color("AppPrimary"))
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                .padding(.leading, 16)
                
                Spacer()
                
                Text("关于")
                    .font(.headline)
                
                Spacer()
                
                // 为了平衡布局添加一个空的视图
                Color.clear
                    .frame(width: 44, height: 44)
                    .padding(.trailing, 16)
            }
            .padding(.top, 16)
            .background(
                Rectangle()
                    .fill(Color.white.opacity(0.9))
                    .edgesIgnoringSafeArea(.top)
                    .frame(height: 60)
                    .blur(radius: 0.5)
            )
        }
    }
}

struct AppFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color("AppPrimary"))
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 16))
        }
        .padding(.vertical, 4)
    }
}

struct AppContactRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color("AppPrimary"))
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 16))
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AboutDetailView()
}
