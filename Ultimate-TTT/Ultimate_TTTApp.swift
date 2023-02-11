//
//  Ultimate_TTTApp.swift
//  Ultimate-TTT
//
//  Created by Shyam Kumar on 2/11/23.
//

import SwiftUI

@main
struct Ultimate_TTTApp: App {
    @StateObject var gameManager = GameManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameManager)
        }
    }
}
