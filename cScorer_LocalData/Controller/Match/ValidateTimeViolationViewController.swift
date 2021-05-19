//
//  ValidateTimeViolationViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 19.05.21.
//

import UIKit

protocol ValidateTimeViolationViewControllerDelegate {
    func validateTimeViolation(player: String, penalty: Int)
}

class ValidateTimeViolationViewController: UIViewController {
    
    // MARK: - Variables
    var delegate: ValidateTimeViolationViewControllerDelegate?
    var currentMatch: Match?
    var indexOfMatch: Int = 0
    var selectedPlayer: String = ""
    var currentViolations: Int = 0
    var selectedPenalty: Int = 0
    
    var selectablePenalties: [String] =
    [
        "Warning",
        "Loss of Serve",
        "Point Penalty"
    ]
    
    // MARK: - Outlets
    @IBOutlet weak var validateTimeViolationView: UIView!
    @IBOutlet weak var validateTimeViolationHeadingLabel: UILabel!
    @IBOutlet weak var validateTimeViolationDescriptionLabel: UILabel!
    @IBOutlet weak var validateTimeViolationButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initLayout()
    }
    
    // MARK: - Actions
    @IBAction func validateTimeViolationButtonTapped(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
        
        delegate?.validateTimeViolation(player: selectedPlayer, penalty: selectedPenalty)
    }
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
    func initLayout() {
        validateTimeViolationView.layer.masksToBounds = true
        validateTimeViolationView.layer.cornerRadius = 10
        
        validateTimeViolationButton.layer.borderWidth = 1
        validateTimeViolationButton.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
        
        switch selectedPlayer{
        case "firstTeamFirstPlayer":
            validateTimeViolationHeadingLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)"
            
            currentViolations = (currentMatch?.matchStatistics.secondTeamSecondPlayerTimeViolations)!
        case "firstTeamSecondPlayer":
            validateTimeViolationHeadingLabel.text = "\(currentMatch!.firstTeamSecondPlayer.prefix(1)). \(currentMatch!.firstTeamSecondPlayerSurname)"
            
            currentViolations = (currentMatch?.matchStatistics.secondTeamSecondPlayerTimeViolations)!
        case "secondTeamFirstPlayer":
            validateTimeViolationHeadingLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)"
            
            currentViolations = (currentMatch?.matchStatistics.secondTeamSecondPlayerTimeViolations)!
        case "secondTeamSecondPlayer":
            validateTimeViolationHeadingLabel.text = "\(currentMatch!.secondTeamSecondPlayer.prefix(1)). \(currentMatch!.secondTeamSecondPlayerSurname)"
            
            currentViolations = (currentMatch?.matchStatistics.secondTeamSecondPlayerTimeViolations)!
        default:
            break
        }
        
        validateTimeViolationDescriptionLabel.text = "Time Violation: \(selectablePenalties[selectedPenalty])"
    }
}
