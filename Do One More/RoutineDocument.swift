import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var domRoutine: UTType {
        UTType(importedAs: "com.yourdomain.domroutine")
    }
}

struct RoutineDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.domRoutine] }
    
    var routine: Routine
    
    init(routine: Routine) {
        self.routine = routine
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let name = jsonObject["name"] as? String,
              let items = jsonObject["items"] as? [[String: Any]]
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        // Convert items back to RoutineItems
        let routineItems = items.compactMap { item -> RoutineItem? in
            guard let type = item["type"] as? String else { return nil }
            
            switch type {
            case "exercise":
                guard let name = item["name"] as? String,
                      let categoryString = item["category"] as? String,
                      let category = ExerciseCategory(rawValue: categoryString)
                else { return nil }
                
                return .exercise(Exercise(name: name, selectedMetrics: [], category: category))
                
            case "header":
                guard let text = item["text"] as? String else { return nil }
                return .header(text)
                
            default:
                return nil
            }
        }
        
        self.routine = Routine(name: name, exercises: [], items: routineItems)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let routineData: [String: Any] = [
            "version": 1,
            "name": routine.name,
            "items": routine.items.map { item in
                switch item {
                case .exercise(let exercise):
                    return [
                        "type": "exercise",
                        "name": exercise.name,
                        "category": exercise.category.rawValue
                    ]
                case .header(let text):
                    return ["type": "header", "text": text]
                }
            }
        ]
        
        let data = try JSONSerialization.data(withJSONObject: routineData, options: .prettyPrinted)
        return .init(regularFileWithContents: data)
    }
} 