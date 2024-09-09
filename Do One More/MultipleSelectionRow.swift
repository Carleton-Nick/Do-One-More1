import SwiftUI

struct MultipleSelectionRow: View {
    let title: String
    var isSelected: Bool
    var action: () -> Void
    @Environment(\.theme) var theme // Inject the global theme

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(theme.secondaryFont)
                    .foregroundColor(isSelected ? .white : theme.primaryColor) // White text when selected, primary color when not selected
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white) // White checkmark when selected
                }
            }
            .padding()
            .background(isSelected ? theme.primaryColor : theme.backgroundColor) // Solid orange background when selected
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.clear : theme.primaryColor, lineWidth: 2) // Orange border when not selected
            )
            .cornerRadius(8)
        }
    }
}
