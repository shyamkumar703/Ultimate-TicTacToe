//
//  GameManager.swift
//  Ultimate-TTT
//
//  Created by Shyam Kumar on 2/11/23.
//

import Foundation

enum SpotState {
    case red // spot occupied by red
    case green // spot occupied by green
    case empty
}

enum SmallBoardState {
    case inProgress([[SpotState]])
    case red([[SpotState]]) // small board won by red
    case green([[SpotState]]) // small board won by green
}

enum GameState {
    case inProgress([[SmallBoardState]])
    case red([[SmallBoardState]]) // game won by red
    case green([[SmallBoardState]]) // game won by green
}

class GameManager: ObservableObject {
    @Published var gameState: GameState
    
    init() {
        // construct starting gameState
        var state = [[SmallBoardState]]()
        for _ in 0..<3 {
            state.append([])
            for _ in 0..<3 {
                state[state.count - 1].append(.inProgress(Self.generateEmptySmallBoardState()))
            }
        }
        
        gameState = .inProgress(state)
    }
    
    private static func generateEmptySmallBoardState() -> [[SpotState]] {
        var state = [[SpotState]]()
        for _ in 0..<3 {
            state.append([])
            for _ in 0..<3 {
                state[state.count - 1].append(.empty)
            }
        }
        return state
    }
    
    // MARK: - Game mechanics
    func handleUserTap(at index: SpotIndex) {
        // TODO: Change state accordingly, check for win/loss, call AI
    }
}
