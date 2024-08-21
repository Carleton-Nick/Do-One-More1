//
//  CustomPlaceholderModifier.swift
//  Do One More
//
//  Created by Nick Carleton on 8/20/24.
//

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
                    .padding(.leading, 8)
            }
            content
                .opacity(showPlaceholder ? 0.5 : 1) // Slight opacity change to make placeholder clearer
        }
    }
}

extension View {
    func customPlaceholder(show: Bool, placeholder: String) -> some View {
        self.modifier(CustomPlaceholderModifier(showPlaceholder: show, placeholder: placeholder))
    }
}
