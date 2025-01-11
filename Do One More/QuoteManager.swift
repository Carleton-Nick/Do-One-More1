import Foundation
import SwiftUI

class QuoteManager: ObservableObject {
    @Published var currentQuote: String?
    @Published var showQuote: Bool = true
    private var timer: Timer?
    private let displayDuration: TimeInterval = 60  // 1 minute
    private let intervalBetweenQuotes: TimeInterval = 600  // 10 minutes
    private var isTimerActive = false
    
    private let quotes = [
        "The only bad workout is the one you didn't do.",
        "It's not about perfection, it's about consistency.",
        "The only reps that count are the ones in the struggle.",
        "It's not about what somebody else is doing. It's you versus you.",
        "Yesterday you said tomorrow. Do what you said you were going to do.",
        "You lift the weights, you do the work. No one can do it for you."
    ]
    
    var isTimerRunning: Bool {
        return timer != nil
    }
    
    init() {
        setupQuoteTimer()
    }
    
    func showMotivationalQuote() {
        // Only show a new quote if the timer isn't already running
        guard !isTimerActive else { return }
        
        currentQuote = getRandomQuote()
        showQuote = true
        isTimerActive = true
        
        // Hide quote after displayDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) {
            withAnimation {
                self.showQuote = false
            }
        }
    }
    
    private func setupQuoteTimer() {
        // Show first quote immediately
        showMotivationalQuote()
        
        // Setup timer for recurring quotes
        timer = Timer.scheduledTimer(withTimeInterval: intervalBetweenQuotes, repeats: true) { [weak self] _ in
            self?.isTimerActive = false
            self?.showMotivationalQuote()
        }
    }
    
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
        isTimerActive = false
    }
    
    func resumeTimer() {
        guard timer == nil else { return }
        setupQuoteTimer()
    }
    
    private func getRandomQuote() -> String {
        return quotes.randomElement() ?? "Keep pushing!"
    }
    
    deinit {
        timer?.invalidate()
    }
} 
