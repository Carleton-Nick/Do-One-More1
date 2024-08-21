//
//  CreateRoutineView.swift
//  Do One More
//
//  Created by Nick Carleton on 6/26/24.
//

import SwiftUI

struct CreateRoutineView: View {
    @Binding var routines: [Routine]
    @State private var routineName: String = ""
    @State private var selectedExercises: [String] = []
    @State private var exerciseTypes: [String] = []
    @State private var newExerciseType: String = ""
    @State private var showAlert = false // Add state property for the alert
    @Environment(\.theme) var theme // Inject the global theme

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
                        .foregroundColor(theme.primaryColor)
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
                    ForEach(exerciseTypes, id: \.self) { exercise in
                        MultipleSelectionRow(title: exercise, isSelected: selectedExercises.contains(exercise)) {
                            if selectedExercises.contains(exercise) {
                                selectedExercises.removeAll { $0 == exercise }
                            } else {
                                selectedExercises.append(exercise)
                            }
                        }
                        .listRowBackground(theme.backgroundColor) // Set each row's background to black
                    }
                    HStack {
                        TextField("", text: $newExerciseType)
                            .font(theme.secondaryFont)
                            .foregroundColor(theme.primaryColor)
                            .padding()
                            .background(theme.backgroundColor)
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(theme.primaryColor, lineWidth: 1)
                            )
                            .customPlaceholder(show: newExerciseType.isEmpty, placeholder: "New Exercise") // Add placeholder text

                        Button(action: addNewExerciseType) {
                            Text("Add")
                        }
                        .customButtonStyle()
                    }
                    .listRowBackground(theme.backgroundColor) // Set the HStack's background to black
                }

                // Save Routine Button
                Section {
                    Button(action: saveRoutine) {
                        Text("Save Routine")
                    }
                    .customButtonStyle()
                    .listRowBackground(theme.backgroundColor) // Remove the default white background
                }
            }
            .background(theme.backgroundColor) // Apply the background color here
            .scrollContentBackground(.hidden) // Ensure the form background respects the theme color
            .alert(isPresented: $showAlert) { // Show alert when routine is saved
                Alert(title: Text("Routine Saved"), message: nil, dismissButton: .default(Text("OK")))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) { // Replace the navigation title with our custom view
                UnderlinedTitle(title: "Create A Routine") // Customize the title text here
            }
        }
        .onAppear(perform: loadExerciseTypes)
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

    // Add a new exercise type to the list
    func addNewExerciseType() {
        guard !newExerciseType.isEmpty else { return }
        exerciseTypes.append(newExerciseType)
        exerciseTypes = exerciseTypes.sorted()
        newExerciseType = ""
    }

    // Save the new routine
    func saveRoutine() {
        let newRoutine = Routine(name: routineName, exercises: selectedExercises)
        routines.append(newRoutine)
        if let encoded = try? JSONEncoder().encode(routines) {
            UserDefaults.standard.set(encoded, forKey: "routines")
        }
        showAlert = true // Trigger the alert
    }
}

struct UnderlinedTitle: View {
    let title: String
    @Environment(\.theme) var theme // Use your global theme

    var body: some View {
        VStack(spacing: 5) {
            Text(title.uppercased()) // Convert the title to uppercase
                .font(theme.primaryFont)
                .foregroundColor(.white)
            Rectangle() // The underline
                .fill(theme.primaryColor) // Use your theme’s primary color (orange)
                .frame(height: 2)
        }
    }
}

struct CreateRoutineView_Previews: PreviewProvider {
    static var previews: some View {
        CreateRoutineView(routines: .constant([]))
            .environment(\.theme, AppTheme()) // Preview with the theme applied
    }
}
