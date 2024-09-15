import Foundation

struct Exercise: Codable, Hashable, Identifiable {
    var id = UUID() // Unique ID for each exercise
    var name: String // Name of the exercise
    var selectedMetrics: [ExerciseMetric] // Metrics related to the exercise
    var creationDate: Date = Date() // Creation date, with a default of current date

    // Equatable conformance (this is automatically synthesized by the compiler now, so you don't need to manually implement it)
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.selectedMetrics == rhs.selectedMetrics &&
               lhs.creationDate == rhs.creationDate
    }

    // Hashable conformance (automatic in most cases, but this custom implementation works)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(selectedMetrics)
        hasher.combine(creationDate)
    }
}

enum ExerciseMetric: String, CaseIterable, Codable, Hashable, Identifiable {
    case weight = "Weight"
    case reps = "Reps"
    case time = "Time"
    case distance = "Distance"
    case calories = "Calories"
    case custom = "Custom Notes"

    var id: String { self.rawValue } // Conformance to Identifiable using rawValue as the ID
}
