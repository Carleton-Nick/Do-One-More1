//
//  CustomButtonStyle.swift
//  Do One More
//
//  Created by Nick Carleton on 8/16/24.
//

import SwiftUI

struct CustomButtonStyle: ViewModifier {
    @Environment(\.theme) var theme

    func body(content: Content) -> some View {
        content
            .padding(theme.buttonPadding)
            .background(theme.buttonBackgroundColor)
            .foregroundColor(theme.buttonTextColor)
            .cornerRadius(theme.buttonCornerRadius)
            .font(theme.primaryFont)
    }
}

extension View {
    func customButtonStyle() -> some View {
        self.modifier(CustomButtonStyle())
    }
}
