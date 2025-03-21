import SwiftUI

struct GuideView: View {
    @Environment(\.presentationMode) var presentationMode
    
    struct GuideItem {
        let title: String
        let description: String
        let imageName: String
    }
    
    let guideItems: [GuideItem] = [
        GuideItem(
            title: "创建决定", 
            description: "点击主页上的\"创建新决定\"按钮，输入你需要做的决定。",
            imageName: "plus.circle.fill"
        ),
        GuideItem(
            title: "添加选项", 
            description: "添加至少两个选项，并提供详细描述，帮助系统更好地分析。", 
            imageName: "text.badge.plus"
        ),
        GuideItem(
            title: "补充信息", 
            description: "添加更多背景信息，这将帮助系统更好地理解你的情况。", 
            imageName: "doc.text.fill"
        ),
        GuideItem(
            title: "查看结果", 
            description: "系统会分析你的决定并给出推荐，包括每个选项的优缺点。", 
            imageName: "chart.bar.fill"
        ),
        GuideItem(
            title: "收藏和分享", 
            description: "你可以收藏重要的决定，也可以分享结果给朋友。", 
            imageName: "star.fill"
        )
    ]
    
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            // 背景色
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部标题栏
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("关闭")
                            .foregroundColor(Color("AppPrimary"))
                    }
                    
                    Spacer()
                    
                    Text("新手指引")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    // 平衡布局的空按钮
                    Color.clear
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(UIColor.systemBackground))
                
                // 内容区域
                TabView(selection: $currentPage) {
                    ForEach(0..<guideItems.count, id: \.self) { index in
                        guideItemView(item: guideItems[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                // 底部按钮
                Button(action: {
                    if currentPage < guideItems.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text(currentPage < guideItems.count - 1 ? "下一步" : "完成")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color("AppPrimary"))
                        .cornerRadius(12)
                }
                .padding()
            }
        }
    }
    
    private func guideItemView(item: GuideItem) -> some View {
        VStack(spacing: 30) {
            // 图标
            Image(systemName: item.imageName)
                .font(.system(size: 80))
                .foregroundColor(Color("AppPrimary"))
                .padding()
                .background(
                    Circle()
                        .fill(Color("AppPrimary").opacity(0.1))
                        .frame(width: 180, height: 180)
                )
            
            // 文本内容
            VStack(spacing: 16) {
                Text(item.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(item.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
        .padding(.top, 60)
        .padding(.bottom, 30)
    }
}

#Preview {
    GuideView()
}