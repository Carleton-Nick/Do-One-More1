import Foundation

struct Routine: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var exercises: [String]
    var createdAt: Date = Date() // Add a timestamp for routine creation

    // Hashable and Equatable conformance is synthesized automatically by the compiler
    // if all properties conform to Hashable and Equatable, so the following is optional:
    
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
