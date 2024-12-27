import SwiftUI

struct MotivationalQuoteView: View {
    let quote: String
    @State private var opacity: Double = 1.0
    
    var body: some View {
        Text(quote)
            .font(.system(.subheadline, design: .rounded))
            .italic()
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