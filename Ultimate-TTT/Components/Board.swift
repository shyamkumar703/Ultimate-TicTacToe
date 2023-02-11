//
//  Board.swift
//  Ultimate-TTT
//
//  Created by Shyam Kumar on 2/11/23.
//

import SwiftUI

struct Board: View {
    @EnvironmentObject var gameManager: GameManager
    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<3) { x in
                HStack(spacing: 16) {
                    ForEach(0..<3) { y in
                        SmallBoard(index: SmallBoardIndex(x: x, y: y))
                    }
                }
            }
        }
    }
}

struct Board_Previews: PreviewProvider {
    static var previews: some View {
        Board()
            .environmentObject(GameManager())
    }
}
