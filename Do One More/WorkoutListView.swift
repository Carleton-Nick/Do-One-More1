import SwiftUI
import UIKit  // For UIActivityViewController

struct WorkoutListView: View {
    @State private var workouts: [Workout] = []
    @Environment(\.theme) var theme
    @State private var showingDeleteAlert = false
    @State private var workoutToDelete: Int?
    @State private var editMode: Bool = false

    var body: some View {
        ZStack {
            theme.backgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Saved Workouts")
                        .font(theme.primaryFont)
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                    
                    Spacer()
                    
                    Button(action: { editMode.toggle() }) {
                        Text(editMode ? "Done" : "Edit")
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.orange)
                
                // Workouts List
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(workouts.indices, id: \.self) { index in
                            WorkoutCard(
                                workout: $workouts[index],
                                editMode: editMode,
                                onDelete: {
                                    workoutToDelete = index
                                    showingDeleteAlert = true
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            
            // Export CSV Button
            VStack {
                Spacer()
                Button(action: { shareCSV(workouts: workouts) }) {
                    Text("Export CSV")
                        .font(theme.secondaryFont)
                        .foregroundColor(theme.buttonTextColor)
                        .padding(theme.buttonPadding)
                        .background(theme.buttonBackgroundColor)
                        .cornerRadius(theme.buttonCornerRadius)
                }
                .padding()
            }
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
}

private struct WorkoutCard: View {
    @Binding var workout: Workout
    let editMode: Bool
    let onDelete: () -> Void
    @Environment(\.theme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(workout.exerciseType)
                    .font(theme.primaryFont)
                    .foregroundColor(.orange)
                    .padding(.vertical, 4)
                    .padding(.horizontal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.orange, lineWidth: 2)
                    )
                
                Spacer()
                
                if editMode {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .padding(4)
                            .background(theme.buttonBackgroundColor)
                            .cornerRadius(8)
                    }
                }
            }
            
            Text("Date: \(formatTimestamp(workout.timestamp))")
                .font(theme.secondaryFont)
                .foregroundColor(.white)
            
            ForEach(workout.sets.indices, id: \.self) { setIndex in
                SetRow(
                    set: $workout.sets[setIndex],
                    index: setIndex,
                    editMode: editMode,
                    onDelete: {
                        workout.sets.remove(at: setIndex)
                    }
                )
            }
            
            if editMode {
                Button(action: {
                    let newSet: SetRecord
                    if let lastSet = workout.sets.last {
                        // Copy the structure of the last set but with empty values
                        newSet = SetRecord(
                            weight: lastSet.weight != nil ? "" : nil,
                            reps: lastSet.reps != nil ? "" : nil,
                            elapsedTime: lastSet.elapsedTime != nil ? "" : nil,
                            distance: lastSet.distance != nil ? "" : nil,
                            calories: lastSet.calories != nil ? "" : nil,
                            custom: lastSet.custom != nil ? "" : nil
                        )
                    } else {
                        // If no existing sets, create a basic set with weight and reps
                        newSet = SetRecord(weight: "", reps: "")
                    }
                    workout.sets.append(newSet)
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Set")
                    }
                    .font(theme.secondaryFont)
                    .foregroundColor(theme.buttonTextColor)
                    .frame(maxWidth: .infinity)
                    .padding(theme.buttonPadding)
                    .background(theme.buttonBackgroundColor)
                    .cornerRadius(theme.buttonCornerRadius)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(12)
    }
}

private struct SetRow: View {
    @Binding var set: SetRecord
    let index: Int
    let editMode: Bool
    let onDelete: () -> Void
    @Environment(\.theme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("Set \(index + 1)")
                    .font(theme.secondaryFont)
                    .foregroundColor(.white)
                
                Spacer()
                
                if editMode {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .padding(4)
                            .background(theme.buttonBackgroundColor)
                            .cornerRadius(8)
                    }
                }
            }
            
            if let weight = set.weight {
                MetricRow(
                    title: "Weight",
                    value: Binding(
                        get: { weight },
                        set: { set.weight = $0 }
                    ),
                    editMode: editMode,
                    keyboardType: .numberPad
                )
            }
            
            if let reps = set.reps {
                MetricRow(
                    title: "Reps",
                    value: Binding(
                        get: { reps },
                        set: { set.reps = $0 }
                    ),
                    editMode: editMode,
                    keyboardType: .numberPad
                )
            }
            
            if let elapsedTime = set.elapsedTime {
                MetricRow(
                    title: "Time",
                    value: Binding(
                        get: { elapsedTime },
                        set: { set.elapsedTime = $0 }
                    ),
                    editMode: editMode
                )
            }
            
            if let distance = set.distance {
                MetricRow(
                    title: "Distance",
                    value: Binding(
                        get: { distance },
                        set: { set.distance = $0 }
                    ),
                    editMode: editMode,
                    keyboardType: .decimalPad
                )
            }
            
            if let calories = set.calories {
                MetricRow(
                    title: "Calories",
                    value: Binding(
                        get: { calories },
                        set: { set.calories = $0 }
                    ),
                    editMode: editMode,
                    keyboardType: .numberPad
                )
            }
            
            if let custom = set.custom {
                MetricRow(
                    title: "Notes",
                    value: Binding(
                        get: { custom },
                        set: { set.custom = $0 }
                    ),
                    editMode: editMode
                )
            }
        }
        .padding(4)
        .background(Color.black.opacity(0.15))
        .cornerRadius(8)
    }
}

private struct MetricRow: View {
    let title: String
    @Binding var value: String
    let editMode: Bool
    var keyboardType: UIKeyboardType = .default
    @Environment(\.theme) var theme
    
    var body: some View {
        HStack {
            Text(title)
                .font(theme.secondaryFont)
                .foregroundColor(.orange)
                .frame(width: 80, alignment: .leading)
            
            if editMode {
                TextField(title, text: $value)
                    .font(theme.secondaryFont)
                    .foregroundColor(.white)
                    .keyboardType(keyboardType)
            } else {
                Text(value)
                    .font(theme.secondaryFont)
                    .foregroundColor(.white)
            }
        }
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
