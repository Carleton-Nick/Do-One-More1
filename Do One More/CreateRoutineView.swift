import SwiftUI

struct CreateRoutineView: View {
    @Binding var routines: [Routine]
    @State private var routineName: String = ""
    @State private var selectedExercises: [Exercise] = []
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

            VStack(alignment: .leading) {
                // Section: Routine Name
                VStack(alignment: .leading, spacing: 10) {
                    Text("Routine Name")
                        .font(theme.secondaryFont)
                        .foregroundColor(theme.primaryColor)

                    // Name Input Field
                    TextField("", text: $routineName)
                        .font(theme.secondaryFont)
                        .foregroundColor(.white)
                        .padding()
                        .background(theme.backgroundColor) // Set the background to match the theme
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(theme.primaryColor, lineWidth: 1) // Orange border around the text field
                        )
                        .customPlaceholder(show: routineName.isEmpty, placeholder: "Name")
                }
                .padding(.horizontal)

                // All Exercises Section
                VStack(alignment: .leading, spacing: 10) {
                    // Centered Title: "Choose exercises for your routine"
                    Text("Choose exercises for your routine")
                        .font(theme.secondaryFont)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center) // Center the text
                        .padding(.bottom, 5)
                        .overlay(
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(theme.primaryColor) // Thin orange underline
                                .offset(y: 10), // Position the underline below the text
                            alignment: .bottomLeading
                        )

                    // List of All Exercises with black background and custom styling
                    List(exercises.sorted(by: { $0.name < $1.name }), id: \.self) { exercise in // Sort alphabetically by name
                            MultipleSelectionRow(title: exercise.name, isSelected: selectedExercises.contains(exercise)) {
                                if selectedExercises.contains(exercise) {
                                    selectedExercises.removeAll { $0 == exercise }
                                } else {
                                    selectedExercises.append(exercise)
                                }
                            }
                        .listRowBackground(Color.clear) // Clear list background to match spacing style
                    }
                    .scrollContentBackground(.hidden) // Remove default white list background
                    .background(theme.backgroundColor) // Set overall background to black
                    .listStyle(InsetListStyle()) // Default inset list style (unstyled)
                    .frame(maxWidth: .infinity)

                    // Centered "Create New Exercise" Button
                    Button(action: {
                        showingNewExerciseView = true
                    }) {
                        Text("Create New Exercise")
                            .font(theme.secondaryFont)
                            .foregroundColor(theme.buttonTextColor)
                            .padding(theme.buttonPadding)
                            .background(theme.buttonBackgroundColor)
                            .cornerRadius(theme.buttonCornerRadius)
                    }
                    .frame(maxWidth: .infinity, alignment: .center) // Center the button
                    .sheet(isPresented: $showingNewExerciseView) {
                        NewExerciseView(exercises: $exercises)
                            .onDisappear {
                                UserDefaultsManager.saveExercises(exercises)
                                if let lastCreatedExercise = exercises.last {
                                    selectedExercises.append(lastCreatedExercise)
                                }
                            }
                    }
                }

                // Section: Selected Exercises
                VStack(alignment: .leading, spacing: 10) {
                    // Centered Title: "Your Routine"
                    Text("Your Routine")
                        .font(theme.secondaryFont)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center) // Center the text
                        .padding(.bottom, 5)
                        .overlay(
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(theme.primaryColor) // Thin orange underline
                                .offset(y: 10), // Position the underline below the text
                            alignment: .bottomLeading
                        )

                    List {
                        ForEach(selectedExercises) { exercise in
                            Text(exercise.name)
                                .foregroundColor(.white) // White text for selected exercises
                                .padding(.vertical, 7) // Consistent padding
                        }
                        .onMove(perform: moveExercise)
                        .listRowBackground(theme.primaryColor) // Set selected exercise row background to theme
                    }
                    .scrollContentBackground(.hidden) // Remove default white list background
                    .background(theme.backgroundColor) // Set overall background color to theme
                    .listStyle(InsetListStyle()) // Default inset list style
                    .toolbar {
                        EditButton() // To rearrange the selected exercises
                    }
                }

                // Save Routine Button
                Button(action: saveRoutine) {
                    Text("Save Routine")
                        .font(theme.secondaryFont)
                        .foregroundColor(hasValidInput ? theme.buttonTextColor : theme.secondaryColor)
                        .padding(theme.buttonPadding)
                        .background(theme.buttonBackgroundColor)
                        .cornerRadius(theme.buttonCornerRadius)
                }
                .frame(maxWidth: .infinity, alignment: .center) // Center the button
                .disabled(!hasValidInput)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Routine Saved"), message: nil, dismissButton: .default(Text("OK")) {
                        dismiss() // Dismiss the current view and go back to RoutineListView
                    })
                }
                .padding(.top, 10)
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                UnderlinedTitle(title: "Create A Routine")
            }
        }
        .onAppear {
            exercises = UserDefaultsManager.loadExercises() // Load latest exercises from global storage
        }
    }

    // Reorder exercises in the selected list
    func moveExercise(from source: IndexSet, to destination: Int) {
        selectedExercises.move(fromOffsets: source, toOffset: destination)
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
