import SwiftUI

struct NewExerciseView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.theme) var theme
    @Binding var exercises: [Exercise]
    @State private var exerciseName = ""
    @State private var selectedMetrics: Set<ExerciseMetric> = []
    @State private var selectedCategory: ExerciseCategory = .arms  // Default category
    @State private var showAlert = false

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
                        .fill(Color.gray.opacity(0.7))
                        .frame(width: 120, height: 5)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                }
                .frame(maxWidth: .infinity)

                // Input Field for Exercise Name with Placeholder
                TextField("", text: $exerciseName)
                    .font(theme.secondaryFont)
                    .foregroundColor(.white)
                    .padding()
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(theme.primaryColor, lineWidth: 1)
                    )
                    .customPlaceholder(
                        show: exerciseName.isEmpty,
                        placeholder: "New Exercise Name",
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

                Text("Select Metrics")
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
                    Text("Save Exercise")
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

        let newExercise = Exercise(
            name: exerciseName,
            selectedMetrics: Array(selectedMetrics),
            category: selectedCategory
        )
        exercises.append(newExercise)
        UserDefaultsManager.saveExercises(exercises)
        dismiss()
    }
}

struct NewExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        NewExerciseView(exercises: .constant([]))
            .environment(\.theme, AppTheme())
    }
}
