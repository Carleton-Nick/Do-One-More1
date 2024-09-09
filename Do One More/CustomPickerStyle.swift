import SwiftUI

struct CustomPickerStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 20))  // You can adjust this font size value here
            .foregroundColor(.white)  // Customize font color
            .padding(12)  // Add padding around the menu
            .background(Color.black)  // Set background color
            .cornerRadius(8)  // Make corners rounded
            .shadow(radius: 5)  // Optional: add shadow for better appearance
    }
}

extension View {
    func customPickerStyle() -> some View {
        self.modifier(CustomPickerStyle())
    }
}
