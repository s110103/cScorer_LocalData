//
//  ClarifyCodeViolationViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 18.05.21.
//

import UIKit

protocol ClarifyCodeViolationViewControllerDelegate {
    func clarifyCodeViolation(player: String, violation: Int, penalty: Int)
}

class ClarifyCodeViolationViewController: UIViewController {
    
    // MARK: - Variables
    var delegate: ClarifyCodeViolationViewControllerDelegate?
    var currentMatch: Match?
    var indexOfMatch: Int = 0
    var selectedPlayer: String = ""
    var selectedCodeViolation: Int = 0
    var currentViolations: Int = 0
    
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
    
    // MARK: - Outlets
    @IBOutlet weak var clarifyCodeViolationView: UIView!
    @IBOutlet weak var clarifyCodeViolationHeadingLabel: UILabel!
    @IBOutlet weak var clarifyCodeViolationDescriptionLabel: UILabel!
    @IBOutlet weak var clarifyCodeViolationRegularPenaltyButton: UIButton!
    @IBOutlet weak var clarifyCodeViolationDefaultButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initLayout()
    }
    
    // MARK: - Actions
    @IBAction func regularPenaltyButtonTapped(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
        
        if currentViolations == 0 {
            delegate?.clarifyCodeViolation(player: selectedPlayer, violation: selectedCodeViolation, penalty: 0)
            
        } else if currentViolations == 1 {
            delegate?.clarifyCodeViolation(player: selectedPlayer, violation: selectedCodeViolation, penalty: 1)
            
        } else {
            delegate?.clarifyCodeViolation(player: selectedPlayer, violation: selectedCodeViolation, penalty: 2)
            
        }
    }
    @IBAction func defaultButtonTapped(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
        
        delegate?.clarifyCodeViolation(player: selectedPlayer, violation: selectedCodeViolation, penalty: 3)
    }
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
    func initLayout() {
        clarifyCodeViolationView.layer.masksToBounds = true
        clarifyCodeViolationView.layer.cornerRadius = 10
        
        switch selectedPlayer{
        case "firstTeamFirstPlayer":
            clarifyCodeViolationHeadingLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)"
            
            currentViolations = (currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolations)!
        case "firstTeamSecondPlayer":
            clarifyCodeViolationHeadingLabel.text = "\(currentMatch!.firstTeamSecondPlayer.prefix(1)). \(currentMatch!.firstTeamSecondPlayerSurname)"
            
            currentViolations = (currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolations)!
        case "secondTeamFirstPlayer":
            clarifyCodeViolationHeadingLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)"
            
            currentViolations = (currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolations)!
        case "secondTeamSecondPlayer":
            clarifyCodeViolationHeadingLabel.text = "\(currentMatch!.secondTeamSecondPlayer.prefix(1)). \(currentMatch!.secondTeamSecondPlayerSurname)"
            
            currentViolations = (currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolations)!
        default:
            break
        }
        
        clarifyCodeViolationDescriptionLabel.text = "Code Violation: \(selectableCodeViolationAbbreviations[selectedCodeViolation]) - \(selectableCodeViolations[selectedCodeViolation])"
        
        if currentViolations == 0 {
            clarifyCodeViolationRegularPenaltyButton.setTitle("Warning", for: .normal)
        } else if currentViolations == 1 {
            clarifyCodeViolationRegularPenaltyButton.setTitle("Point Penalty", for: .normal)
        } else {
            clarifyCodeViolationRegularPenaltyButton.setTitle("Game Penalty", for: .normal)
        }
    }

}
