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
                    ForEach(routine.items, id: \.id) { item in
                        switch item {
                        case .exercise(let exercise):
                            NavigationLink(
                                destination: ContentView(selectedExerciseType: exercise.name, fromRoutine: true)
                            ) {
                                Text(exercise.name)
                                    .font(theme.secondaryFont)
                                    .foregroundColor(theme.primaryColor)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(8)
                                    .background(theme.backgroundColor)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(theme.primaryColor, lineWidth: 1)
                                    )
                            }
                        case .header(let name):
                            HStack {
                                Text(name)
                                    .font(theme.secondaryFont)
                                    .foregroundColor(.orange)  // Use orange for headers
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.black)
                            }
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
                exercises: [Exercise(name: "Bench Press", selectedMetrics: [])], // Provide an array of exercises here
                items: [
                    .header("Warm-up"),
                    .exercise(Exercise(name: "Bench Press", selectedMetrics: []))
                ]
            ),
            routines: .constant([])
        )
        .environment(\.theme, AppTheme()) // Preview with the theme applied
    }
}
