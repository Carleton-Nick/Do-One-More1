import SwiftUI

struct SplashScreenView2: View {
    @Environment(\.theme) var theme
    
    var body: some View {
        ZStack {
            theme.backgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                
                Text("Do One More")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.orange)

                Text("Progress made simple.")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                // Placeholder for Video Player
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 300)
                        .cornerRadius(12)
                    
                    VStack {
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        Text("Tutorial Video")
                            .foregroundColor(.white)
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 40)
        }
        .navigationBarTitle("Help", displayMode: .inline)
    }
} 