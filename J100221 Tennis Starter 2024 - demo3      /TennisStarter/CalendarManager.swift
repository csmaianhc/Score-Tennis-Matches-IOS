//
//  CalendarManager.swift
//  TennisStarter
//
//  Created by Mabook on 3/3/25.
//  Copyright © 2025 University of Chester. All rights reserved.
//

import Foundation
import EventKit

/* - CalendarManager handles scheduling + retrieving calendar events
   - Uses EventKit for interacting with the device's calendar
   - Implements singleton pattern for easy access throughout the app */
 
class CalendarManager {
    
    // Singleton instance for easy access throughout the app
    static let shared = CalendarManager()
    
    // EventKit event store to interact with system calendar
    private let eventStore = EKEventStore()
    
    // Scheduled future match
    private var futureMatch: FutureMatch?
    
    // Private initializer for singleton pattern
    private init() {
        requestCalendarAccess()
    }
    
    // A struct representing a future match
     
    struct FutureMatch: Codable {
        let title: String
        let date: Date
        let location: String
        let notes: String
        let eventIdentifier: String?
        
        init(title: String, date: Date, location: String, notes: String, eventIdentifier: String? = nil) {
            self.title = title
            self.date = date
            self.location = location
            self.notes = notes
            self.eventIdentifier = eventIdentifier
        }
    }
    
    /* - Request access to the device's calendar
       - Must be called before any calendar operations can be performed */
    
     
    private func requestCalendarAccess() {
        eventStore.requestAccess(to: .event) { (granted, error) in
            if let error = error {
                print("Failed to request calendar access: \(error.localizedDescription)")
            }
        }
    }
    
    /* - Schedule a future match and add it to the calendar
       - Creates a calendar event with details and an alarm
       - Returns true if the event was successfully added */
     
   /* Clarify:
       - Title - The title of the match
       - Date - The date and time of the match
       - Location - Where the match will take place
       - Notes - Additional information about the match
       - Completion - Callback with success status and created match */
    
     
    func scheduleFutureMatch(title: String, date: Date, location: String, notes: String, completion: @escaping (Bool, FutureMatch?) -> Void) {
        eventStore.requestAccess(to: .event) { [weak self] (granted, error) in
            guard let self = self, granted, error == nil else {
                DispatchQueue.main.async {
                    completion(false, nil)
                }
                return
            }
            
            // Create an event
            let event = EKEvent(eventStore: self.eventStore)
            event.title = title
            event.startDate = date
            event.endDate = date.addingTimeInterval(2 * 60 * 60) // 2 hours duration
            event.location = location
            event.notes = notes
            
            // Add an alarm 1 day before
            let alarm = EKAlarm(relativeOffset: -86400) // 24 hours before
            event.addAlarm(alarm)
            
            // Add to default calendar
            event.calendar = self.eventStore.defaultCalendarForNewEvents
            
            do {
                try self.eventStore.save(event, span: .thisEvent)
                
                // Create and store the future match
                let futureMatch = FutureMatch(
                    title: title,
                    date: date,
                    location: location,
                    notes: notes,
                    eventIdentifier: event.eventIdentifier
                )
                
                self.saveFutureMatch(futureMatch)
                self.futureMatch = futureMatch
                
                DispatchQueue.main.async {
                    completion(true, futureMatch)
                }
                
            } catch {
                print("Failed to save event: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false, nil)
                }
            }
        }
    }
    
    /* - Get the currently scheduled future match
       - Loads from cache or UserDefaults if not yet loaded
       - Return The future match or nil if none is scheduled */
     
    func getFutureMatch() -> FutureMatch? {
        if futureMatch == nil {
            loadFutureMatch()
        }
        return futureMatch
    }
    
    
    /* - Delete the scheduled future match
       - Removes the match from the calendar and from local storage
       -  Calls the completion handler with a success status (true or false) */
     
    func deleteFutureMatch(completion: @escaping (Bool) -> Void) {
        // Ensure that a future match is available and can be identified by an event identifier.
        guard let futureMatch = futureMatch,
              let eventIdentifier = futureMatch.eventIdentifier,
              let event = try? eventStore.event(withIdentifier: eventIdentifier) else {
            
            // If no future match exists, clear local storage and return failure status.
            self.futureMatch = nil
            UserDefaults.standard.removeObject(forKey: "futureMatch")
            completion(false)
            return
        }
        
        // Attempt to remove the event from the calendar
        do {
            try eventStore.remove(event, span: .thisEvent) // Remove the event from the calendar
            
            // Clear the future match reference and remove it from local storage
            self.futureMatch = nil
            UserDefaults.standard.removeObject(forKey: "futureMatch")
            completion(true)
        }
        catch {
            // If the event removal fails, log the error and return failure status.
            print("Failed to delete event: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    // Save the future match to UserDefaults
     
    private func saveFutureMatch(_ match: FutureMatch) {
        if let encodedData = try? JSONEncoder().encode(match) {
            UserDefaults.standard.set(encodedData, forKey: "futureMatch")
        }
    }
    
    /* - Load the future match from UserDefaults
       - Verifies whether the event still exists in the calendar */
    
     
    private func loadFutureMatch() {
        // Attempt to load the saved future match data from UserDefaults
        guard let data = UserDefaults.standard.data(forKey: "futureMatch"),
              let match = try? JSONDecoder().decode(FutureMatch.self, from: data) else {
            
            // If no data is found or decoding fails, exit the function.
            return
        }
        
        // Verify the event still exists
        if let eventIdentifier = match.eventIdentifier,
           let _ = try? eventStore.event(withIdentifier: eventIdentifier) {
            
            // If the event exists, assign the match to futureMatch
            futureMatch = match
        } else {
            
            // If the event was deleted from the calendar, remove the match data from UserDefaults
            UserDefaults.standard.removeObject(forKey: "futureMatch")
        }
    }
    
    
    // Format a future match for display + return Formatted string with match details
    /* Clarify:
     - Match - The match to format */
     
    func formatFutureMatchForDisplay(_ match: FutureMatch) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short
        
        return "\(match.title)\nDate: \(dateFormatter.string(from: match.date))\nLocation: \(match.location)"
    }
}
