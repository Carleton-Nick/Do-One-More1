import Foundation

class UserDefaultsManager {
    
    // MARK: - Keys
    private enum Keys {
        case exercises
        case routines
        case workouts
        case exerciseRecords

        var rawValue: String {
            switch self {
            case .exercises: return "exercises"
            case .routines: return "routines"
            case .workouts: return "workouts"
            case .exerciseRecords: return "exerciseRecords"
            }
        }
    }
    
    // MARK: - Generic Helpers

    private static func save<T: Encodable>(_ value: T, forKey key: String) {
        if let encoded = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    private static func load<T: Decodable>(forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    // MARK: - Exercises

    static func saveExercises(_ exercises: [Exercise]) {
        save(exercises, forKey: Keys.exercises.rawValue)
    }

    static func loadExercises() -> [Exercise] {
        return load(forKey: Keys.exercises.rawValue) ?? []
    }

    static func loadOrCreateExercises() -> [Exercise] {
        let savedExercises = loadExercises()
        if savedExercises.isEmpty {
            saveExercises(PreloadedExercises.exercises)
            return PreloadedExercises.exercises
        }
        return savedExercises
    }

    // MARK: - Routines

    static func saveRoutines(_ routines: [Routine]) {
        save(routines, forKey: Keys.routines.rawValue)
    }

    static func loadRoutines() -> [Routine] {
        return load(forKey: Keys.routines.rawValue) ?? []
    }

    // MARK: - Workouts

    static func saveWorkouts(_ workouts: [Workout]) {
        save(workouts, forKey: Keys.workouts.rawValue)
    }

    static func loadWorkouts() -> [Workout] {
        return load(forKey: Keys.workouts.rawValue) ?? []
    }

    // MARK: - Exercise Records

    static func saveExerciseRecords(_ records: [ExerciseRecord]) {
        save(records, forKey: Keys.exerciseRecords.rawValue)
    }

    static func loadExerciseRecords() -> [ExerciseRecord] {
        return load(forKey: Keys.exerciseRecords.rawValue) ?? []
    }

    // MARK: - Reset Methods

    static func reset(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

    static func resetAll() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
    }

    static func clearRoutines() {
        UserDefaults.standard.removeObject(forKey: "routines")
    }

    static func updateExerciseNameInRoutines(oldName: String, newName: String) {
        var routines = loadRoutines()
        
        for i in 0..<routines.count {
            var updatedItems = routines[i].items
            for j in 0..<updatedItems.count {
                if case .exercise(let exercise) = updatedItems[j],
                   exercise.name == oldName {
                    updatedItems[j] = .exercise(Exercise(
                        name: newName,
                        selectedMetrics: exercise.selectedMetrics,
                        category: exercise.category
                    ))
                }
            }
            routines[i].items = updatedItems
        }
        
        saveRoutines(routines)
    }
}
