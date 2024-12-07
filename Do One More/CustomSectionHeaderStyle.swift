import SwiftUI

struct CustomSectionHeaderStyle: ViewModifier {
    @Environment(\.theme) var theme

    func body(content: Content) -> some View {
        content
            .font(theme.primaryFont)
            .foregroundColor(theme.primaryColor)
            .padding(.vertical, 5)
            .background(theme.secondaryColor.opacity(0.1))
            .cornerRadius(5)
    }
}

extension View {
    func customSectionHeaderStyle() -> some View {
        self.modifier(CustomSectionHeaderStyle())
    }
}
