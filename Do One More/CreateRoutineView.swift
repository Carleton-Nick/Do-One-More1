import SwiftUI

enum RoutineItem: Identifiable {
    case exercise(Exercise)
    case header(String)

    var id: UUID {
        switch self {
        case .exercise(let exercise):
            return exercise.id
        case .header:
            return UUID()
        }
    }
}

struct CreateRoutineView: View {
    @Binding var routines: [Routine]
    @State private var routineName: String = ""
    @State private var selectedItems: [RoutineItem] = []
    @State private var showAlert = false
    @State private var showingNewExerciseView = false
    @State private var showingHeaderAlert = false
    @State private var headerName = ""
    @State private var editingHeaderIndex: Int?
    @State var exercises: [Exercise] = UserDefaultsManager.loadExercises()
    @State private var flashItem: UUID? = nil // To store the ID of the item to flash
    @Environment(\.theme) var theme
    @Environment(\.dismiss) var dismiss

    var hasValidInput: Bool {
        !routineName.isEmpty
    }

    var body: some View {
        ZStack {
            theme.backgroundColor.edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading) {
                // Section: Routine Name
                VStack(alignment: .leading, spacing: 10) {
                    Text("Routine Name")
                        .font(theme.secondaryFont)
                        .foregroundColor(theme.primaryColor)

                    TextField("", text: $routineName)
                        .font(theme.secondaryFont)
                        .foregroundColor(.white)
                        .padding()
                        .background(theme.backgroundColor)
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(theme.primaryColor, lineWidth: 1)
                        )
                        .customPlaceholder(show: routineName.isEmpty, placeholder: "Name")
                }
                .padding(.horizontal)

                // All Exercises Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Choose exercises for your routine")
                        .font(theme.secondaryFont)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 5)
                        .overlay(
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(theme.primaryColor) // Thin orange underline
                                .offset(y: 10),
                            alignment: .bottomLeading
                        )

