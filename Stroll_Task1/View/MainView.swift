//
//  MainView.swift
//  Stroll_Task1
//
//  Created by Renaldi Antonio on 18/06/25.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
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
            }label: {
                Label("Matches", image: "matches")
            }
            
            Tab {
                
            }label: {
                Label("Profile", image: "profile")
            }
        }
        .toolbarColorScheme(.light, for: .tabBar)
        .toolbarBackground(.red, for: .tabBar)
        .toolbarBackgroundVisibility(.visible, for: .tabBar)
    }
}

#Preview {
    MainView()
}
