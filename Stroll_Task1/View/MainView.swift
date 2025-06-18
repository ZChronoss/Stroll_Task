import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            Group {
                Tab {
                    
                }label: {
                    Label("Cards", image: "cards")
                }
                
                Tab {
                    
                }label: {
                    Label("Bonfire", image: "bonfire")
                }
                
                Tab {
                    ChatView()
                        .toolbarVisibility(.visible, for: .tabBar)
                        .toolbarBackground(.visible, for: .tabBar)
                        .toolbarBackground(.tabBar, for: .tabBar)
                }label: {
                    Label("Matches", image: "matches")
                }
                
                Tab {
                    
                }label: {
                    Label("Profile", image: "profile")
                }
            }
        }
    }
}

#Preview {
    MainView()
}
