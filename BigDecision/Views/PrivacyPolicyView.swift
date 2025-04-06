import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                    Group {
                        Text("隐私政策")
                            .font(.system(size: 24, weight: .bold))
                            .padding(.bottom, 8)
                        
                        Text("最后更新日期：2025年4月1日")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .padding(.bottom, 16)
                        
                        Text("引言")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("感谢您使用\"大决定\"应用（以下简称\"本应用\"）。我们非常重视您的隐私和个人信息保护。本隐私政策旨在向您说明我们如何收集、使用、存储和保护您的个人信息，以及您享有的相关权利。请您在使用本应用前仔细阅读本隐私政策。")
                            .padding(.bottom, 8)
                        
                        Text("信息收集")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("本应用收集的信息类型包括：\n\n1. 您创建的决策内容，包括决策标题、选项、补充信息等\n2. 应用使用数据，如使用频率、功能偏好等\n3. 设备信息，如设备型号、操作系统版本等")
                            .padding(.bottom, 8)
                        
                        Text("信息使用")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("我们使用收集的信息用于：\n\n1. 提供、维护和改进本应用的功能和服务\n2. 进行AI分析，帮助您做出更好的决策\n3. 发送通知，如决策提醒等\n4. 开发新功能和服务")
                            .padding(.bottom, 8)
                    }
                    
                    Group {
                        Text("信息存储与安全")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("您的决策数据主要存储在您的设备本地。我们采取合理的技术措施保护您的信息安全，防止未经授权的访问、使用或泄露。")
                            .padding(.bottom, 8)
                        
                        Text("信息共享")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("除非获得您的明确同意，我们不会与任何第三方共享您的个人信息，但以下情况除外：\n\n1. 为提供服务必须与合作伙伴共享的信息\n2. 法律法规要求披露的情况\n3. 保护我们或用户的权利、财产或安全")
                            .padding(.bottom, 8)
                        
                        Text("您的权利")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("您对自己的个人信息享有以下权利：\n\n1. 访问和查看您的个人信息\n2. 更正或更新您的个人信息\n3. 删除您的个人信息\n4. 限制或反对我们处理您的个人信息\n5. 数据可携带性")
                            .padding(.bottom, 8)
                        
                        Text("隐私政策更新")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("我们可能会不时更新本隐私政策。更新后的隐私政策将在本应用内发布，并在发布时生效。建议您定期查看本隐私政策，以了解我们如何保护您的信息。")
                            .padding(.bottom, 8)
                        
                        Text("联系我们")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("如果您对本隐私政策有任何疑问或建议，请通过以下方式联系我们：\n\nemail@example.com")
                            .padding(.bottom, 24)
                    }
                }
                .padding()
            }
            .padding(.top, 60) // 为顶部标题栏留出空间
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
                
                Text("隐私政策")
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

#Preview {
    PrivacyPolicyView()
}
