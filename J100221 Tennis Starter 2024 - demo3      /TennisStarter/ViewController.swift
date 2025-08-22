import UIKit
import AVFoundation


/* - Manages the user interface
   - Connects user actions to the tennis match model
   - Displays the current match state and additional features */
 
class ViewController: UIViewController {
    
    // MARK: - UI Outlets
    
    @IBOutlet weak var p1Button: UIButton!
    @IBOutlet weak var p2Button: UIButton!
    @IBOutlet weak var p1NameLabel: UILabel!
    @IBOutlet weak var p2NameLabel: UILabel!
    
    @IBOutlet weak var p1PointsLabel: UILabel!
    @IBOutlet weak var p2PointsLabel: UILabel!
    
    @IBOutlet weak var p1GamesLabel: UILabel!
    @IBOutlet weak var p2GamesLabel: UILabel!
    
    @IBOutlet weak var p1SetsLabel: UILabel!
    @IBOutlet weak var p2SetsLabel: UILabel!
    
    @IBOutlet weak var p1PreviousSetsLabel: UILabel!
    @IBOutlet weak var p2PreviousSetsLabel: UILabel!
    
    
    
    // MARK: - New UI Elements 
    
    private var locationLabel: UILabel!
    private var futureMatchTitleLabel: UILabel!
    private var futureMatchLabel: UILabel!
    private var futureMatchLocationLabel: UILabel!
    
    private var historyButton: UIButton!
    private var scheduleButton: UIButton!
    
    
    
    
    // MARK: - Properties
    
    // The match model ( for tennis scoring)
    private var match = TennisMatch()
    
    // Track the total games played for "new balls please" messages
    private var totalGamesPlayed = 0
    
    // Sound player for audio cues
    private var audioPlayer: AVAudioPlayer?
    
    
    // Colors for highlighting
    private let serverColor = UIColor.purple
    private let pointColor = UIColor.green
    private let defaultColor = UIColor.white
    
    // External screen support
    private var externalWindow: UIWindow?
    private var externalViewController: ViewController?
    
    
    // Current location
    private var currentLocation: String = "Unknown location"
    
    
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the initial UI state
        resetMatch()
        
        // Load sound file
        setupAudioPlayer()
        
        // Setup external display if available
        setupExternalScreen()
        
        
        // Add new UI elements
        setupEnhancedUI()
        
