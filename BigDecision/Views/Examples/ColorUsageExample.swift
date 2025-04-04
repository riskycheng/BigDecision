import SwiftUI

struct ColorUsageExample: View {
    var body: some View {
        VStack(spacing: 20) {
            // Example 1: Direct color usage
            Text("Primary Color")
                .foregroundColor(AppColors.primary)
            
            // Example 2: Color with opacity
            Rectangle()
                .fill(AppColors.secondary.opacity(0.2))
                .frame(width: 100, height: 50)
            
            // Example 3: Gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    AppColors.primary,
                    AppColors.secondary
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: 200, height: 100)
            
            // Example 4: System background with custom color
            HStack {
                Text("Custom Button")
                    .foregroundColor(.white)
                    .padding()
                    .background(AppColors.primary)
                    .cornerRadius(8)
            }
            
            // Example 5: Platform-specific color usage
            #if os(iOS)
            let backgroundColor = AppColors.primaryUIColor
            #else
            let backgroundColor = AppColors.primaryNSColor
            #endif
            
            Color(backgroundColor)
                .frame(width: 100, height: 50)
                .cornerRadius(8)
        }
        .padding()
    }
}

#Preview {
    ColorUsageExample()
}
