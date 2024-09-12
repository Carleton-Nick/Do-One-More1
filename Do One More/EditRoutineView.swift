import SwiftUI

struct EditRoutineView: View {
    var routine: Routine
    @Binding var routines: [Routine]
    @State private var newName: String = ""
    @State private var selectedExercises: [Exercise] = []  // Changed to [Exercise]
    @State private var exerciseTypes: [Exercise] = []  // Changed to [Exercise]
    @State private var newExerciseType: Exercise?
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

            VStack {
                // Section: Routine Name
                Form {
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
                }
                .padding(.bottom, 5)

                // Section: All Available Exercises
                VStack(alignment: .leading) {
                    Text("All Exercises").font(theme.secondaryFont).foregroundColor(theme.primaryColor)
                        .padding(.leading)

                    List(exerciseTypes, id: \.self) { exercise in
                        MultipleSelectionRow(title: exercise.name, isSelected: selectedExercises.contains(exercise)) {
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
                    .listStyle(InsetGroupedListStyle())
                }
                .padding(.bottom, 10)

                // Section: Selected Exercises
                VStack(alignment: .leading) {
                    Text("Selected Exercises").font(theme.secondaryFont).foregroundColor(theme.primaryColor)
                        .padding(.leading)

                    List {
                        ForEach(selectedExercises, id: \.self) { exercise in
                            Text(exercise.name)
                                .font(theme.secondaryFont)
                                .foregroundColor(.white)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(theme.primaryColor, lineWidth: 1)
                                )
                                .listRowBackground(theme.backgroundColor)
                        }
                        .onMove(perform: moveExercise)
                    }
                    .listStyle(InsetGroupedListStyle())
                    .toolbar { EditButton() }
                }

                // Save Changes Button
                Button(action: saveChanges) {
                    Text("Save Changes")
                        .foregroundColor(hasValidInput ? theme.buttonTextColor : Color.gray)
                }
                .font(theme.secondaryFont)
                .padding(theme.buttonPadding)
                .background(theme.buttonBackgroundColor)
                .cornerRadius(theme.buttonCornerRadius)
                .disabled(!hasValidInput) // Disable button if no valid input
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Changes Saved"), message: nil, dismissButton: .default(Text("OK")) {
                        dismiss() // Dismiss the current view and go back to RoutineListView
                    })
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) { // Replace the navigation title with our custom view
                UnderlinedTitle(title: "Edit Routine") // Customize the title text here
            }
        }
        .onAppear {
            newName = routine.name
            selectedExercises = routine.exercises // Assign selected exercises from routine
            loadExerciseTypes()
        }
    }

    // Load existing exercise types from saved workouts and routines
    func loadExerciseTypes() {
        exerciseTypes = Array(Set(exercises)).sorted { $0.name < $1.name }
    }

    // Reorder exercises in selected list
    func moveExercise(from source: IndexSet, to destination: Int) {
        selectedExercises.move(fromOffsets: source, toOffset: destination)
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
        EditRoutineView(routine: Routine(name: "Sample Routine", exercises: [Exercise(name: "Bench Press", selectedMetrics: [.weight])]), routines: .constant([]))
            .environment(\.theme, AppTheme()) // Preview with the theme applied
    }
}
