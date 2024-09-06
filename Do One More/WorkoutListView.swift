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

                    // Display the date and time of the workout
                    Text("Saved on \(formatTimestamp(workout.timestamp))")
                        .font(theme.secondaryFont)
                        .foregroundColor(.white)

                    // Display each set in the workout
                    ForEach(workout.sets, id: \.self) { set in
                        // First line: Weight and Reps
                        if let weight = set.weight, let reps = set.reps {
                            Text("Weight: \(weight), Reps: \(reps)")
                                .font(theme.secondaryFont)
                                .foregroundColor(.white) // Set text color to white
                        }

                        // Second line: Time and Distance
                        HStack {
                            if let elapsedTime = set.elapsedTime, !elapsedTime.isEmpty {
                                Text("Time: \(elapsedTime)")
                                    .font(theme.secondaryFont)
                                    .foregroundColor(.white) // Set text color to white
                            }

                            if let distance = set.distance, !distance.isEmpty {
                                Spacer() // Add spacing between Time and Distance
                                Text("Distance: \(distance) miles")
                                    .font(theme.secondaryFont)
                                    .foregroundColor(.white) // Set text color to white
                            }
                        }

                        // Third line: Calories
                        if let calories = set.calories, !calories.isEmpty {
                            Text("Calories: \(calories)")
                                .font(theme.secondaryFont)
                                .foregroundColor(.white) // Set text color to white
                        }

                        // Fourth line: Custom Notes
                        if let custom = set.custom, !custom.isEmpty {
                            Text("Notes: \(custom)")
                                .font(theme.secondaryFont)
                                .foregroundColor(.white) // Set text color to white
                        }
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

    // Helper function to format the timestamp
    func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutListView()
            .environment(\.theme, AppTheme()) // Preview with the theme applied
    }
}
