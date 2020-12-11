//
//  ChairUmpireOnCourtViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 11.12.20.
//

import UIKit

protocol ChairUmpireOnCourtViewControllerDelegate {
    func sendSelectedMatch(currentMatch: Match)
}

class ChairUmpireOnCourtViewController: UIViewController {
    
    // MARK: - Variables
    var currentMatch: Match = Match()
    var delegate: ChairUmpireOnCourtViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var firstTeamLabel: UILabel!
    @IBOutlet weak var secondTeamLabel: UILabel!
    @IBOutlet weak var chairUmpireOnCourtButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        chairUmpireOnCourtButton.layer.cornerRadius = 10
        chairUmpireOnCourtButton.layer.masksToBounds = true
        
        initLabels()
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func chairUmpireOnCourtButtonTapped(_ sender: UIButton) {
        currentMatch.matchStatistics.chairUmpireOnCourt = true
        currentMatch.matchStatistics.chairUmpireOnCourtTimeStamp = NSDate()
    }
    
    // MARK: - Functions
    func initLabels() {
        if currentMatch.matchType.matchType == 0 {
            firstTeamLabel.text = "\(currentMatch.firstTeamFirstPlayerSurname) \(currentMatch.firstTeamFirstPlayer)"
            secondTeamLabel.text = "\(currentMatch.secondTeamFirstPlayerSurname) \(currentMatch.secondTeamFirstPlayer)"
        } else {
            firstTeamLabel.text = "\(currentMatch.firstTeamFirstPlayerSurname) \(currentMatch.firstTeamFirstPlayer) \n \(currentMatch.firstTeamSecondPlayerSurname) \(currentMatch.firstTeamSecondPlayer)"
            secondTeamLabel.text = "\(currentMatch.secondTeamFirstPlayerSurname) \(currentMatch.secondTeamFirstPlayer) \n \(currentMatch.secondTeamSecondPlayerSurname) \(currentMatch.secondTeamSecondPlayer)"
        }
    }

}
