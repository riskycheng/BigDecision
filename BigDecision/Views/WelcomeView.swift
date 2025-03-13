import SwiftUI

struct WelcomeView: View {
    @Binding var showWelcome: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("AppPrimary"), Color("AppSecondary")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "scale.3d")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .scaleEffect(1.0)
                    .padding()
                
                Text("大决定")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Text("告别选择困难症，让AI帮你做出更明智的决定")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(icon: "brain.fill", text: "AI分析两个选项的利弊")
                    FeatureRow(icon: "chart.pie.fill", text: "科学中肯的建议")
                    FeatureRow(icon: "clock.fill", text: "记录并回顾你的决定")
                }
                .padding(.vertical)
                
                Spacer()
                
                Button(action: {
                    UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                    withAnimation {
                        showWelcome = false
                    }
                }) {
                    Text("开始使用")
                        .font(.headline)
                        .foregroundColor(Color("AppPrimary"))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(30)
                        .shadow(radius: 10)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 50)
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40)
            
            Text(text)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    WelcomeView(showWelcome: .constant(true))
} 