//
//  MatchViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 04.04.21.
//

import UIKit
import AVFoundation
import MediaPlayer

protocol MatchViewControllerDelegate {
    func sendMatch(currentMatch: Match, selectedIndex: Int)
}

class MatchViewController: UIViewController {
    
    // MARK: - Variables
    var currentMatch: Match?
    var selectedIndex: Int?
    
    var pointStarted: Bool = false
    var firstFault: Bool = false
    
    var delegate: MatchViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var interactMatchButton: UIButton!
    @IBOutlet weak var courtButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    
    @IBOutlet weak var matchTimeLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var firstTeamFirstScoreLabel: UILabel!
    @IBOutlet weak var firstTeamSecondScoreLabel: UILabel!
    @IBOutlet weak var firstTeamThirdScoreLabel: UILabel!
    @IBOutlet weak var firstTeamFourthScoreLabel: UILabel!
    @IBOutlet weak var firstTeamFifthScoreLabel: UILabel!
    @IBOutlet weak var secondTeamFirstScoreLabel: UILabel!
    @IBOutlet weak var secondTeamSecondScoreLabel: UILabel!
    @IBOutlet weak var secondTeamThirdScoreLabel: UILabel!
    @IBOutlet weak var secondTeamFourthScoreLabel: UILabel!
    @IBOutlet weak var secondTeamFifthScoreLabel: UILabel!
    
    @IBOutlet weak var firstTeamLabel: UILabel!
    @IBOutlet weak var secondTeamLabel: UILabel!
    
    @IBOutlet weak var courtLeftFarLabel: UILabel!
    @IBOutlet weak var courtLeftNearLabel: UILabel!
    @IBOutlet weak var courtRightFarLabel: UILabel!
    @IBOutlet weak var courtRightNearLabel: UILabel!
    
    @IBOutlet weak var ballchangeIndicatorLabel: UILabel!
    
    @IBOutlet weak var firstTeamServerIndicatorView: UIView!
    @IBOutlet weak var secondTeamServerIndicatorView: UIView!
    
    
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var footfaultButton: UIButton!
    @IBOutlet weak var overruleButton: UIButton!
    @IBOutlet weak var faultButton: UIButton!
    @IBOutlet weak var netButton: UIButton!
    @IBOutlet weak var aceButton: UIButton!
    @IBOutlet weak var firstTeamPointButton: UIButton!
    @IBOutlet weak var secondTeamPointButton: UIButton!
    @IBOutlet weak var startOfPointButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initLayout()
        initMatch()
        
