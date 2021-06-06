//
//  GSQLWrapper.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 06/06/2021.
//

import GameServerQueryLibrary
import SwiftUI

class GSQLWrapper: NSObject, ObservableObject {
    @Published var servers: [Server] = []
    private var coordinator: Coordinator?
    
    func updateServers(for game: Game, fromMaster master: MasterServer) {
        coordinator = game.coordinator
        coordinator?.delegate = self
        coordinator?.getServersList(host: master.hostname, port: master.port)
    }
}

extension GSQLWrapper: CoordinatorDelegate {
    func didStartFetchingServersList(for coordinator: Coordinator) {
        servers.removeAll()
    }
    
    func didFinishFetchingServersList(for coordinator: Coordinator) {
        coordinator.fetchServersInfo()
    }
    
    func didFinishFetchingServersInfo(for coordinator: Coordinator) {
        
    }
    
    func coordinator(_ coordinator: Coordinator, didFinishFetchingInfoFor server: Server) {
        DispatchQueue.main.async {
            self.servers.append(server)
        }
    }
    
    func coordinator(_ coordinator: Coordinator, didFinishFetchingStatusFor server: Server) {
        
    }
    
    func coordinator(_ coordinator: Coordinator, didFailWith error: GSQLError) {
        print(error.localizedDescription)
    }
}
