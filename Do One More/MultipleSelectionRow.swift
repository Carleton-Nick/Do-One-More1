//
//  MultipleSelectionRow.swift
//  Do One More
//
//  Created by Nick Carleton on 6/26/24.
//

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
                    .foregroundColor(isSelected ? .white : theme.primaryColor) // Change text color based on selection
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(isSelected ? theme.primaryColor : theme.backgroundColor) // Change background color based on selection
            .cornerRadius(8)
        }
    }
}