        listenVolumeButton()
    }
    
    // MARK: - Actions
    @IBAction func matchSettingsButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func interactMatchButtonTapped(_ sender: UIButton) {
        if interactMatchButton.title(for: .normal) == "Start Match" {
            interactMatchButton.backgroundColor = UIColor.systemRed
            interactMatchButton.setTitle("Stop Match", for: .normal)
            currentMatch?.matchStatistics.matchStartedTimeStamp = NSDate()
            currentMatch?.matchStatistics.matchRunning = true
        }
    }
    
    @IBAction func courtButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func infoButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func startOfPointButtonTapped(_ sender: UIButton) {
        startOfPointButton.isHidden = true
        pointStarted = true
        
        if currentMatch?.matchStatistics.matchRunning == false {
            interactMatchButton.backgroundColor = UIColor.systemRed
            interactMatchButton.setTitle("Stop Match", for: .normal)
            currentMatch?.matchStatistics.matchStartedTimeStamp = NSDate()
            currentMatch?.matchStatistics.matchRunning = true
        }
    }
    
    @IBAction func aceButtonTapped(_ sender: UIButton) {
        pointStarted = false
        startOfPointButton.isHidden = false
    }
    
    @IBAction func netButtonTaped(_ sender: UIButton) {
    }
    
    @IBAction func faultButtonTapped(_ sender: UIButton) {
        if firstFault == false {
            firstFault = true
        } else {
            firstFault = false
            pointStarted = false
            startOfPointButton.isHidden = false
        }
    }
    
    @IBAction func overruleButtonTapped(_ sender: UIButton) {
        currentMatch?.matchStatistics.totalOverrules+=1
    }
    
    @IBAction func undoButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func footfaultButtonTapped(_ sender: UIButton) {
        if firstFault == false {
            firstFault = true
        } else {
            firstFault = false
            pointStarted = false
            startOfPointButton.isHidden = false
        }
    }
    
    @IBAction func firstTeamPointButtonTapped(_ sender: UIButton) {
        pointStarted = false
        startOfPointButton.isHidden = false

        currentMatch?.matchStatistics.currentGameInteger += 1
        
        if currentMatch?.matchType.matchType == 0 {
            if currentMatch?.matchStatistics.currentFirstPosition == "firstTeam" {
                if currentMatch?.matchStatistics.currentGameFirstPlayer == 0 {
                    currentMatch?.matchStatistics.currentGameFirstPlayer = 15
                } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 15 {
                    currentMatch?.matchStatistics.currentGameFirstPlayer = 30
                } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 30 {
                    currentMatch?.matchStatistics.currentGameFirstPlayer = 40
                } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 40 {
                    if currentMatch?.matchStatistics.currentGameSecondPlayer == 40 || currentMatch?.matchStatistics.currentGameSecondPlayer == 50 {
                        if currentMatch?.matchStatistics.currentGameSecondPlayer == 40 {
                            // Ad
                            currentMatch?.matchStatistics.currentGameFirstPlayer = 50
                        } else {
                            // Deuce
                            currentMatch?.matchStatistics.currentGameSecondPlayer = 40
                        }
                        
                    } else{
                        /*
                                Game finished Routine
                         */
                        
                        currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                        currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                        
                        currentMatch?.matchStatistics.currentGameInteger = 0
                    }
                } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 50 {
                    /*
                            Game finished Routine
                     */
                    
                    currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                    currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                    
                    currentMatch?.matchStatistics.currentGameInteger = 0
                }
                
                if currentMatch?.matchStatistics.currentGameFirstPlayer == 40 && currentMatch?.matchStatistics.currentGameSecondPlayer == 40 {
                    currentMatch?.matchStatistics.currentGame = "DEUCE"
                } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 50 && currentMatch?.matchStatistics.currentGameSecondPlayer == 40 {
                    currentMatch?.matchStatistics.currentGame = "Ad \(currentMatch!.firstTeamFirstPlayerSurname)"
                } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 40 && currentMatch?.matchStatistics.currentGameSecondPlayer == 50 {
                    currentMatch?.matchStatistics.currentGame = "Ad \(currentMatch!.secondTeamFirstPlayerSurname)"
                } else {
                    if currentMatch?.matchStatistics.isServer == "firstTeamFirst" {
                        currentMatch?.matchStatistics.currentGame = "\(currentMatch!.matchStatistics.currentGameFirstPlayer)/\(currentMatch!.matchStatistics.currentGameSecondPlayer)"
                    } else {
                        currentMatch?.matchStatistics.currentGame = "\(currentMatch!.matchStatistics.currentGameSecondPlayer)/\(currentMatch!.matchStatistics.currentGameFirstPlayer)"
                    }
                }
                
                scoreLabel.text = currentMatch?.matchStatistics.currentGame
            } else {
                if currentMatch?.matchStatistics.currentGameSecondPlayer == 0 {
                    currentMatch?.matchStatistics.currentGameSecondPlayer = 15
                } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 15 {
                    currentMatch?.matchStatistics.currentGameSecondPlayer = 30
                } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 30 {
                    currentMatch?.matchStatistics.currentGameSecondPlayer = 40
                } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 40 {
                    if currentMatch?.matchStatistics.currentGameFirstPlayer == 40 || currentMatch?.matchStatistics.currentGameFirstPlayer == 50 {
                        if currentMatch?.matchStatistics.currentGameFirstPlayer == 40 {
                            // Ad
                            currentMatch?.matchStatistics.currentGameSecondPlayer = 50
                        } else {
                            // Deuce
                            currentMatch?.matchStatistics.currentGameFirstPlayer = 40
                        }
                        
                    } else{
                        /*
                                Game finished Routine
                         */
                        
                        currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                        currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                        
                        currentMatch?.matchStatistics.currentGameInteger = 0
                    }
                } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 50 {
                    /*
                            Game finished Routine
                     */
                    
                    currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                    currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                    
                    currentMatch?.matchStatistics.currentGameInteger = 0
                }
                
                if currentMatch?.matchStatistics.currentGameFirstPlayer == 40 && currentMatch?.matchStatistics.currentGameSecondPlayer == 40 {
                    currentMatch?.matchStatistics.currentGame = "DEUCE"
                } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 50 && currentMatch?.matchStatistics.currentGameSecondPlayer == 40 {
                    currentMatch?.matchStatistics.currentGame = "Ad \(currentMatch!.firstTeamFirstPlayerSurname)"
                } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 40 && currentMatch?.matchStatistics.currentGameSecondPlayer == 50 {
                    currentMatch?.matchStatistics.currentGame = "Ad \(currentMatch!.secondTeamFirstPlayerSurname)"
                } else {
                    if currentMatch?.matchStatistics.isServer == "firstTeamFirst" {
                        currentMatch?.matchStatistics.currentGame = "\(currentMatch!.matchStatistics.currentGameFirstPlayer)/\(currentMatch!.matchStatistics.currentGameSecondPlayer)"
                    } else {
                        currentMatch?.matchStatistics.currentGame = "\(currentMatch!.matchStatistics.currentGameSecondPlayer)/\(currentMatch!.matchStatistics.currentGameFirstPlayer)"
                    }
                }
                
                scoreLabel.text = currentMatch?.matchStatistics.currentGame
            }
            
            if currentMatch?.matchStatistics.currentGameInteger == 0 {
                courtLeftFarLabel.isHidden = true
                courtLeftNearLabel.isHidden = false
                courtRightFarLabel.isHidden = false
                courtRightNearLabel.isHidden = true
            } else if currentMatch?.matchStatistics.currentGameInteger == 1 {
                courtLeftFarLabel.isHidden = false
                courtLeftNearLabel.isHidden = true
                courtRightFarLabel.isHidden = true
                courtRightNearLabel.isHidden = false
            } else {
                if currentMatch!.matchStatistics.currentGameInteger % 2 == 0 {
                    courtLeftFarLabel.isHidden = true
                    courtLeftNearLabel.isHidden = false
                    courtRightFarLabel.isHidden = false
                    courtRightNearLabel.isHidden = true
                } else {
                    courtLeftFarLabel.isHidden = false
                    courtLeftNearLabel.isHidden = true
                    courtRightFarLabel.isHidden = true
                    courtRightNearLabel.isHidden = false
                }
            }
        } else {
            // Doubles
        }
    }
    
    @IBAction func secondTeamPointButtonTapped(_ sender: UIButton) {
        pointStarted = false
        startOfPointButton.isHidden = false
        
        currentMatch?.matchStatistics.currentGameInteger += 1
        
        if currentMatch?.matchType.matchType == 0 {
            if currentMatch?.matchStatistics.currentSecondPosition == "firstTeam" {
                if currentMatch?.matchStatistics.currentGameFirstPlayer == 0 {
                    currentMatch?.matchStatistics.currentGameFirstPlayer = 15
                } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 15 {
                    currentMatch?.matchStatistics.currentGameFirstPlayer = 30
                } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 30 {
                    currentMatch?.matchStatistics.currentGameFirstPlayer = 40
                } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 40 {
                    if currentMatch?.matchStatistics.currentGameSecondPlayer == 40 || currentMatch?.matchStatistics.currentGameSecondPlayer == 50 {
                        if currentMatch?.matchStatistics.currentGameSecondPlayer == 40 {
                            // Ad
                            currentMatch?.matchStatistics.currentGameFirstPlayer = 50
                        } else {
                            // Deuce
                            currentMatch?.matchStatistics.currentGameSecondPlayer = 40
                        }
                        
                    } else{
                        /*
                                Game finished Routine
                         */
                        
                        currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                        currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                        
                        currentMatch?.matchStatistics.currentGameInteger = 0
                    }
                } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 50 {
                    /*
                            Game finished Routine
                     */
                    
                    currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                    currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                    
                    currentMatch?.matchStatistics.currentGameInteger = 0
                }
                
                if currentMatch?.matchStatistics.currentGameFirstPlayer == 40 && currentMatch?.matchStatistics.currentGameSecondPlayer == 40 {
                    currentMatch?.matchStatistics.currentGame = "DEUCE"
                } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 50 && currentMatch?.matchStatistics.currentGameSecondPlayer == 40 {
                    currentMatch?.matchStatistics.currentGame = "Ad \(currentMatch!.firstTeamFirstPlayerSurname)"
                } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 40 && currentMatch?.matchStatistics.currentGameSecondPlayer == 50 {
                    currentMatch?.matchStatistics.currentGame = "Ad \(currentMatch!.secondTeamFirstPlayerSurname)"
                } else {
                    if currentMatch?.matchStatistics.isServer == "firstTeamFirst" {
                        currentMatch?.matchStatistics.currentGame = "\(currentMatch!.matchStatistics.currentGameFirstPlayer)/\(currentMatch!.matchStatistics.currentGameSecondPlayer)"
                    } else {
                        currentMatch?.matchStatistics.currentGame = "\(currentMatch!.matchStatistics.currentGameSecondPlayer)/\(currentMatch!.matchStatistics.currentGameFirstPlayer)"
                    }
                }
                
                scoreLabel.text = currentMatch?.matchStatistics.currentGame
            } else {
                if currentMatch?.matchStatistics.currentGameSecondPlayer == 0 {
                    currentMatch?.matchStatistics.currentGameSecondPlayer = 15
                } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 15 {
                    currentMatch?.matchStatistics.currentGameSecondPlayer = 30
                } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 30 {
                    currentMatch?.matchStatistics.currentGameSecondPlayer = 40
                } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 40 {
                    if currentMatch?.matchStatistics.currentGameFirstPlayer == 40 || currentMatch?.matchStatistics.currentGameFirstPlayer == 50 {
                        if currentMatch?.matchStatistics.currentGameFirstPlayer == 40 {
                            // Ad
                            currentMatch?.matchStatistics.currentGameSecondPlayer = 50
                        } else {
                            // Deuce
                            currentMatch?.matchStatistics.currentGameFirstPlayer = 40
                        }
                        
                    } else{
                        /*
                                Game finished Routine
                         */
                        
                        currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                        currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                        
                        currentMatch?.matchStatistics.currentGameInteger = 0
                    }
                } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 50 {
                    /*
                            Game finished Routine
                     */
                    
                    currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                    currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                    
                    currentMatch?.matchStatistics.currentGameInteger = 0
                }
                
                if currentMatch?.matchStatistics.currentGameFirstPlayer == 40 && currentMatch?.matchStatistics.currentGameSecondPlayer == 40 {
                    currentMatch?.matchStatistics.currentGame = "DEUCE"
                } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 50 && currentMatch?.matchStatistics.currentGameSecondPlayer == 40 {
                    currentMatch?.matchStatistics.currentGame = "Ad \(currentMatch!.firstTeamFirstPlayerSurname)"
                } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 40 && currentMatch?.matchStatistics.currentGameSecondPlayer == 50 {
                    currentMatch?.matchStatistics.currentGame = "Ad \(currentMatch!.secondTeamFirstPlayerSurname)"
                } else {
                    if currentMatch?.matchStatistics.isServer == "firstTeamFirst" {
                        currentMatch?.matchStatistics.currentGame = "\(currentMatch!.matchStatistics.currentGameFirstPlayer)/\(currentMatch!.matchStatistics.currentGameSecondPlayer)"
                    } else {
                        currentMatch?.matchStatistics.currentGame = "\(currentMatch!.matchStatistics.currentGameSecondPlayer)/\(currentMatch!.matchStatistics.currentGameFirstPlayer)"
                    }
                }
                
                scoreLabel.text = currentMatch?.matchStatistics.currentGame
            }
            
            if currentMatch?.matchStatistics.currentGameInteger == 0 {
                courtLeftFarLabel.isHidden = true
                courtLeftNearLabel.isHidden = false
                courtRightFarLabel.isHidden = false
                courtRightNearLabel.isHidden = true
            } else if currentMatch?.matchStatistics.currentGameInteger == 1 {
                courtLeftFarLabel.isHidden = false
                courtLeftNearLabel.isHidden = true
                courtRightFarLabel.isHidden = true
                courtRightNearLabel.isHidden = false
            } else {
                if currentMatch!.matchStatistics.currentGameInteger % 2 == 0 {
                    courtLeftFarLabel.isHidden = true
                    courtLeftNearLabel.isHidden = false
                    courtRightFarLabel.isHidden = false
                    courtRightNearLabel.isHidden = true
                } else {
                    courtLeftFarLabel.isHidden = false
                    courtLeftNearLabel.isHidden = true
                    courtRightFarLabel.isHidden = true
                    courtRightNearLabel.isHidden = false
                }
            }
        } else {
            // Doubles
        }
    }
    
    // MARK: - Functions
    func initLayout() {
        startOfPointButton.layer.cornerRadius = 10
        
        firstTeamPointButton.layer.cornerRadius = 10
        firstTeamPointButton.layer.maskedCorners = [.layerMinXMaxYCorner]
        
        secondTeamPointButton.layer.cornerRadius = 10
        secondTeamPointButton.layer.maskedCorners = [.layerMaxXMaxYCorner]
        
        aceButton.layer.cornerRadius = 10
        aceButton.layer.maskedCorners = [.layerMinXMinYCorner]
        
        faultButton.layer.cornerRadius = 10
        faultButton.layer.maskedCorners = [.layerMaxXMinYCorner]
        
        courtLeftFarLabel.layer.masksToBounds = true
        courtLeftFarLabel.layer.cornerRadius = 5
        courtLeftNearLabel.layer.masksToBounds = true
        courtLeftNearLabel.layer.cornerRadius = 5
        courtRightFarLabel.layer.masksToBounds = true
        courtRightFarLabel.layer.cornerRadius = 5
        courtRightNearLabel.layer.masksToBounds = true
        courtRightNearLabel.layer.cornerRadius = 5
        
    }
    
    func initMatch() {
        startOfPointButton.isHidden = false
        
        currentMatch?.matchStatistics.isServer = "firstTeamFirst"
        
        if currentMatch?.matchType.matchType == 0 {
            
            firstTeamLabel.text = "\(currentMatch!.firstTeamFirstPlayer), \(currentMatch!.firstTeamFirstPlayerSurname)"
            secondTeamLabel.text = "\(currentMatch!.secondTeamFirstPlayer), \(currentMatch!.secondTeamFirstPlayerSurname)"
            
            if (currentMatch!.matchStatistics.gamesFirstSetFirstPlayer == 0) && (currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == 0) {
                if (currentMatch!.matchStatistics.onLeftSide == "firstTeam") && (currentMatch!.matchStatistics.onRightSide == "secondTeam") {
                    
                    currentMatch?.matchStatistics.currentFirstPosition = "firstTeam"
                    currentMatch?.matchStatistics.currentSecondPosition = "secondTeam"
                    
                    currentMatch?.matchStatistics.currentLeftNear = "firstTeamFirst"
                    currentMatch?.matchStatistics.currentRightFar = "secondTeamFirst"
                    
                    courtLeftNearLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1))\(currentMatch!.firstTeamFirstPlayerSurname.prefix(1))"
                    courtLeftFarLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1))\(currentMatch!.firstTeamFirstPlayerSurname.prefix(1))"
                    
                    courtRightNearLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1))\(currentMatch!.secondTeamFirstPlayerSurname.prefix(1))"
                    courtRightFarLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1))\(currentMatch!.secondTeamFirstPlayerSurname.prefix(1))"
                    
                    firstTeamPointButton.setTitle("\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)", for: .normal)
                    secondTeamPointButton.setTitle("\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)", for: .normal)
                    
                    if currentMatch?.matchStatistics.isServer == "firstTeam" {
                        courtLeftNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftNearLabel.layer.borderWidth = 1
                        courtLeftFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftFarLabel.layer.borderWidth = 1
                    } else {
                        courtRightNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightNearLabel.layer.borderWidth = 1
                        courtRightFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightFarLabel.layer.borderWidth = 1
                    }
                } else {
                    
                    currentMatch?.matchStatistics.currentFirstPosition = "secondTeam"
                    currentMatch?.matchStatistics.currentSecondPosition = "firstTeam"
                    
                    currentMatch?.matchStatistics.currentLeftNear = "secondTeamFirst"
                    currentMatch?.matchStatistics.currentRightFar = "firstTeamFirst"
                    
                    courtRightNearLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1))\(currentMatch!.firstTeamFirstPlayerSurname.prefix(1))"
                    courtRightFarLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1))\(currentMatch!.firstTeamFirstPlayerSurname.prefix(1))"
                    
                    courtLeftNearLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1))\(currentMatch!.secondTeamFirstPlayerSurname.prefix(1))"
                    courtLeftFarLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1))\(currentMatch!.secondTeamFirstPlayerSurname.prefix(1))"
                    
                    firstTeamPointButton.setTitle("\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)", for: .normal)
                    secondTeamPointButton.setTitle("\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)", for: .normal)
                    
                    if currentMatch?.matchStatistics.isServer == "secondTeam" {
                        courtLeftNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftNearLabel.layer.borderWidth = 1
                        courtLeftFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftFarLabel.layer.borderWidth = 1
                    } else {
                        courtRightNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightNearLabel.layer.borderWidth = 1
                        courtRightFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightFarLabel.layer.borderWidth = 1
                    }
                }
            }
        }
    }
    
    func listenVolumeButton() {
        let volumeView = MPVolumeView(frame: CGRect.zero)
        volumeView.isHidden = true
        self.view.addSubview(volumeView)
        NotificationCenter.default.addObserver(self, selector: #selector(volumeChanged(_:)), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
    }
    
    @objc func volumeChanged(_ notification: NSNotification) {
        if (notification.userInfo!["AVSystemController_AudioVolumeNotificationParameter"] as? Float) != nil {
            if pointStarted == false {
                startOfPointButton.isHidden = true
                pointStarted = true
            }
            
            if currentMatch?.matchStatistics.matchRunning == false {
                interactMatchButton.backgroundColor = UIColor.systemRed
                interactMatchButton.setTitle("Stop Match", for: .normal)
                currentMatch?.matchStatistics.matchStartedTimeStamp = NSDate()
                currentMatch?.matchStatistics.matchRunning = true
            }
        }
    }

}