        // Start location services
        startLocationServices()
        
        
        // Register for screen connection notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenDidConnect),
            name: UIScreen.didConnectNotification,
            object: nil
            
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenDidDisconnect),
            name: UIScreen.didDisconnectNotification,
            object: nil
            
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Update location and future match information when the view appears
        updateLocationDisplay()
        updateFutureMatchDisplay()
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self) // Remove any observers to avoid memory leaks
    }
    
    
    // MARK: - Enhanced UI Setup
    
        
    /* - Sets up new UI elements for enhanced functionality
       - Creates a visually appealing container with match information,
       - location services, and buttons for additional features */
     
    private func setupEnhancedUI() {
        
        // Create container view with improved visual style
        let enhancedContainer = UIView()
        enhancedContainer.translatesAutoresizingMaskIntoConstraints = false
        enhancedContainer.backgroundColor = .systemBackground
        enhancedContainer.layer.borderWidth = 0.5 // Add a border
        enhancedContainer.layer.borderColor = UIColor.systemGray4.cgColor // border color
        enhancedContainer.layer.cornerRadius = 16 //  round corners
        enhancedContainer.layer.shadowColor = UIColor.black.cgColor  // Add shadow effect
        enhancedContainer.layer.shadowOffset = CGSize(width: 0, height: 3) // Shadow offset
        enhancedContainer.layer.shadowRadius = 6 // Shadow radius
        enhancedContainer.layer.shadowOpacity = 0.15 // Adjust shadow opacity
        enhancedContainer.layer.masksToBounds = false // Allow shadow to overflow outside bounds
        view.addSubview(enhancedContainer) // Add the container view to the main view
        
        
        // Position the container below the score display elements
        NSLayoutConstraint.activate([
            enhancedContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200),
            enhancedContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            enhancedContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            enhancedContainer.heightAnchor.constraint(equalToConstant: 269)
        ])
        
        // Create a title label for this section with gradient background
        let titleContainerView = UIView()
        titleContainerView.translatesAutoresizingMaskIntoConstraints = false
        titleContainerView.backgroundColor = .systemBlue //background color
        titleContainerView.layer.cornerRadius = 16 // Round corners
        titleContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Round only top corners
        titleContainerView.clipsToBounds = true // Ensure corners are clipped to fit
        enhancedContainer.addSubview(titleContainerView) //Title container
        
        // Create and set up a gradient layer for the title background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemBlue.cgColor,
            UIColor(red: 0, green: 0.5, blue: 0.9, alpha: 1.0).cgColor // Gradient from blue to light blue
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.locations = [0, 1]
        titleContainerView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Add icon to the title container
        let titleIconView = UIImageView(image: UIImage(systemName: "sportscourt.fill"))
        titleIconView.translatesAutoresizingMaskIntoConstraints = false
        titleIconView.contentMode = .scaleAspectFit // Scale icon to fit
        titleIconView.tintColor = .white // Set icon color to white
        titleContainerView.addSubview(titleIconView)
        
        // Create and set up title label for the section
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Match Information"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textAlignment = .center // Center-align the title text
        titleLabel.textColor = .white
        titleContainerView.addSubview(titleLabel)
        
        // Create and set up a horizontal stack for location display
        let locationStack = UIStackView()
        locationStack.translatesAutoresizingMaskIntoConstraints = false
        locationStack.axis = .horizontal
        locationStack.spacing = 8 // Add spacing between elements
        locationStack.alignment = .center
        enhancedContainer.addSubview(locationStack)
        
        // Create and set up location icon
        let locationIcon = UIImageView(image: UIImage(systemName: "mappin.circle.fill"))
        locationIcon.translatesAutoresizingMaskIntoConstraints = false
        locationIcon.tintColor = .systemRed
        locationIcon.contentMode = .scaleAspectFit
        locationStack.addArrangedSubview(locationIcon)
        
        // Create and set up location label
        locationLabel = UILabel()
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.text = "Location: Determining..." // Default text for location
        locationLabel.font = UIFont.systemFont(ofSize: 14)
        locationStack.addArrangedSubview(locationLabel)
        
        // Create divider line for separation
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor.systemGray5 // Set divider color to light gray
        divider.layer.cornerRadius = 0.5
        enhancedContainer.addSubview(divider)
        
        // Create and set up a vertical stack for the next match section
        let nextMatchStack = UIStackView()
        nextMatchStack.translatesAutoresizingMaskIntoConstraints = false
        nextMatchStack.axis = .vertical
        nextMatchStack.spacing = 10
        enhancedContainer.addSubview(nextMatchStack)
        
        // Header for the "Next Match" section with calendar icon
        let nextMatchHeaderStack = UIStackView()
        nextMatchHeaderStack.translatesAutoresizingMaskIntoConstraints = false
        nextMatchHeaderStack.axis = .horizontal
        nextMatchHeaderStack.spacing = 8
        nextMatchHeaderStack.alignment = .center
        
        // Create background for the header
        let headerBackground = UIView()
        headerBackground.translatesAutoresizingMaskIntoConstraints = false
        headerBackground.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1) // light blue background
        headerBackground.layer.cornerRadius = 8 // Round corners
        enhancedContainer.addSubview(headerBackground)
        
        // Create and set up calendar icon for the header
        let calendarIcon = UIImageView(image: UIImage(systemName: "calendar"))
        calendarIcon.translatesAutoresizingMaskIntoConstraints = false
        calendarIcon.tintColor = .systemBlue // calendar icon color
        calendarIcon.contentMode = .scaleAspectFit // Scale icon to fit
        nextMatchHeaderStack.addArrangedSubview(calendarIcon)
        
        // Create and set up title for the next match header
        futureMatchTitleLabel = UILabel()
        futureMatchTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        futureMatchTitleLabel.text = "Next Match:"
        futureMatchTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        futureMatchTitleLabel.textColor = .systemBlue //text color
        nextMatchHeaderStack.addArrangedSubview(futureMatchTitleLabel)
        
        // Add header stack to next match stack
        nextMatchStack.addArrangedSubview(nextMatchHeaderStack)
        
        // Improved match info with card-like container
        let matchInfoContainer = UIView()
        matchInfoContainer.translatesAutoresizingMaskIntoConstraints = false
        matchInfoContainer.backgroundColor = UIColor.systemGray6
        matchInfoContainer.layer.cornerRadius = 8
        matchInfoContainer.layer.borderWidth = 0.5
        matchInfoContainer.layer.borderColor = UIColor.systemGray5.cgColor
        enhancedContainer.addSubview(matchInfoContainer)
        
        // Create and set up the label for displaying future match info
        futureMatchLabel = UILabel()
        futureMatchLabel.translatesAutoresizingMaskIntoConstraints = false
        futureMatchLabel.text = "No upcoming match scheduled"
        futureMatchLabel.font = UIFont.systemFont(ofSize: 13)
        futureMatchLabel.numberOfLines = 2 // Allow two lines of text
        futureMatchLabel.textAlignment = .left // Left-align text
        matchInfoContainer.addSubview(futureMatchLabel)
        
        // Create and set up a stack for displaying the future match location with a pin icon
        let futureLocationStack = UIStackView()
        futureLocationStack.translatesAutoresizingMaskIntoConstraints = false
        futureLocationStack.axis = .horizontal
        futureLocationStack.spacing = 4
        futureLocationStack.alignment = .center
        matchInfoContainer.addSubview(futureLocationStack)
        
        // Set up location icon for future match location
        let smallLocationIcon = UIImageView(image: UIImage(systemName: "mappin"))
        smallLocationIcon.translatesAutoresizingMaskIntoConstraints = false
        smallLocationIcon.tintColor = .systemBlue
        smallLocationIcon.contentMode = .scaleAspectFit
        futureLocationStack.addArrangedSubview(smallLocationIcon)
        
        // Set up location label for future match
        futureMatchLocationLabel = UILabel()
        futureMatchLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        futureMatchLocationLabel.text = ""
        futureMatchLocationLabel.font = UIFont.systemFont(ofSize: 13)
        futureMatchLocationLabel.textColor = .systemBlue //text color
        futureLocationStack.addArrangedSubview(futureMatchLocationLabel)
        
        // Create a stack for buttons (History and Schedule)
        let buttonStack = UIStackView()
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 12
        enhancedContainer.addSubview(buttonStack)
        
        // History button with gradient background
        historyButton = UIButton(type: .system)
        historyButton.translatesAutoresizingMaskIntoConstraints = false
        historyButton.setTitle("Match History", for: .normal) //button title
        historyButton.setImage(UIImage(systemName: "clock.arrow.circlepath"), for: .normal)
        historyButton.backgroundColor = .systemBlue //background color
        historyButton.setTitleColor(.white, for: .normal) // title color
        historyButton.layer.cornerRadius = 10
        historyButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold) // Set font style and size
        historyButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12) // Adjust padding around content
        historyButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 4) // Adjust icon position
        historyButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -6) // Adjust title position
        historyButton.contentHorizontalAlignment = .left
        
        // Add shadow to button for a lifted effect
        historyButton.layer.shadowColor = UIColor.systemBlue.withAlphaComponent(0.5).cgColor
        historyButton.layer.shadowOffset = CGSize(width: 0, height: 2) // Set shadow offset
        historyButton.layer.shadowRadius = 4
        historyButton.layer.shadowOpacity = 0.5
        historyButton.layer.masksToBounds = false // Ensure the shadow is visible outside the button's bounds
        
        historyButton.addTarget(self, action: #selector(historyButtonTapped), for: .touchUpInside) // tap action
        buttonStack.addArrangedSubview(historyButton)
        
        // Schedule button with gradient background
        scheduleButton = UIButton(type: .system)
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false
        scheduleButton.setTitle("Schedule Match", for: .normal) // Set button title
        scheduleButton.setImage(UIImage(systemName: "plus.circle"), for: .normal) // Set icon
        scheduleButton.backgroundColor = .systemGreen
        scheduleButton.setTitleColor(.white, for: .normal)
        scheduleButton.layer.cornerRadius = 10
        scheduleButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        scheduleButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        scheduleButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 4)
        scheduleButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -6)
        
        // Add shadow to button for a lifted effect
        scheduleButton.layer.shadowColor = UIColor.systemGreen.withAlphaComponent(0.5).cgColor
        scheduleButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        scheduleButton.layer.shadowRadius = 4
        scheduleButton.layer.shadowOpacity = 0.5
        scheduleButton.layer.masksToBounds = false
        
        scheduleButton.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
        buttonStack.addArrangedSubview(scheduleButton)
        
        // Layout constraints for the UI components
        NSLayoutConstraint.activate([
            
            // Title container takes full width
            titleContainerView.topAnchor.constraint(equalTo: enhancedContainer.topAnchor),
            titleContainerView.leadingAnchor.constraint(equalTo: enhancedContainer.leadingAnchor),
            titleContainerView.trailingAnchor.constraint(equalTo: enhancedContainer.trailingAnchor),
            titleContainerView.heightAnchor.constraint(equalToConstant: 42),
            
            // Title icon
            titleIconView.leadingAnchor.constraint(equalTo: titleContainerView.leadingAnchor, constant: 16),
            titleIconView.centerYAnchor.constraint(equalTo: titleContainerView.centerYAnchor),
            titleIconView.widthAnchor.constraint(equalToConstant: 22),
            titleIconView.heightAnchor.constraint(equalToConstant: 22),
            
            // Title label
            titleLabel.leadingAnchor.constraint(equalTo: titleIconView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: titleContainerView.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: titleContainerView.centerYAnchor),
            
            // Location stack
            locationStack.topAnchor.constraint(equalTo: titleContainerView.bottomAnchor, constant: 16),
            locationStack.leadingAnchor.constraint(equalTo: enhancedContainer.leadingAnchor, constant: 16),
            locationStack.trailingAnchor.constraint(equalTo: enhancedContainer.trailingAnchor, constant: -16),
            locationIcon.widthAnchor.constraint(equalToConstant: 20),
            locationIcon.heightAnchor.constraint(equalToConstant: 20),
            
            // Divider
            divider.topAnchor.constraint(equalTo: locationStack.bottomAnchor, constant: 12),
            divider.leadingAnchor.constraint(equalTo: enhancedContainer.leadingAnchor, constant: 12),
            divider.trailingAnchor.constraint(equalTo: enhancedContainer.trailingAnchor, constant: -12),
            divider.heightAnchor.constraint(equalToConstant: 1),
            
            // Header background
            headerBackground.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 12),
            headerBackground.leadingAnchor.constraint(equalTo: enhancedContainer.leadingAnchor, constant: 12),
            headerBackground.trailingAnchor.constraint(equalTo: enhancedContainer.trailingAnchor, constant: -12),
            headerBackground.heightAnchor.constraint(equalToConstant: 32),
            
            // Next match header stack
            nextMatchHeaderStack.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 16),
            nextMatchHeaderStack.leadingAnchor.constraint(equalTo: enhancedContainer.leadingAnchor, constant: 20),
            calendarIcon.widthAnchor.constraint(equalToConstant: 18),
            calendarIcon.heightAnchor.constraint(equalToConstant: 18),
            
            // Match info container
            matchInfoContainer.topAnchor.constraint(equalTo: headerBackground.bottomAnchor, constant: 8),
            matchInfoContainer.leadingAnchor.constraint(equalTo: enhancedContainer.leadingAnchor, constant: 16),
            matchInfoContainer.trailingAnchor.constraint(equalTo: enhancedContainer.trailingAnchor, constant: -16),
            matchInfoContainer.heightAnchor.constraint(equalToConstant: 60),
            
            // Future match label
            futureMatchLabel.topAnchor.constraint(equalTo: matchInfoContainer.topAnchor, constant: 8),
            futureMatchLabel.leadingAnchor.constraint(equalTo: matchInfoContainer.leadingAnchor, constant: 12),
            futureMatchLabel.trailingAnchor.constraint(equalTo: matchInfoContainer.trailingAnchor, constant: -12),
            
            // Future location stack
            futureLocationStack.topAnchor.constraint(equalTo: futureMatchLabel.bottomAnchor, constant: 4),
            futureLocationStack.leadingAnchor.constraint(equalTo: matchInfoContainer.leadingAnchor, constant: 12),
            smallLocationIcon.widthAnchor.constraint(equalToConstant: 14),
            smallLocationIcon.heightAnchor.constraint(equalToConstant: 14),
            
            // Button stack at the bottom
            buttonStack.bottomAnchor.constraint(equalTo: enhancedContainer.bottomAnchor, constant: -12),
            buttonStack.leadingAnchor.constraint(equalTo: enhancedContainer.leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: enhancedContainer.trailingAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Set the frame for gradient layer
        DispatchQueue.main.async {
            gradientLayer.frame = titleContainerView.bounds
        }
        
        // Update the UI displays with current data (location and future match)
        updateLocationDisplay()
        updateFutureMatchDisplay()
    }
    
    /* demo 2
    // Sets up new UI elements for enhanced functionality
     
    private func setupEnhancedUI() {
        // Create container view for new elements
        let enhancedContainer = UIView()
        enhancedContainer.translatesAutoresizingMaskIntoConstraints = false
        enhancedContainer.backgroundColor = .systemBackground
        enhancedContainer.layer.borderWidth = 0.5
        enhancedContainer.layer.borderColor = UIColor.lightGray.cgColor
        enhancedContainer.layer.cornerRadius = 12
        enhancedContainer.layer.shadowColor = UIColor.black.cgColor
        enhancedContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        enhancedContainer.layer.shadowRadius = 4
        enhancedContainer.layer.shadowOpacity = 0.1
        view.addSubview(enhancedContainer)
        
        // Position the container below the score display elements
        NSLayoutConstraint.activate([
            enhancedContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200),
            enhancedContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            enhancedContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            enhancedContainer.heightAnchor.constraint(equalToConstant: 223)
        ])
        
        // Create a title label for this section
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Match Information"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = .systemBlue
        titleLabel.textColor = .white
        titleLabel.layer.cornerRadius = 12
        titleLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        titleLabel.clipsToBounds = true
        enhancedContainer.addSubview(titleLabel)
        
        
        // Create and add location label with location icon
        let locationStack = UIStackView()
        locationStack.translatesAutoresizingMaskIntoConstraints = false
        locationStack.axis = .horizontal
        locationStack.spacing = 6
        locationStack.alignment = .center
        enhancedContainer.addSubview(locationStack)
        
        let locationIcon = UIImageView(image: UIImage(systemName: "mappin.circle.fill"))
        locationIcon.translatesAutoresizingMaskIntoConstraints = false
        locationIcon.tintColor = .systemRed
        locationIcon.contentMode = .scaleAspectFit
        locationStack.addArrangedSubview(locationIcon)
        
        locationLabel = UILabel()
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.text = "Location: Determining..."
        locationLabel.font = UIFont.systemFont(ofSize: 14)
        locationStack.addArrangedSubview(locationLabel)
        
        // Create divider
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = .systemGray5
        enhancedContainer.addSubview(divider)
        
        // Create and add future match section
        let nextMatchStack = UIStackView()
        nextMatchStack.translatesAutoresizingMaskIntoConstraints = false
        nextMatchStack.axis = .vertical
        nextMatchStack.spacing = 8
        enhancedContainer.addSubview(nextMatchStack)
        
        // Next match header with calendar icon
        let nextMatchHeaderStack = UIStackView()
        nextMatchHeaderStack.translatesAutoresizingMaskIntoConstraints = false
        nextMatchHeaderStack.axis = .horizontal
        nextMatchHeaderStack.spacing = 6
        nextMatchHeaderStack.alignment = .center
        
        let calendarIcon = UIImageView(image: UIImage(systemName: "calendar"))
        calendarIcon.translatesAutoresizingMaskIntoConstraints = false
        calendarIcon.tintColor = .systemBlue
        calendarIcon.contentMode = .scaleAspectFit
        nextMatchHeaderStack.addArrangedSubview(calendarIcon)
        
        futureMatchTitleLabel = UILabel()
        futureMatchTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        futureMatchTitleLabel.text = "Next Match:"
        futureMatchTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        nextMatchHeaderStack.addArrangedSubview(futureMatchTitleLabel)
        
        nextMatchStack.addArrangedSubview(nextMatchHeaderStack)
        
        futureMatchLabel = UILabel()
        futureMatchLabel.translatesAutoresizingMaskIntoConstraints = false
        futureMatchLabel.text = "No upcoming match scheduled"
        futureMatchLabel.font = UIFont.systemFont(ofSize: 13)
        futureMatchLabel.numberOfLines = 2
        nextMatchStack.addArrangedSubview(futureMatchLabel)
        
        // Location with small pin icon
        let futureLocationStack = UIStackView()
        futureLocationStack.translatesAutoresizingMaskIntoConstraints = false
        futureLocationStack.axis = .horizontal
        futureLocationStack.spacing = 4
        futureLocationStack.alignment = .center
        
        let smallLocationIcon = UIImageView(image: UIImage(systemName: "mappin"))
        smallLocationIcon.translatesAutoresizingMaskIntoConstraints = false
        smallLocationIcon.tintColor = .systemBlue
        smallLocationIcon.contentMode = .scaleAspectFit
        
        futureLocationStack.addArrangedSubview(smallLocationIcon)
        
        futureMatchLocationLabel = UILabel()
        futureMatchLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        futureMatchLocationLabel.text = ""
        futureMatchLocationLabel.font = UIFont.systemFont(ofSize: 13)
        futureMatchLocationLabel.textColor = .systemBlue
        
        futureLocationStack.addArrangedSubview(futureMatchLocationLabel)
        nextMatchStack.addArrangedSubview(futureLocationStack)
        
        // Create buttons for history and scheduling
        let buttonStack = UIStackView()
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 12
        enhancedContainer.addSubview(buttonStack)
        
        historyButton = UIButton(type: .system)
        historyButton.translatesAutoresizingMaskIntoConstraints = false
        historyButton.setTitle("Match History", for: .normal)
        historyButton.setImage(UIImage(systemName: "clock.arrow.circlepath"), for: .normal)
        historyButton.backgroundColor = .systemBlue
        historyButton.setTitleColor(.white, for: .normal)
        historyButton.layer.cornerRadius = 8
        historyButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        historyButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        historyButton.addTarget(self, action: #selector(historyButtonTapped), for: .touchUpInside)
        buttonStack.addArrangedSubview(historyButton)
        
        scheduleButton = UIButton(type: .system)
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false
        scheduleButton.setTitle("Schedule Match", for: .normal)
        scheduleButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        scheduleButton.backgroundColor = .systemGreen
        scheduleButton.setTitleColor(.white, for: .normal)
        scheduleButton.layer.cornerRadius = 8
        scheduleButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        scheduleButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        scheduleButton.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
        buttonStack.addArrangedSubview(scheduleButton)
        
        // Layout constraints with improved spacing
        NSLayoutConstraint.activate([
            // Title label takes full width
            titleLabel.topAnchor.constraint(equalTo: enhancedContainer.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: enhancedContainer.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: enhancedContainer.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 36),
            
            // Location stack
            locationStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            locationStack.leadingAnchor.constraint(equalTo: enhancedContainer.leadingAnchor, constant: 16),
            locationStack.trailingAnchor.constraint(equalTo: enhancedContainer.trailingAnchor, constant: -16),
            locationIcon.widthAnchor.constraint(equalToConstant: 20),
            locationIcon.heightAnchor.constraint(equalToConstant: 20),
            
            // Divider
            divider.topAnchor.constraint(equalTo: locationStack.bottomAnchor, constant: 12),
            divider.leadingAnchor.constraint(equalTo: enhancedContainer.leadingAnchor, constant: 12),
            divider.trailingAnchor.constraint(equalTo: enhancedContainer.trailingAnchor, constant: -12),
            divider.heightAnchor.constraint(equalToConstant: 1),
            
            // Next match stack
            nextMatchStack.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 12),
            nextMatchStack.leadingAnchor.constraint(equalTo: enhancedContainer.leadingAnchor, constant: 16),
            nextMatchStack.trailingAnchor.constraint(equalTo: enhancedContainer.trailingAnchor, constant: -16),
            calendarIcon.widthAnchor.constraint(equalToConstant: 18),
            calendarIcon.heightAnchor.constraint(equalToConstant: 18),
            smallLocationIcon.widthAnchor.constraint(equalToConstant: 14),
            smallLocationIcon.heightAnchor.constraint(equalToConstant: 14),
            
            // Button stack at the bottom
            buttonStack.bottomAnchor.constraint(equalTo: enhancedContainer.bottomAnchor, constant: -12),
            buttonStack.leadingAnchor.constraint(equalTo: enhancedContainer.leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: enhancedContainer.trailingAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Update displays with current data
        updateLocationDisplay()
        updateFutureMatchDisplay()
    }
    
    */
    
    /* demo 1
    // Sets up new UI elements for enhanced functionality
     
    private func setupEnhancedUI() {
        // Create container view for new elements
        let enhancedContainer = UIView()
        enhancedContainer.translatesAutoresizingMaskIntoConstraints = false
        enhancedContainer.backgroundColor = .systemBackground
        //
        enhancedContainer.layer.borderWidth = 0.5
        enhancedContainer.layer.borderColor = UIColor.lightGray.cgColor
        enhancedContainer.layer.cornerRadius = 8
        view.addSubview(enhancedContainer)
        
        // Position the container below the score display elements
        NSLayoutConstraint.activate([
            enhancedContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 200),
            enhancedContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            enhancedContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            enhancedContainer.heightAnchor.constraint(equalToConstant: 130)
        ])
        
        // Create a title label for this section
            let titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.text = "Match Information"
            titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
            titleLabel.textAlignment = .center
            titleLabel.backgroundColor = .systemGray6
            titleLabel.layer.cornerRadius = 8
            titleLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            titleLabel.clipsToBounds = true
            enhancedContainer.addSubview(titleLabel)
        
        
        // Create and add location label
        locationLabel = UILabel()
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.text = "Location: Determining..."
        locationLabel.font = UIFont.systemFont(ofSize: 14)
        locationLabel.textAlignment = .center
        enhancedContainer.addSubview(locationLabel)
        
        // Create and add future match labels
        futureMatchTitleLabel = UILabel()
        futureMatchTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        futureMatchTitleLabel.text = "Next Match:"
        futureMatchTitleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        enhancedContainer.addSubview(futureMatchTitleLabel)
        
        futureMatchLabel = UILabel()
        futureMatchLabel.translatesAutoresizingMaskIntoConstraints = false
        futureMatchLabel.text = "No upcoming match scheduled"
        futureMatchLabel.font = UIFont.systemFont(ofSize: 12)
        futureMatchLabel.numberOfLines = 2
        enhancedContainer.addSubview(futureMatchLabel)
        
        futureMatchLocationLabel = UILabel()
        futureMatchLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        futureMatchLocationLabel.text = ""
        futureMatchLocationLabel.font = UIFont.systemFont(ofSize: 12)
        futureMatchLocationLabel.textColor = .systemBlue
        enhancedContainer.addSubview(futureMatchLocationLabel)
        
        // Create buttons for history and scheduling
        historyButton = UIButton(type: .system)
        historyButton.translatesAutoresizingMaskIntoConstraints = false
        historyButton.setTitle("Match History", for: .normal)
        historyButton.backgroundColor = .systemBlue
        historyButton.setTitleColor(.white, for: .normal)
        historyButton.layer.cornerRadius = 5
        historyButton.addTarget(self, action: #selector(historyButtonTapped), for: .touchUpInside)
        enhancedContainer.addSubview(historyButton)
        
        scheduleButton = UIButton(type: .system)
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false
        scheduleButton.setTitle("Schedule Match", for: .normal)
        scheduleButton.backgroundColor = .systemGreen
        scheduleButton.setTitleColor(.white, for: .normal)
        scheduleButton.layer.cornerRadius = 5
        scheduleButton.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
        enhancedContainer.addSubview(scheduleButton)
        
        /*// Layout constraints
        NSLayoutConstraint.activate([
            locationLabel.topAnchor.constraint(equalTo: enhancedContainer.topAnchor, constant: 10),
            locationLabel.leadingAnchor.constraint(equalTo: enhancedContainer.leadingAnchor, constant: 10),
            locationLabel.trailingAnchor.constraint(equalTo: enhancedContainer.trailingAnchor, constant: -10),
            */
        
        // Layout constraints with improved spacing
            NSLayoutConstraint.activate([
                // Title label takes full width
                titleLabel.topAnchor.constraint(equalTo: enhancedContainer.topAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: enhancedContainer.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: enhancedContainer.trailingAnchor),
                titleLabel.heightAnchor.constraint(equalToConstant: 30),
        
        
            // Location label below title
            futureMatchTitleLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
            futureMatchTitleLabel.leadingAnchor.constraint(equalTo: enhancedContainer.leadingAnchor, constant: 10),
            
            // Future match info
            futureMatchLabel.topAnchor.constraint(equalTo: futureMatchTitleLabel.bottomAnchor, constant: 4),
            futureMatchLabel.leadingAnchor.constraint(equalTo: enhancedContainer.leadingAnchor, constant: 10),
            futureMatchLabel.trailingAnchor.constraint(equalTo: enhancedContainer.centerXAnchor, constant: -5),
            
            futureMatchLocationLabel.topAnchor.constraint(equalTo: futureMatchLabel.bottomAnchor, constant: 4),
            futureMatchLocationLabel.leadingAnchor.constraint(equalTo: enhancedContainer.leadingAnchor, constant: 10),
            futureMatchLocationLabel.trailingAnchor.constraint(equalTo: enhancedContainer.centerXAnchor, constant: -5),
            
            historyButton.bottomAnchor.constraint(equalTo: enhancedContainer.bottomAnchor, constant: -10),
            historyButton.trailingAnchor.constraint(equalTo: enhancedContainer.centerXAnchor, constant: -5),
            historyButton.widthAnchor.constraint(equalToConstant: 120),
            historyButton.heightAnchor.constraint(equalToConstant: 36),
            
            scheduleButton.bottomAnchor.constraint(equalTo: enhancedContainer.bottomAnchor, constant: -10),
            scheduleButton.leadingAnchor.constraint(equalTo: enhancedContainer.centerXAnchor, constant: 5),
            scheduleButton.widthAnchor.constraint(equalToConstant: 120),
            scheduleButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // Update displays with current data
        updateLocationDisplay()
        updateFutureMatchDisplay()
    }
    
     */
    
    
    // MARK: - Location Services
    
    /* - Start location services to get current location
       - Uses LocationManager to obtain geographical information */
     
    private func startLocationServices() {
        LocationManager.shared.startLocationUpdates { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.updateLocationDisplay()
                }
            }
        }
    }
    
    /* - Update the location display with current location
       - Shows the city and country where the match is taking place */
     
    private func updateLocationDisplay() {
        let (city, country) = LocationManager.shared.getCurrentLocation()
        
        if city != "Unknown" { // If the city is not unknown, update the display
            currentLocation = "\(city), \(country)"
            locationLabel.text = "Location: \(currentLocation)"
        }
    }
    
    /* - Update the future match display
       - Shows information about the next scheduled match if available */
     
    private func updateFutureMatchDisplay() {
        if let futureMatch = CalendarManager.shared.getFutureMatch() { // If there is a future match
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            
            futureMatchLabel.text = "\(futureMatch.title) on \(dateFormatter.string(from: futureMatch.date))"
            futureMatchLocationLabel.text = "Location: \(futureMatch.location)"
        } else {
            futureMatchLabel.text = "No upcoming match scheduled" // No upcoming match
            futureMatchLocationLabel.text = ""
        }
    }
    
    
    // MARK: - Button Actions
    
    // Show match history screen when history button is tapped
    @objc private func historyButtonTapped() {
        let historyVC = MatchHistoryViewController()
        let navController = UINavigationController(rootViewController: historyVC)
        present(navController, animated: true) // Present history screen
    }
    
    // Show match scheduling screen when schedule button is tapped
     
    @objc private func scheduleButtonTapped() {
        let scheduleVC = FutureMatchViewController()
        scheduleVC.onMatchScheduled = { [weak self] match in
            self?.updateFutureMatchDisplay() // Update future match display if a new match is scheduled
        }
        let navController = UINavigationController(rootViewController: scheduleVC)
        present(navController, animated: true) // Present match scheduling screen
    }
    
    
    
    
    // MARK: - External Display Methods
    
    /* - Handle external screen connection
       - Called when an external display is connected to the device */
    
    @objc func screenDidConnect(_ notification: Notification) {
        setupExternalScreen() // Setup external screen when connected
    }
    
    //Handle when an external screen is disconnected
    @objc func screenDidDisconnect(_ notification: Notification) {
        // Clean up external display resources
        externalWindow?.isHidden = true
        externalWindow = nil
        externalViewController = nil
    }
    
    
    /* - Set up external screen for match display
       - Creates a window on the external screen and configures it to show match information for spectators */
    
    private func setupExternalScreen() {
        // Check if there's an external screen connected
        if let externalScreen = UIScreen.screens.last, UIScreen.screens.count > 1 {
            
            // Create a window for the external screen
            externalWindow = UIWindow(frame: externalScreen.bounds)
            externalWindow?.screen = externalScreen
            
            // Create an instance of the same storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // Get a reference to the view controller
            if let viewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                externalViewController = viewController
                
                // Configure the external view controller (disable buttons)
                externalViewController?.p1Button.isEnabled = false
                externalViewController?.p2Button.isEnabled = false
                
                externalWindow?.rootViewController = externalViewController
                externalWindow?.isHidden = false
                
                // Update external display
                updateExternalDisplay()
            }
        }
    }
    

    // Update the external display with the current match state
    
    private func updateExternalDisplay() {
        // Update the external display with current match state
        guard let externalVC = externalViewController else { return }
        
        // Transfer scores and other information to external display
        externalVC.p1PointsLabel.text = p1PointsLabel.text
        externalVC.p2PointsLabel.text = p2PointsLabel.text
        externalVC.p1GamesLabel.text = p1GamesLabel.text
        externalVC.p2GamesLabel.text = p2GamesLabel.text
        externalVC.p1SetsLabel.text = p1SetsLabel.text
        externalVC.p2SetsLabel.text = p2SetsLabel.text
        externalVC.p1PreviousSetsLabel.text = p1PreviousSetsLabel.text
        externalVC.p2PreviousSetsLabel.text = p2PreviousSetsLabel.text
        
        // Update colors on the external display
        externalVC.p1NameLabel.backgroundColor = p1NameLabel.backgroundColor
        externalVC.p2NameLabel.backgroundColor = p2NameLabel.backgroundColor
        externalVC.p1PointsLabel.backgroundColor = p1PointsLabel.backgroundColor
        externalVC.p2PointsLabel.backgroundColor = p2PointsLabel.backgroundColor
        externalVC.p1GamesLabel.backgroundColor = p1GamesLabel.backgroundColor
        externalVC.p2GamesLabel.backgroundColor = p2GamesLabel.backgroundColor
        externalVC.p1SetsLabel.backgroundColor = p1SetsLabel.backgroundColor
        externalVC.p2SetsLabel.backgroundColor = p2SetsLabel.backgroundColor
        
        // Update location and future match info on the external display
        if externalVC.locationLabel != nil {
            externalVC.locationLabel.text = locationLabel.text
            externalVC.futureMatchLabel.text = futureMatchLabel.text
            externalVC.futureMatchLocationLabel.text = futureMatchLocationLabel.text
        }
        
    }
    
    // MARK: - Audio Setup
    
    /* - Set up the audio player for sound effects
       - Prepares the audio file for playback during server changes and alerts */
     
    private func setupAudioPlayer() {
        if let soundURL = Bundle.main.url(forResource: "Sound", withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error loading sound file: \(error.localizedDescription)") // Handle error in loading sound file
            }
        }
    }
    
    /* - Play the sound effect
       - Used for server changes, new balls announcements, and match completion */
     
    private func playSound() {
        audioPlayer?.play()
    }
    
    
    // MARK: - Action Methods
    
    /* - Handler for when player 1 scores a point
       - Updates the match model and UI, checks for completed match */
     
    @IBAction func p1AddPointPressed(_ sender: UIButton) {
        if !match.complete() {
            
            //match.addPointToPlayer1()
            let serverChanged = match.addPointToPlayer1() // Add point to player 1
            updateUI()
            
            // Play sound if the server changed
            if serverChanged {
                playSound()
            }
            
            if match.complete() { // If match is complete, save and announce the winner
                //add saving func
                saveMatchToHistory()
                announceWinner()
            }
        }
    }
    
    /* - Handler for when player 2 scores a point
       - Updates the match model and UI, checks for completed match */
     
    @IBAction func p2AddPointPressed(_ sender: UIButton) {
        if !match.complete() {
            //match.addPointToPlayer2()
            let serverChanged = match.addPointToPlayer2()
            updateUI()
            
            
            // Play sound if server changed
            
           /*
            if serverChanged {
                playSound()
            }
            */
            
            if serverChanged == true {
                playSound()
            }
            
            if match.complete() {
                
                // If match is complete, save and announce the winner
                saveMatchToHistory()
                announceWinner()
            }
        }
    }
    
    
    /* - Handler for restarting the match
       - Resets the match to initial state */
     
    @IBAction func restartPressed(_ sender: AnyObject) {
        resetMatch()
    }
    
    /* - Save completed match to history
       - Stores match results in the MatchHistoryManager for future reference */
    
    private func saveMatchToHistory() {
        // Get previous sets scores to store
        let previousSetsScores = match.previousSetsScores()
        
        // Convert to arrays for storage
        var player1Games: [Int] = []
        var player2Games: [Int] = []
        
        // Store previous sets scores
        for setScore in previousSetsScores {
            player1Games.append(setScore.0)
            player2Games.append(setScore.1)
        }
        
        // Add current set if complete
        if match.complete() {
            player1Games.append(match.player1CurrentGames())
            player2Games.append(match.player2CurrentGames())
        }
        
        // Save match details to history
        MatchHistoryManager.shared.saveMatch(
            player1Sets: match.player1Sets(),
            player2Sets: match.player2Sets(),
            player1Games: player1Games,
            player2Games: player2Games,
            location: currentLocation
        )
    }
    
    
    
    // MARK: - Helper Methods
    
    /* - Reset the match and update the UI
       - Creates a new match and resets all UI elements */
     
    private func resetMatch() {
        match.reset()
        totalGamesPlayed = 0
        
        // Make sure buttons are enabled
        p1Button.isEnabled = true // Enable player 1 button
        p2Button.isEnabled = true // Enable player 2 button
        
        updateUI()
    }
    
    /*  - Update the UI with current match state
        - Updates scores, colors, highlights, and external display */
     
    private func updateUI() {
        // Reset background colors for all labels
        resetBackgroundColors()
        
        // Update scores and labels
        p1PointsLabel.text = match.player1GameScore()
        p2PointsLabel.text = match.player2GameScore()
        p1GamesLabel.text = "\(match.player1CurrentGames())"
        p2GamesLabel.text = "\(match.player2CurrentGames())"
        p1SetsLabel.text = "\(match.player1Sets())"
        p2SetsLabel.text = "\(match.player2Sets())"
        
        // Update previous sets scores
        updatePreviousSetsLabels()
        
        // Check for "new balls please" announcements
        checkForNewBalls()
        
        // Highlight the current server
        updateServerHighlight()
                
        // Highlight game/set/match points
        updatePointHighlights()
        
        // Update external display if connected
        updateExternalDisplay()
    }
    
    
    /* - Reset all background colors to default
       - Clears highlighting before applying new highlights */
         
        private func resetBackgroundColors() {
            p1NameLabel.backgroundColor = defaultColor
            p2NameLabel.backgroundColor = defaultColor
            p1PointsLabel.backgroundColor = defaultColor
            p2PointsLabel.backgroundColor = defaultColor
            p1GamesLabel.backgroundColor = defaultColor
            p2GamesLabel.backgroundColor = defaultColor
            p1SetsLabel.backgroundColor = defaultColor
            p2SetsLabel.backgroundColor = defaultColor
        }
        
    /* - Highlight the current server with purple background
       - Visual indicator of whose turn it is to serve */
         
        private func updateServerHighlight() {
            if match.isPlayer1Serving() {
                p1NameLabel.backgroundColor = serverColor
                p2NameLabel.backgroundColor = defaultColor
            } else {
                p1NameLabel.backgroundColor = defaultColor
                p2NameLabel.backgroundColor = serverColor
            }
        }
        
    //  Highlight game/set/match points with green background
       
         
        private func updatePointHighlights() {
            // Game points
            if match.hasPlayer1GamePoint() {
                p1PointsLabel.backgroundColor = pointColor
            }
            
            if match.hasPlayer2GamePoint() {
                p2PointsLabel.backgroundColor = pointColor
            }
            
            // Set points
            if match.hasPlayer1SetPoint() {
                p1GamesLabel.backgroundColor = pointColor
            }
            
            if match.hasPlayer2SetPoint() {
                p2GamesLabel.backgroundColor = pointColor
            }
            
            // Match points
            if match.hasPlayer1MatchPoint() {
                p1SetsLabel.backgroundColor = pointColor
            }
            
            if match.hasPlayer2MatchPoint() {
                p2SetsLabel.backgroundColor = pointColor
            }
        }
    
    
    
    
    /* - Update the previous sets labels with completed sets scores
       - Shows the history of set scores for the match */
    
    private func updatePreviousSetsLabels() {
        let previousSets = match.previousSetsScores()
        
        if previousSets.isEmpty {
            p1PreviousSetsLabel.text = "-"
            p2PreviousSetsLabel.text = "-"
        }
        else {
            var p1ScoresText = ""
            var p2ScoresText = ""
            
            for (p1Score, p2Score) in previousSets {
                p1ScoresText += "\(p1Score) "
                p2ScoresText += "\(p2Score) "
            }
            
            p1PreviousSetsLabel.text = p1ScoresText.trimmingCharacters(in: .whitespaces)
            p2PreviousSetsLabel.text = p2ScoresText.trimmingCharacters(in: .whitespaces)
        }
    }
    
    /* - Check if we need to announce "new balls please"
       - Follows tennis rules for ball changes during a match */
     
    private func checkForNewBalls() {
        let currentTotalGames = calculateTotalGamesPlayed()
        
        // Only announce when the game count changes
        if currentTotalGames > totalGamesPlayed {
            
            // New balls after first 7 games
            if currentTotalGames == 7 {
                announceNewBalls()
            }
            
            // Then after every 9 games
            else if currentTotalGames > 7 && (currentTotalGames - 7) % 9 == 0 {
                announceNewBalls()
            }
            
            // On a tie break
            else if match.isCurrentGameTieBreak() &&
                    (match.player1CurrentGames() == 6 && match.player2CurrentGames() == 6) {
                announceNewBalls()
            }
            
            totalGamesPlayed = currentTotalGames
        }
    }
    
    /* - Calculate the total games played in the match
       - Used for determining when new balls are needed
       - Return Total number of games completed in the match */
     
    private func calculateTotalGamesPlayed() -> Int {
        let previousSets = match.previousSetsScores()
        var total = 0
        
        // Count games from previous sets
        for (p1Games, p2Games) in previousSets {
            total += p1Games + p2Games
        }
        
        // Add games from current set
        total += match.player1CurrentGames() + match.player2CurrentGames()
        
        return total
    }
    
    /* - Announce new balls with an alert
       - Shows a modal dialog and plays a sound */
     
    private func announceNewBalls() {
        let alert = UIAlertController(title: "New Balls Please",
                                      message: nil,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        playSound()
        present(alert, animated: true)
    }
    
    /* - Announce the winner with an alert
       - Shows a modal dialog with the match result */
     
    private func announceWinner() {
        var title = ""
        
        if match.player1Won() {
            title = "Player 1 Wins!"
        } else if match.player2Won() {
            title = "Player 2 Wins!"
        }
        
        let alert = UIAlertController(title: title,
                                      message: "Game, Set, Match!",
                                      preferredStyle: .alert)
        
        
        // alert.addAction(UIAlertAction(title: "New Match", style: .default))
        // { _ in self.resetMatch()})
        
        
        
        // Add OK action - Change 'New Match' to 'OK' and add an option to display the upcoming match (if any).
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        
        // Add action to view future match if scheduled
        if CalendarManager.shared.getFutureMatch() != nil {
            alert.addAction(UIAlertAction(title: "Show Future Match", style: .default) { [weak self] _ in
                self?.showFutureMatchDetails()
            })
        }
        
        // Disable buttons when match is complete
        p1Button.isEnabled = false
        p2Button.isEnabled = false
        
        playSound()
        present(alert, animated: true)
    }
    
    /* - Show details about the next scheduled match
       - Displays information about the upcoming match */
    
        private func showFutureMatchDetails() {
            guard let futureMatch = CalendarManager.shared.getFutureMatch() else { return }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .full
            dateFormatter.timeStyle = .short
            
            let alert = UIAlertController(
                title: "Next Match",
                message: "\(futureMatch.title)\nDate: \(dateFormatter.string(from: futureMatch.date))\nLocation: \(futureMatch.location)",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            present(alert, animated: true)
        }
}


