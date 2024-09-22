import SwiftUI

struct RoutineDetailView: View {
    var routine: Routine
    @Binding var routines: [Routine]
    @Environment(\.theme) var theme

    var body: some View {
        ZStack {
            theme.backgroundColor.edgesIgnoringSafeArea(.all)

            VStack {
                // Underlined title for the routine
                UnderlinedTitle(title: routine.name)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 20)

                List {
                    ForEach(routine.items) { item in
                        switch item {
                        case .exercise(let exercise):
                            // Exercise rows with consistent padding
                            NavigationLink(
                                destination: ContentView(selectedExerciseType: exercise.name, fromRoutine: true)
                            ) {
                                HStack {
                                    Text(exercise.name)
                                        .font(theme.secondaryFont)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 10)
                                        .frame(maxWidth: .infinity, alignment: .center) // Align text to center
                                        .background(.orange)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(.black, lineWidth: 2)
                                        )
                                }
                            }
                            .listRowBackground(Color.clear)

                        case .header(let name):
                            // Header rows styled similarly to exercise rows
                            HStack {
                                Text("- \(name) -")
                                    .font(theme.secondaryFont)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 10)
                                    .frame(maxWidth: .infinity, alignment: .center) // Align text to center
                                    .background(.gray)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(.white, lineWidth: 2)
                                    )
                            }
                            .listRowBackground(Color.clear)
                            .padding(.trailing, 12) // Ensure padding consistency with exercises
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
            routines: .constant([])
        )
        .environment(\.theme, AppTheme())
    }
}
