import SwiftUI

struct CustomTextEditor: View {
    let placeholder: String
    @Binding var text: String
    let minHeight: CGFloat
    let maxHeight: CGFloat
    
    init(placeholder: String, text: Binding<String>, minHeight: CGFloat = 100, maxHeight: CGFloat = 200) {
        self.placeholder = placeholder
        self._text = text
        self.minHeight = minHeight
        self.maxHeight = maxHeight
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    #if canImport(UIKit)
                    .foregroundColor(Color(UIColor.placeholderText))
                    #else
                    .foregroundColor(Color.gray)
                    #endif
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            
            TextEditor(text: $text)
                .frame(minHeight: minHeight, maxHeight: maxHeight)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        #if canImport(UIKit)
        .background(Color(UIColor.systemBackground))
        #else
        .background(Color.white)
        #endif
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                #if canImport(UIKit)
                .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                #else
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                #endif
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, y: 4)
    }
}

#Preview {
    CustomTextEditor(
        placeholder: "请输入内容...", 
        text: .constant(""),
        minHeight: 100,
        maxHeight: 200
    )
    .padding()
} 