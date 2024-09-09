import SwiftUI

struct CreateRoutineView: View {
    @Binding var routines: [Routine]
    @State private var routineName: String = ""
    @State private var selectedExercises: [String] = []
    @State private var showAlert = false
    @State private var showingNewExerciseView = false
    @State var exercises: [Exercise] = UserDefaultsManager.loadExercises() // Load exercises on startup
    @Environment(\.theme) var theme // Inject the global theme
    @Environment(\.dismiss) var dismiss

    var hasValidInput: Bool {
        !routineName.isEmpty
    }

    var body: some View {
        ZStack {
            theme.backgroundColor.edgesIgnoringSafeArea(.all) // Set the entire view's background

            Form {
                // Section: Routine Name
                Section(header: Text("Routine Name")
                    .font(theme.secondaryFont)
                    .foregroundColor(theme.primaryColor)) {
                    TextField("", text: $routineName)
                        .font(theme.secondaryFont)
                        .foregroundColor(.white)
                        .padding()
                        .background(theme.backgroundColor) // Set the background color to match the theme
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(theme.primaryColor, lineWidth: 1)
                        )
                        .customPlaceholder(show: routineName.isEmpty, placeholder: "Name") // Add placeholder text
                        .listRowBackground(theme.backgroundColor) // Remove the default white background for the row
                }

                // Section: Select Exercises
                Section(header: Text("Select Your Exercises")
                    .font(theme.secondaryFont)
                    .foregroundColor(theme.primaryColor)) {
                    ForEach(exercises.map { $0.name }, id: \.self) { exercise in
                        MultipleSelectionRow(title: exercise, isSelected: selectedExercises.contains(exercise)) {
                            if selectedExercises.contains(exercise) {
                                selectedExercises.removeAll { $0 == exercise }
                            } else {
                                selectedExercises.append(exercise)
                            }
                        }
                        .listRowBackground(theme.backgroundColor) // Set each row's background to black
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
                                }
                            }
                    }
                }

                // Save Routine Button
                Section {
                    Button(action: saveRoutine) {
                        Text("Save Routine")
                            .foregroundColor(hasValidInput ? theme.buttonTextColor : theme.secondaryColor) // Gray out if input is invalid
                    }
                    .customButtonStyle()
                    .disabled(!hasValidInput) // Disable the button if the routine name is empty
                    .listRowBackground(theme.backgroundColor) // Remove the default white background
                }
            }
            .background(theme.backgroundColor) // Apply the background color here
            .scrollContentBackground(.hidden) // Ensure the form background respects the theme color
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Routine Saved"), message: nil, dismissButton: .default(Text("OK")) {
                    dismiss() // Dismiss the current view and go back to RoutineListView
                })
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) { // Replace the navigation title with our custom view
                UnderlinedTitle(title: "Create A Routine") // Customize the title text here
            }
        }
        .onAppear {
            exercises = UserDefaultsManager.loadExercises() // Load latest exercises from global storage
        }
    }

    // Save the new routine
    func saveRoutine() {
        guard !routineName.isEmpty else { return }

        let newRoutine = Routine(name: routineName, exercises: selectedExercises)
        routines.append(newRoutine)
        UserDefaultsManager.saveRoutines(routines)
        showAlert = true
    }
}

struct CreateRoutineView_Previews: PreviewProvider {
    static var previews: some View {
        CreateRoutineView(routines: .constant([]))
            .environment(\.theme, AppTheme()) // Preview with the theme applied
    }
}
