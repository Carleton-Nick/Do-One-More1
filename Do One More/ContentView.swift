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
            ZStack {
                theme.backgroundColor.edgesIgnoringSafeArea(.all)

                VStack {
                    ScrollView {
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
                                .onChange(of: selectedExerciseType) { newValue in
                                    // Update set records when an exercise is selected
                                    if exercises.contains(where: { $0.name == newValue }) {
                                        setRecords = [SetRecord()]
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .overlay(RoundedRectangle(cornerRadius: 5).stroke(theme.primaryColor, lineWidth: 1))
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 3)

                            // Display set records based on selected exercise
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

                            // Display the most recent workout data (called after exercise selection)
                            if let recentWorkout = findMostRecentWorkout() {
                                VStack(alignment: .leading) {
                                    Text("Last \(recentWorkout.exerciseType) - \(formatTimestamp(recentWorkout.timestamp))")
                                        .font(theme.primaryFont)
                                        .padding(.top, 10)
                                        .foregroundColor(.orange)
                                    
                                    ForEach(recentWorkout.sets, id: \.self) { set in
                                        HStack {
                                            if let weight = set.weight {
                                                Text("Weight: \(weight) lbs")
                                                    .font(theme.secondaryFont)
                                                    .foregroundColor(.white)
                                            }
                                            if let reps = set.reps {
                                                Text("Reps: \(reps)")
                                                    .font(theme.secondaryFont)
                                                    .foregroundColor(.white)
                                            }
                                            if let time = set.elapsedTime {
                                                Text("Time: \(time)")
                                                    .font(theme.secondaryFont)
                                                    .foregroundColor(.white)
                                            }
                                            if let distance = set.distance {
                                                Text("Distance: \(distance) miles")
                                                    .font(theme.secondaryFont)
                                                    .foregroundColor(.white)
                                            }
                                            if let calories = set.calories {
                                                Text("Calories: \(calories)")
                                                    .font(theme.secondaryFont)
                                                    .foregroundColor(.white)
                                            }
                                            if let notes = set.custom {
                                                Text("Notes: \(notes)")
                                                    .font(theme.secondaryFont)
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .padding(.vertical, 5)
                                    }
                                }
                                .padding(.horizontal)
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

                            Spacer(minLength: 100) // Create some space between the content and the buttons
                        }
                        .padding(.top, 20)
                    }

                    // Bottom Buttons
                    HStack(spacing: 10) {
                        NavigationLink(destination: ExerciseListView(exercises: $exercises)) {
                            Text("Exercises")
                        }
                        .font(theme.secondaryFont)
                        .foregroundColor(theme.buttonTextColor)
                        .padding(theme.buttonPadding)
                        .background(theme.buttonBackgroundColor)
                        .cornerRadius(theme.buttonCornerRadius)

                        NavigationLink(destination: RoutineListView()) {
                            Text("Routines")
                        }
                        .font(theme.secondaryFont)
                        .foregroundColor(theme.buttonTextColor)
                        .padding(theme.buttonPadding)
                        .background(theme.buttonBackgroundColor)
                        .cornerRadius(theme.buttonCornerRadius)

                        NavigationLink(destination: WorkoutListView()) {
                            Text("Saved Workouts")
                        }
                        .font(theme.secondaryFont)
                        .foregroundColor(theme.buttonTextColor)
                        .padding(theme.buttonPadding)
                        .background(theme.buttonBackgroundColor)
                        .cornerRadius(theme.buttonCornerRadius)
                    }
                    .padding(.bottom, 20) // Add bottom padding for safe area
                    .padding(.top, 10) // Ensure space between buttons and content
                }
            }
            .background(theme.backgroundColor.edgesIgnoringSafeArea(.all))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    UnderlinedTitle(title: "Do One More")
                }
            }
            .onAppear {
                exercises = UserDefaultsManager.loadExercises()
                loadSavedWorkouts()

                // Set up notification for exercise selection
                NotificationCenter.default.addObserver(forName: Notification.Name("ExerciseSelected"), object: nil, queue: .main)
                { notification in
                    if let exerciseName = notification.object as? String {
                        selectedExerciseType = exerciseName
                    }
                }

                // Initialize input fields based on the selected exercise or routine
                if fromRoutine {
                    setRecords = [SetRecord()]
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
                    .customPlaceholder(show: setRecords[index].elapsedTime == nil, placeholder: "Elapsed Time")
                    .keyboardType(.default)
            )
        case .distance:
            return AnyView(
                TextField("Distance", text: bindingForDistance(at: index))
                    .customFormFieldStyle()
                    .customPlaceholder(show: setRecords[index].distance == nil, placeholder: "Distance")
                    .keyboardType(.default)
            )
        case .calories:
            return AnyView(
                TextField("Calories burned", text: bindingForCalories(at: index))
                    .customFormFieldStyle()
                    .customPlaceholder(show: setRecords[index].calories == nil, placeholder: "Calories burned")
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
            SetRecord(
                weight: record.weight,
                reps: record.reps,
                elapsedTime: record.elapsedTime,
                distance: record.distance,
                calories: record.calories,
                custom: record.custom
            )
        }

        // Create a new workout with the current timestamp
        let workout = Workout(exerciseType: selectedExerciseType, sets: filledSetRecords, timestamp: Date())

        // Append the new workout to the history
        savedWorkouts.append(workout)

        // Save the updated list of workouts to UserDefaults
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

    func findMostRecentWorkout() -> Workout? {
        return savedWorkouts.filter { $0.exerciseType == selectedExerciseType }.last
    }
}

func formatTimestamp(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"  // Customize this format as needed
    return formatter.string(from: date)
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
            get: { setRecords[index].reps ?? "" },
            set: { setRecords[index].reps = $0 }
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
