import Foundation

struct Routine: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var exercises: [Exercise]  // Store the full Exercise objects instead of just names
    var createdAt: Date = Date() // Timestamp for routine creation

    // Hashable and Equatable conformance
    static func == (lhs: Routine, rhs: Routine) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.exercises == rhs.exercises && lhs.createdAt == rhs.createdAt
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(exercises)
        hasher.combine(createdAt)
    }
}
