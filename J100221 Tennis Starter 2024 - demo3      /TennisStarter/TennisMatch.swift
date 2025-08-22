//
//  TennisMatch.swift
//  TennisStarter
//
//  Created by Mabook on 16/2/25.
//  Copyright © 2025 University of Chester. All rights reserved.
//

import Foundation

// Handles multiple sets, tracking progress, determining the match winner, and manages service changes following tennis rules
 
class TennisMatch {
    // Collection of all sets in the match
    private var sets: [TennisSet] = []
    
    // Index of the current set being played
    private var currentSetIndex: Int = 0
    
    // Track sets won by each player
    private var player1SetsWon: Int = 0
    private var player2SetsWon: Int = 0
    
    // Number of sets needed to win the match (best of 5)
    private let totalSetsNeeded = 3
    
    
    // Track who is serving (true = player 1, false = player 2)
     private var player1Serving: Bool = true
    
    // Track points played in the current tiebreak (for service changes)
     private var tiebreakPointsPlayed: Int = 0
    
    
    // Initialise a new tennis match ( Sets up the first set and assigns player 1 as the first server)
     
    
    init() {
        // Start with the first set
        sets.append(TennisSet())
        
        // Player 1 serves first
        player1Serving = true
    }
    
    /* - Add a point for player 1 and handle set/match progression
       - Manages service changes according to tennis rules
       - Return Bool indicating if server changed */
     
    
    /* demo
     func addPointToPlayer1
     func addPointToPlayer1() {
        // Do nothing if match is already complete
        if complete() {
            return
        }
     */
    
    func addPointToPlayer1() -> Bool {
        // Do nothing if match is already complete
        if complete() {
            return false
        }
        
        let currentSet = sets[currentSetIndex]
        let isInTieBreak = currentSet.isInTieBreak()
        let wasGameComplete = currentSet.isGameComplete()
        let wasSetComplete = currentSet.complete()
        var serverChanged = false
        
        
        // Add point to current set
        
        // let currentSet = sets[currentSetIndex]
        currentSet.addPointToPlayer1()
        
        // Update tiebreak counter if in tiebreak
        if isInTieBreak {
            tiebreakPointsPlayed += 1
        }
        
        
        // Check if the set is complete
        if currentSet.complete() && !wasSetComplete {
            // Update sets won count
            if currentSet.player1Won() {
                player1SetsWon += 1
            }
            else if currentSet.player2Won() {
                player2SetsWon += 1
            }
            
            
            
            // If we were in a tiebreak, the server for the next game is the player
            // who did not serve first in the tiebreak
            
            if isInTieBreak {
                player1Serving = !player1ServingFirstInTiebreak()
            }
            else {
                
                // Otherwise, service alternates normally
                player1Serving = !player1Serving
            }
            
            serverChanged = true
            
            
            // If match is not complete, start a new set
            if !complete() {
                currentSetIndex += 1
                
                // If this will be the fifth set, mark it as the last set
                let isLastSet = currentSetIndex == 4
                sets.append(TennisSet(isLastSet: isLastSet))
                
                // Reset tiebreak counter
                tiebreakPointsPlayed = 0
                
                // return true // Service changed
                
            }
        }
        
        // Check if a regular game completed
        else if currentSet.isGameComplete() && !wasGameComplete && !isInTieBreak {
            
            // Change server after a completed game
            player1Serving = !player1Serving
            serverChanged = true
            
            // return true // Service changed
            
        }
        
        
        // Check for service change during tiebreak
        else if isInTieBreak {
            
            // In tiebreak, service changes after first point, then every 2 points
            if tiebreakPointsPlayed == 1 || tiebreakPointsPlayed > 1 && tiebreakPointsPlayed % 2 == 1 {
                player1Serving = !player1Serving
                
                //return true // Service changed
                serverChanged = true
            }
        }
        
       // return false // No service change
        return serverChanged
    }
    
        
        
        
    /* - Add a point for player 2 and handle set/match progression
       - Manages service changes according to tennis rules
       - Return Bool if server changed */
     
    
    func addPointToPlayer2() -> Bool {
        // Do nothing if match is already complete
        if complete() {
            return false
        }
        
        
        
        
        let currentSet = sets[currentSetIndex]
        let isInTieBreak = currentSet.isInTieBreak()
        let wasGameComplete = currentSet.isGameComplete()
        let wasSetComplete = currentSet.complete()
        var serverChanged = false
        
        /* demo
         // Add point to current set
         let currentSet = sets[currentSetIndex]
         currentSet.addPointToPlayer2()
         */
        
        // Add point to current set
        currentSet.addPointToPlayer2()
        
        
        // Update tiebreak counter if in tiebreak
        if isInTieBreak {
            tiebreakPointsPlayed += 1
        }
        
        
        // Check if the set is complete
        if currentSet.complete() {
            
            // Update sets won count
            if currentSet.player1Won() {
                player1SetsWon += 1
            } else if currentSet.player2Won() {
                player2SetsWon += 1
            }
            
            
            // If we were in a tiebreak, the server for the next game is the player
            if isInTieBreak {
                player1Serving = !player1ServingFirstInTiebreak()
            } else {
                // Otherwise, service alternates normally
                player1Serving = !player1Serving
            }
            
            
            serverChanged = true
            
            // If match is not complete, start a new set
            if !complete() {
                currentSetIndex += 1
                
                // If this will be the fifth set, mark it as the last set
                let isLastSet = currentSetIndex == 4
                sets.append(TennisSet(isLastSet: isLastSet))
                
                // Reset tiebreak counter
                tiebreakPointsPlayed = 0
                //return true // Service changed
            }
        }
        
        // Check if a regular game completed
        else if currentSet.isGameComplete() && !wasGameComplete && !isInTieBreak {
            
            // Change server after a completed game
            player1Serving = !player1Serving
            
            //return true // Service changed
            serverChanged = true
        }
        
        
        
        
            // Check for service change during tiebreak
             else if isInTieBreak {
                 
                 
                 // In tiebreak, service changes after first point, then every 2 points
                    if tiebreakPointsPlayed == 1 || tiebreakPointsPlayed > 1 && tiebreakPointsPlayed % 2 == 1 {
                        player1Serving = !player1Serving
                        
                        //return true // Service changed
                        serverChanged = true
                    }
                }
                
                //return false // No service change
                return serverChanged
        
        
    }
    
