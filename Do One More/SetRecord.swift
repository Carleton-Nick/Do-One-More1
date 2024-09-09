import Foundation

struct SetRecord: Identifiable, Codable, Hashable {
    var id = UUID()
    var weight: Int?           // Weight in lbs (whole number)
    var reps: Int?             // Number of repetitions (whole number)
    var elapsedTime: String?   // Time for the set (alphanumeric input)
    var distance: Double?      // Distance in miles (decimal number)
    var calories: String?      // Calories burned (alphanumeric input)
    var custom: String?        // Custom notes for the set (alphanumeric input)

    // Hashable and Equatable conformance is automatically synthesized by the compiler
}
