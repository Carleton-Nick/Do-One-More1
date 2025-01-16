import SwiftUI

struct RoutineListView: View {
    @State private var routines: [Routine] = []
    @State private var exercises: [Exercise] = UserDefaultsManager.loadExercises()
    @Binding var navigationPath: NavigationPath
    @Environment(\.theme) var theme
    @State private var showingCreateRoutineView = false
    
    // MARK: - Routine Management Functions
    private func loadRoutines() {
        routines = UserDefaultsManager.loadRoutines()
    }
    
    private func moveRoutine(from source: IndexSet, to destination: Int) {
        routines.move(fromOffsets: source, toOffset: destination)
        saveRoutines()
    }
    
    private func deleteRoutine(at offsets: IndexSet) {
        routines.remove(atOffsets: offsets)
        UserDefaultsManager.saveRoutines(routines)
    }
    
    private func saveRoutines() {
        UserDefaultsManager.saveRoutines(routines)
    }
    
    private func createSampleRoutines() {
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
    
    var body: some View {
        ZStack {
            theme.backgroundColor.edgesIgnoringSafeArea(.all)
            VStack {
                if routines.isEmpty {
                    EmptyRoutineView()
                } else {
                    RoutineListContentView(
                        routines: routines,
                        exercises: exercises,
                        routinesBinding: $routines,
                        navigationPath: $navigationPath
                    )
                }
            }
            CreateRoutineButton(showingCreateRoutineView: $showingCreateRoutineView)
        }
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .top) {
            UnderlinedTitle(title: "Routines")
                .background(theme.backgroundColor)
        }
        .sheet(isPresented: $showingCreateRoutineView) {
            CreateRoutineView(
                routine: Routine(name: "", exercises: [], items: []),
                routines: $routines
            )
        }
        .onAppear {
            loadRoutines()
        }
    }
}

// MARK: - Supporting Views
private struct EmptyRoutineView: View {
    var body: some View {
        Text("No routines yet")
            .foregroundColor(.white)
            .padding()
    }
}

private struct RoutineListContentView: View {
    let routines: [Routine]
    let exercises: [Exercise]
    @Binding var routinesBinding: [Routine]
    @Binding var navigationPath: NavigationPath
    @Environment(\.theme) var theme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(Array(routines.enumerated()), id: \.element.id) { index, routine in
                    RoutineRowView(
                        routine: routine,
                        exercises: exercises,
                        routines: $routinesBinding,
                        navigationPath: $navigationPath
                    )
                }
            }
            .padding(.vertical)
        }
    }
}

private struct RoutineRowView: View {
    let routine: Routine
    let exercises: [Exercise]
    @Binding var routines: [Routine]
    @Binding var navigationPath: NavigationPath
    @Environment(\.theme) var theme
    
    var body: some View {
        HStack {
            Text(routine.name)
                .font(theme.secondaryFont)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: {
                navigationPath.append(NavigationDestination.routineDetail(routine))
            }) {
                Text("View")
                    .font(theme.secondaryFont)
                    .foregroundColor(theme.buttonTextColor)
                    .padding(8)
                    .background(theme.buttonBackgroundColor)
                    .cornerRadius(theme.buttonCornerRadius)
            }
            .buttonStyle(PlainButtonStyle())
            
            NavigationLink {
                EditRoutineView(
                    routine: routine,
                    routines: $routines
                )
            } label: {
                Text("Edit")
                    .font(theme.secondaryFont)
                    .foregroundColor(theme.buttonTextColor)
                    .padding(8)
                    .background(theme.buttonBackgroundColor)
                    .cornerRadius(theme.buttonCornerRadius)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
        .padding(.vertical, 0)
        .background(theme.backgroundColor)
    }
}

private struct CreateRoutineButton: View {
    @Binding var showingCreateRoutineView: Bool
    @Environment(\.theme) var theme
    
    var body: some View {
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
}

struct RoutineListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RoutineListView(navigationPath: .constant(NavigationPath()))
                .environment(\.theme, AppTheme())
        }
    }
}
