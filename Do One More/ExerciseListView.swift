import SwiftUI

struct ExerciseListView: View {
    @Binding var exercises: [Exercise]
    @State private var showingNewExerciseView = false
    @State private var showingEditExerciseView = false
    @State private var exerciseToEdit: Exercise? = nil
    @State private var sortAlphabetically = false
    @Environment(\.theme) var theme

    // Group exercises by category
    var groupedExercises: [(ExerciseCategory, [Exercise])] {
        let grouped = Dictionary(grouping: exercises) { $0.category }
        return ExerciseCategory.allCasesSorted.map { category in
            (category, grouped[category]?.sorted { $0.name < $1.name } ?? [])
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Title with Underline
                UnderlinedTitle(title: "Exercises")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 20)

                List {
                    ForEach(groupedExercises, id: \.0) { category, exercises in
                        if !exercises.isEmpty {
                            Section(header: Text(category.rawValue)
                                .font(theme.primaryFont)
                                .foregroundColor(theme.primaryColor)
                            ) {
                                ForEach(exercises) { exercise in
                                    ExerciseRow(exercise: exercise)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            exerciseToEdit = exercise
                                        }
                                }
                                .onDelete { indexSet in
                                    deleteExercise(category: category, at: indexSet)
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetListStyle())
                .background(theme.backgroundColor)
                .scrollContentBackground(.hidden)

                Spacer()

                // Add Exercise Button
                Button(action: { showingNewExerciseView = true }) {
                    Text("Add Exercise")
                        .customButtonStyle()
                }
                .padding(.bottom)
            }
            .background(theme.backgroundColor.edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $showingNewExerciseView) {
                NewExerciseView(exercises: $exercises)
            }
            .sheet(item: $exerciseToEdit) { exercise in
                EditExerciseView(
                    exercise: $exercises[exercises.firstIndex(of: exercise)!],
                    exercises: $exercises
                )
            }
        }
    }

    // Updated delete function to handle categorized exercises
    func deleteExercise(category: ExerciseCategory, at offsets: IndexSet) {
        // Get all exercises in this category with their original indices
        let categoryExercisesWithIndices = exercises.enumerated()
            .filter { $0.element.category == category }
            .map { (index: $0.offset, exercise: $0.element) }
        
        // Map the offset indices to the original array indices
        let originalIndices = offsets.map { categoryExercisesWithIndices[$0].index }
        
        // Remove exercises in reverse order to maintain correct indices
        for index in originalIndices.sorted(by: >) {
            exercises.remove(at: index)
        }
        
        UserDefaultsManager.saveExercises(exercises)
    }
}

// Helper extension for safe array access
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

struct ExerciseListView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseListView(exercises: .constant([]))
            .environment(\.theme, AppTheme())
    }
}
