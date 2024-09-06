import Foundation

struct Exercise: Codable, Hashable, Identifiable {
    var id = UUID() // Ensure each exercise has a unique ID
    var name: String
    var selectedMetrics: [ExerciseMetric]

    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.selectedMetrics == rhs.selectedMetrics
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(selectedMetrics)
    }
}

enum ExerciseMetric: String, CaseIterable, Codable, Hashable, Identifiable {
    case weight = "Weight"
    case reps = "Reps"
    case time = "Time"
    case distance = "Distance"
    case calories = "Calories"
    case custom = "Custom Notes"

    var id: String { self.rawValue } // Identifiable conformance
}
