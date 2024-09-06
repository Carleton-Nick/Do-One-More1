import Foundation

struct SetRecord: Identifiable, Codable, Hashable {
    var id = UUID()
    var weight: String?        // Weight in lbs
    var reps: Int?             // Number of repetitions
    var elapsedTime: String?   // Time for the set, in hh:mm:ss format
    var distance: String?      // Distance in miles
    var calories: String?      // Calories burned
    var custom: String?        // Custom notes for the set

    // Hashable and Equatable conformance is automatically synthesized by the compiler
    // if all properties conform to Hashable and Equatable.
}
