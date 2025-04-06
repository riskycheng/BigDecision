import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                    Group {
                        Text("使用条款")
                            .font(.system(size: 24, weight: .bold))
                            .padding(.bottom, 8)
                        
                        Text("最后更新日期：2025年4月1日")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .padding(.bottom, 16)
                        
                        Text("欢迎使用")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("欢迎使用\"大决定\"应用（以下简称\"本应用\"）。本使用条款构成您与本应用之间的法律协议，规定了您使用本应用的条件。请您在使用本应用前仔细阅读本使用条款。")
                            .padding(.bottom, 8)
                        
                        Text("接受条款")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("通过下载、安装或使用本应用，您确认您已阅读、理解并同意受本使用条款的约束。如果您不同意本使用条款的任何部分，请不要使用本应用。")
                            .padding(.bottom, 8)
                        
                        Text("使用许可")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("本应用授予您一个有限的、非排他性的、不可转让的许可，允许您在您拥有或控制的设备上使用本应用。本许可不允许您将本应用用于任何商业目的，也不允许您复制、修改、分发、销售、租赁、转让、公开展示、公开表演、传输、广播或以其他方式利用本应用。")
                            .padding(.bottom, 8)
                    }
                    
                    Group {
                        Text("用户内容")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("您在使用本应用过程中创建的所有内容（包括但不限于决策数据、选项、评论等）均属于您的个人内容。您保留对这些内容的所有权利，但您授予本应用一个全球性的、免版税的许可，允许本应用存储、使用、复制、修改、创建衍生作品、分发和展示这些内容，以便为您提供服务。")
                            .padding(.bottom, 8)
                        
                        Text("禁止行为")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("在使用本应用时，您同意不会：\n\n1. 违反任何适用的法律法规\n2. 侵犯他人的知识产权或其他权利\n3. 传播恶意软件或有害代码\n4. 干扰或破坏本应用的正常运行\n5. 尝试未经授权访问本应用的系统或网络")
                            .padding(.bottom, 8)
                        
                        Text("免责声明")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("本应用按\"现状\"和\"可用\"的基础提供，不提供任何明示或暗示的保证。本应用不保证服务不会中断或无错误，也不保证缺陷会被纠正。您使用本应用的风险完全由您自己承担。")
                            .padding(.bottom, 8)
                        
                        Text("责任限制")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("在法律允许的最大范围内，本应用及其开发者、员工或代理人在任何情况下均不对因使用或无法使用本应用而导致的任何直接、间接、附带、特殊、惩罚性或后果性损害承担责任。")
                            .padding(.bottom, 8)
                        
                        Text("条款修改")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("我们保留随时修改本使用条款的权利。修改后的条款将在本应用内发布，并在发布时生效。您继续使用本应用将被视为接受修改后的条款。")
                            .padding(.bottom, 8)
                        
                        Text("联系我们")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("如果您对本使用条款有任何疑问或建议，请通过以下方式联系我们：\n\nemail@example.com")
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
                
                Text("使用条款")
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
    TermsOfServiceView()
}
