import SwiftUI

struct EditRoutineView: View {
    var routine: Routine
    @Binding var routines: [Routine]
    @State private var newName: String = ""
    @State private var selectedExercises: [String] = []
    @State private var exerciseTypes: [String] = []
    @State private var newExerciseType: String = ""
    @State private var showAlert = false // Alert for saving changes
    @State private var showingNewExerciseView = false // State for showing the NewExerciseView
    @State var exercises: [Exercise] = UserDefaultsManager.loadExercises() // Load exercises on startup
    @Environment(\.theme) var theme // Inject the global theme
    @Environment(\.dismiss) var dismiss

    var hasValidInput: Bool {
        !newName.isEmpty
    }

    var body: some View {
        ZStack {
            theme.backgroundColor.edgesIgnoringSafeArea(.all) // Set the entire view's background

            Form {
                // Section: Routine Name
                Section(header: Text("Routine Name")
                    .font(theme.secondaryFont)
                    .foregroundColor(theme.primaryColor)) {
                    TextField("", text: $newName)
                        .font(theme.secondaryFont)
                        .foregroundColor(.white) // Set input text color to white
                        .padding()
                        .background(theme.backgroundColor) // Set the background color to match the theme
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(theme.primaryColor, lineWidth: 1) // Keep the orange outline
                        )
                        .customPlaceholder(show: newName.isEmpty, placeholder: "Name") // Add placeholder text
                        .listRowBackground(theme.backgroundColor) // Remove the default white background for the row
                }

                // Section: Edit Exercises
                Section(header: Text("Edit Exercises")
                    .font(theme.secondaryFont)
                    .foregroundColor(theme.primaryColor)) {
                    ForEach(exerciseTypes, id: \.self) { exercise in
                        MultipleSelectionRow(title: exercise, isSelected: selectedExercises.contains(exercise)) {
                            if selectedExercises.contains(exercise) {
                                selectedExercises.removeAll { $0 == exercise }
                            } else {
                                selectedExercises.append(exercise)
                            }
                        }
                        .foregroundColor(.white) // Set unselected exercise text to white
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(theme.primaryColor, lineWidth: 1) // Thin orange outline for unselected exercises
                        )
                        .listRowBackground(theme.backgroundColor) // Set each row's background to match the theme
                    }

                    // New Exercise Button
                    Button("Create New Exercise") {
                        showingNewExerciseView = true
                    }
                    .customButtonStyle() // Apply custom button style
                    .background(theme.backgroundColor) // Override background for the button
                    .listRowBackground(Color.clear) // Clear the background of the list row
                    .navigationDestination(isPresented: $showingNewExerciseView) {
                        NewExerciseView(exercises: $exercises)
                            .onDisappear {
                                UserDefaultsManager.saveExercises(exercises)
                                if let lastCreatedExercise = exercises.last?.name {
                                    selectedExercises.append(lastCreatedExercise)
                                    exerciseTypes.append(lastCreatedExercise)
                                    exerciseTypes = exerciseTypes.sorted()
                                }
                            }
                    }
                }

                // Save Changes Button
                Section {
                    Button(action: saveChanges) {
                        Text("Save Changes")
                            .foregroundColor(hasValidInput ? theme.buttonTextColor : Color.gray)
                    }
                    .customButtonStyle()
                    .disabled(!hasValidInput) // Disable button if no valid input
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Changes Saved"), message: nil, dismissButton: .default(Text("OK")) {
                            dismiss() // Dismiss the current view and go back to RoutineListView
                        })
                    }
                    .listRowBackground(theme.backgroundColor) // Remove the default white background
                }
            }
            .background(theme.backgroundColor) // Apply the background color here
            .scrollContentBackground(.hidden) // Ensure the form background respects the theme color
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) { // Replace the navigation title with our custom view
                UnderlinedTitle(title: "Edit Routine") // Customize the title text here
            }
        }
        .onAppear {
            newName = routine.name
            selectedExercises = routine.exercises
            loadExerciseTypes()
        }
    }

    // Load existing exercise types from saved workouts and routines
    func loadExerciseTypes() {
        if let savedWorkouts = UserDefaults.standard.data(forKey: "workouts"),
           let decodedWorkouts = try? JSONDecoder().decode([Workout].self, from: savedWorkouts) {
            exerciseTypes = Array(Set(decodedWorkouts.map { $0.exerciseType })).sorted()
        }

        if let savedRoutines = UserDefaults.standard.data(forKey: "routines"),
           let decodedRoutines = try? JSONDecoder().decode([Routine].self, from: savedRoutines) {
            exerciseTypes.append(contentsOf: Array(Set(decodedRoutines.flatMap { $0.exercises })))
        }

        exerciseTypes = Array(Set(exerciseTypes)).sorted()
    }

    // Save the updated routine
    func saveChanges() {
        guard !newName.isEmpty else { return }

        if let index = routines.firstIndex(of: routine) {
            routines[index].name = newName
            routines[index].exercises = selectedExercises
            saveRoutines()
            showAlert = true
        }
    }

    func saveRoutines() {
        if let encoded = try? JSONEncoder().encode(routines) {
            UserDefaults.standard.set(encoded, forKey: "routines")
        }
    }
}

struct EditRoutineView_Previews: PreviewProvider {
    static var previews: some View {
        EditRoutineView(routine: Routine(name: "Sample Routine", exercises: ["Bench Press", "Squat"]), routines: .constant([]))
            .environment(\.theme, AppTheme()) // Preview with the theme applied
    }
}
