import SwiftUI

struct EmptyStateView: View {
    var icon: String
    var message: String
    var buttonText: String
    var action: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(Color("AppPrimary").opacity(0.7))
            
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: action) {
                Text(buttonText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color("AppPrimary"))
                    .cornerRadius(10)
            }
            .padding(.top, 5)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView(
            icon: "list.bullet.clipboard",
            message: "你还没有做过任何决定",
            buttonText: "创建第一个决定",
            action: {}
        )
        .previewLayout(.sizeThatFits)
        .frame(height: 250)
        .padding()
    }
} 