//
//  ClarifyTimeViolationViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 19.05.21.
//

import UIKit

protocol ClarifyTimeViolationViewControllerDelegate {
    func clarifyTimeViolation(player: String, penalty: Int)
}

class ClarifyTimeViolationViewController: UIViewController {
    
    // MARK: - Variables
    var delegate: ClarifyTimeViolationViewControllerDelegate?
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
    @IBOutlet weak var clarifyTimeViolationView: UIView!
    @IBOutlet weak var clarifyTimeViolationHeadingLabel: UILabel!
    @IBOutlet weak var clairfyTimeViolationDescriptionLabel: UILabel!
    @IBOutlet weak var clarifyTimeViolationPenaltyButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initLayout()
    }
    

    // MARK: - Actions
    @IBAction func clarifyTimeViolationButtonTapped(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
        
        delegate?.clarifyTimeViolation(player: selectedPlayer, penalty: selectedPenalty)
    }
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
    func initLayout() {
        clarifyTimeViolationView.layer.masksToBounds = true
        clarifyTimeViolationView.layer.cornerRadius = 10
        
        switch selectedPlayer{
        case "firstTeamFirstPlayer":
            clarifyTimeViolationHeadingLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)"
            
            currentViolations = (currentMatch?.matchStatistics.firstTeamFirstPlayerTimeViolations)!
        case "firstTeamSecondPlayer":
            clarifyTimeViolationHeadingLabel.text = "\(currentMatch!.firstTeamSecondPlayer.prefix(1)). \(currentMatch!.firstTeamSecondPlayerSurname)"
            
            currentViolations = (currentMatch?.matchStatistics.firstTeamSecondPlayerTimeViolations)!
        case "secondTeamFirstPlayer":
            clarifyTimeViolationHeadingLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)"
            
            currentViolations = (currentMatch?.matchStatistics.secondTeamFirstPlayerTimeViolations)!
        case "secondTeamSecondPlayer":
            clarifyTimeViolationHeadingLabel.text = "\(currentMatch!.secondTeamSecondPlayer.prefix(1)). \(currentMatch!.secondTeamSecondPlayerSurname)"
            
            currentViolations = (currentMatch?.matchStatistics.secondTeamSecondPlayerTimeViolations)!
        default:
            break
        }
        
        clairfyTimeViolationDescriptionLabel.text = "Time Violation"
        
        if currentViolations == 0 {
            clarifyTimeViolationPenaltyButton.setTitle("Warning", for: .normal)
            selectedPenalty = 0
        } else {
            
            if selectedPlayer.starts(with: "firstTeam") && currentMatch!.matchStatistics.isServer.starts(with: "firstTeam") {
                clarifyTimeViolationPenaltyButton.setTitle("Loss of Serve", for: .normal)
                selectedPenalty = 1
            } else if selectedPlayer.starts(with: "secondTeam") && currentMatch!.matchStatistics.isServer.starts(with: "secondTeam") {
                clarifyTimeViolationPenaltyButton.setTitle("Loss of Serve", for: .normal)
                selectedPenalty = 1
            } else {
                clarifyTimeViolationPenaltyButton.setTitle("Point Penalty", for: .normal)
                selectedPenalty = 2
            }
        }
    }

}
