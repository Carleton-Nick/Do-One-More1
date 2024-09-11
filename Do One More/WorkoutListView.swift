import SwiftUI
import UIKit  // For UIActivityViewController

struct WorkoutListView: View {
    @State private var workouts: [Workout] = []
    @Environment(\.theme) var theme // Inject the global theme

    var body: some View {
        ZStack(alignment: .bottom) {  // Align contents to the bottom
            theme.backgroundColor.edgesIgnoringSafeArea(.all) // Set the entire view's background

            List(workouts, id: \.exerciseType) { workout in
                VStack(alignment: .leading, spacing: 10) {
                    // Display the exercise type with a light orange border
                    Text(workout.exerciseType)
                        .font(theme.primaryFont)
                        .foregroundColor(.orange)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.orange, lineWidth: 2) // Light orange border
                        )
                    // Display the date and time of the workout (on the same line as the exercise name)
                    Text("Date: \(formatTimestamp(workout.timestamp))")
                        .font(theme.secondaryFont)
                        .foregroundColor(.white)

                    // Display each set in the workout
                    ForEach(Array(workout.sets.enumerated()), id: \.offset) { index, set in
                        VStack(alignment: .leading, spacing: 5) {
                            // Set number with light orange underline
                            Text("Set \(index + 1)")
                                .font(theme.primaryFont)
                                .foregroundColor(.white)
                                .padding(.bottom, 2)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(.orange) // Light orange underline
                                        .offset(y: 2),
                                    alignment: .bottom
                                )

                            // Weight and Reps
                            if let weight = set.weight {
                                Text("Weight: \(weight) lbs")
                                    .font(theme.secondaryFont)
                                    .foregroundColor(.white)
                            }

                            if let reps = set.reps {
                                Text("Reps: \(reps)")
                                    .font(theme.secondaryFont)
                                    .foregroundColor(.white)
                            }

                            // Time and Distance
                            if let elapsedTime = set.elapsedTime, !elapsedTime.isEmpty {
                                Text("Time: \(elapsedTime)")
                                    .font(theme.secondaryFont)
                                    .foregroundColor(.white)
                            }

                            if let distance = set.distance {
                                Text("Distance: \(distance) miles")
                                    .font(theme.secondaryFont)
                                    .foregroundColor(.white)
                            }

                            // Calories
                            if let calories = set.calories, !calories.isEmpty {
                                Text("Calories: \(calories)")
                                    .font(theme.secondaryFont)
                                    .foregroundColor(.white)
                            }

                            // Custom Notes
                            if let custom = set.custom, !custom.isEmpty {
                                Text("Notes: \(custom)")
                                    .font(theme.secondaryFont)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.vertical, 5) // Space between each set
                        .background(Color.black.opacity(0.2)) // Light background for each set
                        .cornerRadius(8)
                    }
                }
                .padding(8)
                .background(theme.backgroundColor) // Match the background to the app’s theme
                .cornerRadius(8)
                .listRowBackground(theme.backgroundColor) // Set the row background color to match the theme
            }
            .scrollContentBackground(.hidden) // Hide the default list background
            .listStyle(PlainListStyle()) // Simplify the list style to avoid additional padding

            // CSV Export Button at the bottom-center
            Button(action: {
                shareCSV(workouts: workouts) // Trigger CSV share
            }) {
                Text("Export CSV")
                    .font(theme.secondaryFont)
                    .foregroundColor(theme.buttonTextColor)
                    .padding(theme.buttonPadding)
                    .background(theme.buttonBackgroundColor)
                    .cornerRadius(theme.buttonCornerRadius)
            }
            .padding(.bottom, 20)  // Padding from the bottom
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

    // Helper function to format the timestamp as "yyyy-MM-dd"
    func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"  // Custom date format
        return formatter.string(from: date)
    }

    // Generate CSV String from Workouts
    func generateCSV(from workouts: [Workout]) -> String {
        var csvString = "Exercise Type,Date,Set,Weight,Reps,Time,Distance,Calories,Notes\n"
        
        for workout in workouts {
            for (index, set) in workout.sets.enumerated() {
                // Break down the components of the row into individual variables
                let exerciseType = workout.exerciseType
                let formattedDate = formatTimestamp(workout.timestamp)
                let setIndex = "Set \(index + 1)"
                let weight = set.weight ?? ""
                let reps = set.reps ?? ""
                let elapsedTime = set.elapsedTime ?? ""
                let distance = set.distance ?? ""
                let calories = set.calories ?? ""
                let custom = set.custom ?? ""
                
                // Combine the components into a single CSV row
                let row = [
                    exerciseType,
                    formattedDate,
                    setIndex,
                    weight,
                    reps,
                    elapsedTime,
                    distance,
                    calories,
                    custom
                ].joined(separator: ",")
                
                csvString.append("\(row)\n")
            }
        }
        
        return csvString
    }

    // Share CSV file
    func shareCSV(workouts: [Workout]) {
        let csvString = generateCSV(from: workouts)
        let fileName = "Workouts.csv"
        
        // Create a temporary file with the CSV content
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            // Write the CSV data to the file
            try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
            
            // Present the UIActivityViewController to share the file
            let activityViewController = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            // Get the active window's root view controller for presenting the share sheet
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first,
               let rootViewController = window.rootViewController {
                rootViewController.present(activityViewController, animated: true, completion: nil)
            }
        } catch {
            print("Failed to write CSV file: \(error)")
        }
    }
}

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutListView()
            .environment(\.theme, AppTheme()) // Preview with the theme applied
    }
}
