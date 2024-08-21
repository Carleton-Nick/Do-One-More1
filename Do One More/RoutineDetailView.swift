//
//  RoutineDetailView.swift
//  Do One More
//
//  Created by Nick Carleton on 6/26/24.
//

import SwiftUI

struct RoutineDetailView: View {
    var routine: Routine
    @Binding var routines: [Routine]
    @Environment(\.theme) var theme // Inject the global theme

    var body: some View {
        ZStack {
            theme.backgroundColor.edgesIgnoringSafeArea(.all) // Set the background color

            List {
                ForEach(routine.exercises, id: \.self) { exercise in
                    NavigationLink(
                        destination: ContentView(selectedExerciseType: exercise, fromRoutine: true)
                    ) {
                        Text(exercise)
                            .font(theme.secondaryFont) // Apply theme font
                            .foregroundColor(theme.primaryColor) // Apply theme text color
                            .frame(maxWidth: .infinity, alignment: .center) // Center the text and span the full width
                            .padding(8)
                            .background(theme.backgroundColor) // Match the background with the theme
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(theme.primaryColor, lineWidth: 1) // Add the thin orange border
                            )
                    }
                    .listRowBackground(theme.backgroundColor) // Remove the default white background
                }
            }
            .scrollContentBackground(.hidden) // Hide the default list background
            .listStyle(PlainListStyle()) // Simplify the list style to avoid additional padding
        }
        .navigationTitle(routine.name)
        .navigationBarTitleDisplayMode(.inline)
        .font(theme.primaryFont) // Apply theme font to the title
        .foregroundColor(theme.primaryColor) // Apply theme color to the title
        .navigationBarItems(trailing: NavigationLink(destination: EditRoutineView(routine: routine, routines: $routines)) { // Use a binding for 'routine'
            Text("Edit")
                .font(theme.secondaryFont) // Apply theme font
                .foregroundColor(theme.buttonTextColor) // Set the text color to the theme’s button text color
                .padding(theme.buttonPadding)
                .background(theme.buttonBackgroundColor)
                .cornerRadius(theme.buttonCornerRadius)
        })
    }
}

struct RoutineDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RoutineDetailView(routine: Routine(name: "Sample Routine", exercises: ["Bench Press", "Squat"]), routines: .constant([]))
            .environment(\.theme, AppTheme()) // Preview with the theme applied
    }
}
