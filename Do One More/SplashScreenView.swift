import SwiftUI
import AVKit

struct SplashScreenView: View {
    @AppStorage("hasSeenSplashScreen") private var hasSeenSplashScreen = false
    @State private var doNotShowAgain = false
    @State private var showMainApp = false
    @Environment(\.theme) var theme
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        if showMainApp || hasSeenSplashScreen {
            ContentView(
                exercises: UserDefaultsManager.loadExercises(),
                exerciseRecords: [ExerciseRecord()]
            )
        } else {
            ZStack {
                theme.backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Image("AppLogo") // Make sure to add your app logo to assets
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
                    
                    // Do not show again checkbox
                    Toggle(isOn: $doNotShowAgain) {
                        Text("Don't show this screen again")
                            .foregroundColor(.white)
                    }
                    .toggleStyle(CheckboxToggleStyle())
                    .padding(.horizontal)
                    
                    Button(action: {
                        if doNotShowAgain {
                            hasSeenSplashScreen = true
                        }
                        showMainApp = true
                    }) {
                        Text("Get Started")
                            .font(theme.secondaryFont)
                            .foregroundColor(theme.buttonTextColor)
                            .padding(theme.buttonPadding)
                            .frame(maxWidth: .infinity)
                            .background(theme.buttonBackgroundColor)
                            .cornerRadius(theme.buttonCornerRadius)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 40)
            }
        }
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(.orange)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}

#Preview {
    SplashScreenView()
        .environment(\.theme, AppTheme())
} 
