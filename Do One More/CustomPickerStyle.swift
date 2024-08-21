//
//  CustomPickerStyle.swift
//  Do One More
//
//  Created by Nick Carleton on 8/20/24.
//

import SwiftUI

struct CustomPickerStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(8)
            .background(Color(.black)) // Background color that contrasts with the text
            .cornerRadius(5)
            .foregroundColor(.orange) // Set the text color explicitly to keep it visible
    }
}

extension View {
    func customPickerStyle() -> some View {
        self.modifier(CustomPickerStyle())
    }
}
