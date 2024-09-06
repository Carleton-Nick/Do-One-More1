import SwiftUI

struct NewExerciseView: View {
    @Binding var exercises: [Exercise]
    @Environment(\.presentationMode) var presentationMode
    @State private var exerciseName: String = ""
    @State private var selectedMetrics: Set<ExerciseMetric> = []
    @State private var showAlert = false // Show alert if no exercise name or metrics are selected

    var canSave: Bool {
        // Enable the Save button only when exerciseName is not empty and at least one metric is selected
        return !exerciseName.isEmpty && !selectedMetrics.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Create New Exercise")
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

            Button(action: saveExercise) {
                Text("Save Exercise")
                    .padding()
                    .background(canSave ? Color.blue : Color.gray) // Button background color based on criteria
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(!canSave) // Disable the button if criteria are not met
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Incomplete Exercise"),
                    message: Text("Please provide a name and select at least one metric."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .padding()
    }

    // Save the new exercise and dismiss
    func saveExercise() {
        // Validate: Require a name and at least one metric
        guard !exerciseName.isEmpty && !selectedMetrics.isEmpty else {
            showAlert = true
            return
        }

        let newExercise = Exercise(name: exerciseName, selectedMetrics: Array(selectedMetrics))
        exercises.append(newExercise)

        // Save the updated exercises to UserDefaults
        UserDefaultsManager.saveExercises(exercises)

        // Dismiss the current view
        presentationMode.wrappedValue.dismiss()
    }
}

struct NewExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        NewExerciseView(exercises: .constant([]))
    }
}
