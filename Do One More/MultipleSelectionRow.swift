import SwiftUI

struct MultipleSelectionRow: View {
    let title: String
    let isSelected: Bool
    let isFlashing: Bool // New parameter to control flashing effect
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(isSelected ? .white : .orange) // White text when selected, orange when unselected
                    .padding(.leading, 10) // Add leading padding to create space from the left edge

                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white) // White checkmark when selected
                        .padding(.trailing, 10) // Add some trailing padding for the checkmark
                }
            }
            .padding(.vertical, 12) // Consistent vertical padding
            .background(isFlashing ? Color.orange.opacity(0.5) : (isSelected ? Color.orange : Color.black)) // Flashing effect or background color
            .frame(maxWidth: .infinity, alignment: .leading) // Ensure it spans the entire width and aligns left
        }
        .buttonStyle(PlainButtonStyle()) // Remove default button padding and styling
        .listRowInsets(EdgeInsets()) // Remove extra list row insets
    }
}
