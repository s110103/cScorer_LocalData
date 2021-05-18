//
//  ValidateCodeViolationViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 18.05.21.
//

import UIKit

protocol ValidateCodeViolationViewControllerDelegate {
    func validateCodeViolation(player: String, violation: Int, penalty: Int)
}

class ValidateCodeViolationViewController: UIViewController {
    
    // MARK: - Variables
    var delegate: ValidateCodeViolationViewControllerDelegate?
    var currentMatch: Match?
    var indexOfMatch: Int = 0
    var selectedPlayer: String = ""
    var selectedCodeViolation: Int = 0
    var currentViolations: Int = 0
    var selectedPenalty: Int = 0
    
    var selectableCodeViolations: [String] =
    [
        "Unreasonable Delays",
        "Audible obscenity",
        "Visible obscenity",
        "Ball abuse",
        "Racket abuse",
        "Verbal abuse",
        "Physical abuse",
        "Coaching",
        "Unsportsmanlike conduct"
    ]
    var selectableCodeViolationAbbreviations: [String] =
    [
        "Del",
        "AOb",
        "VOb",
        "BA",
        "RA",
        "VA",
        "PhA",
        "CC",
        "UnC"
    ]
    var selectablePenalties: [String] =
    [
        "Warning",
        "Point Penalty",
        "Game Penalty",
        "Default"
    ]
    
    // MARK: - Outlets
    @IBOutlet weak var validateCodeViolationView: UIView!
    @IBOutlet weak var validateCodeViolationHeadingLabel: UILabel!
    @IBOutlet weak var validateCodeViolationDescriptionLabel: UILabel!
    @IBOutlet weak var validateCodeViolationButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initLayout()
    }
    
    // MARK: - Actions
    @IBAction func validateButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        
        delegate?.validateCodeViolation(player: selectedPlayer, violation: selectedCodeViolation, penalty: selectedPenalty)
    }
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
    func initLayout() {
        validateCodeViolationView.layer.masksToBounds = true
        validateCodeViolationView.layer.cornerRadius = 10
        
        validateCodeViolationButton.layer.borderWidth = 1
        validateCodeViolationButton.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
        
        switch selectedPlayer{
        case "firstTeamFirstPlayer":
            validateCodeViolationHeadingLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)"
            
            currentViolations = (currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolations)!
        case "firstTeamSecondPlayer":
            validateCodeViolationHeadingLabel.text = "\(currentMatch!.firstTeamSecondPlayer.prefix(1)). \(currentMatch!.firstTeamSecondPlayerSurname)"
            
            currentViolations = (currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolations)!
        case "secondTeamFirstPlayer":
            validateCodeViolationHeadingLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)"
            
            currentViolations = (currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolations)!
        case "secondTeamSecondPlayer":
            validateCodeViolationHeadingLabel.text = "\(currentMatch!.secondTeamSecondPlayer.prefix(1)). \(currentMatch!.secondTeamSecondPlayerSurname)"
            
            currentViolations = (currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolations)!
        default:
            break
        }
        
        validateCodeViolationDescriptionLabel.text = "Code Violation: \(selectablePenalties[selectedPenalty]) -  \(selectableCodeViolationAbbreviations[selectedCodeViolation])"
    }

}
