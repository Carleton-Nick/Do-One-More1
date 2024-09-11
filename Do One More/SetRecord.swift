import Foundation

struct SetRecord: Identifiable, Codable, Hashable {
    var id = UUID()
    var weight: String?     // Change from Int? to String?
    var reps: String?       // Change from Int? to String?
    var elapsedTime: String?  // Already a String?
    var distance: String?   // Change from Double? to String?
    var calories: String?   // Change from Int? to String?
    var custom: String?     // Already a String?
}
