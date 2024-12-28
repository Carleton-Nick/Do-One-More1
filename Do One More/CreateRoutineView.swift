import SwiftUI

struct CreateRoutineView: View {
    @Binding var routines: [Routine]
    @State private var routineName: String = ""
    @State private var selectedItems: [RoutineItem] = []
    @State private var showAlert = false
    @State private var showingNewExerciseView = false
    @State private var showingHeaderAlert = false
    @State private var headerName = ""
    @State private var editingHeaderIndex: Int?
    @State var exercises: [Exercise] = UserDefaultsManager.loadExercises()
    @State private var flashItem: UUID? = nil
    @Environment(\.theme) var theme
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                theme.backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    dragHandle
                    
                    // Name TextField
                    TextField("", text: $routineName)
                        .font(theme.secondaryFont)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(theme.primaryColor, lineWidth: 1)
                        )
                        .customPlaceholder(
                            show: routineName.isEmpty,
                            placeholder: "Enter Routine Name",
                            placeholderColor: .gray
                        )
                        .padding()
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Available Exercises Section
                            availableExercisesSection
                            
                            // Buttons
                            HStack(spacing: 20) {
                                Button(action: {
                                    showingNewExerciseView = true
                                }) {
                                    Text("Create New Exercise")
                                        .font(theme.secondaryFont)
                                        .foregroundColor(theme.buttonTextColor)
                                        .padding(theme.buttonPadding)
                                        .background(theme.buttonBackgroundColor)
                                        .cornerRadius(theme.buttonCornerRadius)
                                }
                                
                                Button(action: {
                                    showingHeaderAlert = true
                                }) {
                                    Text("Add Header")
                                        .font(theme.secondaryFont)
                                        .foregroundColor(theme.buttonTextColor)
                                        .padding(theme.buttonPadding)
                                        .background(theme.buttonBackgroundColor)
                                        .cornerRadius(theme.buttonCornerRadius)
                                }
                            }
                            .padding(.vertical)
                            
                            // Selected Items Section
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Selected Items")
                                    .font(theme.secondaryFont)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .overlay(
                                        Rectangle()
                                            .frame(height: 2)
                                            .foregroundColor(theme.primaryColor)
                                            .offset(y: 10),
                                        alignment: .bottom
                                    )
                                    .padding(.bottom, 10)
                                    .background(theme.backgroundColor)
                                
                                ForEach(Array(selectedItems.enumerated()), id: \.element.id) { index, item in
                                    switch item {
                                    case .exercise(let exercise):
                                        HStack {
                                            Text(exercise.name)
                                                .foregroundColor(.white)
                                                .padding(.leading, 10)
                                            Spacer()
                                        }
                                        .padding(.vertical, 12)
                                        .background(theme.primaryColor)
                                        .cornerRadius(8)
                                        .padding(.horizontal)
                                        .padding(.vertical, 4)
                                        
                                    case .header(let name):
                                        HStack {
                                            Spacer()
                                            Text(name)
                                                .foregroundColor(.white)
                                                .padding(.vertical, 12)
                                            Spacer()
                                            Button(action: {
                                                editingHeaderIndex = index
                                                headerName = name
                                                showingHeaderAlert = true
                                            }) {
                                                Image(systemName: "pencil")
                                                    .foregroundColor(.gray)
                                            }
                                            .padding(.trailing, 10)
                                        }
                                        .overlay(
                                            Rectangle()
                                                .frame(height: 1)
                                                .foregroundColor(theme.primaryColor)
                                                .offset(y: 12),
                                            alignment: .bottom
                                        )
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            .background(theme.backgroundColor)
                            
                            // Save Button
                            Button(action: saveRoutine) {
                                Text("Save Routine")
                                    .font(theme.secondaryFont)
                                    .foregroundColor(!routineName.isEmpty ? theme.buttonTextColor : theme.secondaryColor)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(!routineName.isEmpty ? theme.buttonBackgroundColor : Color.gray)
                                    .cornerRadius(theme.buttonCornerRadius)
                            }
                            .disabled(routineName.isEmpty)
                            .padding()
                        }
                        .background(theme.backgroundColor)
                    }
                    .background(theme.backgroundColor)
                }
            }
            .background(theme.backgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    UnderlinedTitle(title: "Create A Routine")
                }
            }
        }
        .sheet(isPresented: $showingNewExerciseView) {
            NewExerciseView(exercises: $exercises)
                .onDisappear {
                    UserDefaultsManager.saveExercises(exercises)
                    if let lastCreatedExercise = exercises.last {
                        selectedItems.append(.exercise(lastCreatedExercise))
                    }
                }
        }
        .alert("Name your header", isPresented: $showingHeaderAlert) {
            TextField("Header", text: $headerName)
            Button("OK") {
                if let index = editingHeaderIndex {
                    selectedItems[index] = .header(headerName)
                    editingHeaderIndex = nil
                } else {
                    selectedItems.append(.header(headerName))
                }
            }
            Button("Cancel", role: .cancel) {
                editingHeaderIndex = nil
            }
        }
        .alert("Routine Saved", isPresented: $showAlert) {
            Button("OK") {
                dismiss()
            }
        }
        .background(theme.backgroundColor)
    }

    // Helper Views
    private var dragHandle: some View {
        HStack {
            Capsule()
                .fill(Color.gray.opacity(0.7))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity)
        .background(theme.backgroundColor)
    }

    private var availableExercisesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Available Exercises")
                .font(theme.secondaryFont)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .overlay(
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(theme.primaryColor)
                        .offset(y: 10),
                    alignment: .bottom
                )
                .padding(.bottom, 10)
                .background(theme.backgroundColor)
            
            exercisesList
        }
        .background(theme.backgroundColor)
    }

    private var exercisesList: some View {
        ForEach(ExerciseCategory.allCasesSorted, id: \.self) { category in
            let categoryExercises = exercises.filter { $0.category == category }
            if !categoryExercises.isEmpty {
                categoryHeader(category)
                exercisesForCategory(categoryExercises)
            }
        }
    }

    private func categoryHeader(_ category: ExerciseCategory) -> some View {
        Text(category.rawValue)
            .font(theme.secondaryFont)
            .foregroundColor(.white)
            .padding(.horizontal)
            .padding(.top, 10)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(theme.primaryColor)
                    .offset(y: 5),
                alignment: .bottom
            )
            .background(theme.backgroundColor)
    }

    private func exercisesForCategory(_ exercises: [Exercise]) -> some View {
        ForEach(exercises.sorted(by: { $0.name < $1.name })) { exercise in
            MultipleSelectionRow(
                title: exercise.name,
                isSelected: selectedItems.contains(where: {
                    if case .exercise(let selectedExercise) = $0 {
                        return selectedExercise.id == exercise.id
                    }
                    return false
                }),
                isFlashing: flashItem == exercise.id
            ) {
                if let index = selectedItems.firstIndex(where: {
                    if case .exercise(let selectedExercise) = $0 {
                        return selectedExercise.id == exercise.id
                    }
                    return false
                }) {
                    selectedItems.remove(at: index)
                } else {
                    selectedItems.append(.exercise(exercise))
                    flashItem = exercise.id
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        flashItem = nil
                    }
                }
            }
            .background(theme.backgroundColor)
        }
    }

    func saveRoutine() {
        guard !routineName.isEmpty else { return }
        
        let exercisesOnly = selectedItems.compactMap { item -> Exercise? in
            if case .exercise(let exercise) = item {
                return exercise
            }
            return nil
        }
        
        let newRoutine = Routine(name: routineName, exercises: exercisesOnly, items: selectedItems)
        routines.append(newRoutine)
        UserDefaultsManager.saveRoutines(routines)
        showAlert = true
    }
}

struct CreateRoutineView_Previews: PreviewProvider {
    static var previews: some View {
        EditRoutineView(
            routine: Routine(
                name: "Sample Routine",
                exercises: [Exercise(name: "Bench Press", selectedMetrics: [], category: .chest)],
                items: [
                    .header("Warm-up"),
                    .exercise(Exercise(name: "Bench Press", selectedMetrics: [], category: .chest))
                ]
            ),
            routines: .constant([])
        )
        .environment(\.theme, AppTheme())
    }
}
