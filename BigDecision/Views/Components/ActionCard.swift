import SwiftUI

struct ActionCard: View {
    var icon: String
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color("AppPrimary"))
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, minHeight: 60)
            .padding(.vertical, 6)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}

struct ActionCard_Previews: PreviewProvider {
    static var previews: some View {
        ActionCard(icon: "shuffle", title: "随机决定", action: {})
            .previewLayout(.sizeThatFits)
            .padding()
    }
} 