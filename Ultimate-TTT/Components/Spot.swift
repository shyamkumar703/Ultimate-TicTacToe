//
//  Spot.swift
//  Ultimate-TTT
//
//  Created by Shyam Kumar on 2/11/23.
//

import SwiftUI

struct SpotIndex {
    var smallBoardIndexX: Int
    var smallBoardIndexY: Int
    var spotIndexX: Int
    var spotIndexY: Int
}

struct Spot: View {
    @EnvironmentObject var gameManager: GameManager
    
    var size: CGFloat = (UIScreen.main.bounds.width - 72) / 9
    var spotIndex: SpotIndex
    
    var foregroundColor: Color {
        switch gameManager.gameState {
        case .green: return .green
        case .red: return .red
        case .inProgress(let state):
            let smallBoardState = state[spotIndex.smallBoardIndexX][spotIndex.smallBoardIndexY]
            switch smallBoardState {
            case .red: return .red
            case .green: return .green
            case .inProgress(let state):
                let spotState = state[spotIndex.spotIndexX][spotIndex.spotIndexY]
                switch spotState {
                case .red: return .red
                case .green: return .green
                case .empty: return .gray.opacity(0.4)
                }
            }
        }
    }
    
    var body: some View {
        Rectangle()
            .frame(width: size, height: size)
            .cornerRadius(8)
            .foregroundColor(foregroundColor)
            .onTapGesture {
                gameManager.handleUserTap(at: spotIndex)
            }
    }
}

struct Spot_Previews: PreviewProvider {
    static var previews: some View {
        Spot(spotIndex: SpotIndex(smallBoardIndexX: 0, smallBoardIndexY: 0, spotIndexX: 0, spotIndexY: 0))
            .environmentObject(GameManager())
    }
}
