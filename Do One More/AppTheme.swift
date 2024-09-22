//
//  AppTheme.swift
//  Do One More
//
//  Created by Nick Carleton on 8/16/24.
//

import SwiftUI

struct AppTheme: EnvironmentKey {
    static let defaultValue = AppTheme()

    // Define your global styling properties here
    let primaryColor: Color = Color.orange
    let secondaryColor: Color = Color(.darkGray)
    let buttonBackgroundColor: Color = Color(.orange)
    let buttonTextColor: Color = Color.white
    let backgroundColor: Color = Color.black // Added background color

    // Fonts
    let primaryFont: Font = .custom("Avenir Next", size: 20)
    let secondaryFont: Font = .custom("Avenir", size: 18)

    // Button Styles
    let buttonCornerRadius: CGFloat = 8
    let buttonPadding: CGFloat = 7 // affects the padding around main buttons, but not items that have the roundedRectangle design. 
}

extension EnvironmentValues {
    var theme: AppTheme {
        get { self[AppTheme.self] }
        set { self[AppTheme.self] = newValue }
    }
}
