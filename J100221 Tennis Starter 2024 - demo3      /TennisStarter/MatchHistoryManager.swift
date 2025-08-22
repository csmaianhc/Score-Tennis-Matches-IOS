//
//  MatchHistoryManager.swift
//  TennisStarter
//
//  Created by Mabook on 26/2/25.
//  Copyright © 2025 University of Chester. All rights reserved.
//


import Foundation

// Handles saving and retrieving match history data + implements singleton pattern for centralized access to match history

class MatchHistoryManager {
    
    // Singleton instance for easy access throughout the app
    static let shared = MatchHistoryManager()
    
    // UserDefaults key for storing match history
    private let matchHistoryKey = "com.tennisapp.matchHistory"
    
    // Private initializer for singleton pattern to prevent multiple instances of this class
    private init() {}
    
    
    
    /* - A struct representing a completed match for storage
       - Contains all necessary data to reconstruct match result
       - Uses Codable for serialization/deserialization */
     
    struct MatchRecord: Codable {
        let date: Date
        let player1Sets: Int
        let player2Sets: Int
        let player1Games: [Int]
        let player2Games: [Int]
        let location: String
        var id: String // Unique identifier for each match
        
        // Initializer for creating a new match record
        init(date: Date, player1Sets: Int, player2Sets: Int, player1Games: [Int], player2Games: [Int], location: String) {
            self.date = date
            self.player1Sets = player1Sets
            self.player2Sets = player2Sets
            self.player1Games = player1Games
            self.player2Games = player2Games
            self.location = location
            
            // Generate a unique ID for this match record
            self.id = UUID().uuidString
        }
    }
    
    // Save a completed match to persistent storage
    /* Clarify:
     - player1Sets - Number of sets won by player 1
     - player2Sets - Number of sets won by player 2
     - player1Games - Array of games won by player 1 in each set
     - player2Games - Array of games won by player 2 in each set
     - location - Where the match was played */
    
    func saveMatch(player1Sets: Int, player2Sets: Int, player1Games: [Int], player2Games: [Int], location: String) {
        // Create a new match record
        let matchRecord = MatchRecord(
            date: Date(),
            player1Sets: player1Sets,
            player2Sets: player2Sets,
            player1Games: player1Games,
            player2Games: player2Games,
            location: location
        )
        
        // Retrieve the current match history
        var matchHistory = getAllMatches()
        
        // Add the new match record to the history
        matchHistory.append(matchRecord)
        
        // Save the updated history to UserDefaults
        if let encodedData = try? JSONEncoder().encode(matchHistory) {
            UserDefaults.standard.set(encodedData, forKey: matchHistoryKey)
        }
    }
    
    /* - Retrieve all stored matches
       - Return Array of match records, empty array if none exist */
     
    func getAllMatches() -> [MatchRecord] {
        
        // Attempt to load and decode match history from UserDefaults
        guard let data = UserDefaults.standard.data(forKey: matchHistoryKey),
              let matchHistory = try? JSONDecoder().decode([MatchRecord].self, from: data) else { 
            return [] // Return an empty array if no data is found or decoding fails
        }
        
        return matchHistory
    }
    
    
    
    /* - Retrieve a specific match by ID + return The match record if found, nil otherwise */
    // Clarify: id - Unique identifier of the match to retrieve
    
     
    func getMatch(withId id: String) -> MatchRecord? {
        return getAllMatches().first { $0.id == id }
    }
    
    
    // Delete a specific match by ID
    // Clarify: id - Unique identifier of the match to delete
     
    func deleteMatch(withId id: String) {
        
        // Retrieve all matches
        var matchHistory = getAllMatches()
        
        // Remove the match with the specified ID from the history
        matchHistory.removeAll { $0.id == id }
        
        // Save the updated history back to UserDefaults
        if let encodedData = try? JSONEncoder().encode(matchHistory) {
            UserDefaults.standard.set(encodedData, forKey: matchHistoryKey)
        }
    }
    
    
    // Clear all match history from UserDefaults + removes all stored matches
    
    func clearAllMatches() {
        UserDefaults.standard.removeObject(forKey: matchHistoryKey)
    }
    
    
    
    // Format a match record for display + return Formatted string with match details
    // Clarify: match - The match to format
     
    func formatMatchForDisplay(_ match: MatchRecord) -> String {
        // Set up a date formatter to display the match date and time
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        // Convert the match date to a string
        let dateString = dateFormatter.string(from: match.date)
        
        // Create a string summarizing the match's game scores
        var gameSummary = ""
        for i in 0..<min(match.player1Games.count, match.player2Games.count) {
            gameSummary += "[\(match.player1Games[i])-\(match.player2Games[i])] "
        }
        
        // Return the match details formatted for display
        return "\(dateString) - \(match.location)\nPlayer 1: \(match.player1Sets) sets, Player 2: \(match.player2Sets) sets\nGames: \(gameSummary)"
    }
}