    // Returns true if player 1 has won the match ( A player wins by winning the required number of sets (3 in best of 5))
     
    func player1Won() -> Bool {
        return player1SetsWon >= totalSetsNeeded
    }
    
    // Returns true if player 2 has won the match (A player wins by winning the required number of sets (3 in best of 5))
     
    func player2Won() -> Bool {
        return player2SetsWon >= totalSetsNeeded
    }
    
    // Returns true if the match is complete (either player has won)
     
    func complete() -> Bool {
        return player1Won() || player2Won()
    }
    
    // Get the current game score for player 1
     
    func player1GameScore() -> String {
        if currentSetIndex < sets.count {
            return sets[currentSetIndex].player1GameScore()
        }
        return ""
    }
    
    // Get the current game score for player 2
    
    func player2GameScore() -> String {
        if currentSetIndex < sets.count {
            return sets[currentSetIndex].player2GameScore()
        }
        return ""
    }
    
    // Get the games in the current set for player 1
     
    func player1CurrentGames() -> Int {
        if currentSetIndex < sets.count {
            return sets[currentSetIndex].getPlayer1Games()
        }
        return 0
    }
    
    // Get the games in the current set for player 2
     
    func player2CurrentGames() -> Int {
        if currentSetIndex < sets.count {
            return sets[currentSetIndex].getPlayer2Games()
        }
        return 0
    }
    
    // Get the number of sets won by player 1
     
    func player1Sets() -> Int {
        return player1SetsWon
    }
    
    // Get the number of sets won by player 2
     
    func player2Sets() -> Int {
        return player2SetsWon
    }
    
    /* - Get previous sets scores for display
       - Return Array of tuples with (player1Games, player2Games) for each completed set */
     
    func previousSetsScores() -> [(Int, Int)] {
        var result: [(Int, Int)] = []
        
        
        // Return scores for completed sets only
        for i in 0..<currentSetIndex {
            let set = sets[i]
            result.append((set.getPlayer1Games(), set.getPlayer2Games()))
        }
        
        return result
    }
    
    // Check if the current game is a tie break
     
    func isCurrentGameTieBreak() -> Bool {
        if currentSetIndex < sets.count {
            return sets[currentSetIndex].isInTieBreak()
        }
        return false
    }
    
       //Check if player 1 is currently serving
         
        func isPlayer1Serving() -> Bool {
            return player1Serving
        }
        
        /* - Check if player 1 served first in the current tiebreak
           - Always returns the opposite of the player who served the game before the tiebreak
           - The player who would normally receive serve will be the one to serve first in the tiebreak. */
         
        private func player1ServingFirstInTiebreak() -> Bool {
            // In a tiebreak, the player who would normally receive serves first
            return !player1Serving
        }
        
        // Check if player 1 has game point/s
         
        func hasPlayer1GamePoint() -> Bool {
            let currentSet = sets[currentSetIndex]
            return currentSet.hasPlayer1GamePoint()
        }
        
        // Check if player 2 has game point/s
         
        func hasPlayer2GamePoint() -> Bool {
            let currentSet = sets[currentSetIndex]
            return currentSet.hasPlayer2GamePoint()
        }
        
        // Check if player 1 has set point/s
         
        func hasPlayer1SetPoint() -> Bool {
            let currentSet = sets[currentSetIndex]
            return currentSet.hasPlayer1SetPoint()
        }
        
        // Check if player 2 has set point/s
         
        func hasPlayer2SetPoint() -> Bool {
            let currentSet = sets[currentSetIndex]
            return currentSet.hasPlayer2SetPoint()
        }
        
        // Check if player 1 has match point/s
         
        func hasPlayer1MatchPoint() -> Bool {
            // Player 1 has match point if they have set point and winning this set would win the match
            return hasPlayer1SetPoint() && player1SetsWon == totalSetsNeeded - 1
        }
        
        //Check if player 2 has match point/s
         
        func hasPlayer2MatchPoint() -> Bool {
            
        // Player 2 has match point if they have set point and winning this set would win the match
        return hasPlayer2SetPoint() && player2SetsWon == totalSetsNeeded - 1
        }
        
    
    
    //Reset the match to start a new one (Initialises a new first set and resets all counters)
     
    func reset() {
        sets = [TennisSet()]
        currentSetIndex = 0
        player1SetsWon = 0
        player2SetsWon = 0
        player1Serving = true
        tiebreakPointsPlayed = 0
    }
}
