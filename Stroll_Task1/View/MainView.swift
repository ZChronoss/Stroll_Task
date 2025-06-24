import SwiftUI

struct MainView: View {
    init() {
        let tabBarAppearance = UITabBarAppearance()
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.badgeBackgroundColor = .pastelPurple
        tabBarAppearance.backgroundColor = .tabBar
        tabBarAppearance.stackedLayoutAppearance = itemAppearance
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    var body: some View {
        TabView {
            Group {
                Tab {
                    
                }label: {
                    Label("Cards", image: "cards")
                }
                .badge(
                    Text("10")
                )
                
                Tab {
                    
                }label: {
                    Label("Bonfire", image: "bonfire")
                }
                
                Tab {
                    ChatView()
                }label: {
                    Label("Matches", image: "matches")
                }
                
                Tab {
                    
                }label: {
                    Label("Profile", image: "profile")
                }
            }
        }
        .shadow(color: .black, radius: 300, y: 100)
    }
}

#Preview {
    MainView()
}
