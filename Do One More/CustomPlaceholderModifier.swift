import SwiftUI

struct CustomPlaceholderModifier: ViewModifier {
    var showPlaceholder: Bool
    var placeholder: String
    var placeholderColor: Color = Color.white

    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceholder {
                Text(placeholder)
                    .foregroundColor(placeholderColor)
                    .padding(.leading, 8) // Ensure text aligns properly
            }
            content
        }
    }
}

extension View {
    func customPlaceholder(show: Bool, placeholder: String, placeholderColor: Color = .white) -> some View {
        self.modifier(CustomPlaceholderModifier(showPlaceholder: show, placeholder: placeholder, placeholderColor: placeholderColor))
    }
}
