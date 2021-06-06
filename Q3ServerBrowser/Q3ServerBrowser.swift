//
//  AppDelegate.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 19/09/10.
//  Copyright 2010 Andrea Giavatto. All rights reserved.
//

import GameServerQueryLibrary
import SwiftUI

@main
struct Q3ServerBrowser: App {
    var body: some Scene {
        WindowGroup {
            SidebarView()
        }
    }
}
