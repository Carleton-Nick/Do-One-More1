import SwiftUI

struct EditExerciseView: View {
    @Binding var exercises: [Exercise]
    @State var exercise: Exercise
    @Environment(\.dismiss) var dismiss
    @State private var exerciseName: String
    @State private var selectedMetrics: Set<ExerciseMetric>
    @State private var showAlert = false

    init(exercise: Exercise, exercises: Binding<[Exercise]>) {
        self._exercise = State(initialValue: exercise)
        self._exercises = exercises
        self._exerciseName = State(initialValue: exercise.name)
        self._selectedMetrics = State(initialValue: Set(exercise.selectedMetrics))
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Edit Exercise")
                .font(.title)
                .padding(.bottom, 20)

            TextField("Exercise Name", text: $exerciseName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 20)

            Text("Select Metrics")
                .font(.headline)

            ForEach(ExerciseMetric.allCases, id: \.self) { metric in
                HStack {
                    Text(metric.rawValue)
                    Spacer()
                    Toggle(isOn: Binding<Bool>(
                        get: { selectedMetrics.contains(metric) },
                        set: { isSelected in
                            if isSelected {
                                selectedMetrics.insert(metric)
                            } else {
                                selectedMetrics.remove(metric)
                            }
                        }
                    )) {
                        EmptyView()
                    }
                    .labelsHidden()
                }
                .padding(.vertical, 5)
            }

            Spacer()

            Button(action: saveChanges) {
                Text("Save Changes")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Incomplete Exercise"),
                    message: Text("Please enter a name and select at least one metric for the exercise."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .padding()
    }

    // MARK: - Save Changes Function
    func saveChanges() {
        guard !exerciseName.isEmpty && !selectedMetrics.isEmpty else {
            showAlert = true
            return
        }

        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
            exercises[index].name = exerciseName
            exercises[index].selectedMetrics = Array(selectedMetrics)

            // Save the updated exercises to UserDefaults
            ContentView.saveExercises(exercises)
        }

        // Dismiss the view after saving changes
        dismiss()
    }
}

struct EditExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        EditExerciseView(
            exercise: Exercise(name: "Sample", selectedMetrics: [.weight, .reps]),
            exercises: .constant([Exercise(name: "Sample", selectedMetrics: [.weight, .reps])])
        )
    }
}
