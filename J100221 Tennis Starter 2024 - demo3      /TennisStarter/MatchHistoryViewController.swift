//
//  MatchHistoryViewController.swift
//  TennisStarter
//
//  Created by Mabook on 6/3/25.
//  Copyright © 2025 University of Chester. All rights reserved.


// ViewController for displaying match history

import UIKit

  /* Default Suggestions
   override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


/* - ViewController for displaying match history
   - Shows a list of past matches and allows viewing details or deleting records
   - Uses UITableView to display the match list */
    
   class MatchHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
       
       private var tableView: UITableView!
       private var matches: [MatchHistoryManager.MatchRecord] = []
       
       override func viewDidLoad() {
           super.viewDidLoad()
           
           setupUI()
           loadMatches() // Refresh the table view
       }
       
       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           loadMatches()
           tableView.reloadData()
       }
       
       /* - Set up the UI elements
          - Creates and configures the table view + navigation */
        
       private func setupUI() {
           view.backgroundColor = .white // background view colour
           
           // Create table view to display matches
           tableView = UITableView(frame: view.bounds, style: .plain)
           tableView.delegate = self
           tableView.dataSource = self
           tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MatchCell")
           tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // Make the table view resize automatically
           view.addSubview(tableView)
           
           // Title of the view
           title = "Match History"
           
           // Add a Clear All button
           navigationItem.rightBarButtonItem = UIBarButtonItem(
               title: "Clear All",
               style: .plain,
               target: self,
               action: #selector(clearAllTapped)
           )
       }
       
       /* - Load match history data
          - Gets matches from MatchHistoryManager and sorts by date */
        
       private func loadMatches() {
           matches = MatchHistoryManager.shared.getAllMatches().sorted { $0.date > $1.date } // Sort matches by date (newest first)
       }
       
       // Action when the "Clear All" button is tapped
       @objc private func clearAllTapped() {
           
           // Show an alert to confirm deletion of all matches
           let alert = UIAlertController(
               title: "Clear All Matches",
               message: "Are you sure you want to delete all match history? This cannot be undone.",
               preferredStyle: .alert
           )
           
           // Add actions for the alert
           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel)) // Cancel action
           
           // Clear all matches + reload the data
           alert.addAction(UIAlertAction(title: "Clear All", style: .destructive) { [weak self] _ in
               MatchHistoryManager.shared.clearAllMatches()
               self?.loadMatches()
               self?.tableView.reloadData()
           })
           
           present(alert, animated: true)
       }
       
       // MARK: - UITableViewDataSource
       
       // Return the number of rows for the table view (either 1 for no matches or the count of matches)
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return matches.isEmpty ? 1 : matches.count
       }
       
       // Configure each cell in the table view
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCell", for: indexPath)
           
           if matches.isEmpty {
               cell.textLabel?.text = "No match history available"
               cell.isUserInteractionEnabled = false
           } else {
               let match = matches[indexPath.row]
               let dateFormatter = DateFormatter()
               dateFormatter.dateStyle = .medium
               
               cell.textLabel?.numberOfLines = 0
               cell.textLabel?.text = formatMatchCellText(match)
               cell.accessoryType = .disclosureIndicator
           }
           
           return cell
       }
       
       /* - Format match information for display in table cell
          - Return Formatted string with match summary */
       // Clarify: match - The match record to format
            
        
       private func formatMatchCellText(_ match: MatchHistoryManager.MatchRecord) -> String {
           let dateFormatter = DateFormatter()
           dateFormatter.dateStyle = .medium
           
           let dateString = dateFormatter.string(from: match.date)
           let winnerText = match.player1Sets > match.player2Sets ? "Player 1 won" : "Player 2 won"
           
           return "\(dateString) - \(match.location)\n\(winnerText) (\(match.player1Sets)-\(match.player2Sets))"
       }
       
       // MARK: - UITableViewDelegate
       
       // Handle row selection in the table view
       
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after it’s tapped
           
           if !matches.isEmpty {
               let match = matches[indexPath.row]
               showMatchDetail(match)
           }
       }
       
       // Handle swipe-to-delete action in the table view

       func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete && !matches.isEmpty {
               let match = matches[indexPath.row] // Get the match to delete
               MatchHistoryManager.shared.deleteMatch(withId: match.id)
               
               loadMatches()
               
               // Check if there are no matches left
               if matches.isEmpty {
                   tableView.reloadData() // Reload the table to show "No match history" message
               } else {
                   tableView.deleteRows(at: [indexPath], with: .fade)
               }
           }
       }
       
       /* - Show detailed information about a match
          - Displays a modal with full match statistics */
       //Clarify: Match - The match to display
            
        
       private func showMatchDetail(_ match: MatchHistoryManager.MatchRecord) {
           let alert = UIAlertController(
               title: "Match Details",
               message: MatchHistoryManager.shared.formatMatchForDisplay(match),
               preferredStyle: .alert
           )
           
           alert.addAction(UIAlertAction(title: "Close", style: .default))
           
           present(alert, animated: true)
       }
   }
