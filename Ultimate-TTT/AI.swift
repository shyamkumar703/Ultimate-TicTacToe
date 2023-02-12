//
//  AI.swift
//  Ultimate-TTT
//
//  Created by Shyam Kumar on 2/11/23.
//

import Foundation

class AI {
    // TODO: - Marshall
    public static func computeMove(currentState: [[SmallBoardState]]) -> SpotIndex {
        for (bigBoardX, bigBoardRow) in currentState.enumerated() {
            for (bigBoardY, smallBoard) in bigBoardRow.enumerated() {
                switch smallBoard {
                case .red, .green, .draw: continue
                case .inProgress(let spotStates):
                    for (spotX, spotRow) in spotStates.enumerated() {
                        for (spotY, spot) in spotRow.enumerated() {
                            switch spot {
                            case .red, .green: continue
                            case .empty: return SpotIndex(smallBoardIndexX: bigBoardX, smallBoardIndexY: bigBoardY, spotIndexX: spotX, spotIndexY: spotY)
                            }
                        }
                    }
                }
            }
        }
        fatalError()
    }
}
