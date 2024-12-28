import Foundation

struct PreloadedExercises {
    static let exercises: [Exercise] = [
        // Chest Exercises
        Exercise(name: "Bench Press", selectedMetrics: [.weight, .reps], category: .chest),
        Exercise(name: "Incline Bench Press", selectedMetrics: [.weight, .reps], category: .chest),
        Exercise(name: "Decline Bench Press", selectedMetrics: [.weight, .reps], category: .chest),
        Exercise(name: "Dumbbell Press", selectedMetrics: [.weight, .reps], category: .chest),
        Exercise(name: "Push-Ups", selectedMetrics: [.reps], category: .chest),
        
        // Back Exercises
        Exercise(name: "Deadlift", selectedMetrics: [.weight, .reps], category: .back),
        Exercise(name: "Barbell Row", selectedMetrics: [.weight, .reps], category: .back),
        Exercise(name: "Pull-Ups", selectedMetrics: [.reps], category: .back),
        Exercise(name: "Lat Pulldown", selectedMetrics: [.weight, .reps], category: .back),
        
        // Leg Exercises
        Exercise(name: "Squats", selectedMetrics: [.weight, .reps], category: .legs),
        Exercise(name: "Leg Press", selectedMetrics: [.weight, .reps], category: .legs),
        Exercise(name: "Lunges", selectedMetrics: [.weight, .reps], category: .legs),
        Exercise(name: "Calf Raises", selectedMetrics: [.weight, .reps], category: .legs),
        Exercise(name: "Leg Extensions", selectedMetrics: [.weight, .reps], category: .legs),
        
        // Arm Exercises
        Exercise(name: "Bicep Curls", selectedMetrics: [.weight, .reps], category: .arms),
        Exercise(name: "Tricep Extensions", selectedMetrics: [.weight, .reps], category: .arms),
        Exercise(name: "Hammer Curls", selectedMetrics: [.weight, .reps], category: .arms),
        Exercise(name: "Skull Crushers", selectedMetrics: [.weight, .reps], category: .arms),
        
        // Cardio Exercises
        Exercise(name: "Running", selectedMetrics: [.distance, .time, .calories], category: .cardio),
        Exercise(name: "Cycling", selectedMetrics: [.distance, .time, .calories], category: .cardio),
        Exercise(name: "Swimming", selectedMetrics: [.distance, .time, .calories], category: .cardio),
        Exercise(name: "Jump Rope", selectedMetrics: [.time, .calories], category: .cardio),
        
        // HIIT Exercises
        Exercise(name: "Burpees", selectedMetrics: [.reps, .time], category: .hiit),
        Exercise(name: "Mountain Climbers", selectedMetrics: [.reps, .time], category: .hiit),
        Exercise(name: "Box Jumps", selectedMetrics: [.reps, .time], category: .hiit),
        Exercise(name: "Kettlebell Swings", selectedMetrics: [.weight, .reps], category: .hiit),
        
        // Crossfit Exercises
        Exercise(name: "Clean and Jerk", selectedMetrics: [.weight, .reps], category: .crossfit),
        Exercise(name: "Snatch", selectedMetrics: [.weight, .reps], category: .crossfit),
        Exercise(name: "Thrusters", selectedMetrics: [.weight, .reps], category: .crossfit),
        Exercise(name: "Wall Balls", selectedMetrics: [.weight, .reps], category: .crossfit)
    ]
}
