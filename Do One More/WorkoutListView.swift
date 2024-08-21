//
//  WorkoutListView.swift
//  Do One More
//
//  Created by Nick Carleton on 6/26/24.
//

import SwiftUI

struct WorkoutListView: View {
    @State private var workouts: [Workout] = []
    @Environment(\.theme) var theme // Inject the global theme

    var body: some View {
        ZStack {
            theme.backgroundColor.edgesIgnoringSafeArea(.all) // Set the entire view's background

            List(workouts, id: \.exerciseType) { workout in
                VStack(alignment: .leading, spacing: 10) {
                    // Display the exercise type with an underline
                    Text(workout.exerciseType)
                        .font(theme.primaryFont)
                        .foregroundColor(.orange)
                        .padding(.vertical, 5)
                        .overlay(
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(theme.primaryColor) // Underline in orange
                                .offset(y: 1), // Position the underline below the text
                            alignment: .bottom
                        )

                    // Display each set in the workout
                    ForEach(workout.sets, id: \.self) { set in
                        let displayWeight = set.weight?.isEmpty ?? true ? "bodyweight" : set.weight!
                        Text("Weight: \(displayWeight), Reps: \(set.reps ?? 0)")
                            .font(theme.secondaryFont)
                            .foregroundColor(.white)
                    }
                }
                .padding(8)
                .background(theme.backgroundColor) // Match the background to the app’s theme
                .cornerRadius(8)
                .listRowBackground(theme.backgroundColor) // Set the row background color to match the theme
            }
            .scrollContentBackground(.hidden) // Hide the default list background
            .listStyle(PlainListStyle()) // Simplify the list style to avoid additional padding
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) { // Replace the navigation title with our custom view
                UnderlinedTitle(title: "Saved Workouts") // Customize the title text here
            }
        }
        .onAppear(perform: loadWorkouts)
    }

    func loadWorkouts() {
        if let savedWorkouts = UserDefaults.standard.data(forKey: "workouts"),
           let decodedWorkouts = try? JSONDecoder().decode([Workout].self, from: savedWorkouts) {
            workouts = decodedWorkouts
        }
    }
}

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutListView()
            .environment(\.theme, AppTheme()) // Preview with the theme applied
    }
}
