//
//  SelectPlayerViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 18.05.21.
//

import UIKit

protocol SelectPlayerViewControllerDelegate {
    func returnSelectedPlayer(player: String, furtherAction: String)
}

class SelectPlayerViewController: UIViewController {
    
    // MARK: - Variables
    var delegate: SelectPlayerViewControllerDelegate?
    var currentMatch: Match?
    var currentTeam: String = ""
    var furtherAction: String = ""
    var indexOfMatch: Int = 0
    
    // MARK: - Outlets
    @IBOutlet weak var selectPlayerView: UIView!
    @IBOutlet weak var selectFirstPlayerButton: UIButton!
    @IBOutlet weak var selectSecondPlayerButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initLayout()
    }
    
    // MARK: - Actions
    @IBAction func firstPlayerButtonTapped(_ sender: UIButton) {
        if currentTeam == "firstTeam" {
            delegate?.returnSelectedPlayer(player: "firstTeamFirstPlayer", furtherAction: furtherAction)
        } else {
            delegate?.returnSelectedPlayer(player: "secondTeamFirstPlayer", furtherAction: furtherAction)
        }
    }
    
    @IBAction func secondPlayerButtonTapped(_ sender: UIButton) {
        if currentTeam == "firstTeam" {
            delegate?.returnSelectedPlayer(player: "firstTeamSecondPlayer", furtherAction: furtherAction)
        } else {
            delegate?.returnSelectedPlayer(player: "secondTeamSecondPlayer", furtherAction: furtherAction)
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
    func initLayout() {
        selectPlayerView.layer.cornerRadius = 10
        selectPlayerView.layer.masksToBounds = true
        
        if currentTeam == "firstTeam" {
            selectFirstPlayerButton.setTitle("\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)", for: .normal)
            selectSecondPlayerButton.setTitle("\(currentMatch!.firstTeamSecondPlayer.prefix(1)). \(currentMatch!.firstTeamSecondPlayerSurname)", for: .normal)
        } else {
            selectFirstPlayerButton.setTitle("\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)", for: .normal)
            selectSecondPlayerButton.setTitle("\(currentMatch!.secondTeamSecondPlayer.prefix(1)). \(currentMatch!.secondTeamSecondPlayerSurname)", for: .normal)
        }
    }

}
