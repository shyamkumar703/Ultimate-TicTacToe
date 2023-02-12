//
//  ContentView.swift
//  Ultimate-TTT
//
//  Created by Shyam Kumar on 2/11/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameManager: GameManager
    var navigationTitle: String {
        switch gameManager.gameState {
        case .inProgress: return "In progress"
        case .draw: return "Draw"
        case .green: return "User wins"
        case .red: return "AI wins"
        }
    }
    
    var body: some View {
        NavigationView {
            Board()
                .environmentObject(gameManager)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Reset") {
                            withAnimation {
                                gameManager.reset()
                            }
                        }
                    }
                    
                }
                .navigationTitle(navigationTitle)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(GameManager())
    }
}
