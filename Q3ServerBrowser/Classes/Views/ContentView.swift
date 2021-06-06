//
//  ContentView.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 06/06/2021.
//

import SwiftUI
import GameServerQueryLibrary

struct ContentView: View {
    private let game: Game
    @ObservedObject private var gsqlWrapper = GSQLWrapper()
    
    init(game: Game) {
        self.game = game
        gsqlWrapper.updateServers(for: game, fromMaster: game.defaultMasterServer)
    }
    
    var body: some View {
        List(gsqlWrapper.servers, id: \.hostname) { server in
            Text(server.name)
        }
    }
}
