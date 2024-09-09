import SwiftUI

struct ContentView: View {
    @State var exercises: [Exercise] = UserDefaultsManager.loadExercises() // Load exercises on startup
    @State var selectedExerciseType: String = ""
    @State var setRecords: [SetRecord] = [SetRecord()]
    @State var savedWorkouts: [Workout] = []  // Ensure this is declared only once
    @State private var showAlert = false
    @State private var showingNewExerciseView = false
    var fromRoutine: Bool = false
    @Environment(\.theme) var theme

    // The fixed array with the desired metric order
    let metricOrder: [ExerciseMetric] = [
        .weight, .reps, .time, .distance, .calories, .custom
    ]

    var hasValidInput: Bool {
        let validExercise = !selectedExerciseType.isEmpty
        let validDetailsInput = setRecords.allSatisfy { record in
            record.weight != nil ||
            record.reps != nil ||
            record.elapsedTime != nil ||
            record.distance != nil ||
            record.calories != nil ||
            record.custom != nil
        }
        return validExercise && validDetailsInput
    }

    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    // Exercise Picker
                    HStack {
                        Menu {
                            Picker(selection: $selectedExerciseType) {
                                ForEach(exercises.sorted(by: { $0.name < $1.name }).map { $0.name }, id: \.self) { exercise in
                                    Text(exercise)
                                        .foregroundColor(.primary) // Set color for picker options
                                }
                            } label: {
                                EmptyView()  // Hide Picker label inside the Menu
                            }
                        } label: {
                            Text(selectedExerciseType.isEmpty ? "Choose an exercise" : selectedExerciseType)
                                .customPickerStyle()  // Apply the custom style
                            Image(systemName: "chevron.up.chevron.down")
                                .customPickerStyle()  // Apply the custom style
                        }
                        .padding(10)
                        .onChange(of: selectedExerciseType) {
                            if exercises.contains(where: { $0.name == selectedExerciseType }) {
                                setRecords = [SetRecord()]
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(theme.primaryColor, lineWidth: 1))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 3)

                    if let currentExercise = exercises.first(where: { $0.name == selectedExerciseType }) {
                        ForEach(Array(setRecords.enumerated()), id: \.offset) { index, _ in
                            VStack {
                                // Horizontal Stack for Weight and Reps, if selected
                                if currentExercise.selectedMetrics.contains(.weight) || currentExercise.selectedMetrics.contains(.reps) {
                                    HStack {
                                        if currentExercise.selectedMetrics.contains(.weight) {
                                            createTextField(for: .weight, at: index)
                                                .frame(maxWidth: .infinity)
                                        }
                                        if currentExercise.selectedMetrics.contains(.reps) {
                                            createTextField(for: .reps, at: index)
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                    .padding(.horizontal)
                                }

                                // Horizontal Stack for Time and Distance, if selected
                                if currentExercise.selectedMetrics.contains(.time) || currentExercise.selectedMetrics.contains(.distance) {
                                    HStack {
                                        if currentExercise.selectedMetrics.contains(.time) {
                                            createTextField(for: .time, at: index)
                                                .frame(maxWidth: .infinity)
                                        }
                                        if currentExercise.selectedMetrics.contains(.distance) {
                                            createTextField(for: .distance, at: index)
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                    .padding(.horizontal)
                                }

                                // Horizontal Stack for Calories and Custom Notes, if selected
                                if currentExercise.selectedMetrics.contains(.calories) || currentExercise.selectedMetrics.contains(.custom) {
                                    HStack {
                                        if currentExercise.selectedMetrics.contains(.calories) {
                                            createTextField(for: .calories, at: index)
                                                .frame(maxWidth: .infinity)
                                        }
                                        if currentExercise.selectedMetrics.contains(.custom) {
                                            createTextField(for: .custom, at: index)
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }

                    HStack {
                        Button(action: {
                            setRecords.append(SetRecord())  // Add a new SetRecord to the list
                        }) {
                            Text("Add Set")
                        }
                        .font(theme.secondaryFont)
                        .foregroundColor(theme.buttonTextColor)
                        .padding(theme.buttonPadding)
                        .background(theme.buttonBackgroundColor)
                        .cornerRadius(theme.buttonCornerRadius)

                        Spacer()

                        Button(action: saveWorkout) {
                            Text("Save Workout")
                                .foregroundColor(hasValidInput ? theme.buttonTextColor : Color.gray)
                        }
                        .font(theme.secondaryFont)
                        .padding(theme.buttonPadding)
                        .background(theme.buttonBackgroundColor)
                        .cornerRadius(theme.buttonCornerRadius)
                        .disabled(!hasValidInput)
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Workout Saved!"), dismissButton: .default(Text("OK")) {
                                clearInputFields()
                            })
                        }
                    }
                    .padding(.top, 5)
                    .padding(.horizontal)
                }
                .padding(.top, 20)
                Spacer(minLength: 0)

                VStack(spacing: 10) {
                    // Button for Exercises
                    NavigationLink(destination: ExerciseListView(exercises: $exercises)) {
                        Text("Exercises")
                    }
                    .font(theme.secondaryFont)
                    .foregroundColor(theme.buttonTextColor)
                    .padding(theme.buttonPadding)
                    .background(theme.buttonBackgroundColor)
                    .cornerRadius(theme.buttonCornerRadius)

                    // Button for Routines
                    NavigationLink(destination: RoutineListView()) {
                        Text("Routines")
                    }
                    .font(theme.secondaryFont)
                    .foregroundColor(theme.buttonTextColor)
                    .padding(theme.buttonPadding)
                    .background(theme.buttonBackgroundColor)
                    .cornerRadius(theme.buttonCornerRadius)

                    // Button for Saved Workouts
                    NavigationLink(destination: WorkoutListView()) {
                        Text("View Saved Workouts")
                    }
                    .font(theme.secondaryFont)
                    .foregroundColor(theme.buttonTextColor)
                    .padding(theme.buttonPadding)
                    .background(theme.buttonBackgroundColor)
                    .cornerRadius(theme.buttonCornerRadius)
                }
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.backgroundColor.edgesIgnoringSafeArea(.all))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    UnderlinedTitle(title: "Do One More")
                }
            }
            .onAppear {
                exercises = UserDefaultsManager.loadExercises()
                NotificationCenter.default.addObserver(forName: Notification.Name("ExerciseSelected"), object: nil, queue: .main) { notification in
                    if let exerciseName = notification.object as? String {
                        selectedExerciseType = exerciseName
                    }
                }

                if fromRoutine, let previousWorkout = findPreviousWorkout() {
                    setRecords = previousWorkout.sets
                } else {
                    setRecords = [SetRecord()]
                }
            }
        }
    }

    // Helper Function to Create Text Fields
    private func createTextField(for metric: ExerciseMetric, at index: Int) -> some View {
        switch metric {
        case .weight:
            return AnyView(
                TextField("Weight (lbs)", text: bindingForWeight(at: index))
                    .customFormFieldStyle()
                    .customPlaceholder(show: setRecords[index].weight == nil, placeholder: "Weight (lbs)")
                    .keyboardType(.numberPad)
            )
        case .reps:
            return AnyView(
                TextField("Reps", text: bindingForReps(at: index))
                    .customFormFieldStyle()
                    .customPlaceholder(show: setRecords[index].reps == nil, placeholder: "Reps")
                    .keyboardType(.numberPad)
            )
        case .time:
            return AnyView(
                TextField("Time (h:m:s)", text: bindingForElapsedTime(at: index))
                    .customFormFieldStyle()
                    .customPlaceholder(show: setRecords[index].elapsedTime == nil, placeholder: "Enter time")
            )
        case .distance:
            return AnyView(
                TextField("Enter distance (miles)", text: bindingForDistance(at: index))
                    .customFormFieldStyle()
                    .customPlaceholder(show: setRecords[index].distance == nil, placeholder: "Enter distance (miles)")
                    .keyboardType(.decimalPad)
            )
        case .calories:
            return AnyView(
                TextField("Enter calories burned", text: bindingForCalories(at: index))
                    .customFormFieldStyle()
                    .customPlaceholder(show: setRecords[index].calories == nil, placeholder: "Enter calories burned")
                    .keyboardType(.numberPad)
            )
        case .custom:
            return AnyView(
                TextField("Enter notes", text: bindingForCustomNotes(at: index))
                    .customFormFieldStyle()
                    .customPlaceholder(show: setRecords[index].custom == nil, placeholder: "Enter notes")
                    .keyboardType(.default)
            )
        }
    }

    // MARK: - Workout Management Functions

    func saveWorkout() {
        guard hasValidInput else {
            showAlert = true
            return
        }

        let filledSetRecords = setRecords.compactMap { record -> SetRecord? in
            // Since weight is already Int?, no need for isEmpty; use the value directly
            let weight = record.weight
            
            // Reps is already Int?, use it directly
            let reps = record.reps

            // Check if elapsedTime (String?) is empty or nil
            let elapsedTime = record.elapsedTime?.isEmpty == false ? record.elapsedTime : nil

            // Since distance is already Int?, no need for isEmpty; use the value directly
            let distance = record.distance
            
            // Calories and custom notes, handle empty values
            let calories = record.calories?.isEmpty == false ? record.calories : nil
            let custom = record.custom?.isEmpty == false ? record.custom : nil

            return SetRecord(
                weight: weight,
                reps: reps,
                elapsedTime: elapsedTime,
                distance: distance,
                calories: calories,
                custom: custom
            )
        }

        let workout = Workout(exerciseType: selectedExerciseType, sets: filledSetRecords)

        if let index = savedWorkouts.firstIndex(where: { $0.exerciseType == workout.exerciseType }) {
            savedWorkouts[index] = workout
        } else {
            savedWorkouts.append(workout)
        }

        if let encoded = try? JSONEncoder().encode(savedWorkouts) {
            UserDefaults.standard.set(encoded, forKey: "workouts")
        }

        showAlert = true
    }

    func clearInputFields() {
        setRecords = [SetRecord()]
        selectedExerciseType = ""
    }

    // MARK: - Persistence Functions

    func loadSavedWorkouts() {
        if let savedWorkoutsData = UserDefaults.standard.data(forKey: "workouts"),
           let decodedWorkouts = try? JSONDecoder().decode([Workout].self, from: savedWorkoutsData) {
            savedWorkouts = decodedWorkouts
        }
    }

    func findPreviousWorkout() -> Workout? {
        return savedWorkouts.filter { $0.exerciseType == selectedExerciseType }.last
    }
}

// Additional Persistence Functions

func loadRoutineExercises() -> [String] {
    if let savedRoutines = UserDefaults.standard.data(forKey: "routines"),
       let decodedRoutines = try? JSONDecoder().decode([Routine].self, from: savedRoutines) {
        return decodedRoutines.flatMap { $0.exercises }
    }
    return []
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(fromRoutine: false)
            .environment(\.theme, AppTheme()) // Inject the theme for a consistent preview
    }
}

