import SwiftUI

struct ExerciseListView: View {
    @Binding var exercises: [Exercise]
    @State private var showingNewExerciseView = false
    @State private var showingEditExerciseView: Exercise? = nil
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
                                showingEditExerciseView = exercise // Trigger edit view for the exercise
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
            .sheet(isPresented: $showingNewExerciseView) {
                NewExerciseView(exercises: $exercises)
                    .onDisappear {
                        UserDefaultsManager.saveExercises(exercises)
                    }
            }
            .navigationDestination(item: $showingEditExerciseView) { exercise in
                EditExerciseView(exercise: exercise, exercises: $exercises)
                    .onDisappear {
                        UserDefaultsManager.saveExercises(exercises)
                    }
            }
        }
    }

    // MARK: - Delete Function

    // Handle deleting an exercise
    func deleteExercise(at offsets: IndexSet) {
        exercises.remove(atOffsets: offsets)
        UserDefaultsManager.saveExercises(exercises)
    }
}

struct ExerciseListView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseListView(exercises: .constant([]))
            .environment(\.theme, AppTheme())
    }
}
