import SwiftUI

struct RoutineListView: View {
    @State private var routines: [Routine] = []
    @State private var exercises: [Exercise] = UserDefaultsManager.loadExercises()
    @Environment(\.theme) var theme
    @State private var showingCreateRoutineView = false

    var body: some View {
        NavigationView {
            ZStack {
                theme.backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack {
                    if routines.isEmpty {
                        Text("No routines yet")
                            .foregroundColor(.white)
                            .padding()
                    } else {
                        List {
                            ForEach(routines) { routine in
                                NavigationLink(destination: RoutineDetailView(routine: routine, exercises: exercises, routines: $routines)) {
                                    Text(routine.name)
                                        .foregroundColor(.white)
                                }
                                .listRowBackground(theme.backgroundColor)
                            }
                            .onDelete(perform: deleteRoutine)
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                
                // Create New Routine Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingCreateRoutineView = true
                        }) {
                            Text("Create New Routine")
                                .font(theme.secondaryFont)
                                .foregroundColor(theme.buttonTextColor)
                                .padding()
                                .background(theme.buttonBackgroundColor)
                                .cornerRadius(theme.buttonCornerRadius)
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    UnderlinedTitle(title: "Routines")
                }
            }
        }
        .sheet(isPresented: $showingCreateRoutineView) {
            CreateRoutineView(routines: $routines)
        }
        .onAppear {
            routines = UserDefaultsManager.loadRoutines()
            if routines.isEmpty {
                createSampleRoutines()
            }
        }
    }

    // MARK: - Routine Management Functions

    func loadRoutines() {
        routines = UserDefaultsManager.loadRoutines()
    }

    func moveRoutine(from source: IndexSet, to destination: Int) {
        routines.move(fromOffsets: source, toOffset: destination)
        saveRoutines()
    }

    func deleteRoutine(at offsets: IndexSet) {
        routines.remove(atOffsets: offsets)
        UserDefaultsManager.saveRoutines(routines)
    }

    func saveRoutines() {
        UserDefaultsManager.saveRoutines(routines)
    }

    func createSampleRoutines() {
        let sampleRoutines = [
            Routine(
                name: "Push Day",
                exercises: [
                    Exercise(name: "Bench Press", selectedMetrics: [.weight, .reps], category: .chest),
                    Exercise(name: "Shoulder Press", selectedMetrics: [.weight, .reps], category: .chest)
                ],
                items: [
                    .header("Chest"),
                    .exercise(Exercise(name: "Bench Press", selectedMetrics: [.weight, .reps], category: .chest)),
                    .header("Shoulders"),
                    .exercise(Exercise(name: "Shoulder Press", selectedMetrics: [.weight, .reps], category: .chest))
                ]
            )
        ]
        routines = sampleRoutines
        UserDefaultsManager.saveRoutines(routines)
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
                                Exercise(name: "Bench Press", selectedMetrics: [.weight, .reps], category: .chest),
                                Exercise(name: "Shoulder Press", selectedMetrics: [.weight, .reps], category: .chest)
                            ],
                            items: [
                                .header("Chest"),
                                .exercise(Exercise(name: "Bench Press", selectedMetrics: [.weight, .reps], category: .chest)),
                                .header("Shoulders"),
                                .exercise(Exercise(name: "Shoulder Press", selectedMetrics: [.weight, .reps], category: .chest))
                            ]
                        )
                    ]
                    UserDefaultsManager.saveRoutines(sampleRoutines)
                }
        }
    }
}
