//
//  GameManager.swift
//  Ultimate-TTT
//
//  Created by Shyam Kumar on 2/11/23.
//

import Foundation
import SwiftUI


enum SpotState {
    case red // spot occupied by red
    case green // spot occupied by green
    case empty
}

enum SmallBoardState {
    case inProgress([[SpotState]])
    case red([[SpotState]]) // small board won by red
    case green([[SpotState]]) // small board won by green
    
    func isEqual(to state: SmallBoardState) -> Bool {
        switch (self, state) {
        case (.red, .red): return true
        case (.green, .green): return true
        default: return false
        }
    }
}

enum GameState {
    case inProgress([[SmallBoardState]])
    case red([[SmallBoardState]]) // game won by red
    case green([[SmallBoardState]]) // game won by green
}

class GameManager: ObservableObject {
    @Published var gameState: GameState
    var isUserTurn: Bool = true
    
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
    
    private func setWinState(for spotState: SpotState) {
        guard spotState != .empty else { fatalError() }
        var state = [[SmallBoardState]]()
        for _ in 0..<3 {
            state.append([])
            for _ in 0..<3 {
                switch spotState {
                case .red:
                    state[state.count - 1].append(.red(generateSmallBoardWinState(for: spotState)))
                case .green:
                    state[state.count - 1].append(.green(generateSmallBoardWinState(for: spotState)))
                default:
                    fatalError()
                }
            }
        }
        
        switch spotState {
        case .red:
            gameState = .red(state)
        case .green:
            gameState = .green(state)
        default:
            fatalError()
        }
        
    }
    
    private func generateSmallBoardWinState(for spotState: SpotState) -> [[SpotState]] {
        var state = [[SpotState]]()
        for _ in 0..<3 {
            state.append([])
            for _ in 0..<3 {
                state[state.count - 1].append(spotState)
            }
        }
        return state
    }
    
    private func setWinStateForSmallBoardAt(x: Int, y: Int, for spotState: SpotState) {
        switch gameState {
        case .inProgress(var state):
            switch spotState {
            case .red:
                state[x][y] = .red(generateSmallBoardWinState(for: spotState))
            case .green:
                state[x][y] = .green(generateSmallBoardWinState(for: spotState))
            default:
                return
            }
            gameState = .inProgress(state)
        default: return
        }
    }
    
    // MARK: - Game mechanics
    func handleUserTap(at index: SpotIndex) {
        // TODO: Change state accordingly, check for win/loss, call AI
        guard isUserTurn else { return }
        switch gameState {
        case .inProgress(var state):
            let smallBoard = state[index.smallBoardIndexX][index.smallBoardIndexY]
            switch smallBoard {
            case .inProgress(var spotStates):
                let spot = spotStates[index.spotIndexX][index.spotIndexY]
                switch spot {
                case .empty:
                    // something
                    spotStates[index.spotIndexX][index.spotIndexY] = .green
                    state[index.smallBoardIndexX][index.smallBoardIndexY] = .inProgress(spotStates)
                    DispatchQueue.main.async { [weak self] in
                        withAnimation {
                            guard let self = self else { return }
                            self.gameState = .inProgress(state)
                            if self.checkForSmallBoardWin(gameState: state, x: index.smallBoardIndexX, y: index.smallBoardIndexY) {
                                self.checkForGameWin()
                            }
                        }
                    }
                default:
                    return
                }
            default:
                return
            }
        default:
            return
        }
    }
    
    private func reduce(_ spotStates: [SpotState], matching: SpotState) -> Bool {
        return spotStates.map({ $0 == .green ? 1 : 0 }).reduce(0, +) == 3
    }
    
    private func checkForSmallBoardWin(gameState: [[SmallBoardState]], x: Int, y: Int) -> Bool {
        let smallBoardState = gameState[x][y]
        switch smallBoardState {
        case .inProgress(let spotStates):
            for row in spotStates {
                // row check
                if reduce(row, matching: .green) {
                    // green wins this small board
                    setWinStateForSmallBoardAt(x: x, y: y, for: .green)
                    return true
                }
                
                if reduce(row, matching: .red) {
                    // red wins this small board
                    setWinStateForSmallBoardAt(x: x, y: y, for: .red)
                    return true
                }
            }
            
            for index in 0..<3 {
                // column check
                if reduce(spotStates.map({ $0[index] }), matching: .green) {
                    // green wins this small board
                    setWinStateForSmallBoardAt(x: x, y: y, for: .green)
                    return true
                }
                
                if reduce(spotStates.map({ $0[index] }), matching: .red) {
                    // red wins this small board
                    setWinStateForSmallBoardAt(x: x, y: y, for: .red)
                    return true
                }
            }
            
            // leading diagonal check
            if reduce(zip(0..<3, 0..<3).map({ spotStates[$0.0][$0.1] }), matching: .green) {
                // green wins this small board
                setWinStateForSmallBoardAt(x: x, y: y, for: .green)
                return true
            }
            
            if reduce(zip(0..<3, 0..<3).map({ spotStates[$0.0][$0.1] }), matching: .red) {
                // red wins this small board
                setWinStateForSmallBoardAt(x: x, y: y, for: .red)
                return true
            }
            
            // trailing diagonal check
            if reduce([(0, 2), (1, 1), (2, 0)].map({ spotStates[$0.0][$0.1] }), matching: .green) {
                // green wins this small board
                setWinStateForSmallBoardAt(x: x, y: y, for: .green)
                return true
            }
            
            if reduce([(0, 2), (1, 1), (2, 0)].map({ spotStates[$0.0][$0.1] }), matching: .red) {
                // red wins this small board
                setWinStateForSmallBoardAt(x: x, y: y, for: .red)
                return true
            }
            
            return false
        default:
            fatalError()
        }
    }
    
    private func reduce(_ smallBoardStates: [SmallBoardState], matching: SmallBoardState) -> Bool {
        smallBoardStates.map({ $0.isEqual(to: matching) ? 1 : 0 }).reduce(0, +) == 3
    }
    
    private func checkForGameWin() {
        switch gameState {
        case .inProgress(let state):
            for row in state {
                // row check
                if reduce(row, matching: .green([])) {
                    // green wins the game
                    setWinState(for: .green)
                    return
                }
                
                if reduce(row, matching: .red([])) {
                    // red wins the game
                    setWinState(for: .red)
                    return
                }
            }
            
            for index in 0..<3 {
                // column check
                if reduce(state.map({ $0[index] }), matching: .green([])) {
                    // green wins the game
                    setWinState(for: .green)
                    return
                }
                
                if reduce(state.map({ $0[index] }), matching: .red([])) {
                    // red wins the game
                    setWinState(for: .red)
                    return
                }
            }
            
            // TODO: - Diagonal check
            // leading diagonal check
            if reduce(zip(0..<3, 0..<3).map({ state[$0.0][$0.1] }), matching: .green([])) {
                // green wins the game
                setWinState(for: .green)
                return
            }
            
            if reduce(zip(0..<3, 0..<3).map({ state[$0.0][$0.1] }), matching: .red([])) {
                // red wins the game
                setWinState(for: .red)
                return
            }
            
            if reduce([(0, 2), (1, 1), (2, 0)].map({ state[$0.0][$0.1] }), matching: .green([])) {
                // green wins the game
                setWinState(for: .green)
                return
            }
            
            if reduce([(0, 2), (1, 1), (2, 0)].map({ state[$0.0][$0.1] }), matching: .red([])) {
                // green wins the game
                setWinState(for: .red)
                return
            }
            
        default: return // game is already over
        }
    }
}
