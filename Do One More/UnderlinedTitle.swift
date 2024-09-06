import SwiftUI

struct UnderlinedTitle: View {
    let title: String
    @Environment(\.theme) var theme // Assuming you have a custom theme

    var body: some View {
        VStack(spacing: 5) {
            Text(title.uppercased())
                .font(theme.primaryFont)
                .foregroundColor(.white) // Customize text color as per your theme
            Rectangle()
                .fill(theme.primaryColor) // Use theme color for the underline
                .frame(height: 2)
        }
    }
}

struct UnderlinedTitle_Previews: PreviewProvider {
    static var previews: some View {
        UnderlinedTitle(title: "Sample Title")
            .environment(\.theme, AppTheme()) // Provide a sample theme for preview
    }
}
