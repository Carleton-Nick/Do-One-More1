import SwiftUI

struct RoutineDetailView: View {
    var routine: Routine
    var exercises: [Exercise]  // Ensure this is passed in
    @Binding var routines: [Routine]
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
                            exerciseRow(exercise: exercise)  // Use helper function below
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
        .navigationBarItems(trailing: NavigationLink(destination: EditRoutineView(routine: routine, routines: $routines)) {
            Text("Edit")
                .font(theme.secondaryFont)
                .foregroundColor(theme.buttonTextColor)
                .padding(theme.buttonPadding)
                .background(theme.buttonBackgroundColor)
                .cornerRadius(theme.buttonCornerRadius)
        })
    }
    
    // MARK: - Helper Views
    
    private func exerciseRow(exercise: Exercise) -> some View {
        NavigationLink(
            destination: ContentView(
                exercises: exercises,
                exerciseRecords: [ExerciseRecord(selectedExerciseType: exercise.name)],
                fromRoutine: true
            )
        ) {
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
