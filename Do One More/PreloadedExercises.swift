import Foundation

struct PreloadedExercises {
    static let exercises: [Exercise] = [
        // MARK: - Chest Exercises
        Exercise(name: "Push-Ups", selectedMetrics: [.reps]),
        Exercise(name: "Bench Press - Barbell", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Incline Press - Barbell", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Incline Press - Dumbbell", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Flat Dumbbell Fly", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Cable Crossovers", selectedMetrics: [.weight, .reps]),

        // MARK: - Back Exercises
        Exercise(name: "Deadlift - Barbell", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Romanian Deadlift - Dumbbell", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Pull-Ups", selectedMetrics: [.reps]),
        Exercise(name: "Chin-Ups", selectedMetrics: [.reps]),
        Exercise(name: "Seated Cable Row", selectedMetrics: [.weight, .reps]),
        Exercise(name: "T-Bar Row - Barbell", selectedMetrics: [.weight, .reps]),
        Exercise(name: "One-Arm Row - Dumbbell", selectedMetrics: [.weight, .reps]),

        // MARK: - Shoulder Exercises
        Exercise(name: "Overhead Press - Barbell", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Arnold Press - Dumbbell", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Front Raises - Dumbbell", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Lateral Raises - Dumbbell", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Face Pulls", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Clean & Press - Barbell", selectedMetrics: [.weight, .reps]),

        // MARK: - Leg Exercises
        Exercise(name: "Squats - Barbell", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Front Squats - Barbell", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Lunges - Dumbbell", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Leg Press", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Leg Curls - Machine", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Calf Raises - Barbell", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Step-Ups - Dumbbell", selectedMetrics: [.weight, .reps]),

        // MARK: - Arm Exercises
        Exercise(name: "Bicep Curls - Barbell", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Hammer Curls - Dumbbell", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Concentration Curls - Dumbbell", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Tricep Pushdowns", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Overhead Tricep Extension - Dumbbell", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Skull Crushers - Barbell", selectedMetrics: [.weight, .reps]),

        // MARK: - Core Exercises
        Exercise(name: "Plank", selectedMetrics: [.time]),
        Exercise(name: "Hanging Leg Raises", selectedMetrics: [.reps]),
        Exercise(name: "Russian Twists - Dumbbell", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Cable Woodchoppers", selectedMetrics: [.weight, .reps]),
        Exercise(name: "Ab Wheel Rollouts", selectedMetrics: [.reps]),

        // MARK: - Cardio Exercises
        Exercise(name: "Assault Bike", selectedMetrics: [.time, .calories]),
        Exercise(name: "Indoor Run", selectedMetrics: [.time, .distance]),
        Exercise(name: "Outdoor Run", selectedMetrics: [.time, .distance]),
        Exercise(name: "Treadmill Walk", selectedMetrics: [.time, .distance]),
        Exercise(name: "Outdoor Cycle", selectedMetrics: [.time, .distance]),
        Exercise(name: "Stationary Bike", selectedMetrics: [.time, .distance]),
        Exercise(name: "Rowing Machine", selectedMetrics: [.time, .distance]),

        // MARK: - Calisthenics
        Exercise(name: "Burpees", selectedMetrics: [.reps]),
        Exercise(name: "Mountain Climbers", selectedMetrics: [.time]),
        Exercise(name: "Jumping Jacks", selectedMetrics: [.reps]),
        Exercise(name: "Dips", selectedMetrics: [.reps]),
        Exercise(name: "Box Jumps", selectedMetrics: [.reps])
    ]
}