// MARK: - Extracted Binding Functions

extension ContentView {
    private func bindingForWeight(at index: Int) -> Binding<String> {
        Binding(
            get: {
                if let weight = setRecords[index].weight {
                    return String(weight) // Convert Int? to String for display
                } else {
                    return "" // Return an empty string if weight is nil
                }
            },
            set: { newValue in
                if let weight = Int(newValue) { // Convert the String back to Int
                    setRecords[index].weight = weight
                } else {
                    setRecords[index].weight = nil // Set to nil if conversion fails
                }
            }
        )
    }

    private func bindingForReps(at index: Int) -> Binding<String> {
        Binding(
            get: { setRecords[index].reps.map { String($0) } ?? "" },
            set: { setRecords[index].reps = Int($0) ?? nil }
        )
    }

    private func bindingForElapsedTime(at index: Int) -> Binding<String> {
        Binding(
            get: { setRecords[index].elapsedTime ?? "" },
            set: { setRecords[index].elapsedTime = $0 }
        )
    }

    private func bindingForDistance(at index: Int) -> Binding<String> {
        Binding(
            get: {
                if let distance = setRecords[index].distance {
                    return String(distance) // Convert Double? to String for display
                } else {
                    return "" // Return an empty string if distance is nil
                }
            },
            set: { newValue in
                if let distance = Double(newValue) { // Convert String back to Double
                    setRecords[index].distance = distance
                } else {
                    setRecords[index].distance = nil // Set to nil if conversion fails
                }
            }
        )
    }

    private func bindingForCalories(at index: Int) -> Binding<String> {
        Binding(
            get: { setRecords[index].calories ?? "" },
            set: { setRecords[index].calories = $0 }
        )
    }

    private func bindingForCustomNotes(at index: Int) -> Binding<String> {
        Binding(
            get: { setRecords[index].custom ?? "" },
            set: { setRecords[index].custom = $0 }
        )
    }
}
