//
//  RoutineListView.swift
//  Do One More
//
//  Created by Nick Carleton on 6/26/24.
//

import SwiftUI

struct RoutineListView: View {
    @State private var routines: [Routine] = []
    @State private var isEditing = false // Track edit mode
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

                            Spacer() // Push the move handle to the right

                            if isEditing {
                                // Custom move handle at the far right
                                Image(systemName: "line.horizontal.3")
                                    .foregroundColor(.orange) // Customize the handle color here
                                    .padding(.leading, 8)
                            }
                        }
                        .listRowBackground(theme.backgroundColor)
                    }
                    .onDelete(perform: deleteRoutine)
                    .onMove(perform: moveRoutine)
                }
                .environment(\.editMode, .constant(isEditing ? EditMode.active : EditMode.inactive))
                .scrollContentBackground(.hidden)
                .listStyle(PlainListStyle())
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    UnderlinedTitle(title: "Workout Routines")
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    // "Edit Routines" button with consistent styling
                    Button(action: { isEditing.toggle() }) {
                        Text(isEditing ? "Done" : "Edit Routines")
                            .font(theme.secondaryFont)
                            .foregroundColor(theme.buttonTextColor)
                            .padding(theme.buttonPadding)
                            .background(theme.buttonBackgroundColor)
                            .cornerRadius(theme.buttonCornerRadius)
                    }

                    Spacer()

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
