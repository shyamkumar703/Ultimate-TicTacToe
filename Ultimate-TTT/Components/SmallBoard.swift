//
//  SmallBoard.swift
//  Ultimate-TTT
//
//  Created by Shyam Kumar on 2/11/23.
//

import SwiftUI

struct SmallBoardIndex {
    var x: Int
    var y: Int
}

struct SmallBoard: View {
    @EnvironmentObject var gameManager: GameManager
    var index: SmallBoardIndex
    
    var body: some View {
        VStack(spacing: 4) {
            switch gameManager.gameState {
            case .inProgress(let state): constructBoard(from: state)
            case .green(let state): constructBoard(from: state)
            case .red(let state): constructBoard(from: state)
            case .draw(let state): constructBoard(from: state)
            }
        }
    }
    
    func constructBoard(from state: [[SmallBoardState]]) -> some View {
        let currentBoardState = state[index.x][index.y]
        switch currentBoardState {
        case .inProgress(let state):
            return constructBoard(from: state)
        case .red(let state):
            return constructBoard(from: state)
        case .green(let state):
            return constructBoard(from: state)
        case .draw(let state):
            return constructBoard(from: state)
        }
    }
    
    func constructBoard(from state: [[SpotState]]) -> some View {
        return ForEach(0..<3) { x in
            HStack(spacing: 4) {
                ForEach(0..<3) { y in
                    Spot(spotIndex: SpotIndex(smallBoardIndexX: index.x, smallBoardIndexY: index.y, spotIndexX: x, spotIndexY: y))
                        .environmentObject(gameManager)
                }
            }
        }
    }
}

struct SmallBoard_Previews: PreviewProvider {
    static var previews: some View {
        SmallBoard(index: SmallBoardIndex(x: 0, y: 0))
            .environmentObject(GameManager())
    }
}
