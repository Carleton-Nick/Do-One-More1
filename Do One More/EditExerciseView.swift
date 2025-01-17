import SwiftUI

struct EditExerciseView: View {
    @Binding var exercise: Exercise
    @Binding var exercises: [Exercise]
    @Environment(\.presentationMode) var presentationMode
    @State private var exerciseName: String
    @State private var selectedMetrics: Set<ExerciseMetric>
    @State private var showAlert = false
    @Environment(\.theme) var theme

    init(exercise: Binding<Exercise>, exercises: Binding<[Exercise]>) {
        self._exercise = exercise
        self._exercises = exercises
        self._exerciseName = State(initialValue: exercise.wrappedValue.name)
        self._selectedMetrics = State(initialValue: Set(exercise.wrappedValue.selectedMetrics))
    }

    var canSave: Bool {
        return !exerciseName.isEmpty && !selectedMetrics.isEmpty
    }

    var body: some View {
        ZStack {
            theme.backgroundColor.edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading) {
                // Drag Handle
                HStack {
                    Capsule()
                        .fill(Color.gray.opacity(0.7)) // Grey color with some opacity
                        .frame(width: 120, height: 5) // Handle size
                        .padding(.top, 10) // Padding above the handle
                        .padding(.bottom, 10) // Padding below the handle
                }
                .frame(maxWidth: .infinity) // Center the drag handle horizontally

                // Input Field for Exercise Name with Placeholder
                TextField("", text: $exerciseName)
                    .font(theme.secondaryFont)
                    .foregroundColor(.white)
                    .padding()
                    .background(theme.backgroundColor)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(theme.primaryColor, lineWidth: 1)
                    )
                    .customPlaceholder(show: exerciseName.isEmpty, placeholder: "Edit Exercise Name")
                    .padding(.bottom, 20)

                Text("Edit Metrics")
                    .font(theme.secondaryFont)
                    .foregroundColor(theme.primaryColor)

                ForEach(ExerciseMetric.allCases, id: \.self) { metric in
                    HStack {
                        Text(metric.rawValue)
                            .font(theme.secondaryFont)
                            .foregroundColor(.white)
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
                        .tint(theme.primaryColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(theme.primaryColor, lineWidth: 1)
                        )
                        .labelsHidden()
                    }
                    .padding(.vertical, 5)
                }

                Spacer()

                Button(action: saveExercise) {
                    Text("Save Changes")
                        .font(theme.secondaryFont)
                        .foregroundColor(theme.buttonTextColor)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(canSave ? theme.buttonBackgroundColor : Color.gray)
                        .cornerRadius(theme.buttonCornerRadius)
                }
                .disabled(!canSave)
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
    }

    func saveExercise() {
        guard !exerciseName.isEmpty && !selectedMetrics.isEmpty else {
            showAlert = true
            return
        }

        // Update the existing exercise with the new data
        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
            exercises[index] = Exercise(id: exercise.id, name: exerciseName, selectedMetrics: Array(selectedMetrics))
            UserDefaultsManager.saveExercises(exercises)
        }

        presentationMode.wrappedValue.dismiss() // Dismiss the current view
    }
}

struct EditExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        EditExerciseView(
            exercise: .constant(Exercise(name: "Squat", selectedMetrics: [.weight, .reps])),
            exercises: .constant([])
        )
        .environment(\.theme, AppTheme())
    }
}
