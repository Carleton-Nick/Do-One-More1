import SwiftUI

struct RoutineDetailView: View {
    var routine: Routine
    var exercises: [Exercise]
    @Binding var routines: [Routine]
    @State private var showingShareSheet = false
    @Environment(\.theme) var theme

    var body: some View {
        ZStack {
            theme.backgroundColor.edgesIgnoringSafeArea(.all)
            VStack {
                UnderlinedTitle(title: routine.name)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 20)
                
                List {
                    ForEach(Array(routine.items.enumerated()), id: \.offset) { index, item in
                        switch item {
                        case .exercise(let exercise):
                            NavigationLink(
                                destination: ContentView(
                                    exercises: exercises,
                                    exerciseRecords: [ExerciseRecord(selectedExerciseType: exercise.name)],
                                    fromRoutine: true,
                                    clearExistingRecords: true
                                )
                            ) {
                                exerciseRow(exercise: exercise)
                            }
                        case .header(let name):
                            headerRow(name: name)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(PlainListStyle())
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(theme.buttonTextColor)
                            .padding(theme.buttonPadding)
                            .background(theme.buttonBackgroundColor)
                            .cornerRadius(theme.buttonCornerRadius)
                    }
                    
                    NavigationLink(destination: EditRoutineView(routine: routine, routines: $routines)) {
                        Text("Edit")
                            .font(theme.secondaryFont)
                            .foregroundColor(theme.buttonTextColor)
                            .padding(theme.buttonPadding)
                            .background(theme.buttonBackgroundColor)
                            .cornerRadius(theme.buttonCornerRadius)
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [createShareableRoutine()])
        }
    }
    
    private func exerciseRow(exercise: Exercise) -> some View {
        HStack {
            Text(exercise.name)
                .font(theme.secondaryFont)
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(.orange)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.black, lineWidth: 2)
                )
        }
        .listRowBackground(Color.clear)
    }
    
    private func headerRow(name: String) -> some View {
        HStack {
            Text("- \(name) -")
                .font(theme.secondaryFont)
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(.gray)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.white, lineWidth: 2)
                )
        }
        .listRowBackground(Color.clear)
        .padding(.trailing, 12)
    }
    
    private func createShareableRoutine() -> URL {
        // Create a dictionary containing all necessary data
        let routineData: [String: Any] = [
            "type": "routine",
            "name": routine.name,
            "exercises": routine.exercises.map { exercise in
                [
                    "name": exercise.name,
                    "selectedMetrics": exercise.selectedMetrics.map { $0.rawValue }
                ]
            },
            "items": routine.items.map { item in
                switch item {
                case .exercise(let exercise):
                    return ["type": "exercise", "name": exercise.name]
                case .header(let text):
                    return ["type": "header", "text": text]
                }
            }
        ]
        
        // Convert to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: routineData),
              let jsonString = String(data: jsonData, encoding: .utf8),
              let encodedString = jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "doonemorefitness://routine?data=\(encodedString)") else {
            // Fallback to a simple sharing format if JSON creation fails
            let fallbackURL = URL(string: "doonemorefitness://routine?name=\(routine.name)")!
            return fallbackURL
        }
        
        return url
    }
}

struct RoutineDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RoutineDetailView(
            routine: Routine(
                name: "Sample Routine",
                exercises: [Exercise(name: "Bench Press", selectedMetrics: [])],
                items: [
                    .header("Warm-up"),
                    .exercise(Exercise(name: "Bench Press", selectedMetrics: []))
                ]
            ),
            exercises: [Exercise(name: "Bench Press", selectedMetrics: [])],
            routines: .constant([])
        )
        .environment(\.theme, AppTheme())
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
