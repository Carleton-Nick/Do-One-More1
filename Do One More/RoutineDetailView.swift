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
                Button(action: {
                    showingShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(theme.buttonTextColor)
                        .padding(theme.buttonPadding)
                        .background(theme.buttonBackgroundColor)
                        .cornerRadius(theme.buttonCornerRadius)
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
    
    private func emojiForCategory(_ category: ExerciseCategory) -> String {
        switch category {
        case .arms:
            return "💪"
        case .legs:
            return "🦵"
        case .chest:
            return "🏋️‍♂️"
        case .back:
            return "🏋"
        case .hiit:
            return "⚡"  
        case .cardio:
            return "🏃‍♂️"
        case .crossfit:
            return "🤾‍♂️"
        }
    }
    
    private func createShareableRoutine() -> String {
        // Create a simple text representation of the routine
        var routineText = "Exercise Routine: \(routine.name)\n\n"
        
        for item in routine.items {
            switch item {
            case .exercise(let exercise):
                routineText += "• \(exercise.name)\n"
            case .header(let text):
                routineText += "\n🔷 \(text)\n"
            }
        }
        
        routineText += "\nBuilt in Do One More 💪"
        
        return routineText
    }
}

struct RoutineDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RoutineDetailView(
            routine: Routine(
                name: "Sample Routine",
                exercises: [Exercise(name: "Bench Press", selectedMetrics: [], category: .chest)],
                items: [
                    .header("Warm-up"),
                    .exercise(Exercise(name: "Bench Press", selectedMetrics: [], category: .chest))
                ]
            ),
            exercises: [Exercise(name: "Bench Press", selectedMetrics: [], category: .chest)],
            routines: .constant([])
        )
        .environment(\.theme, AppTheme())
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
