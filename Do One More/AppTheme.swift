import SwiftUI

// MARK: - AppTheme
struct AppTheme: EnvironmentKey {
    static let defaultValue = AppTheme()

    // Define your global styling properties here
    let primaryColor: Color = Color.orange
    let secondaryColor: Color = Color(.darkGray)
    let buttonBackgroundColor: Color = Color.orange
    let buttonTextColor: Color = Color.white
    let backgroundColor: Color = Color.black

    // Fonts
    let primaryFont: Font = .custom("Avenir Next", size: 20)
    let secondaryFont: Font = .custom("Avenir", size: 18)

    // Button Styles
    let buttonCornerRadius: CGFloat = 8
    let buttonPadding: CGFloat = 7 // Padding around main buttons
}

// Extend EnvironmentValues to include AppTheme
extension EnvironmentValues {
    var theme: AppTheme {
        get { self[AppTheme.self] }
        set { self[AppTheme.self] = newValue }
    }
}

// MARK: - UnderlinedTitle
struct UnderlinedTitle: View {
    let title: String

    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: 5) {
            Text(title.uppercased())
                .font(theme.primaryFont)
                .foregroundColor(theme.buttonTextColor)
            Rectangle()
                .fill(theme.primaryColor)
                .frame(height: 2)
        }
    }
}

// Preview
struct UnderlinedTitle_Previews: PreviewProvider {
    static var previews: some View {
        UnderlinedTitle(title: "Sample Title")
            .environment(\.theme, AppTheme()) // Inject sample theme for preview
    }
}
