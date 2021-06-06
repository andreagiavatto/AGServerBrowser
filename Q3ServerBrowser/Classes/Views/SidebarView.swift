//
//  SidebarView.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 06/06/2021.
//

import SwiftUI
import GameServerQueryLibrary

struct SidebarView: View {
    let supportedGames = SupportedGames.allCases.map { Game(type: $0) }
    
    var body: some View {
        NavigationView {
            List {
                //Caption
                Text("Games")
                Spacer()
                ForEach(supportedGames) { game in
                    NavigationLink(destination: ContentView(game: game)) {
                        Label(game.name, systemImage: "message")
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Q3ServerBrowser")
            //Set Sidebar Width (and height)
            .frame(minWidth: 150, idealWidth: 250, maxWidth: 300)
            .toolbar{
                //Toggle Sidebar Button
                ToolbarItem(placement: .navigation){
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "sidebar.left")
                    })
                }
            }
            //Default View on Mac
            MainView()
        }
    }
    
    func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
    }
}
