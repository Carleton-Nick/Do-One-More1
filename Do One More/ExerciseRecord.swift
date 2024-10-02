import Foundation

struct ExerciseRecord: Identifiable {
    var id = UUID()
    var selectedExerciseType: String = ""
    var setRecords: [SetRecord] = [SetRecord()]
    var showHistoricalData: Bool = true // Control visibility of historical data
}
