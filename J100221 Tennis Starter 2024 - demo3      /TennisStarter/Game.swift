
/*
 - Handles scoring for a single tennis game
 - Manages scoring with the standard tennis system (0,15,30,40,A)
 - Detects when a game is complete
 */

class Game {
    // Tracking points for both players
    private var player1Points: Int = 0
    private var player2Points: Int = 0
    
    
    
    /*
     - Adds a point for player 1 and handles deuce/advantage logic
     - If game is already complete, no action is taken */
    
     
    func addPointToPlayer1() {
        // If game is already complete, do nothing
        if complete() {
            return
        }
        
        // Check if player 2 has advantage
        if player2Points >= 4 && player2Points == player1Points + 1 {
            // Remove player 2's advantage, back to deuce
            player2Points = 3
            player1Points = 3
        } else {
            // Otherwise, increment player 1's points
            player1Points += 1
        }
    }
    
    /*
     - Adds a point for player 2 and handles deuce/advantage logic
     - If game is already complete, no action is taken */
     
    func addPointToPlayer2() {
        // If game is already complete, do nothing
        if complete() {
            return
        }
        
        // Check if player 1 has advantage
        if player1Points >= 4 && player1Points == player2Points + 1 {
            // Remove player 1's advantage, back to deuce
            player1Points = 3
            player2Points = 3
        } else {
            // Otherwise, increment player 2's points
            player2Points += 1
        }
    }

    
    /*
      - Returns the score for player 1 in tennis notation
      - Returns "0","15","30","40" or "A" based on current points
      - If the game is complete, returns an empty string */
     
    func player1Score() -> String {
        if complete() {
            return ""
        }
        
        return scoreString(player1Points, otherPlayerPoints: player2Points)
    }

    
    /*
      - Returns the score for player 2 in tennis notation
      - Returns "0","15","30","40" or "A" based on current points
      - If the game is complete, returns an empty string */
    
    func player2Score() -> String {
        if complete() {
            return ""
        }
        
        return scoreString(player2Points, otherPlayerPoints: player1Points)
    }
    
    /*
      - Returns true if player 1 has won the game
      - A player wins when they have at least 4 points and a 2-point lead */
     
    func player1Won() -> Bool {
        // Player 1 wins if they have at least 4 points and lead by at least 2
        return player1Points >= 4
        && player1Points >= player2Points + 2
    }
    
    /*
      - Returns true if player 2 has won the game
      - A player wins when they have at least 4 points and a 2-point lead */
     
    func player2Won() -> Bool {
        // Player 2 wins if they have at least 4 points and lead by at least 2
        return player2Points >= 4 && player2Points >= player1Points + 2
    }
    
    // Returns true if the game is finished (either player has won)
     
    func complete() -> Bool {
        return player1Won() || player2Won()
    }
    
    /*
     - If player 1 would win the game if they won the next point, returns the number of points player 2 would need to win to equalise the score, otherwise returns 0
     - E.g: if the score is 40:15 to player 1, player 1 would win if they scored the next point, and player 2 would need 2 points in a row to prevent that, so this method should return 2 in that case. */
     
    func gamePointsForPlayer1() -> Int {
        if player1Points < 3 {
            // Player 1 is not yet at 40, so no game point
            return 0
        
        }
        
        if player1Points == 3 && player2Points < 3 {
            // Player 1 at 40, player 2 not yet at 40
            return 3 - player2Points
        }
        
        if player1Points >= 4 && player1Points == player2Points + 1 {
            // Player 1 has advantage
            return 1
        }
        
        return 0
    }
    
    // If player 2 would win the game if they won the next point, returns the number of points player 1 would need to win to equalise the score
     
    func gamePointsForPlayer2() -> Int {
        if player2Points < 3 {
            // Player 2 is not yet at 40, so no game point
            return 0
        }
        
        if player2Points == 3 && player1Points < 3 {
            // Player 2 at 40, player 1 not yet at 40
            return 3 - player1Points
        }
        
        if player2Points >= 4 && player2Points == player1Points + 1 {
            // Player 2 has advantage
            return 1
        }
        
        return 0
    }
    
    // Helper method to convert numeric score to tennis score string
    
    private func scoreString(_ points: Int, otherPlayerPoints: Int) -> String {
        switch points {
        case 0:
            return "0"
        case 1:
            return "15"
        case 2:
            return "30"
        case 3:
            return "40"
        default:
            // If points > 3 and one point ahead, it's advantage
            if points >= 4 && points == otherPlayerPoints + 1 {
                return "A"
            } else {
                return "40" // Otherwise it's still 40 (e.g in deuce)
            }
        }
    }
}
