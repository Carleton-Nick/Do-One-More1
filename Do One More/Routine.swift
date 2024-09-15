import Foundation

// RoutineItem Enum
enum RoutineItem: Identifiable, Codable {
    case exercise(Exercise)
    case header(String)

    // Unique ID based on the case
    var id: UUID {
        switch self {
        case .exercise(let exercise):
            return exercise.id
        case .header:
            return UUID() // Each header gets a unique random ID
        }
    }

    // Custom Coding Keys to differentiate between the enum cases during encoding/decoding
    private enum CodingKeys: String, CodingKey {
        case type
        case exercise
        case header
    }

    // Custom encoding logic
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .exercise(let exercise):
            try container.encode("exercise", forKey: .type)
            try container.encode(exercise, forKey: .exercise)
        case .header(let header):
            try container.encode("header", forKey: .type)
            try container.encode(header, forKey: .header)
        }
    }

    // Custom decoding logic
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "exercise":
            let exercise = try container.decode(Exercise.self, forKey: .exercise)
            self = .exercise(exercise)
        case "header":
            let header = try container.decode(String.self, forKey: .header)
            self = .header(header)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown type")
        }
    }
}

// Routine Struct
struct Routine: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var exercises: [Exercise]  // Store the full Exercise objects instead of just names
    var createdAt: Date = Date() // Timestamp for routine creation
    var items: [RoutineItem] // Store both exercises and headers here

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
