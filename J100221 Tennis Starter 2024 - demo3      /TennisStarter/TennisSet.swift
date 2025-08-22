//
//  TennisSet.swift
//  TennisStarter
//
//  Created by Mabook on 13/2/25.
//  Copyright © 2025 University of Chester. All rights reserved.
//

import Foundation

 /* - TennisSet class handles the scoring and progression of games within a tennis set
    - It manages the games within a set and tracks when sets are completed
    - Also handles special tie-break rules, including the different rules for the final set */
 
class TennisSet {
    // Track games won by each player
    private var player1Games: Int = 0
    private var player2Games: Int = 0
    
    // Current game being played in this set
    private var currentGame: Game
    
    // Whether this set is in tie-break mode
    private var isTieBreak: Bool = false
    
    // Whether this is the final set of the match (special rules apply)
    private var isLastSet: Bool = false
    
    // Whether the current game was just completed
    private var gameJustCompleted: Bool = false
    
    /*  Initialize a new tennis set (whether this is the last set of the match, affects tie-break rules) */
    
    init(isLastSet: Bool = false) {
        self.currentGame = Game()
        self.isLastSet = isLastSet
        
        self.gameJustCompleted = false
    }
    
    /* - Adds a point for player 1 and handles game/set progression
       - Updates game count if player wins a game
       - Checks for tie-break conditions
       - Creates new games as needed */
         
    func addPointToPlayer1() {
        // Do nothing if set is already complete
        if complete() {
            return
        }
        
        
        // Reset the gameJustCompleted flag
        gameJustCompleted = false
        
        
        // Handle scoring based on whether we're in a tie-break
        if !isTieBreak {
            // Standard game scoring
            currentGame.addPointToPlayer1()
            
            // If player 1 won the game, update games count
            if currentGame.player1Won() {
                player1Games += 1
                gameJustCompleted = true
                
                
                // If set is not complete, prepare for next game
                if !complete() {
                    currentGame = Game()
                    // Check if we need to enter tie-break mode
                    isTieBreak = shouldStartTieBreak()
                }
            }
        } else {
            // Tie-break scoring
            currentGame.addPointToPlayer1()
            
            // If player 1 won the tie-break, they win the set
            if currentGame.player1Won() {
                player1Games += 1
                gameJustCompleted = true
            }
        }
    }
    
    
    
    
    /* - Adds a point for player 2 and handles game/set progression
       - Updates game count if player wins a game
       - Checks for tie-break conditions
       - Creates new games as needed */
     
    func addPointToPlayer2() {
        // Do nothing if set is already complete
        if complete() {
            return
        }
        
        // Reset the gameJustCompleted flag
        gameJustCompleted = false
        
        
        // Handle scoring based on whether we're in a tie-break
        if !isTieBreak {
            
            // Standard game scoring
            currentGame.addPointToPlayer2()
            
            // If player 2 won the game, update games count
            if currentGame.player2Won() {
                player2Games += 1
                gameJustCompleted = true
                
                
                // If set is not complete, prepare for next game
                if !complete() {
                    currentGame = Game()
                    
                    // Check if we need to enter tie-break mode
                    isTieBreak = shouldStartTieBreak()
                }
            }
        } else {
            // Tie-break scoring
            currentGame.addPointToPlayer2()
            
            // If player 2 won the tie-break, they win the set
            if currentGame.player2Won() {
                player2Games += 1
                gameJustCompleted = true
            }
        }
    }
    
    
    
    /* - Determines if a tie-break should start based on current score
       - For final set, tie-break starts at 12-12
       - For other sets, tie-break starts at 6-6
       - Return True if tie-break should begin */
    
    
    private func shouldStartTieBreak() -> Bool {
        // In the final set, tie-break only starts at 12-12
        if isLastSet {
            return player1Games == 12 && player2Games == 12
        }
        
        
        // In other sets, tie-break starts at 6-6
        return player1Games == 6 && player2Games == 6
    }
    
    
    /* - Get current game score for player 1, handling tie-break differently
       - For tie-breaks, displays actual points (1,2,3...) instead of tennis scores
       - Return Score as a string */
    
    func player1GameScore() -> String {
        if isTieBreak {
            // For tie-breaks, display actual points (1,2,3...) instead of tennis scores
            if let p1Points = Int(currentGame.player1Score()) {
                return "\(p1Points)"
            } else if currentGame.player1Score() == "15" {
                return "1"
            } else if currentGame.player1Score() == "30" {
                return "2"
            } else if currentGame.player1Score() == "40" {
                return "3"
            } else if currentGame.player1Score() == "A" {
                
                // Shouldn't happen in tie-break, but handle anyway
                return "A"
            }
            return currentGame.player1Score()
        } else {
            return currentGame.player1Score()
        }
    }
    
