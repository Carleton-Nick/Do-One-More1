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

    var hasValidInput: Bool {
        let validExercise = !selectedExerciseType.isEmpty
        let validDetailsInput = setRecords.allSatisfy { record in
            record.weight?.isEmpty == false ||
            record.reps != nil ||
            record.elapsedTime?.isEmpty == false ||
            record.distance?.isEmpty == false ||
            record.calories?.isEmpty == false ||
            record.custom?.isEmpty == false
        }
        return validExercise && validDetailsInput
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Moved the form content to the top
                VStack {
                    // Exercise Picker Wheel with dynamic placeholder text
                    HStack {
                        Picker(selection: $selectedExerciseType, label: Text("")) {
                            if exercises.isEmpty {
                                Text("Create a new exercise first")
                                    .foregroundColor(.gray)
                            } else {
                                Text("Choose an exercise")
                                    .foregroundColor(.gray)
                                    .tag("")

                                ForEach(exercises.sorted(by: { $0.name < $1.name }).map { $0.name }, id: \.self) { exercise in
                                    Text(exercise)
                                        .foregroundColor(theme.primaryColor)
                                }
                            }
                        }
                        .padding(.leading, 5)
                        .onChange(of: selectedExerciseType) {
                            if exercises.contains(where: { $0.name == selectedExerciseType }) {
                                setRecords = [SetRecord()]
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(theme.primaryColor, lineWidth: 1))
                    }
                    .padding(.horizontal)

                    if let currentExercise = exercises.first(where: { $0.name == selectedExerciseType }) {
                        ForEach(Array(setRecords.enumerated()), id: \.offset) { index, _ in
                            let metrics = currentExercise.selectedMetrics
                            ForEach(0..<metrics.count, id: \.self) { metricIndex in
                                if metricIndex % 2 == 0 {
                                    HStack {
                                        createTextField(for: metrics[metricIndex], at: index)
                                            .frame(maxWidth: .infinity)

                                        if metricIndex + 1 < metrics.count {
                                            createTextField(for: metrics[metricIndex + 1], at: index)
                                                .frame(maxWidth: .infinity)
                                        } else {
                                            Spacer()
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
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
                    .padding(.top, 10) // Add padding above the buttons
                }
                .padding(.top, 20) // Adds space below the title and underline

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
                
                // Listen for exercise selection
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

    // MARK: - Helper Function to Create Text Fields
    private func createTextField(for metric: ExerciseMetric, at index: Int) -> some View {
        switch metric {
        case .weight:
            return AnyView(
                TextField("Enter weight (lbs)", text: bindingForWeight(at: index))
                    .customFormFieldStyle()
                    .customPlaceholder(show: setRecords[index].weight?.isEmpty ?? true, placeholder: "Enter weight (lbs)")
                    .keyboardType(.decimalPad)  // Numeric input with decimal for weight
            )
        case .reps:
            return AnyView(
                TextField("Enter reps", text: bindingForReps(at: index))
                    .customFormFieldStyle()
                    .customPlaceholder(show: setRecords[index].reps == nil, placeholder: "Enter reps")
                    .keyboardType(.numberPad)  // Numeric input for reps
            )
        case .time:
            return AnyView(
                TextField("Enter time (minutes)", text: bindingForElapsedTime(at: index))
                    .customFormFieldStyle()
                    .customPlaceholder(show: setRecords[index].elapsedTime?.isEmpty ?? true, placeholder: "Enter time (minutes)")
                    .keyboardType(.decimalPad)  // Numeric input with decimal for time
            )
        case .distance:
            return AnyView(
                TextField("Enter distance (miles)", text: bindingForDistance(at: index))
                    .customFormFieldStyle()
                    .customPlaceholder(show: setRecords[index].distance?.isEmpty ?? true, placeholder: "Enter distance (miles)")
                    .keyboardType(.decimalPad)  // Numeric input with decimal for distance
            )
        case .calories:
            return AnyView(
                TextField("Enter calories burned", text: bindingForCalories(at: index))
                    .customFormFieldStyle()
                    .customPlaceholder(show: setRecords[index].calories?.isEmpty ?? true, placeholder: "Enter calories burned")
                    .keyboardType(.numberPad)  // Numeric input for calories
            )
        case .custom:
            return AnyView(
                TextField("Enter notes", text: bindingForCustomNotes(at: index))
                    .customFormFieldStyle()
                    .customPlaceholder(show: setRecords[index].custom?.isEmpty ?? true, placeholder: "Enter notes")
                    .keyboardType(.default)  // Alphanumeric input for custom notes
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
            let weight = record.weight?.isEmpty ?? true ? nil : record.weight
            let reps = record.reps
            let elapsedTime = record.elapsedTime?.isEmpty ?? true ? nil : record.elapsedTime
            let distance = record.distance?.isEmpty ?? true ? nil : record.distance
            let calories = record.calories?.isEmpty ?? true ? nil : record.calories
            let custom = record.custom?.isEmpty ?? true ? nil : record.custom
            
            return SetRecord(weight: weight, reps: reps, elapsedTime: elapsedTime, distance: distance, calories: calories, custom: custom)
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
            get: { setRecords[index].weight ?? "" },
            set: { setRecords[index].weight = $0 }
        )
    }

    private func bindingForReps(at index: Int) -> Binding<String> {
        Binding(
            get: { setRecords[index].reps.map { String($0) } ?? "" },
            set: { setRecords[index].reps = Int($0) }
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
            get: { setRecords[index].distance ?? "" },
            set: { setRecords[index].distance = $0 }
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
