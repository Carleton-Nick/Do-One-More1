//
//  Do_One_MoreApp.swift
//  Do One More
//
//  Created by Nick Carleton on 6/26/24.
//

import SwiftUI

@main
struct Do_One_MoreApp: App {
    init() {
        // Customize the navigation bar appearance globally
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black

        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "Avenir Next", size: 20)!
        ]

        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.orange,
            .font: UIFont(name: "Avenir", size: 18)!
        ]

        appearance.buttonAppearance = buttonAppearance

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance

        // Set the global tint color (affects system elements like move handles)
        UIView.appearance().tintColor = .white
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.theme, AppTheme()) // Inject the theme globally
        }
    }
}
