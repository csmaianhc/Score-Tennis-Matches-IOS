//
//  FutureMatchViewController.swift
//  TennisStarter
//
//  Created by Mabook on 11/3/25.
//  Copyright © 2025 University of Chester. All rights reserved.




import UIKit

  /* Default suggestion d
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



/* - ViewController for scheduling future matches
   - Allows users to enter match details and add to calendar
   - Uses CalendarManager to handle the actual scheduling */

class FutureMatchViewController: UIViewController {
    
    // UI Components
    private let titleTextField = UITextField()
    private let datePicker = UIDatePicker()
    private let locationTextField = UITextField()
    private let notesTextView = UITextView()
    private let scheduleButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let locationButton = UIButton(type: .system)
    
    // Selected location
    private var selectedLocation: String = ""
    
    // Completion handler for when a match is scheduled
    var onMatchScheduled: ((CalendarManager.FutureMatch) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI() // Initialise and set up UI components
        setupActions() // Set up actions for button taps
        
        // Check and update the location display with current location
        updateLocationDisplay()
    }
    
    
    /* - Set up the UI elements
       - Creates and positions all interface components */
     
    private func setupUI() {
        view.backgroundColor = .white
        title = "Schedule Future Match" // Set the title for the view
        
        // Set up containers for layout
        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentStackView)
        
        // Add a label and text field for match title
        let titleLabel = UILabel()
        titleLabel.text = "Match Title:"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleTextField.placeholder = "Enter match title"
        titleTextField.borderStyle = .roundedRect
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        let titleStackView = UIStackView(arrangedSubviews: [titleLabel, titleTextField])
        titleStackView.axis = .vertical
        titleStackView.spacing = 8
        contentStackView.addArrangedSubview(titleStackView)
        
        // Add a label and date picker for match date
        let dateLabel = UILabel()
        dateLabel.text = "Match Date:"
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .compact
        datePicker.minimumDate = Date() // Can't schedule in the past
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        let dateStackView = UIStackView(arrangedSubviews: [dateLabel, datePicker])
        dateStackView.axis = .vertical
        dateStackView.spacing = 8
        contentStackView.addArrangedSubview(dateStackView)
        
        // Add a label and text field for location
        let locationLabel = UILabel()
        locationLabel.text = "Location:"
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        locationTextField.placeholder = "Enter location"
        locationTextField.borderStyle = .roundedRect
        locationTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // Use Current Location button
        locationButton.setTitle("Use Current Location", for: .normal)
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        
        let locationStackView = UIStackView(arrangedSubviews: [locationLabel, locationTextField, locationButton])
        locationStackView.axis = .vertical
        locationStackView.spacing = 8
        contentStackView.addArrangedSubview(locationStackView)
        
        // Notes section
        let notesLabel = UILabel()
        notesLabel.text = "Notes:"
        notesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        notesTextView.layer.borderColor = UIColor.lightGray.cgColor
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.cornerRadius = 5
        notesTextView.font = UIFont.systemFont(ofSize: 15)
        notesTextView.translatesAutoresizingMaskIntoConstraints = false
        
        let notesStackView = UIStackView(arrangedSubviews: [notesLabel, notesTextView])
        notesStackView.axis = .vertical
        notesStackView.spacing = 8
        contentStackView.addArrangedSubview(notesStackView)
        
        // Add buttons
        scheduleButton.setTitle("Schedule Match", for: .normal)
        scheduleButton.backgroundColor = .systemBlue
        scheduleButton.setTitleColor(.white, for: .normal)
        scheduleButton.layer.cornerRadius = 8
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false
        
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.backgroundColor = .systemGray
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.layer.cornerRadius = 8
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonStackView = UIStackView(arrangedSubviews: [scheduleButton, cancelButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 16
        buttonStackView.distribution = .fillEqually
        contentStackView.addArrangedSubview(buttonStackView)
        
        // Apply constraints
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            titleTextField.heightAnchor.constraint(equalToConstant: 40),
            notesTextView.heightAnchor.constraint(equalToConstant: 100),
            scheduleButton.heightAnchor.constraint(equalToConstant: 44),
            cancelButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    /* - Set up action handlers for buttons
       - Connects UI elements to their corresponding methods */
    
    private func setupActions() {
        scheduleButton.addTarget(self, action:  #selector(scheduleButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(useCurrentLocationTapped), for: .touchUpInside)
    }
    
    /* - Update location display with current location
       - Gets location information from LocationManager */
     
    private func updateLocationDisplay() {
        let (city, country) = LocationManager.shared.getCurrentLocation()
        
        if city != "Unknown" {
            selectedLocation = "\(city), \(country)"
            locationTextField.text = selectedLocation
        }
    }
    
    
    /* - Handle the schedule button tap
       - Validates inputs and schedules the match */
    
    @objc private func scheduleButtonTapped() {
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(title: "Error", message: "Please enter a match title")
            return
        }
        
        guard let location = locationTextField.text, !location.isEmpty else {
            showAlert(title: "Error", message: "Please enter a location")
            return
        }
        
        let date = datePicker.date
        let notes = notesTextView.text ?? ""
        
        // Schedule the match using CalendarManager
        CalendarManager.shared.scheduleFutureMatch(
            title: title,
            date: date,
            location: location,
            notes: notes ){
                [weak self] success, futureMatch in
            if success, let match = futureMatch {
                self?.onMatchScheduled?(match)
                self?.showAlert(title: "Success", message: "Match has been scheduled") { [weak self] in
                    self?.dismiss(animated: true)
                }
            } else {
                self?.showAlert(title: "Error", message: "Failed to schedule match. Please check calendar permissions.")
            }
        }
    }
    
    /* - Handle the cancel button tap
       - Dismisses the view controller without scheduling */
     
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    /* - Handle the use current location button tap
       - Gets the current location + updates the location field */
     
    @objc private func useCurrentLocationTapped() {
        
        // Start location updates
        LocationManager.shared.startLocationUpdates { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    
                    // If location is successfully retrieved, update the UI with the location
                    self?.updateLocationDisplay()
                }
            } else {
                DispatchQueue.main.async {
                    
                    // If there's an error, show an alert
                    self?.showAlert(title: "Location Error", message: "Could not get current location. Please check location permissions or enter location manually.")
                }
            }
        }
    }
    
    // Show an alert with a message
    /* Clarify:
     - Title - Alert title
     - Message - Alert message
     - Completion - Optional callback after user dismisses the alert */
     
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?() // Executes completion if provided
        })
        present(alert, animated: true)
    }
    
    
}
