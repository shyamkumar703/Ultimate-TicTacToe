//
//  Ultimate_TTTTests.swift
//  Ultimate-TTTTests
//
//  Created by Shyam Kumar on 2/11/23.
//

import XCTest
@testable import Ultimate_TTT

final class Ultimate_TTTTests: XCTestCase {
    
    func testGameManagerInit_IsInProgress() {
        let sut = GameManager()
        switch sut.gameState {
        case .inProgress: XCTAssertTrue(true) // game in progress
        default: XCTFail("Game should be in progress")
        }
    }
    
    func testGameManagerInit_HasCorrectDimensions() {
        let sut = GameManager()
        switch sut.gameState {
        case .inProgress(let state):
            // board is 3x3
            XCTAssertEqual(state.count, 3)
            XCTAssertEqual(state[0].count, 3)
            
            // each small board is 3x3 and in progress
            for smallBoardRow in state {
                for smallBoardState in smallBoardRow {
                    switch smallBoardState {
                    case .red, .green: XCTFail("Board should be in progress")
                    case .inProgress(let state):
                        // small board is 3x3
                        XCTAssertEqual(state.count, 3)
                        XCTAssertEqual(state[0].count, 3)
                        
                        // each spot is empty to start
                        for spotRow in state {
                            for spot in spotRow {
                                switch spot {
                                case .red, .green: XCTFail("Spot should be empty")
                                case .empty: continue
                                }
                            }
                        }
                    }
                }
            }
        default: XCTFail("Game should be in progress")
        }
    }
}
