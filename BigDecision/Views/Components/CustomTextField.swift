import SwiftUI

public struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    
    public init(title: String, text: Binding<String>, icon: String) {
        self.title = title
        self._text = text
        self.icon = icon
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color("AppPrimary"))
                .frame(width: 20)
            
            TextField(title, text: $text)
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        #if canImport(UIKit)
        .background(Color(UIColor.systemBackground))
        #else
        .background(Color.white)
        #endif
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
    }
}

#Preview {
    CustomTextField(title: "输入文本", text: .constant(""), icon: "text.alignleft")
        .padding()
        #if canImport(UIKit)
        .background(Color(UIColor.systemGroupedBackground))
        #else
        .background(Color.gray.opacity(0.1))
        #endif
} 