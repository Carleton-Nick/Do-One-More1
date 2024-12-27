import Foundation

class QuoteManager: ObservableObject {
    @Published var showQuote = false
    @Published var currentQuote: String? = nil
    private var hasShownQuoteThisSession = false
    
    func showMotivationalQuote() {
        guard !hasShownQuoteThisSession else { return }
        
        hasShownQuoteThisSession = true
        currentQuote = MotivationalQuotes.getRandomQuote()
        showQuote = true
        
        // Hide the quote after 60 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
            self.showQuote = false
            self.currentQuote = nil
        }
    }
} 