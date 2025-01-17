import SwiftUI

struct CustomFormFieldStyle: ViewModifier {
    @Environment(\.theme) var theme

    func body(content: Content) -> some View {
        content
            .padding(.vertical, 8) // Adjust vertical padding to fit your design
            .padding(.horizontal, 12) // Adjust horizontal padding to fit your design
            .background(theme.backgroundColor) // Match the background with your app's theme
            .cornerRadius(5) // Optional: Rounds the corners slightly
            .foregroundColor(.white) // Set the text input color to white
            RoundedRectangle(cornerRadius: 5)
            .stroke(Color.orange, lineWidth: 2) // Optional: Add a thin border if needed
    }
}

extension View {
    func customFormFieldStyle() -> some View {
        self.modifier(CustomFormFieldStyle())
    }
}