    /* - Get current game score for player 2, handling tie-break differently
       - For tie-breaks, displays actual points (1,2,3...) instead of tennis scores
       - Return Score as a string */
    
    func player2GameScore() -> String {
        if isTieBreak {
            // For tie-breaks, display actual points (1,2,3...) instead of tennis scores
            if let p2Points = Int(currentGame.player2Score()) {
                return "\(p2Points)"
            } else if currentGame.player2Score() == "15" {
                return "1"
            } else if currentGame.player2Score() == "30" {
                return "2"
            } else if currentGame.player2Score() == "40" {
                return "3"
            } else if currentGame.player2Score() == "A" {
                // Shouldn't happen in tie-break, but handle anyway
                return "A"
            }
            return currentGame.player2Score()
        } else {
            return currentGame.player2Score()
        }
    }
    
    
    /* - Returns true if player 1 has won the set
       - In tie-break mode, winning the tie-break game means winning the set
       - In standard mode, need at least 6 games and a 2-game lead */
     
    func player1Won() -> Bool {
        if isTieBreak {
            // In tie-break, winning the tie-break game means winning the set
            return currentGame.player1Won()
        }
        
        // Standard set rules - need at least 6 games and 2-game lead
        return (player1Games >= 6 && player1Games >= player2Games + 2)
    }
    
    
    /* - Returns true if player 2 has won the set
       - In tie-break mode, winning the tie-break game means winning the set
       - In standard mode, need at least 6 games and a 2-game lead */
 
    func player2Won() -> Bool {
        if isTieBreak {
            // In tie-break, winning the tie-break game means winning the set
            return currentGame.player2Won()
        }
        
        // Standard set rules - need at least 6 games and 2-game lead
        return (player2Games >= 6 && player2Games >= player1Games + 2)
    }
    
    //Returns true if the set is complete (either player has won)
     
    func complete() -> Bool {
        return player1Won() || player2Won()
    }
    
    // Get the number of games won by player 1 in this set
     
    func getPlayer1Games() -> Int {
        return player1Games
    }
    
    
    // Get the number of games won by player 2 in this set
     
    func getPlayer2Games() -> Int {
        return player2Games
    }
    
    // Check if a game was just completed ( Used to determine when to change server, etc)
         
    func isGameComplete() -> Bool {
        return gameJustCompleted
    }
    
    
    //Check if the set is currently in tie-break mode
     
    func isInTieBreak() -> Bool {
        return isTieBreak
    }
    
    
    //Check if player 1 has game point/s ( Different for tie-break vs. regular game)
    
    func hasPlayer1GamePoint() -> Bool {
        if isTieBreak {
            // In tiebreak, game point is when player has 6+ points and leads by at least 1
            return currentGame.gamePointsForPlayer1() > 0
        } else {
            // In regular game, 40-0, 40-15, or 40-30 is game point
            return currentGame.gamePointsForPlayer1() > 0
        }
    }
        
    //Check if player 2 has game point/s ( Different for tie-break vs. regular game)
    
    func hasPlayer2GamePoint() -> Bool {
        if isTieBreak {
            // In tiebreak, game point is when player has 6+ points and leads by at least 1
            return currentGame.gamePointsForPlayer2() > 0
        } else {
            // In regular game, 0-40, 15-40, or 30-40 is game point
            return currentGame.gamePointsForPlayer2() > 0
        }
    }
        
        // Check if player 1 has set point/s ( Set point occurs when winning the current game would win the set)
         
    func hasPlayer1SetPoint() -> Bool {
        // If the set is already complete, there's no set point
        if complete() {
            return false
        }
        
        if isTieBreak {
            // In tiebreak, set point is the same as game point
            return hasPlayer1GamePoint()
            
        } else {
            // In regular play, set point is when player has 5+ games and:
            // 1. Leads by 1 game and has game point, or
            // 2. Leads by 2+ games and has game point
            return (player1Games >= 5 &&
                    ((player1Games == player2Games + 1 && hasPlayer1GamePoint()) ||
                     (player1Games >= player2Games + 2 && hasPlayer1GamePoint())))
        }
    }
        
     
    //Check if player 2 has set point/s ( Set point occurs when winning the current game would win the set)
    
    func hasPlayer2SetPoint() -> Bool {
        // If the set is already complete, there's no set point
        if complete() {
            return false
        }
        
        if isTieBreak {
            // In tiebreak, set point is the same as game point
            return hasPlayer2GamePoint()
        } else {
            // In regular play, set point is when player has 5+ games and:
            // 1. Leads by 1 game and has game point, or
            // 2. Leads by 2+ games and has game point
            
            return (player2Games >= 5 &&
                    ((player2Games == player1Games + 1 && hasPlayer2GamePoint()) ||
                     (player2Games >= player1Games + 2 && hasPlayer2GamePoint())))
        }
    }
    
}
