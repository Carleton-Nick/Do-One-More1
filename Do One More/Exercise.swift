import Foundation

struct Exercise: Codable, Identifiable, Equatable, Hashable {
    var id = UUID()
    var name: String
    var selectedMetrics: [ExerciseMetric]
    var category: ExerciseCategory
    
    init(name: String, selectedMetrics: [ExerciseMetric], category: ExerciseCategory) {
        self.name = name
        self.selectedMetrics = selectedMetrics
        self.category = category
    }
    
    // Add Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(selectedMetrics)
        hasher.combine(category)
    }
    
    // We already have Equatable conformance through the compiler synthesis,
    // but we can make it explicit if needed:
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.selectedMetrics == rhs.selectedMetrics &&
        lhs.category == rhs.category
    }
}

enum ExerciseMetric: String, CaseIterable, Codable, Hashable, Identifiable {
    case weight = "Weight"
    case reps = "Reps"
    case time = "Time"
    case distance = "Distance"
    case calories = "Calories"
    case custom = "Custom Notes"

    var id: String { self.rawValue }
}
