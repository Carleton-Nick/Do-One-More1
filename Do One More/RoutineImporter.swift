import SwiftUI

class RoutineImporter: ObservableObject {
    @Published var showingImportAlert = false
    @Published var importedRoutine: Routine?
    @Published var importError: String?
    
    func handleIncomingURL(_ url: URL) {
        guard url.scheme == "doonemorefitness",
              url.host == "routine",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let dataString = components.queryItems?.first(where: { $0.name == "data" })?.value,
              let jsonString = dataString.removingPercentEncoding,
              let jsonData = jsonString.data(using: .utf8) else {
            importError = "Invalid routine data"
            showingImportAlert = true
            return
        }
        
        do {
            if let routineDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                // Parse exercises
                let exercises = (routineDict["exercises"] as? [[String: Any]])?.compactMap { exerciseDict -> Exercise? in
                    guard let name = exerciseDict["name"] as? String,
                          let metricStrings = exerciseDict["selectedMetrics"] as? [String],
                          let categoryString = exerciseDict["category"] as? String,
                          let category = ExerciseCategory(rawValue: categoryString) else {
                        return nil
                    }
                    
                    let metrics = metricStrings.compactMap { ExerciseMetric(rawValue: $0) }
                    return Exercise(name: name, selectedMetrics: metrics, category: category)
                } ?? []
                
                // Parse items
                let items = (routineDict["items"] as? [[String: Any]])?.compactMap { itemDict -> RoutineItem? in
                    guard let type = itemDict["type"] as? String else { return nil }
                    
                    if type == "exercise",
                       let name = itemDict["name"] as? String,
                       let exercise = exercises.first(where: { $0.name == name }) {
                        return .exercise(exercise)
                    } else if type == "header",
                              let text = itemDict["text"] as? String {
                        return .header(text)
                    }
                    return nil
                } ?? []
                
                // Create the routine
                if let name = routineDict["name"] as? String {
                    importedRoutine = Routine(name: name, exercises: exercises, items: items)
                    
                    // Add any missing exercises to the app's exercise list
                    let existingExercises = UserDefaultsManager.loadExercises()
                    let newExercises = exercises.filter { exercise in
                        !existingExercises.contains { $0.name == exercise.name }
                    }
                    
                    if !newExercises.isEmpty {
                        var updatedExercises = existingExercises
                        updatedExercises.append(contentsOf: newExercises)
                        UserDefaultsManager.saveExercises(updatedExercises)
                    }
                    
                    showingImportAlert = true
                }
            }
        } catch {
            importError = "Error parsing routine data"
            showingImportAlert = true
        }
    }
} 