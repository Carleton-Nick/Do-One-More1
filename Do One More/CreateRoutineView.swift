import Foundation
import SwiftUI

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
    @State private var flashItem: UUID? = nil
    @State private var editMode: EditMode = .inactive // Manage edit mode

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
                        .customPlaceholder(show: routineName.isEmpty, placeholder: "Routine Name")
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
                                .foregroundColor(theme.primaryColor)
                                .offset(y: 10),
                            alignment: .bottomLeading
                        )

                    // List of All Exercises
                    List(exercises.sorted(by: { $0.name < $1.name }), id: \.self) { exercise in
                        MultipleSelectionRow(title: exercise.name, isSelected: false, isFlashing: flashItem == exercise.id) {
                            selectedItems.append(.exercise(exercise))

                            // Set flash state to this exercise, and clear after delay
                            flashItem = exercise.id
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                flashItem = nil
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                    .scrollContentBackground(.hidden)
                    .background(theme.backgroundColor)
                    .listStyle(InsetListStyle())
                    .frame(maxWidth: .infinity)

                    // Centered Buttons
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
                                        selectedItems.append(.exercise(lastCreatedExercise))
                                    }
                                }
                        }

                        Button(action: {
                            showingHeaderAlert = true
                        }) {
                            Text("Add Header")
                                .font(theme.secondaryFont)
                                .foregroundColor(theme.buttonTextColor)
                                .padding(theme.buttonPadding)
                                .background(theme.buttonBackgroundColor)
                                .cornerRadius(theme.buttonCornerRadius)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }

                // Section: Selected Items
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Routine")
                        .font(theme.secondaryFont)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 5)
                        .overlay(
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(theme.primaryColor)
                                .offset(y: 10),
                            alignment: .bottomLeading
                        )

                    List {
                        ForEach(Array(selectedItems.enumerated()), id: \.element.id) { index, item in
                            switch item {
                            case .exercise(let exercise):
                                HStack {
                                    Text(exercise.name)
                                        .foregroundColor(.white)
                                        .padding(.leading, 10)

                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                .background(theme.primaryColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .listRowInsets(EdgeInsets())

                            case .header(let name):
                                HStack {
                                    Text(name)
                                        .foregroundColor(.orange)
                                        .padding(.leading, 10)
                                    Spacer()
                                    Button(action: {
                                        editingHeaderIndex = index
                                        headerName = name
                                        showingHeaderAlert = true
                                    }) {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.orange)
                                    }
                                    .padding(.trailing, 10)
                                }
                                .padding(.vertical, 12)
                                .background(Color.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .listRowInsets(EdgeInsets())
                            }
                        }
                        .onDelete(perform: deleteItem)
                        .onMove(perform: moveItem)
                        .listRowBackground(Color.clear)
                    }
                    .scrollContentBackground(.hidden)
                    .background(theme.backgroundColor)
                    .listStyle(InsetListStyle())
                    .environment(\.editMode, $editMode) // Apply edit mode to the list
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

        // Extract exercises from the selectedItems array
        let exercisesOnly = selectedItems.compactMap { item -> Exercise? in
            if case .exercise(let exercise) = item {
                return exercise
            }
            return nil
        }

        // Create a new Routine with both exercises and items
        let newRoutine = Routine(name: routineName, exercises: exercisesOnly, items: selectedItems)
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
