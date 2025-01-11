import SwiftUI
import UIKit  // For UIActivityViewController

struct WorkoutListView: View {
    @State private var workouts: [Workout] = []
    @Environment(\.theme) var theme // Inject the global theme
    @State private var showingDeleteAlert = false
    @State private var workoutToDelete: Int?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            theme.backgroundColor.edgesIgnoringSafeArea(.all) // Set the entire view's background

            VStack(spacing: 0) {
                // Saved Workouts Title with underline
                VStack(spacing: 0) {
                    Text("Saved Workouts")
                        .font(theme.primaryFont)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .textCase(.uppercase) // Make text uppercase

                    // Orange underline spanning the width of the screen
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, 8)  // Add slight padding below the top

                // List of workouts
                List(workouts.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 10) {
                        // Display the exercise type with delete button
                        HStack {
                            Text(workouts[index].exerciseType)
                                .font(theme.primaryFont)
                                .foregroundColor(.orange)
                                .padding(.vertical, 5)
                                .padding(.horizontal)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.orange, lineWidth: 2)
                                )
                            
                            Spacer()
                            
                            Button {
                                deleteWorkout(at: index)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .padding(8)
                                    .background(theme.buttonBackgroundColor)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        Text("Date: \(formatTimestamp(workouts[index].timestamp))")
                            .font(theme.secondaryFont)
                            .foregroundColor(.white)
                        
                        ForEach(Array(workouts[index].sets.enumerated()), id: \.offset) { setIndex, set in
                            VStack(alignment: .leading, spacing: 5) {
                                // Set number with light orange underline
                                Text("Set \(setIndex + 1)")
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
                        // Edit button (now without the delete button)
                        NavigationLink(destination: EditWorkoutView(workout: $workouts[index]) { updatedWorkout in
                            workouts[index] = updatedWorkout
                            saveWorkouts()
                        }) {
                            Text("Edit")
                                .font(theme.secondaryFont)
                                .foregroundColor(theme.buttonTextColor)
                                .padding(8)
                                .background(theme.buttonBackgroundColor)
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(8)
                    .background(theme.backgroundColor)
                    .cornerRadius(8)
                    .listRowBackground(theme.backgroundColor)
                }
                .scrollContentBackground(.hidden) // Hide the default list background
                .listStyle(PlainListStyle()) // Simplify the list style to avoid additional padding
            }
            // Export CSV Button at the bottom-right corner
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
            .padding([.bottom, .trailing], 20) // Padding from the bottom-right corner
        }
        .onAppear(perform: loadWorkouts)
        .alert("Delete Workout?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let index = workoutToDelete {
                    workouts.remove(at: index)
                    saveWorkouts()
                }
            }
        } message: {
            Text("Are you sure you want to delete this workout? This action cannot be undone.")
        }
    }

    func loadWorkouts() {
        workouts = UserDefaultsManager.loadWorkouts().reversed()
    }
    
    func saveWorkouts() {
        // Save the workouts in their current (reversed) order
        UserDefaultsManager.saveWorkouts(workouts.reversed())
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
                let exerciseType = workout.exerciseType
                let formattedDate = formatTimestamp(workout.timestamp)
                let setIndex = "Set \(index + 1)"
                let weight = set.weight ?? ""
                let reps = set.reps ?? ""
                let elapsedTime = set.elapsedTime ?? ""
                let distance = set.distance ?? ""
                let calories = set.calories ?? ""
                let custom = set.custom ?? ""

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
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
            
            let activityViewController = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first,
               let rootViewController = window.rootViewController {
                rootViewController.present(activityViewController, animated: true, completion: nil)
            }
        } catch {
            print("Failed to write CSV file: \(error)")
        }
    }

    private func deleteWorkout(at index: Int) {
        workoutToDelete = index
        showingDeleteAlert = true
    }
}

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WorkoutListView()
                .environment(\.theme, AppTheme())
                .onAppear {
                    // Add sample workout data for preview
                    let sampleWorkouts = [
                        Workout(
                            exerciseType: "Bench Press",
                            sets: [
                                SetRecord(weight: "135", reps: "10"),
                                SetRecord(weight: "155", reps: "8")
                            ],
                            timestamp: Date()
                        ),
                        Workout(
                            exerciseType: "Squats",
                            sets: [
                                SetRecord(weight: "225", reps: "5"),
                                SetRecord(weight: "245", reps: "3")
                            ],
                            timestamp: Date().addingTimeInterval(-86400) // Yesterday
                        )
                    ]
                    UserDefaultsManager.saveWorkouts(sampleWorkouts)
                }
        }
    }
}
