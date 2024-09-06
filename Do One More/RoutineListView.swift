import SwiftUI

struct RoutineListView: View {
    @State private var routines: [Routine] = []
    @Environment(\.theme) var theme // Inject the global theme

    var body: some View {
        NavigationView {
            ZStack {
                theme.backgroundColor.edgesIgnoringSafeArea(.all) // Set the entire view's background

                List {
                    ForEach(routines.indices, id: \.self) { index in
                        HStack {
                            NavigationLink(destination: RoutineDetailView(routine: routines[index], routines: $routines)) {
                                Text(routines[index].name)
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
                        .listRowBackground(theme.backgroundColor)
                    }
                    .onDelete(perform: deleteRoutine) // Swipe to delete
                    .onMove(perform: moveRoutine)     // Tap and hold to reorder
                }
                .scrollContentBackground(.hidden)
                .listStyle(PlainListStyle())
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    UnderlinedTitle(title: "Workout Routines")
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer() // Align the "Add Routine" button to the right

                    // "Add Routine" button with consistent styling
                    NavigationLink(destination: CreateRoutineView(routines: $routines)) {
                        Text("Add Routine")
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

struct RoutineListView_Previews: PreviewProvider {
    static var previews: some View {
        RoutineListView()
            .environment(\.theme, AppTheme()) // Preview with the theme applied
    }
}
