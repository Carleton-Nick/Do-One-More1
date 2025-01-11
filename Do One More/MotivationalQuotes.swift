import Foundation

struct MotivationalQuotes {
    static let quotes = [
        "The only bad workout is the one you didn't do. - Nick Carleton",
        "It's not about perfection, it's about consistency. - Nick Carleton",
        "the only reps that count are the ones in the struggle. - Nick Carleton",
        "It's not about what somebody else is doing.  It's you versus you. - Nick Carleton",
        "Yesterday you said tomorrow. Do what you said you were going to do. - Nick Carleton",
        "You lift the weights, you do the work. No one can do it for you. - Nick Carleton",
        // Add more quotes as desired
    ]
    
    static func getRandomQuote() -> String {
        quotes.randomElement() ?? "Push yourself, because no one else is going to do it for you."
    }
} 
