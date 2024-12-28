import SwiftUI

struct ExerciseRow: View {
    let exercise: Exercise
    @Environment(\.theme) var theme
    
    var body: some View {
        Text(exercise.name)
            .font(theme.secondaryFont)
            .foregroundColor(.white)
            .padding(.vertical, 4)
    }
}

struct ExerciseRow_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseRow(exercise: Exercise(
            name: "Bench Press",
            selectedMetrics: [.weight, .reps],
            category: .chest
        ))
        .environment(\.theme, AppTheme())
        .previewLayout(.sizeThatFits)
        .background(Color.black)
    }
} 