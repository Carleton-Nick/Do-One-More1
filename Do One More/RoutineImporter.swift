import SwiftUI

class RoutineImporter: ObservableObject {
    @Published var importError: String?
    @Published var showingImportAlert = false
    
    func handleImportedData(_ data: Data) {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let name = json["name"] as? String,
                  let items = json["items"] as? [[String: Any]] else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid routine format"])
            }
            
            // Convert JSON items back to RoutineItems
            let routineItems = items.compactMap { itemDict -> RoutineItem? in
                guard let type = itemDict["type"] as? String else { return nil }
                
                if type == "exercise",
                   let name = itemDict["name"] as? String,
                   let categoryRaw = itemDict["category"] as? String,
                   let category = ExerciseCategory(rawValue: categoryRaw) {
                    // Default to weight and reps for imported exercises
                    return .exercise(Exercise(name: name, selectedMetrics: [.weight, .reps], category: category))
                } else if type == "header",
                          let text = itemDict["text"] as? String {
                    return .header(text)
                }
                return nil
            }
            
            // Create and save the new routine
            let exercises = routineItems.compactMap { item -> Exercise? in
                if case .exercise(let exercise) = item {
                    return exercise
                }
                return nil
            }
            
            let newRoutine = Routine(name: name, exercises: exercises, items: routineItems)
            var currentRoutines = UserDefaultsManager.loadRoutines()
            currentRoutines.append(newRoutine)
            UserDefaultsManager.saveRoutines(currentRoutines)
            
        } catch {
            importError = "Error importing routine: \(error.localizedDescription)"
            showingImportAlert = true
        }
    }
} 