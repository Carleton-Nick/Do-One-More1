import Foundation

class UserDefaultsManager {
    
    // MARK: - Keys
    private enum Keys {
        static let exercises = "exercises"
        static let routines = "routines"
        static let workouts = "workouts"
    }
    
    // MARK: - Exercises

    static func saveExercises(_ exercises: [Exercise]) {
        if let encoded = try? JSONEncoder().encode(exercises) {
            UserDefaults.standard.set(encoded, forKey: Keys.exercises)
        }
    }

    static func loadExercises() -> [Exercise] {
        if let data = UserDefaults.standard.data(forKey: Keys.exercises),
           let decoded = try? JSONDecoder().decode([Exercise].self, from: data) {
            return decoded
        }
        return []
    }

    static func loadOrCreateExercises() -> [Exercise] {
        let savedExercises = loadExercises()
        if savedExercises.isEmpty {
            saveExercises(PreloadedExercises.exercises) // Save pre-loaded exercises if none exist
            return PreloadedExercises.exercises
        }
        return savedExercises
    }
    
    // MARK: - Routines

    static func saveRoutines(_ routines: [Routine]) {
        if let encoded = try? JSONEncoder().encode(routines) {
            UserDefaults.standard.set(encoded, forKey: Keys.routines)
        }
    }

    static func loadRoutines() -> [Routine] {
        if let data = UserDefaults.standard.data(forKey: Keys.routines),
           let decoded = try? JSONDecoder().decode([Routine].self, from: data) {
            return decoded
        }
        return []
    }
    
    // MARK: - Workouts

    static func saveWorkouts(_ workouts: [Workout]) {
        if let encoded = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(encoded, forKey: Keys.workouts)
        }
    }

    static func loadWorkouts() -> [Workout] {
        if let data = UserDefaults.standard.data(forKey: Keys.workouts),
           let decoded = try? JSONDecoder().decode([Workout].self, from: data) {
            return decoded
        }
        return []
    }
}