                    // List of All Exercises with black background and custom styling
                    List(exercises.sorted(by: { $0.name < $1.name }), id: \.self) { exercise in
                        MultipleSelectionRow(title: exercise.name, isSelected: false, isFlashing: flashItem == exercise.id) {
                            selectedItems.append(.exercise(exercise)) // Append the selected exercise to the routine

                            // Set the flash state to this exercise, and clear after delay
                            flashItem = exercise.id
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                flashItem = nil // Reset flash after 0.3 seconds
                            }
                        }
                        .listRowBackground(Color.clear) // Clear list background to match spacing style
                    }
                    .scrollContentBackground(.hidden) // Remove default white list background
                    .background(theme.backgroundColor) // Set overall background to black
                    .listStyle(InsetListStyle()) // Default inset list style (unstyled)
                    .frame(maxWidth: .infinity)

                    // Centered "Create New Exercise" and "Add Header" Button
                    HStack {
                        Button(action: {
                            showingNewExerciseView = true
                        }) {
                            Text("Create New Exercise")
                                .font(theme.secondaryFont)
                                .foregroundColor(theme.buttonTextColor)
                                .padding(theme.buttonPadding)
                                .background(theme.buttonBackgroundColor)
                                .cornerRadius(theme.buttonCornerRadius)
                        }
                        .sheet(isPresented: $showingNewExerciseView) {
                            NewExerciseView(exercises: $exercises)
                                .onDisappear {
                                    UserDefaultsManager.saveExercises(exercises)
                                    if let lastCreatedExercise = exercises.last {
                                        selectedItems.append(.exercise(lastCreatedExercise)) // Append newly created exercise to routine
                                    }
                                }
                        }

                        Button(action: {
                            showingHeaderAlert = true // Show the alert for header naming
                        }) {
                            Text("Add Header")
                                .font(theme.secondaryFont)
                                .foregroundColor(theme.buttonTextColor)
                                .padding(theme.buttonPadding)
                                .background(theme.buttonBackgroundColor)
                                .cornerRadius(theme.buttonCornerRadius)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center) // Center the buttons
                }

                // Section: Selected Items (Exercises + Headers)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Routine")
                        .font(theme.secondaryFont)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center) // Center the text
                        .padding(.bottom, 5)
                        .overlay(
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(theme.primaryColor) // Thin orange underline
                                .offset(y: 10),
                            alignment: .bottomLeading
                        )

                    List {
                        ForEach(Array(selectedItems.enumerated()), id: \.element.id) { index, item in
                            switch item {
                            case .exercise(let exercise):
                                HStack {
                                    Text(exercise.name)
                                        .foregroundColor(.white) // White text when selected
                                        .padding(.leading, 10) // Add leading padding to match "All Exercises"

                                    Spacer()
                                }
                                .padding(.vertical, 12) // Add consistent vertical padding
                                .background(theme.primaryColor) // Orange background for selected exercises
                                .frame(maxWidth: .infinity, alignment: .leading) // Ensure it spans the entire width and aligns left
                                .listRowInsets(EdgeInsets()) // Remove extra insets

                            case .header(let name):
                                HStack {
                                    Text(name)
                                        .foregroundColor(.orange) // Orange text for headers
                                        .padding(.leading, 10) // Add leading padding to match "All Exercises"
                                    Spacer()
                                    Button(action: {
                                        editingHeaderIndex = index
                                        headerName = name
                                        showingHeaderAlert = true
                                    }) {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.orange)
                                    }
                                    .padding(.trailing, 10) // Add trailing padding for the edit button
                                }
                                .padding(.vertical, 12)
                                .background(Color.black) // Black background for headers
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .listRowInsets(EdgeInsets()) // Remove extra insets
                            }
                        }
                        .onDelete(perform: deleteItem)
                        .onMove(perform: moveItem)
                        .listRowBackground(Color.clear) // Set the list row background to clear to remove extra styling
                    }
                    .scrollContentBackground(.hidden) // Remove default white list background
                    .background(theme.backgroundColor) // Set overall background color to theme
                    .listStyle(InsetListStyle())
                    .toolbar {
                        EditButton() // To rearrange the selected exercises and headers
                    }
                }

                Button(action: saveRoutine) {
                    Text("Save Routine")
                        .font(theme.secondaryFont)
                        .foregroundColor(hasValidInput ? theme.buttonTextColor : theme.secondaryColor)
                        .padding(theme.buttonPadding)
                        .background(theme.buttonBackgroundColor)
                        .cornerRadius(theme.buttonCornerRadius)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .disabled(!hasValidInput)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Routine Saved"), message: nil, dismissButton: .default(Text("OK")) {
                        dismiss()
                    })
                }
                .padding(.top, 10)
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                UnderlinedTitle(title: "Create A Routine")
            }
        }
        .onAppear {
            exercises = UserDefaultsManager.loadExercises()
        }
        .alert("Name your header", isPresented: $showingHeaderAlert, actions: {
            TextField("Header", text: $headerName)
            Button("OK", action: {
                if let index = editingHeaderIndex {
                    selectedItems[index] = .header(headerName)
                } else {
                    selectedItems.append(.header(headerName))
                }
                editingHeaderIndex = nil
            })
            Button("Cancel", role: .cancel, action: {
                editingHeaderIndex = nil
            })
        })
    }

    func moveItem(from source: IndexSet, to destination: Int) {
        selectedItems.move(fromOffsets: source, toOffset: destination)
    }

    func deleteItem(at offsets: IndexSet) {
        selectedItems.remove(atOffsets: offsets)
    }

    func saveRoutine() {
        guard !routineName.isEmpty else { return }

        let exercisesOnly = selectedItems.compactMap { item -> Exercise? in
            if case .exercise(let exercise) = item {
                return exercise
            }
            return nil
        }

        let newRoutine = Routine(name: routineName, exercises: exercisesOnly)
        routines.append(newRoutine)
        UserDefaultsManager.saveRoutines(routines)
        showAlert = true
    }
}

struct CreateRoutineView_Previews: PreviewProvider {
    static var previews: some View {
        CreateRoutineView(routines: .constant([]))
            .environment(\.theme, AppTheme())
    }
}
