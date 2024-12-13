import SwiftUI

struct ContentView: View {
    @State var exercises: [Exercise] = []
    @State var exerciseRecords: [ExerciseRecord] = [ExerciseRecord()]
    @State var savedWorkouts: [Workout] = []
    @State private var showAlert = false
    @State private var showingNewExerciseView = false
    var fromRoutine: Bool = false
    @Environment(\.theme) var theme
    
    // Initializer
    init(exercises: [Exercise], exerciseRecords: [ExerciseRecord] = [ExerciseRecord()], fromRoutine: Bool = false) {
        self._exercises = State(initialValue: exercises)
        self._exerciseRecords = State(initialValue: exerciseRecords)
        self.fromRoutine = fromRoutine
    }
    
    // Check if all exercises have valid input
    var hasValidInput: Bool {
        return exerciseRecords.allSatisfy { record in
            !record.selectedExerciseType.isEmpty && record.setRecords.allSatisfy { set in
                set.weight != nil || set.reps != nil || set.elapsedTime != nil || set.distance != nil || set.calories != nil || set.custom != nil
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack {
                    ScrollView {
                        ForEach(Array($exerciseRecords.enumerated()), id: \.offset) { index, $exerciseRecord in
                            // This spacing affects vertical space between sets
                            VStack(spacing: 10) {
                                // Exercise Picker for each record
                                HStack {
                                    Menu {
                                        Picker(selection: $exerciseRecord.selectedExerciseType) {
                                            ForEach(exercises.sorted(by: { $0.name < $1.name }).map { $0.name }, id: \.self) { exercise in
                                                Text(exercise)
                                            }
                                        } label: {
                                            EmptyView()
                                        }
                                    } label: {
                                        Text(exerciseRecord.selectedExerciseType.isEmpty ? "Choose an exercise" : exerciseRecord.selectedExerciseType)
                                            .customPickerStyle()
                                        Image(systemName: "chevron.up.chevron.down")
                                            .customPickerStyle()
                                    }
                                    .padding(10)
                                    .frame(maxWidth: .infinity)
                                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(theme.primaryColor, lineWidth: 3))
                                    
                                    // Minus button to remove the exercise record (only visible if more than one record exists)
                                    if exerciseRecords.count > 1 {
                                        Button(action: {
                                            exerciseRecords.remove(at: index)
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.orange)
                                                .padding(.leading, 8)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                                
                                if let currentExercise = exercises.first(where: { $0.name == exerciseRecord.selectedExerciseType }) {
                                    ForEach(Array(exerciseRecord.setRecords.enumerated()), id: \.offset) { index, _ in
                                        VStack(spacing: 10) { // Adjust vertical spacing between sets
                                            
                                            // Input fields for the selected metrics with "X" button on the right
                                            HStack {
                                                ForEach(currentExercise.selectedMetrics, id: \.self) { metric in
                                                    createTextField(for: metric, at: index, in: $exerciseRecord.setRecords)
                                                        .frame(maxWidth: .infinity)
                                                }

                                                // Add "X" button for removing a set (only if more than one set exists)
                                                if exerciseRecord.setRecords.count > 1 {
                                                    Button(action: {
                                                        exerciseRecord.setRecords.remove(at: index)
                                                    }) {
                                                        Image(systemName: "xmark.circle")
                                                            .foregroundColor(.orange)
                                                            .padding(.leading, 8)
                                                    }
                                                }
                                            }
                                            .padding(.horizontal)

                                            // Additional rows for metrics that require specific groupings (if needed)
                                            if currentExercise.selectedMetrics.contains(.time) || currentExercise.selectedMetrics.contains(.distance) {
                                                HStack {
                                                    if currentExercise.selectedMetrics.contains(.time) {
                                                        createTextField(for: .time, at: index, in: $exerciseRecord.setRecords)
                                                            .frame(maxWidth: .infinity)
                                                    }
                                                    if currentExercise.selectedMetrics.contains(.distance) {
                                                        createTextField(for: .distance, at: index, in: $exerciseRecord.setRecords)
                                                            .frame(maxWidth: .infinity)
                                                    }
                                                }
                                                .padding(.horizontal)
                                            }

                                            if currentExercise.selectedMetrics.contains(.calories) || currentExercise.selectedMetrics.contains(.custom) {
                                                HStack {
                                                    if currentExercise.selectedMetrics.contains(.calories) {
                                                        createTextField(for: .calories, at: index, in: $exerciseRecord.setRecords)
                                                            .frame(maxWidth: .infinity)
                                                    }
                                                    if currentExercise.selectedMetrics.contains(.custom) {
                                                        createTextField(for: .custom, at: index, in: $exerciseRecord.setRecords)
                                                            .frame(maxWidth: .infinity)
                                                    }
                                                }
                                                .padding(.horizontal)
                                            }
                                        }
                                        .padding(.vertical, 0) // Adjust spacing between sets here
                                    }
                                }
                                
                                // Add Set Button for each exercise
                                if !exerciseRecord.selectedExerciseType.isEmpty {
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            exerciseRecord.setRecords.append(SetRecord())
                                        }) {
                                            Text("Add Set")
                                        }
                                        .font(theme.secondaryFont)
                                        .foregroundColor(theme.buttonTextColor)
                                        .padding(theme.buttonPadding)
                                        .background(theme.buttonBackgroundColor)
                                        .cornerRadius(theme.buttonCornerRadius)
                                        .padding(.trailing, UIScreen.main.bounds.width * 0.04) // Add 5% padding to the right
                                    }
                                }
                                
                                // Replace the "X" button with a toggle button
                                if let recentWorkout = findMostRecentWorkout(for: exerciseRecord.selectedExerciseType) {
                                    if exerciseRecord.showHistoricalData {
                                        VStack(alignment: .leading) {
                                            Text("Last \(recentWorkout.exerciseType) - \(formatTimestamp(recentWorkout.timestamp))")
                                                .font(theme.primaryFont)
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
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    
                                    // Show/Hide button
                                    Button(action: {
                                        exerciseRecord.showHistoricalData.toggle()
                                    }) {
                                        Text(exerciseRecord.showHistoricalData
                                             ? "Hide"
                                             : "Show Last \(recentWorkout.exerciseType)")
                                        .font(theme.secondaryFont)
                                        .foregroundColor(.orange)
                                        .padding(.top, 5)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                            .padding(.top, 10)
                            // .background(Color.green.opacity(0.2)) // Debug VStack Spacing
                            }
                        
                        // Save Workout and Add New Exercise Buttons in the same line
                        HStack {
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
                            
                            Spacer()
                            
                            Button(action: {
                                exerciseRecords.append(ExerciseRecord()) // Add new exercise record
                            }) {
                                Text("Track Another Exercise")
                            }
                            .font(theme.secondaryFont)
                            .foregroundColor(theme.buttonTextColor)
                            .padding(theme.buttonPadding)
                            .background(theme.buttonBackgroundColor)
                            .cornerRadius(theme.buttonCornerRadius)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal)
                    }
                    // Makes keyboard hide when you tap away from input field
                    .onTapGesture {
                        hideKeyboard()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // Add the title in the principal placement
                    ToolbarItem(placement: .principal) {
                        UnderlinedTitle(title: "Do One More")
                    }
                    
                    // Add the menu in the leading placement
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu {
                            NavigationLink(destination: ExerciseListView(exercises: $exercises)) {
                                Text("Exercises")
                            }
                            
                            NavigationLink(destination: RoutineListView()) {
                                Text("Routines")
                            }
                            
                            NavigationLink(destination: WorkoutListView()) {
                                Text("View Past Workouts")
                            }
                        } label: {
                            Label("Menu", systemImage: "line.3.horizontal")
                                .foregroundColor(theme.buttonTextColor)
                        }
                    }
                }
                .onAppear {
                    exercises = UserDefaultsManager.loadOrCreateExercises() // Load exercises or use preloaded ones
                    loadSavedWorkouts()
                }
                .preferredColorScheme(.dark) // Force dark mode for the menu
            }
        }
    }
    // Helper function to hide keyboard when user taps away from input field
        func hideKeyboard() {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    // Helper Function to Create Text Fields for a specific metric
    private func createTextField(for metric: ExerciseMetric, at index: Int, in records: Binding<[SetRecord]>) -> some View {
        switch metric {
        case .weight:
            return AnyView(
                TextField("Weight (lbs)", text: bindingForWeight(at: index, in: records))
                    .customFormFieldStyle()
                    .customPlaceholder(
                        show: records[index].weight.wrappedValue == nil || records[index].weight.wrappedValue!.isEmpty,
                        placeholder: "Weight (lbs)",
                        placeholderColor: .gray // Optional: Adjust placeholder color
                    )
                    .keyboardType(.numberPad)
            )
        case .reps:
            return AnyView(
                TextField("Reps", text: bindingForReps(at: index, in: records))
                    .customFormFieldStyle()
                    .customPlaceholder(
                        show: records[index].reps.wrappedValue == nil ||
                        records[index].reps.wrappedValue!.isEmpty,
                        placeholder: "Reps",
                        placeholderColor: .gray // Optional: Adjust placeholder color
                        )
                    .keyboardType(.numberPad)
            )
        case .time:
            return AnyView(
                TextField("Time (h:m:s)", text: bindingForElapsedTime(at: index, in: records))
                    .customFormFieldStyle()
                    .customPlaceholder(
                        show: records[index].elapsedTime.wrappedValue == nil ||
                        records[index].elapsedTime.wrappedValue!.isEmpty,
                        placeholder: "Elapsed Time",
                        placeholderColor: .gray // Optional: Adjust placeholder color
                        )
                    .keyboardType(.default)
            )
        case .distance:
            return AnyView(
                TextField("Distance (miles)", text: bindingForDistance(at: index, in: records))
                    .customFormFieldStyle()
                    .customPlaceholder(
                        show: records[index].distance.wrappedValue == nil ||
                        records[index].distance.wrappedValue!.isEmpty,
                        placeholder: "Distance",
                        placeholderColor: .gray // Optional: Adjust placeholder color
                        )
                    .keyboardType(.default)
            )
        case .calories:
            return AnyView(
                TextField("Calories burned", text: bindingForCalories(at: index, in: records))
                    .customFormFieldStyle()
                    .customPlaceholder(
                        show: records[index].calories.wrappedValue == nil ||
                        records[index].calories.wrappedValue!.isEmpty,
                        placeholder: "Calories burned",
                        placeholderColor: .gray // Optional: Adjust placeholder color
                        )
                    .keyboardType(.numberPad)
            )
        case .custom:
            return AnyView(
                TextField("Enter notes", text: bindingForCustomNotes(at: index, in: records))
                    .customFormFieldStyle()
                    .customPlaceholder(
                        show: records[index].custom.wrappedValue == nil ||
                        records[index].custom.wrappedValue!.isEmpty,
                        placeholder: "Enter notes",
                        placeholderColor: .gray // Optional: Adjust placeholder color
                        )
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
        
        // Create a workout for each exercise
        let workouts = exerciseRecords.map { record -> Workout in
            let filledSetRecords = record.setRecords.compactMap { setRecord -> SetRecord? in
                SetRecord(
                    weight: setRecord.weight,
                    reps: setRecord.reps,
                    elapsedTime: setRecord.elapsedTime,
                    distance: setRecord.distance,
                    calories: setRecord.calories,
                    custom: setRecord.custom
                )
            }
            return Workout(
                exerciseType: record.selectedExerciseType,
                sets: filledSetRecords,
                timestamp: Date()
            )
        }
        
        // Append the new workouts to savedWorkouts
        savedWorkouts.append(contentsOf: workouts)
        
        // Save the updated list of workouts to UserDefaults
        if let encoded = try? JSONEncoder().encode(savedWorkouts) {
            UserDefaults.standard.set(encoded, forKey: "workouts")
        }
        
        showAlert = true
    }
    
    func clearInputFields() {
        exerciseRecords = [ExerciseRecord()]
    }
    
    // MARK: - Persistence Functions
    
    func loadSavedWorkouts() {
        if let savedWorkoutsData = UserDefaults.standard.data(forKey: "workouts"),
           let decodedWorkouts = try? JSONDecoder().decode([Workout].self, from: savedWorkoutsData) {
            savedWorkouts = decodedWorkouts
        }
    }
    
    // MARK: - Extracted Binding Functions for SetRecord
    
    private func bindingForWeight(at index: Int, in records: Binding<[SetRecord]>) -> Binding<String> {
        Binding(
            get: { records[index].weight.wrappedValue ?? "" },
            set: { records[index].weight.wrappedValue = $0 }
        )
    }
    
    private func bindingForReps(at index: Int, in records: Binding<[SetRecord]>) -> Binding<String> {
        Binding(
            get: { records[index].reps.wrappedValue ?? "" },
            set: { records[index].reps.wrappedValue = $0 }
        )
    }
    
    private func bindingForElapsedTime(at index: Int, in records: Binding<[SetRecord]>) -> Binding<String> {
        Binding(
            get: { records[index].elapsedTime.wrappedValue ?? "" },
            set: { records[index].elapsedTime.wrappedValue = $0 }
        )
    }
    
    private func bindingForDistance(at index: Int, in records: Binding<[SetRecord]>) -> Binding<String> {
        Binding(
            get: { records[index].distance.wrappedValue ?? "" },
            set: { records[index].distance.wrappedValue = $0 }
        )
    }
    
    private func bindingForCalories(at index: Int, in records: Binding<[SetRecord]>) -> Binding<String> {
        Binding(
            get: { records[index].calories.wrappedValue ?? "" },
            set: { records[index].calories.wrappedValue = $0 }
        )
    }
    
    private func bindingForCustomNotes(at index: Int, in records: Binding<[SetRecord]>) -> Binding<String> {
        Binding(
            get: { records[index].custom.wrappedValue ?? "" },
            set: { records[index].custom.wrappedValue = $0 }
        )
    }
    
    // MARK: - Helper for Finding Most Recent Workout
    
    func findMostRecentWorkout(for exerciseType: String) -> Workout? {
        return savedWorkouts.filter { $0.exerciseType == exerciseType }.last
    }
}

// Helper to format the timestamp
func formatTimestamp(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}
