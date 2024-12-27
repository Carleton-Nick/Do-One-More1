import Foundation

struct SetRecord: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var weight: String? = nil
    var reps: String? = nil
    var elapsedTime: String? = nil
    var distance: String? = nil
    var calories: String? = nil
    var custom: String? = nil
}
