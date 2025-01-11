import Foundation

struct PreloadedExercises {
    static let exercises: [Exercise] = [
        // Chest Exercises
        Exercise(name: "Bench Press - Barbell", selectedMetrics: [.weight, .reps], category: .chest),
        Exercise(name: "Bench Press - Dumbbell", selectedMetrics: [.weight, .reps], category: .chest),
        Exercise(name: "Chest Fly", selectedMetrics: [.weight, .reps], category: .chest),
        Exercise(name: "Decline Bench - Barbell", selectedMetrics: [.weight, .reps], category: .chest),
        Exercise(name: "Decline Bench - Dumbbell", selectedMetrics: [.weight, .reps], category: .chest),
        Exercise(name: "High Cable Fly", selectedMetrics: [.weight, .reps], category: .chest),
        Exercise(name: "Incline Bench - Barbell", selectedMetrics: [.weight, .reps], category: .chest),
        Exercise(name: "Incline Bench - Dumbbell", selectedMetrics: [.weight, .reps], category: .chest),
        Exercise(name: "Incline Chest Fly", selectedMetrics: [.weight, .reps], category: .chest),
        Exercise(name: "Incline Squeeze Press", selectedMetrics: [.weight, .reps], category: .chest),
        Exercise(name: "Low Cable Fly", selectedMetrics: [.weight, .reps], category: .chest),
        Exercise(name: "Mid Cable Fly", selectedMetrics: [.weight, .reps], category: .chest),
        Exercise(name: "Pullovers", selectedMetrics: [.weight, .reps], category: .chest),
        Exercise(name: "Push-Ups", selectedMetrics: [.reps], category: .chest),
        Exercise(name: "Squeeze Press", selectedMetrics: [.weight, .reps], category: .chest),
        
        // Back Exercises
        Exercise(name: "Close-grip seated cable row", selectedMetrics: [.weight, .reps], category: .back),
        Exercise(name: "Barbell Row", selectedMetrics: [.weight, .reps], category: .back),
        Exercise(name: "Bent Over Rows", selectedMetrics: [.weight, .reps], category: .back),
        Exercise(name: "Pull-Ups", selectedMetrics: [.reps], category: .back),
        Exercise(name: "High Band Pull", selectedMetrics: [.reps, .custom], category: .back),
        Exercise(name: "Lat Pulldown", selectedMetrics: [.weight, .reps], category: .back),
        Exercise(name: "Lawn Mowers", selectedMetrics: [.weight, .reps], category: .back),
        
        // Leg Exercises
        Exercise(name: "Bent Knee Calf Raises", selectedMetrics: [.reps], category: .legs),
        Exercise(name: "Bulgarian Split Squats", selectedMetrics: [.weight, .reps], category: .legs),
        Exercise(name: "Goblet Squats", selectedMetrics: [.weight, .reps], category: .legs),
        Exercise(name: "Deadlift", selectedMetrics: [.weight, .reps], category: .legs),
        Exercise(name: "Squats", selectedMetrics: [.weight, .reps], category: .legs),
        Exercise(name: "Leg Press", selectedMetrics: [.weight, .reps], category: .legs),
        Exercise(name: "Jumping Lunges", selectedMetrics: [.weight, .reps], category: .legs),
        Exercise(name: "Lunges", selectedMetrics: [.weight, .reps], category: .legs),
        Exercise(name: "Calf Raises", selectedMetrics: [.weight, .reps], category: .legs),
        Exercise(name: "Single Leg Calf Raises", selectedMetrics: [.weight, .reps], category: .legs),
        Exercise(name: "Leg Extensions", selectedMetrics: [.weight, .reps], category: .legs),
        Exercise(name: "Seated Leg Curls", selectedMetrics: [.weight, .reps], category: .legs),
        Exercise(name: "Romanian Dead Lifts - Barbell", selectedMetrics: [.weight, .reps], category: .legs),
        Exercise(name: "Romanian Dead Lifts - Dumbbell", selectedMetrics: [.weight, .reps], category: .legs),
        
        // Arm Exercises
        Exercise(name: "Dips", selectedMetrics: [.reps], category: .arms),
        Exercise(name: "Bicep Curls", selectedMetrics: [.weight, .reps], category: .arms),
        Exercise(name: "Banded Shoulder Abduction", selectedMetrics: [.reps, .custom], category: .arms),
        Exercise(name: "Chin-Ups", selectedMetrics: [.weight, .reps], category: .arms),
        Exercise(name: "Alternating Iso Hold Curls", selectedMetrics: [.weight, .reps], category: .arms),
        Exercise(name: "Tricep Extensions", selectedMetrics: [.weight, .reps], category: .arms),
        Exercise(name: "Front Raises", selectedMetrics: [.weight, .reps], category: .arms),
        Exercise(name: "Lateral Raises", selectedMetrics: [.weight, .reps], category: .arms),
        Exercise(name: "Shrugs", selectedMetrics: [.weight, .reps], category: .arms),
        Exercise(name: "Tricep Rope Pressdown", selectedMetrics: [.weight, .reps], category: .arms),
        Exercise(name: "Shoulder Halos", selectedMetrics: [.weight, .reps], category: .arms),
        Exercise(name: "Hammer Curls", selectedMetrics: [.weight, .reps], category: .arms),
        Exercise(name: "Military Press - Barbell", selectedMetrics: [.weight, .reps], category: .arms),
        Exercise(name: "Overhead Cable Tricep Rope Extension", selectedMetrics: [.weight, .reps], category: .arms),
        Exercise(name: "Military Press - Dumbbell", selectedMetrics: [.weight, .reps], category: .arms),
        Exercise(name: "Rear Delt Raises", selectedMetrics: [.weight, .reps], category: .arms),
        Exercise(name: "Skull Crushers", selectedMetrics: [.weight, .reps], category: .arms),
        Exercise(name: "Single Arm Overhead Press", selectedMetrics: [.weight, .reps], category: .arms),
        
        // Core/Stomach Exercises
        Exercise(name: "Planks", selectedMetrics: [.time], category: .core),
        Exercise(name: "Russian Twists", selectedMetrics: [.weight, .reps], category: .core),
        Exercise(name: "Hanging Knee Raises", selectedMetrics: [.reps], category: .core),
        Exercise(name: "Incline Sit-Ups", selectedMetrics: [.weight, .reps], category: .core),
        Exercise(name: "Sit-Ups", selectedMetrics: [.reps], category: .core),
        Exercise(name: "Leg Raises", selectedMetrics: [.reps], category: .core),
        Exercise(name: "Crunches", selectedMetrics: [.reps], category: .core),
        Exercise(name: "Resistance Band Chop", selectedMetrics: [.reps, .custom], category: .core),
        Exercise(name: "Bycycle Crunches", selectedMetrics: [.reps], category: .core),
        Exercise(name: "Flutter Kicks", selectedMetrics: [.reps], category: .core),
        
        // Cardio Exercises
        Exercise(name: "Running", selectedMetrics: [.distance, .time, .calories], category: .cardio),
        Exercise(name: "Cycling", selectedMetrics: [.distance, .time, .calories], category: .cardio),
        Exercise(name: "Swimming", selectedMetrics: [.distance, .time, .calories], category: .cardio),
        Exercise(name: "Jump Rope", selectedMetrics: [.time, .calories], category: .cardio),
        Exercise(name: "Walking", selectedMetrics: [.time, .distance], category: .cardio),
        Exercise(name: "Assault Bike", selectedMetrics: [.time, .calories], category: .cardio),
        Exercise(name: "Elliptical", selectedMetrics: [.time, .calories], category: .cardio),
        
        // HIIT Exercises
        Exercise(name: "Box Jumps", selectedMetrics: [.reps, .time], category: .hiit),
        Exercise(name: "Burpees", selectedMetrics: [.reps, .time], category: .hiit),
        Exercise(name: "Kettlebell Swings", selectedMetrics: [.weight, .reps], category: .hiit),
        Exercise(name: "Mountain Climbers", selectedMetrics: [.reps, .time], category: .hiit),
        Exercise(name: "Navy Seals", selectedMetrics: [.reps], category: .hiit),
        Exercise(name: "Tire Flip", selectedMetrics: [.reps], category: .hiit),
        Exercise(name: "Slam Ball Squat Slams", selectedMetrics: [.weight, .reps], category: .hiit),
        
        // Crossfit Exercises
        Exercise(name: "Clean and Jerk", selectedMetrics: [.weight, .reps], category: .crossfit),
        Exercise(name: "Plank Press Up", selectedMetrics: [.reps], category: .crossfit),
        Exercise(name: "Hang Clean and Press - Kettlebell", selectedMetrics: [.weight, .reps], category: .crossfit),
        Exercise(name: "Hang Clean and Press - Barbell", selectedMetrics: [.weight, .reps], category: .crossfit),
        Exercise(name: "Low Kettlebell Clean and Press", selectedMetrics: [.weight, .reps], category: .crossfit),
        Exercise(name: "Snatch", selectedMetrics: [.weight, .reps], category: .crossfit),
        Exercise(name: "Thrusters", selectedMetrics: [.weight, .reps], category: .crossfit),
        Exercise(name: "Wall Balls", selectedMetrics: [.weight, .reps], category: .crossfit)
    ]
}
