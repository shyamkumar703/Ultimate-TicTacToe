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
    case draw([[SpotState]])
    
    func isEqual(to state: SmallBoardState) -> Bool {
        switch (self, state) {
        case (.red, .red): return true
        case (.green, .green): return true
        case (.draw, .draw): return true
        case (.inProgress, .inProgress): return true
        default: return false
        }
    }
}

enum GameState {
    case inProgress([[SmallBoardState]])
    case red([[SmallBoardState]]) // game won by red
    case green([[SmallBoardState]]) // game won by green
    case draw([[SmallBoardState]])
    
    func isEqual(to state: GameState) -> Bool {
        switch (self, state) {
        case (.red, .red): return true
        case (.green, .green): return true
        case (.draw, .draw): return true
        case (.inProgress, .inProgress): return true
        default: return false
        }
    }
}

class GameManager: ObservableObject {
    @Published var gameState: GameState
    var isUserTurn: Bool = true
    var isGameOver: Bool {
        gameState.isEqual(to: .red([])) || gameState.isEqual(to: .green([])) || gameState.isEqual(to: .draw([]))
    }
    
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
    
    func reset() {
        var state = [[SmallBoardState]]()
        for _ in 0..<3 {
            state.append([])
            for _ in 0..<3 {
                state[state.count - 1].append(.inProgress(Self.generateEmptySmallBoardState()))
            }
        }
        
        gameState = .inProgress(state)
        isUserTurn = true
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
    
    private func setDrawStateForSmallBoardAt(x: Int, y: Int) {
        switch gameState {
        case .inProgress(var state):
            let currentSmallBoardState = state[x][y]
            switch currentSmallBoardState {
            case .inProgress(let spotStates):
                state[x][y] = .draw(spotStates)
                gameState = .inProgress(state)
            default: return
            }
        default: return
        }
    }
    
    // MARK: - Game mechanics
    enum Player {
        case user
        case ai
    }
    
    func handleMove(at index: SpotIndex, by player: Player) {
        // TODO: Change state accordingly, check for win/loss, call AI
        guard !isGameOver else { return }
        if player == .user {
            guard isUserTurn else { return }
        } else {
            guard !isUserTurn else { return }
        }
        switch gameState {
        case .inProgress(var state):
            let smallBoard = state[index.smallBoardIndexX][index.smallBoardIndexY]
            switch smallBoard {
            case .inProgress(var spotStates):
                let spot = spotStates[index.spotIndexX][index.spotIndexY]
                switch spot {
                case .empty:
                    spotStates[index.spotIndexX][index.spotIndexY] = player == .user ? .green : .red
                    state[index.smallBoardIndexX][index.smallBoardIndexY] = .inProgress(spotStates)
                    DispatchQueue.main.async { [weak self] in
                        withAnimation {
                            guard let self = self else { return }
                            self.gameState = .inProgress(state)
                            if self.checkForSmallBoardWin(gameState: state, x: index.smallBoardIndexX, y: index.smallBoardIndexY) {
                                self.checkForGameWin()
                            }
                            self.isUserTurn.toggle()
                            if !self.isGameOver && player == .user {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    switch self.gameState {
                                    case .inProgress(let state): self.handleMove(at: AI.computeMove(currentState: state), by: .ai)
                                    default: return
                                    }
                                }
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
    
    private func reduce(_ spotStates: [SpotState], matching state: SpotState) -> Bool {
        return spotStates.map({ $0 == state ? 1 : 0 }).reduce(0, +) == 3
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
            
            if spotStates.flatMap({ $0 }).filter({ $0 == .empty }).count == 0 {
                setDrawStateForSmallBoardAt(x: x, y: y)
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
            
            if state.flatMap({ $0 }).filter({ $0.isEqual(to: .inProgress([])) }).isEmpty {
                gameState = .draw(state)
                return
            }
            
        default: return // game is already over
        }
    }
}
