import SwiftUI

struct EditExerciseView: View {
    @Binding var exercise: Exercise
    @Binding var exercises: [Exercise]
    @Environment(\.presentationMode) var presentationMode
    @State private var exerciseName: String
    @State private var selectedMetrics: Set<ExerciseMetric>
    @State private var selectedCategory: ExerciseCategory
    @State private var showAlert = false
    @Environment(\.theme) var theme

    init(exercise: Binding<Exercise>, exercises: Binding<[Exercise]>) {
        self._exercise = exercise
        self._exercises = exercises
        self._exerciseName = State(initialValue: exercise.wrappedValue.name)
        self._selectedMetrics = State(initialValue: Set(exercise.wrappedValue.selectedMetrics))
        self._selectedCategory = State(initialValue: exercise.wrappedValue.category)
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
                    .foregroundColor(.white) // Keep or remove based on testing
                    .padding()
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(theme.primaryColor, lineWidth: 1)
                    )
                    .customPlaceholder(
                        show: exerciseName.isEmpty,
                        placeholder: "Edit Exercise Name",
                        placeholderColor: .gray
                    )
                    .autocapitalization(.words)
                    .textInputAutocapitalization(.words)
                    .padding(.bottom, 20)

                // Category picker with orange border
                HStack {
                    Text("Category")
                        .font(theme.secondaryFont)
                        .foregroundColor(.white)
                    Spacer()
                    Picker("", selection: $selectedCategory) {
                        ForEach(ExerciseCategory.allCasesSorted, id: \.self) { category in
                            Text(category.rawValue)
                                .foregroundColor(.white)
                                .tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(theme.primaryColor, lineWidth: 1)
                    )
                }
                .padding(.vertical, 5)

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

        // Create an ordered array of selected metrics
        let orderedMetrics = ExerciseMetric.allCases.filter { selectedMetrics.contains($0) }

        // Update the existing exercise with the new data
        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
            let oldName = exercises[index].name  // Store the old name
            exercises[index] = Exercise(
                name: exerciseName,
                selectedMetrics: orderedMetrics,
                category: selectedCategory
            )
            UserDefaultsManager.saveExercises(exercises)
            
            // Update the exercise name in all routines
            if oldName != exerciseName {
                UserDefaultsManager.updateExerciseNameInRoutines(oldName: oldName, newName: exerciseName)
            }
        }

        presentationMode.wrappedValue.dismiss()
    }
}

struct EditExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        EditExerciseView(
            exercise: .constant(Exercise(
                name: "Squat",
                selectedMetrics: [.weight, .reps],
                category: .legs
            )),
            exercises: .constant([])
        )
        .environment(\.theme, AppTheme())
    }
}
