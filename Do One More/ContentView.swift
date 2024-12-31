import SwiftUI

struct ContentView: View {
    @State var exercises: [Exercise] = []
    @State var exerciseRecords: [ExerciseRecord]
    @State var savedWorkouts: [Workout] = []
    @State private var showAlert = false
    @State private var showingNewExerciseView = false
    var fromRoutine: Bool = false
    var clearExistingRecords: Bool = false
    @Environment(\.theme) var theme
    @EnvironmentObject private var quoteManager: QuoteManager

    var hasValidInput: Bool {
        for record in exerciseRecords {
            if record.selectedExerciseType.isEmpty {
                return false
            }
            for set in record.setRecords {
                if !set.weight.isNilOrEmpty && !set.reps.isNilOrEmpty {
                    return true
                }
                if !set.elapsedTime.isNilOrEmpty {
                    return true
                }
                if !set.distance.isNilOrEmpty {
                    return true
                }
                if !set.calories.isNilOrEmpty {
                    return true
                }
                if !set.custom.isNilOrEmpty {
                    return true
                }
            }
        }
        return false
    }

    init(exercises: [Exercise], exerciseRecords: [ExerciseRecord] = [ExerciseRecord()], fromRoutine: Bool = false, clearExistingRecords: Bool = false) {
        self._exercises = State(initialValue: exercises)
        self._exerciseRecords = State(initialValue: exerciseRecords)
        self.fromRoutine = fromRoutine
        self.clearExistingRecords = clearExistingRecords
    }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.edgesIgnoringSafeArea(.all)
                VStack {
                    VStack {
                        exerciseRecordsList() // List of Exercise Records
                    }
                    
                    Spacer() // This pushes everything below down
                    
                    SaveAndAddButtons(
                        exerciseRecords: $exerciseRecords,
                        hasValidInput: hasValidInput,
                        saveWorkoutAction: saveWorkout,
                        showAlert: $showAlert,
                        theme: theme
                    )
                }
                .onTapGesture { hideKeyboard() }
                .onChange(of: exerciseRecords) { oldRecords, newRecords in
                    UserDefaultsManager.saveExerciseRecords(newRecords)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbarItems()
                }
                .onAppear {
                    quoteManager.showMotivationalQuote()
                    savedWorkouts = UserDefaultsManager.loadWorkouts()
                    if fromRoutine {
                        // Load existing records and append the new one
                        var currentRecords = UserDefaultsManager.loadExerciseRecords()
                        if currentRecords.isEmpty || (currentRecords.count == 1 && currentRecords[0].selectedExerciseType.isEmpty) {
                            currentRecords = exerciseRecords
                        } else {
                            // Only append if the exercise isn't already in the records
                            let newExercise = exerciseRecords[0].selectedExerciseType
                            if !currentRecords.contains(where: { $0.selectedExerciseType == newExercise }) {
                                currentRecords.append(contentsOf: exerciseRecords)
                            }
                        }
                        exerciseRecords = currentRecords
                        UserDefaultsManager.saveExerciseRecords(currentRecords)
                    }
                    if clearExistingRecords {
                        // Clear any saved records when coming from routine
                        UserDefaultsManager.saveExerciseRecords(exerciseRecords)
                    }
                }
            }
        }
        .onDisappear {
            if !fromRoutine {
                // Clear the saved records when leaving the main view (not from routine)
                UserDefaultsManager.saveExerciseRecords([ExerciseRecord()])
            }
        }
    }
    
    private func exerciseRecordsList() -> some View {
        ScrollView {
            VStack(spacing: 20) { // Add some spacing between records
                ForEach(Array($exerciseRecords.enumerated()), id: \.offset) { index, $exerciseRecord in
                    ExerciseRecordView(
                        exerciseRecord: $exerciseRecord,
                        exercises: exercises,
                        exerciseRecords: $exerciseRecords,
                        index: index,
                        theme: theme,
                        createTextField: createTextField,
                        findMostRecentWorkout: findMostRecentWorkout(for:)
                    )
                    .padding(.top, 10) // Add padding to the top of each exercise record
                }
                
                if quoteManager.showQuote {
                    MotivationalQuoteView(quote: quoteManager.currentQuote ?? "")
                        .padding(.vertical)
                }
            }
            .padding(.bottom, 20) // Add some padding at the bottom of the scroll view
        }
    }
    
    private func toolbarItems() -> some ToolbarContent {
        Group {
            ToolbarItem(placement: .principal) {
                UnderlinedTitle(title: "Do One More")
            }
            ToolbarItem(placement: .navigationBarLeading) {
                MenuView(exercises: $exercises, theme: theme)
            }
        }
    }
    
    struct ExerciseRecordView: View {
        @Binding var exerciseRecord: ExerciseRecord
        var exercises: [Exercise]
        @Binding var exerciseRecords: [ExerciseRecord]
        var index: Int
        var theme: AppTheme
        var createTextField: (ExerciseMetric, Int, Binding<[SetRecord]>) -> AnyView
        var findMostRecentWorkout: (String) -> Workout? // Accept the function as a parameter

        var body: some View {
            VStack(spacing: 10) {
                // Picker for selecting an exercise
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

                    // Remove button if more than one exercise record exists
                    if exerciseRecords.count > 1 {
                        Button(action: { exerciseRecords.remove(at: index) }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.orange)
                                .padding(.leading, 8)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .padding(.horizontal)

                // Input fields for metrics
                if let currentExercise = exercises.first(where: { $0.name == exerciseRecord.selectedExerciseType }) {
                    ForEach(Array(exerciseRecord.setRecords.enumerated()), id: \.offset) { setIndex, _ in
                        VStack(spacing: 10) {
                            ForEach(Array(stride(from: 0, to: currentExercise.selectedMetrics.count, by: 2)), id: \.self) { chunkStartIndex in
                                HStack {
                                    ForEach(currentExercise.selectedMetrics[chunkStartIndex..<min(chunkStartIndex + 2, currentExercise.selectedMetrics.count)], id: \.self) { metric in
                                        createTextField(metric, setIndex, $exerciseRecord.setRecords)
                                            .frame(maxWidth: .infinity)
                                    }
                                    if chunkStartIndex == 0 && exerciseRecord.setRecords.count > 1 {
                                        Button(action: { exerciseRecord.setRecords.remove(at: setIndex) }) {
                                            Image(systemName: "xmark.circle")
                                                .foregroundColor(.orange)
                                        }
                                        .padding(.leading, 8)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 0)
                    }
                }

                // Add Set Button and Historical Data for each exercise
                if !exerciseRecord.selectedExerciseType.isEmpty {
                    HStack {
                        // Historical Data Section
                        if let recentWorkout = findMostRecentWorkout(exerciseRecord.selectedExerciseType) {
                            VStack(alignment: .leading) {
                                Button(action: {
                                    exerciseRecord.showHistoricalData.toggle()
                                }) {
                                    Text(exerciseRecord.showHistoricalData ? "Hide Last" : "Show Last")
                                        .font(theme.secondaryFont)
                                        .foregroundColor(.orange)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                
                                if exerciseRecord.showHistoricalData {
                                    Text("\(recentWorkout.exerciseType) - \(formatTimestamp(recentWorkout.timestamp))")
                                        .font(theme.historicalTitleFont)
                                        .foregroundColor(.orange)
                                    
                                    ForEach(recentWorkout.sets, id: \.self) { set in
                                        HStack(alignment: .top, spacing: 8) {
                                            if let weight = set.weight {
                                                Text("Weight: \(weight)lbs")
                                                    .font(theme.historicalDataFont)
                                                    .foregroundColor(.white)
                                            }
                                            if let reps = set.reps {
                                                Text("Reps: \(reps)")
                                                    .font(theme.historicalDataFont)
                                                    .foregroundColor(.white)
                                            }
                                            if let time = set.elapsedTime {
                                                Text("Time: \(time)")
                                                    .font(theme.historicalDataFont)
                                                    .foregroundColor(.white)
                                            }
                                            if let distance = set.distance {
                                                Text("Distance: \(distance)mi")
                                                    .font(theme.historicalDataFont)
                                                    .foregroundColor(.white)
                                            }
                                            if let calories = set.calories {
                                                Text("Cal: \(calories)")
                                                    .font(theme.historicalDataFont)
                                                    .foregroundColor(.white)
                                            }
                                            if let notes = set.custom {
                                                Text("Notes: \(notes)")
                                                    .font(theme.historicalDataFont)
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, UIScreen.main.bounds.width * 0.04)
                        }
                        
                        Spacer()
                        
                        // Add Set Button
                        Button(action: {
                            exerciseRecord.setRecords.append(SetRecord())
                        }) {
                            Text("Add Set")
                                .font(theme.secondaryFont)
                                .foregroundColor(theme.buttonTextColor)
                                .padding(theme.buttonPadding)
                                .background(theme.buttonBackgroundColor)
                                .cornerRadius(theme.buttonCornerRadius)
                        }
                        .padding(.trailing, UIScreen.main.bounds.width * 0.04)
                    }
                    .padding(.bottom, 8)
                }
            }
        }
    }

    struct SaveAndAddButtons: View {
        @Binding var exerciseRecords: [ExerciseRecord]
        var hasValidInput: Bool
        var saveWorkoutAction: () -> Void
        @Binding var showAlert: Bool // Add showAlert as a binding
        var theme: AppTheme

        var body: some View {
            HStack {
                Button(action: {
                    if hasValidInput {
                        saveWorkoutAction()
                        showAlert = true // Show the alert when saving is successful
                    } else {
                        showAlert = true // Trigger the alert when input is invalid
                    }
                }) {
                    Text("Save Workout")
                        .foregroundColor(hasValidInput ? theme.buttonTextColor : .gray)
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

                Button(action: { exerciseRecords.append(ExerciseRecord()) }) {
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

        private func clearInputFields() {
            exerciseRecords = [ExerciseRecord()]
        }
    }

struct MenuView: View {
    @Binding var exercises: [Exercise]
    var theme: AppTheme

    var body: some View {
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
                .preferredColorScheme(.dark) // Force dark mode for the menu
        }
    }
}

    // Helper function to hide keyboard when user taps away from input field
        func hideKeyboard() {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    // Helper Function to Create Text Fields for a specific metric
    private func createTextField(for metric: ExerciseMetric, at index: Int, in records: Binding<[SetRecord]>) -> AnyView {
        switch metric {
        case .weight:
            return AnyView(
                TextField("Weight (lbs)", text: bindingForWeight(at: index, in: records))
                    .customFormFieldStyle()
                    .customPlaceholder(
                        show: records[index].weight.wrappedValue?.isEmpty ?? true,
                        placeholder: "Weight (lbs)"
                    )
                    .keyboardType(.numberPad)
            )
        case .reps:
            return AnyView(
                TextField("Reps", text: bindingForReps(at: index, in: records))
                    .customFormFieldStyle()
                    .customPlaceholder(
                        show: records[index].reps.wrappedValue?.isEmpty ?? true,
                        placeholder: "Reps"
                    )
                    .keyboardType(.numberPad)
            )
        case .time:
            return AnyView(
                TextField("Time (h:m:s)", text: bindingForElapsedTime(at: index, in: records))
                    .customFormFieldStyle()
                    .customPlaceholder(
                        show: records[index].elapsedTime.wrappedValue?.isEmpty ?? true,
                        placeholder: "Time"
                    )
                    .keyboardType(.default)
            )
        case .distance:
            return AnyView(
                TextField("Distance (miles)", text: bindingForDistance(at: index, in: records))
                    .customFormFieldStyle()
                    .customPlaceholder(
                        show: records[index].distance.wrappedValue?.isEmpty ?? true,
                        placeholder: "Distance"
                    )
                    .keyboardType(.default)
            )
        case .calories:
            return AnyView(
                TextField("Calories", text: bindingForCalories(at: index, in: records))
                    .customFormFieldStyle()
                    .customPlaceholder(
                        show: records[index].calories.wrappedValue?.isEmpty ?? true,
                        placeholder: "Calories"
                    )
                    .keyboardType(.numberPad)
            )
        case .custom:
            return AnyView(
                TextField("Notes", text: bindingForCustomNotes(at: index, in: records))
                    .customFormFieldStyle()
                    .customPlaceholder(
                        show: records[index].custom.wrappedValue?.isEmpty ?? true,
                        placeholder: "Notes"
                    )
                    .keyboardType(.default)
            )
        }
    }
    
    // MARK: - Workout Management Functions
    
    func saveWorkout() {
        let workout = createWorkout()
        var existingWorkouts = UserDefaultsManager.loadWorkouts()
        existingWorkouts.append(workout)
        UserDefaultsManager.saveWorkouts(existingWorkouts)
        
        // Update local savedWorkouts array
        savedWorkouts = existingWorkouts
        
        // Reset exercise records after saving
        exerciseRecords = [ExerciseRecord()]
        UserDefaultsManager.saveExerciseRecords(exerciseRecords)
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

    func createWorkout() -> Workout {
        let workout = Workout(
            exerciseType: "",
            sets: [],
            timestamp: Date()
        )
        
        // Create an array to store all sets from all exercise records
        var allSets: [(type: String, set: SetRecord)] = []
        
        // Gather all sets from all exercise records
        for record in exerciseRecords {
            for set in record.setRecords {
                // Only add sets that have some data
                if !set.isEmpty {
                    allSets.append((type: record.selectedExerciseType, set: set))
                }
            }
        }
        
        // If we have any sets, create the workout with the first exercise type
        if let firstSet = allSets.first {
            return Workout(
                exerciseType: firstSet.type,
                sets: allSets.filter { $0.type == firstSet.type }.map { $0.set },
                timestamp: Date()
            )
        }
        
        return workout
    }
}

// Helper to format the timestamp
func formatTimestamp(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview with sample data
        ContentView(
            exercises: [
                Exercise(name: "Bench Press", selectedMetrics: [.weight, .reps], category: .chest),
                Exercise(name: "Squats", selectedMetrics: [.weight, .reps], category: .legs)
            ],
            exerciseRecords: [
                ExerciseRecord(
                    selectedExerciseType: "Bench Press",
                    setRecords: [
                        SetRecord(weight: "135", reps: "10"),
                        SetRecord(weight: "155", reps: "8")
                    ]
                )
            ]
        )
        .environment(\.theme, AppTheme())
        .environmentObject(QuoteManager())
    }
}

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }
}
