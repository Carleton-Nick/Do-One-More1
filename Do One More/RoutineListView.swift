import SwiftUI

struct RoutineListView: View {
    @State private var routines: [Routine] = []
    @State private var exercises: [Exercise] = UserDefaultsManager.loadExercises() // Load exercises
    @Environment(\.theme) var theme // Inject the global theme

    var body: some View {
        NavigationView {
            ZStack {
                theme.backgroundColor.edgesIgnoringSafeArea(.all) // Set the entire view's background
                
                routineList // Use a separate view for the list content
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            UnderlinedTitle(title: "Workout Routines")
                        }
                        ToolbarItemGroup(placement: .bottomBar) {
                            Spacer() // Align the "Add Routine" button to the right

                            // "Add Routine" button with consistent styling
                            NavigationLink(destination: CreateRoutineView(routines: $routines)) {
                                Text("Create Routine")
                                    .font(theme.secondaryFont)
                                    .foregroundColor(theme.buttonTextColor)
                                    .padding(theme.buttonPadding)
                                    .background(theme.buttonBackgroundColor)
                                    .cornerRadius(theme.buttonCornerRadius)
                            }
                        }
                    }
                    .onAppear(perform: loadRoutines)
            }
        }
    }

    // MARK: - Routine List View
    private var routineList: some View {
        List {
            ForEach(routines.indices, id: \.self) { index in
                RoutineRow(routine: routines[index], routines: $routines, exercises: exercises, index: index)
                    .listRowBackground(theme.backgroundColor)
            }
            .onDelete(perform: deleteRoutine) // Swipe to delete
            .onMove(perform: moveRoutine)     // Tap and hold to reorder
        }
        .scrollContentBackground(.hidden)
        .listStyle(PlainListStyle())
    }

    // MARK: - Routine Management Functions

    func loadRoutines() {
        if let savedRoutines = UserDefaults.standard.data(forKey: "routines"),
           let decodedRoutines = try? JSONDecoder().decode([Routine].self, from: savedRoutines) {
            routines = decodedRoutines
        }
    }

    func moveRoutine(from source: IndexSet, to destination: Int) {
        routines.move(fromOffsets: source, toOffset: destination)
        saveRoutines()
    }

    func deleteRoutine(at offsets: IndexSet) {
        routines.remove(atOffsets: offsets)
        saveRoutines()
    }

    func saveRoutines() {
        if let encoded = try? JSONEncoder().encode(routines) {
            UserDefaults.standard.set(encoded, forKey: "routines")
        }
    }
}

// MARK: - Routine Row View
struct RoutineRow: View {
    let routine: Routine
    @Binding var routines: [Routine]
    let exercises: [Exercise]
    let index: Int
    @Environment(\.theme) var theme

    var body: some View {
        HStack {
            NavigationLink(destination: RoutineDetailView(routine: routine, exercises: exercises, routines: $routines)) {
                Text(routine.name)
                    .font(theme.secondaryFont)
                    .foregroundColor(theme.primaryColor)
                    .padding(8)
                    .background(theme.backgroundColor)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(theme.primaryColor, lineWidth: 1)
                    )
            }
            Spacer()
        }
    }
}

struct RoutineListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RoutineListView()
                .environment(\.theme, AppTheme())
                .onAppear {
                    // Add sample routine data for preview
                    let sampleRoutines = [
                        Routine(
                            name: "Push Day",
                            exercises: [
                                Exercise(name: "Bench Press", selectedMetrics: [.weight, .reps]),
                                Exercise(name: "Shoulder Press", selectedMetrics: [.weight, .reps])
                            ],
                            items: [
                                .header("Chest"),
                                .exercise(Exercise(name: "Bench Press", selectedMetrics: [.weight, .reps])),
                                .header("Shoulders"),
                                .exercise(Exercise(name: "Shoulder Press", selectedMetrics: [.weight, .reps]))
                            ]
                        )
                    ]
                    UserDefaultsManager.saveRoutines(sampleRoutines)
                }
        }
    }
}
