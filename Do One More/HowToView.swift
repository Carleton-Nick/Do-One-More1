import SwiftUI

struct HowToView: View {
    @Environment(\.theme) var theme
    
    var body: some View {
        ZStack {
            theme.backgroundColor.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 30) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    
                    Text("Do One More")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Text("How to use this app")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Tutorial sections
                    tutorialSection(
                        title: "Record Your Workouts",
                        description: "Track sets, reps, weight, time, distance, and more for each exercise.",
                        icon: "dumbbell.fill"
                    )
                    
                    tutorialSection(
                        title: "Create Routines",
                        description: "Save your favorite exercise combinations as routines for quick access.",
                        icon: "list.bullet.clipboard.fill"
                    )
                    
                    tutorialSection(
                        title: "Track Progress",
                        description: "View your workout history and export data to analyze your progress.",
                        icon: "chart.line.uptrend.xyaxis"
                    )
                }
                .padding(.vertical, 40)
                .padding(.horizontal)
            }
        }
        .navigationBarTitle("Help", displayMode: .inline)
    }
    
    private func tutorialSection(title: String, description: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.orange)
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Text(description)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(12)
    }
} 