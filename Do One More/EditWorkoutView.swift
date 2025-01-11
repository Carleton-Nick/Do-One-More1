import SwiftUI

struct EditWorkoutView: View {
    @Binding var workout: Workout
    @Environment(\.dismiss) var dismiss
    @Environment(\.theme) var theme
    
    var onSave: (Workout) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // Exercise Type Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Exercise")
                            .font(theme.secondaryFont)
                            .foregroundColor(theme.primaryColor)
                            .padding(.horizontal)
                        
                        TextField("Exercise Type", text: $workout.exerciseType)
                            .font(theme.secondaryFont)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(theme.primaryColor, lineWidth: 2)
                            )
                            .padding(.horizontal)
                    }
                    
                    // Sets Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sets")
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
                            .padding(.horizontal)
                        
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach($workout.sets.indices, id: \.self) { index in
                                    SetView(set: $workout.sets[index], index: index)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Add Set Button
                        Button(action: addSet) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Set")
                            }
                            .font(theme.secondaryFont)
                            .foregroundColor(theme.buttonTextColor)
                            .padding(theme.buttonPadding)
                            .frame(maxWidth: .infinity)
                            .background(theme.buttonBackgroundColor)
                            .cornerRadius(theme.buttonCornerRadius)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle("Edit Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(workout)
                        dismiss()
                    }
                    .font(theme.secondaryFont)
                    .foregroundColor(theme.buttonTextColor)
                    .padding(8)
                    .background(theme.buttonBackgroundColor)
                    .cornerRadius(theme.buttonCornerRadius)
                }
            }
        }
    }
    
    private func addSet() {
        let newSet = createNewSet()
        workout.sets.append(newSet)
    }
    
    private func createNewSet() -> SetRecord {
        if let lastSet = workout.sets.last {
            return SetRecord(
                weight: lastSet.weight != nil ? "" : nil,
                reps: lastSet.reps != nil ? "" : nil,
                elapsedTime: lastSet.elapsedTime != nil ? "" : nil,
                distance: lastSet.distance != nil ? "" : nil,
                calories: lastSet.calories != nil ? "" : nil,
                custom: lastSet.custom != nil ? "" : nil
            )
        }
        return SetRecord()
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), 
                                      to: nil, 
                                      from: nil, 
                                      for: nil)
    }
}

// Helper view for individual sets
struct SetView: View {
    @Binding var set: SetRecord
    let index: Int
    @Environment(\.theme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Set \(index + 1)")
                .font(theme.secondaryFont)
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                if let weight = set.weight {
                    MetricField(title: "Weight", value: Binding(
                        get: { weight },
                        set: { set.weight = $0 }
                    ), keyboardType: .numberPad)
                }
                
                if let reps = set.reps {
                    MetricField(title: "Reps", value: Binding(
                        get: { reps },
                        set: { set.reps = $0 }
                    ), keyboardType: .numberPad)
                }
                
                if let time = set.elapsedTime {
                    MetricField(title: "Time", value: Binding(
                        get: { time },
                        set: { set.elapsedTime = $0 }
                    ))
                }
                
                if let distance = set.distance {
                    MetricField(title: "Distance", value: Binding(
                        get: { distance },
                        set: { set.distance = $0 }
                    ))
                }
                
                if let calories = set.calories {
                    MetricField(title: "Calories", value: Binding(
                        get: { calories },
                        set: { set.calories = $0 }
                    ), keyboardType: .numberPad)
                }
                
                if let custom = set.custom {
                    MetricField(title: "Notes", value: Binding(
                        get: { custom },
                        set: { set.custom = $0 }
                    ))
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(theme.primaryColor.opacity(0.3), lineWidth: 1)
        )
    }
}

// Reusable metric input field
struct MetricField: View {
    let title: String
    @Binding var value: String
    var keyboardType: UIKeyboardType = .default
    @Environment(\.theme) var theme
    
    var body: some View {
        HStack {
            Text(title)
                .font(theme.secondaryFont)
                .foregroundColor(theme.primaryColor)
                .frame(width: 80, alignment: .leading)
            
            TextField(title, text: $value)
                .font(theme.secondaryFont)
                .foregroundColor(.white)
                .padding(10)
                .background(Color.black.opacity(0.2))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(theme.primaryColor, lineWidth: 1)
                )
                .keyboardType(keyboardType)
        }
    }
}

// Preview provider
struct EditWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        EditWorkoutView(
            workout: .constant(Workout(
                exerciseType: "Bench Press",
                sets: [
                    SetRecord(weight: "135", reps: "10"),
                    SetRecord(weight: "155", reps: "8")
                ]
            )),
            onSave: { _ in }
        )
        .environment(\.theme, AppTheme())
    }
}
