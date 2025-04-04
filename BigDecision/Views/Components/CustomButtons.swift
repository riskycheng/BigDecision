import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "4A4A4A"), Color(hex: "2A2A2A")]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(27)
                .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)
        }
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                #if canImport(UIKit)
                .background(Color(UIColor.systemBackground))
                #else
                .background(Color.white)
                #endif
                .cornerRadius(27)
                .overlay(
                    RoundedRectangle(cornerRadius: 27)
                        #if canImport(UIKit)
                        .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                        #else
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        #endif
                )
        }
    }
} 