import SwiftUI

struct ActionCard: View {
    var icon: String
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(Color("AppPrimary"))
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

struct ActionCard_Previews: PreviewProvider {
    static var previews: some View {
        ActionCard(icon: "shuffle", title: "随机决定", action: {})
            .previewLayout(.sizeThatFits)
            .padding()
            #if canImport(UIKit)
            .background(Color(UIColor.systemGroupedBackground))
            #else
            .background(Color.gray.opacity(0.1))
            #endif
    }
} 