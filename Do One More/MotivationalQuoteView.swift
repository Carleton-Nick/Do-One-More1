import SwiftUI

struct MotivationalQuoteView: View {
    let quote: String
    @State private var opacity: Double = 1.0
    @Environment(\.theme) var theme
    
    var body: some View {
        Text(quote)
            .font(.custom("AvenirNext-Regular", size: 16))
            .foregroundColor(.orange)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 10.0).delay(50)) {
                    opacity = 0
                }
            }
    }
}

#Preview {
    MotivationalQuoteView(quote: "Your future self is watching you right now.")
        .preferredColorScheme(.dark)
} 
