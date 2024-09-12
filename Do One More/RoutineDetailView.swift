import SwiftUI

struct RoutineDetailView: View {
    var routine: Routine
    @Binding var routines: [Routine]
    @Environment(\.theme) var theme // Inject the global theme

    var body: some View {
        ZStack {
            theme.backgroundColor.edgesIgnoringSafeArea(.all) // Set the background color

            VStack {
                // Underlined title for the routine
                UnderlinedTitle(title: routine.name) // Add the underlined title
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 20)

                List {
                    ForEach(routine.exercises, id: \.self) { exercise in
                        NavigationLink(
                            destination: ContentView(selectedExerciseType: exercise.name, fromRoutine: true)
                        ) {
                            Text(exercise.name) // Updated to display exercise name
                                .font(theme.secondaryFont) // Apply theme font
                                .foregroundColor(theme.primaryColor) // Apply theme text color
                                .frame(maxWidth: .infinity, alignment: .center) // Center the text and span the full width
                                .padding(8)
                                .background(theme.backgroundColor) // Match the background with the theme
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(theme.primaryColor, lineWidth: 1) // Add the thin orange border
                                )
                        }
                        .listRowBackground(theme.backgroundColor) // Remove the default white background
                    }
                }
                .scrollContentBackground(.hidden) // Hide the default list background
                .listStyle(PlainListStyle()) // Simplify the list style to avoid additional padding
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: NavigationLink(destination: EditRoutineView(routine: routine, routines: $routines)) {
            Text("Edit")
                .font(theme.secondaryFont) // Apply theme font
                .foregroundColor(theme.buttonTextColor) // Set the text color to the theme’s button text color
                .padding(theme.buttonPadding)
                .background(theme.buttonBackgroundColor)
                .cornerRadius(theme.buttonCornerRadius)
        })
    }
}

struct RoutineDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RoutineDetailView(routine: Routine(name: "Sample Routine", exercises: [Exercise(name: "Bench Press", selectedMetrics: [])]), routines: .constant([]))
            .environment(\.theme, AppTheme()) // Preview with the theme applied
    }
}
