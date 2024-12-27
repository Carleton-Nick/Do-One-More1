import Foundation

struct MotivationalQuotes {
    static let quotes = [
        "One more rep, one step closer.",
        "Your future self is watching you right now.",
        "The only bad workout is the one that didn't happen.",
        "Progress is progress, no matter how small.",
        "You're stronger than you think.",
        "Every rep counts. Make it happen.",
        "Small steps, big changes.",
        "Your only competition is yourself.",
        "Yesterday you said tomorrow.",
        "Strength doesn't come from what you can do. It comes from overcoming the things you once thought you couldn't.",
        "You have to lift the weights, you do the work.  No one can do it for you.",
        // Add more quotes as desired
    ]
    
    static func getRandomQuote() -> String {
        quotes.randomElement() ?? "Push yourself, because no one else is going to do it for you."
    }
} 
