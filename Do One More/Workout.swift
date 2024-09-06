import Foundation

struct Workout: Identifiable, Codable, Hashable {
    var id = UUID()
    var exerciseType: String
    var sets: [SetRecord]
    var timestamp: Date = Date() // Automatically set the timestamp when a workout is created

    // Hashable and Equatable conformance is synthesized automatically by the compiler
    // if all properties conform to Hashable and Equatable, so the following is optional:
    
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        return lhs.id == rhs.id && lhs.exerciseType == rhs.exerciseType && lhs.sets == rhs.sets && lhs.timestamp == rhs.timestamp
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(exerciseType)
        hasher.combine(sets)
        hasher.combine(timestamp)
    }
}
