import Foundation

enum ExerciseCategory: String, CaseIterable, Codable {
    case arms = "Arms"
    case legs = "Legs"
    case chest = "Chest"
    case back = "Back"
    case hiit = "HIIT"
    case cardio = "Cardio"
    case crossfit = "Crossfit"
    
    static var allCasesSorted: [ExerciseCategory] {
        allCases.sorted { $0.rawValue < $1.rawValue }
    }
} 