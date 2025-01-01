import Foundation
import SwiftUI

class QuoteManager: ObservableObject {
    @Published var currentQuote: String?
    @Published var showQuote: Bool = true
    private var timer: Timer?
    private let displayDuration: TimeInterval = 60  // 1 minute
    private let intervalBetweenQuotes: TimeInterval = 600  // 10 minutes
    private var isTimerActive = false
    
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
        let quotes = [
            "Discipline crushes excuses. Start now.",
            "Pain is the proof you're getting stronger.",
            "One more rep is where growth begins.",
            "Comfort is the enemy. Seek the challenge.",
            "Dominate your weaknesses before they dominate you.",
            "You're not tired; your mind is lying to you.",
            "Small wins stack into unstoppable momentum.",
            "The hardest day builds the strongest you.",
            "You're not done when it's easy; you're done when it's right.",
            "Chaos in the gym creates order in your life.",
            "Suffer now, succeed forever.",
            "The grind doesn't care about how you feel—do it anyway.",
            "Every excuse is a step backwards. Take a step forward.",
            "When you hit the wall, that's when the real work starts.",
            "The weight doesn't get lighter—you get stronger.",
            "Earn your progress rep by rep.",
            "Stay relentless. Weakness doesn't take breaks.",
            "One battle at a time, one victory closer to your best self.",
            "No shortcuts. Just hard work and grit.",
            "Your limits are only as real as you believe they are.",
            "Every failure is fuel—burn it to rise again.",
            "The path forward is simple: step, push, grow.",
            "Strength is built in the struggle, not the ease.",
            "Don't count the reps—make the reps count.",
            "Wake up. Show up. Push forward."
        ]
        return quotes.randomElement() ?? "Keep pushing!"
    }
    
    deinit {
        timer?.invalidate()
    }
} 
