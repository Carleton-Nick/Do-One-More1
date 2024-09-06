import SwiftUI

struct ExerciseListView: View {
    @Binding var exercises: [Exercise]
    @State private var showingNewExerciseView = false
    @State private var showingEditExerciseView: Exercise? = nil
    @State private var editMode: EditMode = .inactive // Track the edit mode
    @Environment(\.theme) var theme

    var sortedExercises: [Exercise] {
        exercises.sorted { $0.name.lowercased() < $1.name.lowercased() }
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Title with Underline
                UnderlinedTitle(title: "EXERCISES")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 20)

                // HStack for "Create New Exercise" and "Arrange/Delete" buttons
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

                    // Arrange/Delete button
                    Button(action: {
                        // Toggle edit mode
                        withAnimation {
                            editMode = editMode == .active ? .inactive : .active
                        }
                    }) {
                        Text(editMode == .active ? "Done" : "Arrange/Delete")
                            .foregroundColor(theme.primaryColor)
                            .padding(theme.buttonPadding)
                            .background(Color.black)
                            .cornerRadius(theme.buttonCornerRadius)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)

                // List of sorted exercises
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
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .onDelete(perform: deleteExercise)
                    .onMove(perform: moveExercise)
                }
                .environment(\.editMode, $editMode) // Set the edit mode
                .background(theme.backgroundColor)
                .scrollContentBackground(.hidden) // Respect background color

                Spacer()
            }
            .background(theme.backgroundColor.edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $showingNewExerciseView) {
                NewExerciseView(exercises: $exercises)
                    .onDisappear {
                        ContentView.saveExercises(exercises)
                    }
            }
            .navigationDestination(item: $showingEditExerciseView) { exercise in
                EditExerciseView(exercise: exercise, exercises: $exercises)
                    .onDisappear {
                        ContentView.saveExercises(exercises)
                    }
            }
        }
    }

    // MARK: - Delete and Move Functions

    // Handle deleting an exercise
    func deleteExercise(at offsets: IndexSet) {
        exercises.remove(atOffsets: offsets)
        ContentView.saveExercises(exercises)
    }

    // Handle reordering exercises
    func moveExercise(from source: IndexSet, to destination: Int) {
        exercises.move(fromOffsets: source, toOffset: destination)
        ContentView.saveExercises(exercises)
    }
}

struct ExerciseListView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseListView(exercises: .constant([]))
            .environment(\.theme, AppTheme())
    }
}
