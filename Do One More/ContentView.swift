//
//  ContentView.swift
//  Do One More
//
//  Created by Nick Carleton on 6/26/24.
//

import SwiftUI

struct ContentView: View {
    @State var selectedExerciseType: String
    @State var exerciseType = ""
    @State var setRecords: [SetRecord] = [SetRecord(weight: nil, reps: nil)]
    @State var savedWorkouts: [Workout] = []
    @State var exerciseTypes: [String] = []
    @State private var showAlert = false
    var fromRoutine: Bool
    @Environment(\.theme) var theme

    init(selectedExerciseType: String = "", fromRoutine: Bool = false) {
        _selectedExerciseType = State(initialValue: selectedExerciseType)
        self.fromRoutine = fromRoutine
    }

    var body: some View {
        NavigationView {
            VStack {
                Spacer(minLength: 0)
                VStack(spacing: 20) {
                    // Section: Choose or Create Exercise
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Choose or Create Exercise")
                            .customSectionHeaderStyle()

                        HStack {
                            Picker(selection: $selectedExerciseType, label: Text("")) {
                                Text("New").tag("New") // Add the "New" option
                                ForEach(exerciseTypes, id: \.self) { exercise in
                                    Text(exercise)
                                        .foregroundColor(theme.primaryColor)
                                }
                            }
                            .padding(.leading, 5)
                            .onChange(of: selectedExerciseType) { oldValue, newValue in
                                if newValue == "New" {
                                    exerciseType = ""
                                    setRecords = [SetRecord(weight: nil, reps: nil)]
                                } else {
                                    exerciseType = newValue
                                    if findPreviousWorkout() == nil {
                                        setRecords = [SetRecord(weight: nil, reps: nil)]
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(theme.primaryColor, lineWidth: 1))
                        }

                        // Always show the text field when "New" is selected
                        if selectedExerciseType == "New" {
                            TextField("", text: $exerciseType)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(theme.backgroundColor)
                                .cornerRadius(5)
                                .overlay(RoundedRectangle(cornerRadius: 5).stroke(theme.primaryColor, lineWidth: 1))
                                .customPlaceholder(show: exerciseType.isEmpty, placeholder: "New Exercise Name")
                        }
                    }

                    // Section: Exercise Details
                    if selectedExerciseType == "New" || !exerciseType.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Exercise Details")
                                .customSectionHeaderStyle()

                            ForEach(Array(setRecords.enumerated()), id: \.offset) { index, _ in
                                HStack {
                                    TextField("", text: Binding(
                                        get: {
                                            if index < setRecords.count {
                                                return setRecords[index].weight ?? ""
                                            } else {
                                                return ""
                                            }
                                        },
                                        set: {
                                            if index < setRecords.count {
                                                setRecords[index].weight = $0
                                            }
                                        }
                                    ))
                                    .foregroundColor(.white)
                                    .keyboardType(.decimalPad)
                                    .padding(8)
                                    .background(theme.backgroundColor)
                                    .cornerRadius(5)
                                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(theme.primaryColor, lineWidth: 1))
                                    .customPlaceholder(show: setRecords[index].weight?.isEmpty ?? true, placeholder: "Weight (lbs)")

                                    TextField("", text: Binding(
                                        get: {
                                            if index < setRecords.count {
                                                return setRecords[index].reps.map { String($0) } ?? ""
                                            } else {
                                                return ""
                                            }
                                        },
                                        set: {
                                            if index < setRecords.count {
                                                setRecords[index].reps = Int($0)
                                            }
                                        }
                                    ))
                                    .foregroundColor(.white)
                                    .keyboardType(.numberPad)
                                    .padding(8)
                                    .background(theme.backgroundColor)
                                    .cornerRadius(5)
                                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(theme.primaryColor, lineWidth: 1))
                                    .customPlaceholder(show: setRecords[index].reps == nil, placeholder: "Reps")
                                }
                            }

                            // Place both buttons in an HStack
                            HStack {
                                Button(action: {
                                    setRecords.append(SetRecord(weight: nil, reps: nil))
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
                                    Text("Save Set")
                                }
                                .font(theme.secondaryFont)
                                .foregroundColor(theme.buttonTextColor)
                                .padding(theme.buttonPadding)
                                .background(theme.buttonBackgroundColor)
                                .cornerRadius(theme.buttonCornerRadius)
                                .alert(isPresented: $showAlert) {
                                    Alert(title: Text("Set Saved"), message: nil, dismissButton: .default(Text("OK")))
                                }
                            }
                        }
                    }

                    // Section: Previous Workout
                    if let previousWorkout = findPreviousWorkout() {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Previous Workout")
                                .customSectionHeaderStyle()

                            ForEach(previousWorkout.sets, id: \.self) { set in
                                let displayWeight = set.weight?.isEmpty ?? true ? "bodyweight" : set.weight!
                                Text("Weight: \(displayWeight), Reps: \(set.reps ?? 0)")
                                    .foregroundColor(theme.primaryColor)
                                    .padding(8)
                                    .background(theme.backgroundColor)
                                    .cornerRadius(5)
                                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(theme.primaryColor, lineWidth: 1))
                            }
                        }
                    }
                }
                .padding(20)
                .background(theme.backgroundColor)
                .cornerRadius(10)
                Spacer(minLength: 0)

                // Navigation Links
                NavigationLink(destination: RoutineListView()) {
                    Text("Manage Routines")
                }
                .font(theme.secondaryFont)
                .foregroundColor(theme.buttonTextColor)
                .padding(theme.buttonPadding)
                .background(theme.buttonBackgroundColor)
                .cornerRadius(theme.buttonCornerRadius)

                NavigationLink(destination: WorkoutListView()) {
                    Text("View Saved Workouts")
                }
                .font(theme.secondaryFont)
                .foregroundColor(theme.buttonTextColor)
                .padding(theme.buttonPadding)
                .background(theme.buttonBackgroundColor)
                .cornerRadius(theme.buttonCornerRadius)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.backgroundColor.edgesIgnoringSafeArea(.all))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    UnderlinedTitle(title: "Do One More")
                }
            }
            .onAppear(perform: loadSavedWorkouts)
        }
        .onAppear {
            if fromRoutine {
                exerciseType = selectedExerciseType
                if let previousWorkout = findPreviousWorkout() {
                    setRecords = previousWorkout.sets
                } else {
                    setRecords = [SetRecord(weight: nil, reps: nil)]
                }
            }
        }
    }

    // MARK: - Workout Management Functions

    func saveWorkout() {
        guard !exerciseType.isEmpty else { return }

        let filledSetRecords = setRecords.compactMap { record -> SetRecord? in
            let weight = record.weight?.isEmpty ?? true ? "bodyweight" : record.weight
            if let reps = record.reps {
                return SetRecord(weight: weight, reps: reps)
            }
            return nil
        }

        let workout = Workout(exerciseType: exerciseType, sets: filledSetRecords)

        if let index = savedWorkouts.firstIndex(where: { $0.exerciseType == workout.exerciseType }) {
            savedWorkouts[index] = workout
        } else {
            savedWorkouts.append(workout)
            exerciseTypes.append(workout.exerciseType)
        }

        saveExerciseTypes()

        if let encoded = try? JSONEncoder().encode(savedWorkouts) {
            UserDefaults.standard.set(encoded, forKey: "workouts")
        }

        showAlert = true
        clearInputFields()
    }

    func clearInputFields() {
        exerciseType = ""
        setRecords = [SetRecord(weight: nil, reps: nil)]
    }

    func loadSavedWorkouts() {
        savedWorkouts = loadWorkouts()
        let routineExercises = loadRoutineExercises()
        exerciseTypes = Array(Set(savedWorkouts.map { $0.exerciseType } + routineExercises)).sorted()
    }

    func findPreviousWorkout() -> Workout? {
        return savedWorkouts.filter { $0.exerciseType == selectedExerciseType }.last
    }

    func loadWorkouts() -> [Workout] {
        if let savedWorkouts = UserDefaults.standard.data(forKey: "workouts"),
           let decodedWorkouts = try? JSONDecoder().decode([Workout].self, from: savedWorkouts) {
            return decodedWorkouts
        }
        return []
    }

    func loadRoutineExercises() -> [String] {
        if let savedRoutines = UserDefaults.standard.data(forKey: "routines"),
           let decodedRoutines = try? JSONDecoder().decode([Routine].self, from: savedRoutines) {
                       return decodedRoutines.flatMap { $0.exercises }
                   }
                   return []
               }

               func saveExerciseTypes() {
                   let uniqueExerciseTypes = Array(Set(savedWorkouts.map { $0.exerciseType }))
                   if let encoded = try? JSONEncoder().encode(uniqueExerciseTypes) {
                       UserDefaults.standard.set(encoded, forKey: "exerciseTypes")
                   }
               }

               func loadExerciseTypes() {
                   if let savedExerciseTypes = UserDefaults.standard.data(forKey: "exerciseTypes"),
                      let decodedExerciseTypes = try? JSONDecoder().decode([String].self, from: savedExerciseTypes) {
                       exerciseTypes = decodedExerciseTypes
                   }
               }
           }
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(selectedExerciseType: "", fromRoutine: false)
            .environment(\.theme, AppTheme()) // Inject the theme for a consistent preview
    }
}
