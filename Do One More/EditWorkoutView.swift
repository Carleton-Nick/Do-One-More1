import SwiftUI

struct EditWorkoutView: View {
    @Binding var workout: Workout
    @Environment(\.dismiss) var dismiss
    @Environment(\.theme) var theme
    
    var onSave: (Workout) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Workout Details")) {
                    TextField("Exercise Type", text: $workout.exerciseType)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section(header: Text("Sets")) {
                    ForEach($workout.sets) { $set in
                        VStack(alignment: .leading) {
                            if let weight = set.weight {
                                TextField("Weight", text: Binding(
                                    get: { weight },
                                    set: { set.weight = $0 }
                                ))
                                .keyboardType(.numberPad)
                            }
                            if let reps = set.reps {
                                TextField("Reps", text: Binding(
                                    get: { reps },
                                    set: { set.reps = $0 }
                                ))
                                .keyboardType(.numberPad)
                            }
                            if let elapsedTime = set.elapsedTime {
                                TextField("Time", text: Binding(
                                    get: { elapsedTime },
                                    set: { set.elapsedTime = $0 }
                                ))
                                .keyboardType(.default)
                            }
                            if let distance = set.distance {
                                TextField("Distance", text: Binding(
                                    get: { distance },
                                    set: { set.distance = $0 }
                                ))
                                .keyboardType(.decimalPad)
                            }
                            if let calories = set.calories {
                                TextField("Calories", text: Binding(
                                    get: { calories },
                                    set: { set.calories = $0 }
                                ))
                                .keyboardType(.numberPad)
                            }
                            if let custom = set.custom {
                                TextField("Notes", text: Binding(
                                    get: { custom },
                                    set: { set.custom = $0 }
                                ))
                            }
                        }
                    }
                    .onDelete(perform: deleteSets)
                    
                    Button(action: addSet) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Set")
                        }
                        .foregroundColor(theme.primaryColor)
                    }
                }
            }
            .navigationTitle("Edit Workout")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(workout)
                        dismiss()
                    }
                    .foregroundColor(theme.buttonTextColor)
                }
            }
        }
    }
    
    // Function to add a new set
    private func addSet() {
        // Create a new set with the same properties as the last set
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
            // If no existing sets, create a basic set
            newSet = SetRecord()
        }
        workout.sets.append(newSet)
    }
    
    // Function to delete sets
    private func deleteSets(at offsets: IndexSet) {
        workout.sets.remove(atOffsets: offsets)
    }
}

// Preview provider
struct EditWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        EditWorkoutView(
            workout: .constant(Workout(
                exerciseType: "Bench Press",
                sets: [
                    SetRecord(weight: "135", reps: "10"),
                    SetRecord(weight: "155", reps: "8")
                ]
            )),
            onSave: { _ in }
        )
        .environment(\.theme, AppTheme())
    }
}
