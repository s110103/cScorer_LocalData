//
//  WarmupInfoViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 30.12.20.
//

import UIKit

protocol WarmupInfoViewControllerDelegate {
    func dismissWarmupInfo()
}

class WarmupInfoViewController: UIViewController {
    
    // MARK: - Variables
    var currentMatch: Match?
    var delegate: WarmupInfoViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var firstTeamFirstLabel: UILabel!
    @IBOutlet weak var firstTeamSecondLabel: UILabel!
    @IBOutlet weak var secondTeamFirstLabel: UILabel!
    @IBOutlet weak var secondTeamSecondLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initObjects()
        initPlayers()
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
    
    func initPlayers() {
        if currentMatch?.matchType.matchType == 0 {
            /*
                Singles
             */
            
            firstTeamFirstLabel.isHidden = true
            firstTeamSecondLabel.isHidden = false
            secondTeamFirstLabel.isHidden = false
            secondTeamSecondLabel.isHidden = true
            
            /*
                1. Team
             */
            
            if currentMatch?.firstTeamFirstPlayerDetails.country != "" {
                if currentMatch?.firstTeamFirstPlayerDetails.tennisClub != "" {
                    firstTeamSecondLabel.text = "\(currentMatch?.firstTeamFirstPlayerSurname ?? ""), \(currentMatch?.firstTeamFirstPlayer ?? "") [\(currentMatch?.firstTeamFirstPlayerDetails.country ?? "")] \n\(currentMatch?.firstTeamFirstPlayerDetails.tennisClub ?? "")"
                } else {
                    firstTeamSecondLabel.text = "\(currentMatch?.firstTeamFirstPlayerSurname ?? ""), \(currentMatch?.firstTeamFirstPlayer ?? "") [\(currentMatch?.firstTeamFirstPlayerDetails.country ?? "")]"
                }
            } else {
                if currentMatch?.firstTeamFirstPlayerDetails.tennisClub != "" {
                    firstTeamSecondLabel.text = "\(currentMatch?.firstTeamFirstPlayerSurname ?? ""), \(currentMatch?.firstTeamFirstPlayer ?? "") \n\(currentMatch?.firstTeamFirstPlayerDetails.tennisClub ?? "")"
                } else {
                    firstTeamSecondLabel.text = "\(currentMatch?.firstTeamFirstPlayerSurname ?? ""), \(currentMatch?.firstTeamFirstPlayer ?? "")"
                }
            }
            
            /*
                2. Team
             */
            
            if currentMatch?.secondTeamFirstPlayerDetails.country != "" {
                if currentMatch?.secondTeamFirstPlayerDetails.tennisClub != "" {
                    secondTeamFirstLabel.text = "\(currentMatch?.secondTeamFirstPlayerSurname ?? ""), \(currentMatch?.secondTeamFirstPlayer ?? "") [\(currentMatch?.secondTeamFirstPlayerDetails.country ?? "")] \n\(currentMatch?.secondTeamFirstPlayerDetails.tennisClub ?? "")"
                } else {
                    secondTeamFirstLabel.text = "\(currentMatch?.secondTeamFirstPlayerSurname ?? ""), \(currentMatch?.secondTeamFirstPlayer ?? "") [\(currentMatch?.secondTeamFirstPlayerDetails.country ?? "")]"
                }
            } else {
                if currentMatch?.firstTeamFirstPlayerDetails.tennisClub != "" {
                    secondTeamFirstLabel.text = "\(currentMatch?.secondTeamFirstPlayerSurname ?? ""), \(currentMatch?.secondTeamFirstPlayer ?? "") \n\(currentMatch?.secondTeamFirstPlayerDetails.tennisClub ?? "")"
                } else {
                    secondTeamFirstLabel.text = "\(currentMatch?.secondTeamFirstPlayerSurname ?? ""), \(currentMatch?.secondTeamFirstPlayer ?? "")"
                }
            }
            
        } else {
            /*
                Doubles
             */
            
            firstTeamFirstLabel.isHidden = true
            firstTeamSecondLabel.isHidden = false
            secondTeamFirstLabel.isHidden = false
            secondTeamSecondLabel.isHidden = true
            
            /*
                1. Team
             */
            
            if currentMatch?.firstTeamFirstPlayerDetails.country != "" {
                if currentMatch?.firstTeamFirstPlayerDetails.tennisClub != "" {
                    firstTeamFirstLabel.text = "\(currentMatch?.firstTeamFirstPlayerSurname ?? ""), \(currentMatch?.firstTeamFirstPlayer ?? "") [\(currentMatch?.firstTeamFirstPlayerDetails.country ?? "")] \n\(currentMatch?.firstTeamFirstPlayerDetails.tennisClub ?? "")"
                } else {
                    firstTeamFirstLabel.text = "\(currentMatch?.firstTeamFirstPlayerSurname ?? ""), \(currentMatch?.firstTeamFirstPlayer ?? "") [\(currentMatch?.firstTeamFirstPlayerDetails.country ?? "")]"
                }
            } else {
                if currentMatch?.firstTeamFirstPlayerDetails.tennisClub != "" {
                    firstTeamFirstLabel.text = "\(currentMatch?.firstTeamFirstPlayerSurname ?? ""), \(currentMatch?.firstTeamFirstPlayer ?? "") \n\(currentMatch?.firstTeamFirstPlayerDetails.tennisClub ?? "")"
                } else {
                    firstTeamFirstLabel.text = "\(currentMatch?.firstTeamFirstPlayerSurname ?? ""), \(currentMatch?.firstTeamFirstPlayer ?? "")"
                }
            }
            
            if currentMatch?.firstTeamSecondPlayerDetails.country != "" {
                if currentMatch?.firstTeamSecondPlayerDetails.tennisClub != "" {
                    firstTeamSecondLabel.text = "\(currentMatch?.firstTeamSecondPlayerSurname ?? ""), \(currentMatch?.firstTeamSecondPlayer ?? "") [\(currentMatch?.firstTeamSecondPlayerDetails.country ?? "")] \n\(currentMatch?.firstTeamSecondPlayerDetails.tennisClub ?? "")"
                } else {
                    firstTeamSecondLabel.text = "\(currentMatch?.firstTeamSecondPlayerSurname ?? ""), \(currentMatch?.firstTeamSecondPlayer ?? "") [\(currentMatch?.firstTeamSecondPlayerDetails.country ?? "")]"
                }
            } else {
                if currentMatch?.firstTeamSecondPlayerDetails.tennisClub != "" {
                    firstTeamSecondLabel.text = "\(currentMatch?.firstTeamSecondPlayerSurname ?? ""), \(currentMatch?.firstTeamSecondPlayer ?? "") \n\(currentMatch?.firstTeamSecondPlayerDetails.tennisClub ?? "")"
                } else {
                    firstTeamSecondLabel.text = "\(currentMatch?.firstTeamSecondPlayerSurname ?? ""), \(currentMatch?.firstTeamSecondPlayer ?? "")"
                }
            }
            
            /*
                2. Team
             */
            
            if currentMatch?.secondTeamFirstPlayerDetails.country != "" {
                if currentMatch?.secondTeamFirstPlayerDetails.tennisClub != "" {
                    secondTeamFirstLabel.text = "\(currentMatch?.secondTeamFirstPlayerSurname ?? ""), \(currentMatch?.secondTeamFirstPlayer ?? "") [\(currentMatch?.secondTeamFirstPlayerDetails.country ?? "")] \n\(currentMatch?.secondTeamFirstPlayerDetails.tennisClub ?? "")"
                } else {
                    secondTeamFirstLabel.text = "\(currentMatch?.secondTeamFirstPlayerSurname ?? ""), \(currentMatch?.secondTeamFirstPlayer ?? "") [\(currentMatch?.secondTeamFirstPlayerDetails.country ?? "")]"
                }
            } else {
                if currentMatch?.secondTeamFirstPlayerDetails.tennisClub != "" {
                    secondTeamFirstLabel.text = "\(currentMatch?.secondTeamFirstPlayerSurname ?? ""), \(currentMatch?.secondTeamFirstPlayer ?? "") \n\(currentMatch?.secondTeamFirstPlayerDetails.tennisClub ?? "")"
                } else {
                    secondTeamFirstLabel.text = "\(currentMatch?.secondTeamFirstPlayerSurname ?? ""), \(currentMatch?.secondTeamFirstPlayer ?? "")"
                }
            }
            
            if currentMatch?.secondTeamSecondPlayerDetails.country != "" {
                if currentMatch?.secondTeamSecondPlayerDetails.tennisClub != "" {
                    secondTeamSecondLabel.text = "\(currentMatch?.secondTeamSecondPlayerSurname ?? ""), \(currentMatch?.secondTeamSecondPlayer ?? "") [\(currentMatch?.secondTeamSecondPlayerDetails.country ?? "")] \n\(currentMatch?.secondTeamSecondPlayerDetails.tennisClub ?? "")"
                } else {
                    secondTeamSecondLabel.text = "\(currentMatch?.secondTeamSecondPlayerSurname ?? ""), \(currentMatch?.secondTeamSecondPlayer ?? "") [\(currentMatch?.secondTeamSecondPlayerDetails.country ?? "")]"
                }
            } else {
                if currentMatch?.secondTeamSecondPlayerDetails.tennisClub != "" {
                    secondTeamSecondLabel.text = "\(currentMatch?.secondTeamSecondPlayerSurname ?? ""), \(currentMatch?.secondTeamSecondPlayer ?? "") \n\(currentMatch?.secondTeamSecondPlayerDetails.tennisClub ?? "")"
                } else {
                    secondTeamSecondLabel.text = "\(currentMatch?.secondTeamSecondPlayerSurname ?? ""), \(currentMatch?.secondTeamSecondPlayer ?? "")"
                }
            }
        }
    }
    
    func initObjects() {
        backgroundView.layer.cornerRadius = 20
        backgroundView.layer.masksToBounds = true
        
        firstTeamFirstLabel.layer.cornerRadius = 5
        firstTeamFirstLabel.layer.masksToBounds = true
        firstTeamSecondLabel.layer.cornerRadius = 5
        firstTeamSecondLabel.layer.masksToBounds = true
        secondTeamFirstLabel.layer.cornerRadius = 5
        secondTeamFirstLabel.layer.masksToBounds = true
        secondTeamSecondLabel.layer.cornerRadius = 5
        secondTeamSecondLabel.layer.masksToBounds = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super .touchesBegan(touches, with: event)
        
        let touch = touches.first
        
        guard let location = touch?.location(in: view) else { return }
        
        if !backgroundView.frame.contains(location) {
            dismiss(animated: true, completion: nil)
        }
    }

}
