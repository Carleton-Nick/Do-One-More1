import SwiftUI

struct ExerciseListView: View {
    @Binding var exercises: [Exercise]
    @State private var showingNewExerciseView = false
    @State private var showingEditExerciseView = false
    @State private var exerciseToEdit: Exercise? = nil
    @State private var sortAlphabetically = false // Track sort order
    @Environment(\.theme) var theme

    // Sort by either A-Z or by Most Recent (Date Created)
    var sortedExercises: [Exercise] {
        if sortAlphabetically {
            return exercises.sorted { $0.name.lowercased() < $1.name.lowercased() }
        } else {
            return exercises.sorted { $0.creationDate > $1.creationDate } // Sort by most recent first
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Title with Underline
                UnderlinedTitle(title: "EXERCISES")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 20)

                // HStack for "Create New Exercise" and "Sort" buttons
                HStack {
                    // Create New Exercise button
                    Button(action: {
                        showingNewExerciseView = true
                    }) {
                        Text("Create New Exercise")
                    }
                    .font(theme.secondaryFont)
                    .padding(theme.buttonPadding)
                    .background(theme.buttonBackgroundColor)
                    .foregroundColor(.white)
                    .cornerRadius(theme.buttonCornerRadius)

                    Spacer()

                    // Sort button
                    Button(action: {
                        sortAlphabetically.toggle() // Toggle sort order
                    }) {
                        Text(sortAlphabetically ? "Sort by Date" : "Sort A-Z")
                            .foregroundColor(theme.primaryColor)
                            .padding(theme.buttonPadding)
                            .background(Color.black)
                            .cornerRadius(theme.buttonCornerRadius)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)

                // List of sorted exercises using InsetListStyle
                List {
                    ForEach(sortedExercises) { exercise in
                        HStack {
                            Text(exercise.name)
                                .foregroundColor(theme.primaryColor)
                            
                            Spacer()

                            // "Edit" link
                            Button(action: {
                                exerciseToEdit = exercise // Store the exercise to be edited
                                showingEditExerciseView = true
                            }) {
                                Text("Edit")
                                    .foregroundColor(.white) // White color for the "Edit" link
                            }
                        }
                        .listRowBackground(Color.black) // Black background for each exercise row
                        .listRowSeparatorTint(theme.primaryColor) // Optional: Color for the separator
                    }
                    .onDelete(perform: deleteExercise) // Swipe to delete
                }
                .listStyle(InsetListStyle()) // Use InsetListStyle for a cohesive, proper list look
                .background(theme.backgroundColor)
                .scrollContentBackground(.hidden) // Respect background color

                Spacer()
            }
            .background(theme.backgroundColor.edgesIgnoringSafeArea(.all))

            // Sheet for creating a new exercise
            .sheet(isPresented: $showingNewExerciseView) {
                NewExerciseView(exercises: $exercises)
                    .onDisappear {
                        UserDefaultsManager.saveExercises(exercises)
                    }
            }

            // Sheet for editing an existing exercise
            .sheet(item: $exerciseToEdit) { exercise in
                EditExerciseView(exercise: $exercises[exercises.firstIndex(of: exercise)!], exercises: $exercises)
                    .onDisappear {
                        UserDefaultsManager.saveExercises(exercises)
                    }
            }
        }
    }

    // MARK: - Delete Function

    // Handle deleting an exercise
    func deleteExercise(at offsets: IndexSet) {
        for index in offsets {
            let exerciseToDelete = sortedExercises[index] // Get the exercise to delete from the sorted list
            if let originalIndex = exercises.firstIndex(of: exerciseToDelete) { // Find the original index in exercises
                exercises.remove(at: originalIndex) // Remove the item from the original list
            }
        }
        UserDefaultsManager.saveExercises(exercises)
    }
}

struct ExerciseListView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseListView(exercises: .constant([]))
            .environment(\.theme, AppTheme())
    }
}
