import SwiftUI

struct MultipleSelectionRow: View {
    let title: String
    let isSelected: Bool
    let isFlashing: Bool
    let action: () -> Void
    @Environment(\.theme) var theme

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.white)
                    .padding(.leading, 10)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isSelected ? Color.orange.opacity(0.7) : theme.backgroundColor
            )
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
