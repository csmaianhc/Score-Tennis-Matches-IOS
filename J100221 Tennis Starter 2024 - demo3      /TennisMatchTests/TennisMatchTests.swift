//
//  TennisMatchTests.swift
//  TennisMatchTests
//
//  Created by Mabook on 23/2/25.
//  Copyright © 2025 University of Chester. All rights reserved.
//

import XCTest
@testable import TennisStarter

/* Suggestions by default 
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
*/


final class TennisMatchTests: XCTestCase {
    
    var match: TennisMatch!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        match = TennisMatch()
    }
    
    override func tearDownWithError() throws {
        match = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertEqual(match.player1Sets(), 0, "Player 1 should start with 0 sets")
        XCTAssertEqual(match.player2Sets(), 0, "Player 2 should start with 0 sets")
        XCTAssertEqual(match.player1CurrentGames(), 0, "Player 1 should start with 0 games")
        XCTAssertEqual(match.player2CurrentGames(), 0, "Player 2 should start with 0 games")
        XCTAssertEqual(match.player1GameScore(), "0", "Player 1 should start with score 0")
        XCTAssertEqual(match.player2GameScore(), "0", "Player 2 should start with score 0")
        XCTAssertFalse(match.complete(), "Match should not be complete at start")
        XCTAssertTrue(match.isPlayer1Serving(), "Player 1 should serve first")
    }
    
    // MARK: - Game Progression Tests
    
    func testWinningAPoint() {
        _ = match.addPointToPlayer1()
        XCTAssertEqual(match.player1GameScore(), "15", "Player 1 should have score 15 after winning a point")
        XCTAssertEqual(match.player2GameScore(), "0", "Player 2 should still have score 0")
    }
    
    func testWinningAGame() {
        // Player 1 wins a game
        for _ in 0..<4 {
            _ = match.addPointToPlayer1()
        }
        
        XCTAssertEqual(match.player1CurrentGames(), 1, "Player 1 should have 1 game after winning")
        XCTAssertEqual(match.player2CurrentGames(), 0, "Player 2 should still have 0 games")
        XCTAssertEqual(match.player1GameScore(), "0", "New game should have started")
        XCTAssertEqual(match.player2GameScore(), "0", "New game should have started")
    }
    
    // MARK: - Set Progression Tests
    
    func testWinningASet() {
        // Player 1 wins 6 games (a set)
        for _ in 0..<6 {
            for _ in 0..<4 {
                _ = match.addPointToPlayer1()
            }
        }
        
        XCTAssertEqual(match.player1Sets(), 1, "Player 1 should have 1 set after winning 6 games")
        XCTAssertEqual(match.player2Sets(), 0, "Player 2 should still have 0 sets")
        XCTAssertEqual(match.player1CurrentGames(), 0, "New set should have started")
        XCTAssertEqual(match.player2CurrentGames(), 0, "New set should have started")
    }
    
    // MARK: - Match Completion Tests
    
    func testWinningTheMatch() {
        // Player 1 wins 3 sets (best of 5)
        for _ in 0..<3 {
            for _ in 0..<6 {
                for _ in 0..<4 {
                    _ = match.addPointToPlayer1()
                }
            }
        }
        
        XCTAssertTrue(match.complete(), "Match should be complete after player 1 wins 3 sets")
        XCTAssertTrue(match.player1Won(), "Player 1 should have won the match")
        XCTAssertFalse(match.player2Won(), "Player 2 should not have won the match")
    }
    
    func testMatchNotCompleteAfter2Sets() {
        // Player 1 wins 2 sets
        for _ in 0..<2 {
            for _ in 0..<6 {
                for _ in 0..<4 {
                    _ = match.addPointToPlayer1()
                }
            }
        }
        
        XCTAssertFalse(match.complete(), "Match should not be complete after player 1 wins only 2 sets")
        XCTAssertFalse(match.player1Won(), "Player 1 should not have won the match yet")
    }
    
    // MARK: - Server Change Tests
    
    func testServerChangeAfterGame() {
        XCTAssertTrue(match.isPlayer1Serving(), "Player 1 should serve first")
        
        // Player 1 wins a game
        for i in 0..<4 {
            let serverChanged = match.addPointToPlayer1()
            // Only the last point should change the server
            if i == 3 {
                XCTAssertTrue(serverChanged, "Server should change after a game")
                XCTAssertFalse(match.isPlayer1Serving(), "Player 2 should be serving after player 1 wins a game")
            } else {
                XCTAssertFalse(serverChanged, "Server should not change during a game")
            }
        }
    }
    
    func testServerChangeInTiebreak() {
        // Get to 6-6 (tiebreak)
        for _ in 0..<6 {
            for _ in 0..<4 { _ = match.addPointToPlayer1() }
            for _ in 0..<4 { _ = match.addPointToPlayer2() }
        }
        
        // Record who serves first in tiebreak
        let initialServer = match.isPlayer1Serving()
        
        // First point - server should change
        let firstPoint = match.addPointToPlayer1()
        XCTAssertTrue(firstPoint, "Server should change after first point in tiebreak")
        XCTAssertNotEqual(match.isPlayer1Serving(), initialServer, "Server should change after first point")
        
        // Second point - server should not change
        let secondPoint = match.addPointToPlayer1()
        XCTAssertFalse(secondPoint, "Server should not change after second point in tiebreak")
        
        // Third point - server should change
        let thirdPoint = match.addPointToPlayer1()
        XCTAssertTrue(thirdPoint, "Server should change after third point in tiebreak")
    }
    
    // MARK: - Previous Set Scores Tests
    
    func testPreviousSetsScores() {
        // Player 1 wins first set 6-4
        for _ in 0..<4 {
            for _ in 0..<4 { _ = match.addPointToPlayer2() }
        }
        for _ in 0..<6 {
            for _ in 0..<4 { _ = match.addPointToPlayer1() }
        }
        
        let previousScores = match.previousSetsScores()
        XCTAssertEqual(previousScores.count, 1, "Should have one previous set")
        XCTAssertEqual(previousScores[0].0, 6, "Player 1 should have 6 games in previous set")
        XCTAssertEqual(previousScores[0].1, 4, "Player 2 should have 4 games in previous set")
    }
    
    // MARK: - Game/Set/Match Point Tests
    
    func testGamePointDetection() {
        // Get to 40-0
        for _ in 0..<3 {
            _ = match.addPointToPlayer1()
        }
        
        XCTAssertTrue(match.hasPlayer1GamePoint(), "Player 1 should have game point at 40-0")
        XCTAssertFalse(match.hasPlayer2GamePoint(), "Player 2 should not have game point at 40-0")
    }
    
    func testSetPointDetection() {
        // Player 1 wins 5 games
        for _ in 0..<5 {
            for _ in 0..<4 {
                _ = match.addPointToPlayer1()
            }
        }
        
        // Get to 40-0 in the next game
        for _ in 0..<3 {
            _ = match.addPointToPlayer1()
        }
        
        XCTAssertTrue(match.hasPlayer1SetPoint(), "Player 1 should have set point at 5-0, 40-0")
        XCTAssertFalse(match.hasPlayer2SetPoint(), "Player 2 should not have set point")
    }
    
    func testMatchPointDetection() {
        // Player 1 wins 2 sets
        for _ in 0..<2 {
            for _ in 0..<6 {
                for _ in 0..<4 {
                    _ = match.addPointToPlayer1()
                }
            }
        }
        
        // Player 1 wins 5 games in third set
        for _ in 0..<5 {
            for _ in 0..<4 {
                _ = match.addPointToPlayer1()
            }
        }
        
        // Get to 40-0 in the next game
        for _ in 0..<3 {
            _ = match.addPointToPlayer1()
        }
        
        XCTAssertTrue(match.hasPlayer1MatchPoint(), "Player 1 should have match point")
        XCTAssertFalse(match.hasPlayer2MatchPoint(), "Player 2 should not have match point")
    }
    
    // MARK: - Reset Tests
    
    func testReset() {
        // Play some points
        for _ in 0..<10 {
            _ = match.addPointToPlayer1()
        }
        
        // Reset the match
        match.reset()
        
        // Check initial state is restored
        XCTAssertEqual(match.player1Sets(), 0, "Player 1 should have 0 sets after reset")
        XCTAssertEqual(match.player2Sets(), 0, "Player 2 should have 0 sets after reset")
        XCTAssertEqual(match.player1CurrentGames(), 0, "Player 1 should have 0 games after reset")
        XCTAssertEqual(match.player2CurrentGames(), 0, "Player 2 should have 0 games after reset")
        XCTAssertEqual(match.player1GameScore(), "0", "Player 1 should have score 0 after reset")
        XCTAssertEqual(match.player2GameScore(), "0", "Player 2 should have score 0 after reset")
        XCTAssertTrue(match.isPlayer1Serving(), "Player 1 should serve first after reset")
    }
    
    // MARK: - Tiebreak Tests
    
    func testTiebreakDetection() {
        // Get to 6-6
        for _ in 0..<6 {
            for _ in 0..<4 { _ = match.addPointToPlayer1() }
            for _ in 0..<4 { _ = match.addPointToPlayer2() }
        }
        
        XCTAssertTrue(match.isCurrentGameTieBreak(), "Should detect tiebreak at 6-6")
    }
}
