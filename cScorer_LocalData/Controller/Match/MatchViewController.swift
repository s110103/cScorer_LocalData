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

class MatchViewController: UIViewController, StopMatchViewControllerDelegate, WarmupInfoViewControllerDelegate {
    
    // MARK: - Variables
    var currentMatch: Match?
    var selectedIndex: Int?
    
    var pointStarted: Bool = false
    var firstFault: Bool = false
    var timer: Timer?
    var interruptionTimer: Timer?
    
    var delegate: MatchViewControllerDelegate?
        
    var matchSuspensions: [String] =
    [
        "Rain",
        "Darkness",
        "Heat",
        "Switch Device",
        "Other"
    ]
    var matchInterruptions: [String] =
    [
        "Power Down",
        "Lights Out",
        "Other"
    ]
    
    // Court orange color: R151 G101 B56
    
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
    
    @IBOutlet weak var interruptedMatchView: UIView!
    @IBOutlet weak var interruptedMatchTimerLabel: UILabel!
    @IBOutlet weak var interruptedMatchContinueButton: UIButton!
    @IBOutlet weak var interruptedMatchReWarmupButton: UIButton!
    
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
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        //dismiss(animated: true, completion: nil)
    }
    
    @IBAction func interactMatchButtonTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        if interactMatchButton.title(for: .normal) == "Start Match" {
            
            if currentMatch?.matchStatistics.matchSuspended == true {
                interactMatchButton.backgroundColor = UIColor.systemRed
                interactMatchButton.setTitle("Stop Match", for: .normal)
                currentMatch?.matchStatistics.matchRestartTimeStamp = NSDate()
                currentMatch?.matchStatistics.matchRunning = true
                currentMatch?.matchStatistics.matchSuspended = false
                currentMatch?.matchStatistics.matchSuspensionReason = ""
                
                timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(startMatchTimer), userInfo: nil, repeats: true)
            } else if currentMatch?.matchStatistics.matchInterrupted == true {
                interactMatchButton.backgroundColor = UIColor.systemRed
                interactMatchButton.setTitle("Stop Match", for: .normal)
                currentMatch?.matchStatistics.matchRestartTimeStamp = NSDate()
                currentMatch?.matchStatistics.matchRunning = true
                currentMatch?.matchStatistics.matchInterrupted = false
                currentMatch?.matchStatistics.matchInterruptionReason = ""
                currentMatch?.matchStatistics.matchInterruptedTimeInterval = TimeInterval()
                interruptedMatchView.isHidden = true
                interruptionTimer?.invalidate()
                
                timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(startMatchTimer), userInfo: nil, repeats: true)
            } else {
                interactMatchButton.backgroundColor = UIColor.systemRed
                interactMatchButton.setTitle("Stop Match", for: .normal)
                currentMatch?.matchStatistics.matchStartedTimeStamp = NSDate()
                currentMatch?.matchStatistics.matchRestartTimeStamp = NSDate()
                currentMatch?.matchStatistics.matchRunning = true
                
                timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(startMatchTimer), userInfo: nil, repeats: true)
            }
        } else if interactMatchButton.title(for: .normal) == "Stop Match" {
            performSegue(withIdentifier: "showStopMatchSegue", sender: self)
        }
    }
    
    @IBAction func courtButtonTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        performSegue(withIdentifier: "showWarmupInfoFromMatchSegue", sender: self)
    }
    
    @IBAction func startOfPointButtonTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        startOfPointButton.isHidden = true
        pointStarted = true
        
        if currentMatch?.matchStatistics.matchRunning == false {
            if currentMatch?.matchStatistics.matchSuspended == true {
                interactMatchButton.backgroundColor = UIColor.systemRed
                interactMatchButton.setTitle("Stop Match", for: .normal)
                currentMatch?.matchStatistics.matchRestartTimeStamp = NSDate()
                currentMatch?.matchStatistics.matchRunning = true
                currentMatch?.matchStatistics.matchSuspended = false
                currentMatch?.matchStatistics.matchSuspensionReason = ""
                
                timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(startMatchTimer), userInfo: nil, repeats: true)
            } else if currentMatch?.matchStatistics.matchInterrupted == true {
                interactMatchButton.backgroundColor = UIColor.systemRed
                interactMatchButton.setTitle("Stop Match", for: .normal)
                currentMatch?.matchStatistics.matchRestartTimeStamp = NSDate()
                currentMatch?.matchStatistics.matchRunning = true
                currentMatch?.matchStatistics.matchInterrupted = false
                currentMatch?.matchStatistics.matchInterruptionReason = ""
                
                timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(startMatchTimer), userInfo: nil, repeats: true)
            } else {
                interactMatchButton.backgroundColor = UIColor.systemRed
                interactMatchButton.setTitle("Stop Match", for: .normal)
                currentMatch?.matchStatistics.matchStartedTimeStamp = NSDate()
                currentMatch?.matchStatistics.matchRestartTimeStamp = NSDate()
                currentMatch?.matchStatistics.matchRunning = true
                
                timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(startMatchTimer), userInfo: nil, repeats: true)
            }
        }
    }
    
    @IBAction func aceButtonTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
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
                        
                        updateGames(teamWon: "firstTeam")
                    }
                } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 50 {
                    /*
                            Game finished Routine
                     */
                    
                    currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                    currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                    
                    currentMatch?.matchStatistics.currentGameInteger = 0
                    
                    updateGames(teamWon: "firstTeam")
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
                        
                        updateGames(teamWon: "secondTeam")
                    }
                } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 50 {
                    /*
                            Game finished Routine
                     */
                    
                    currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                    currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                    
                    currentMatch?.matchStatistics.currentGameInteger = 0
                    
                    updateGames(teamWon: "secondTeam")
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
    
    @IBAction func netButtonTaped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    @IBAction func faultButtonTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        pointStarted = false
        startOfPointButton.isHidden = false
        
        if firstFault == false {
            firstFault = true
        } else {
            firstFault = false
            
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
                            
                            updateGames(teamWon: "firstTeam")
                        }
                    } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 50 {
                        /*
                                Game finished Routine
                         */
                        
                        currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                        currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                        
                        currentMatch?.matchStatistics.currentGameInteger = 0
                        
                        updateGames(teamWon: "firstTeam")
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
                            
                            updateGames(teamWon: "secondTeam")
                        }
                    } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 50 {
                        /*
                                Game finished Routine
                         */
                        
                        currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                        currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                        
                        currentMatch?.matchStatistics.currentGameInteger = 0
                        
                        updateGames(teamWon: "secondTeam")
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
    }
    
    @IBAction func overruleButtonTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        currentMatch?.matchStatistics.totalOverrules+=1
    }
    
    @IBAction func undoButtonTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    @IBAction func footfaultButtonTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        pointStarted = false
        startOfPointButton.isHidden = false
        
        if firstFault == false {
            firstFault = true
        } else {
            firstFault = false
            
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
                            
                            updateGames(teamWon: "firstTeam")
                        }
                    } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 50 {
                        /*
                                Game finished Routine
                         */
                        
                        currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                        currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                        
                        currentMatch?.matchStatistics.currentGameInteger = 0
                        
                        updateGames(teamWon: "firstTeam")
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
                            
                            updateGames(teamWon: "secondTeam")
                        }
                    } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 50 {
                        /*
                                Game finished Routine
                         */
                        
                        currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                        currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                        
                        currentMatch?.matchStatistics.currentGameInteger = 0
                        
                        updateGames(teamWon: "secondTeam")
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
    }
    
    @IBAction func firstTeamPointButtonTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
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
                        
                        updateGames(teamWon: "firstTeam")
                    }
                } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 50 {
                    /*
                            Game finished Routine
                     */
                    
                    currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                    currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                    
                    currentMatch?.matchStatistics.currentGameInteger = 0
                    
                    updateGames(teamWon: "firstTeam")
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
                        
                        updateGames(teamWon: "secondTeam")
                    }
                } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 50 {
                    /*
                            Game finished Routine
                     */
                    
                    currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                    currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                    
                    currentMatch?.matchStatistics.currentGameInteger = 0
                    
                    updateGames(teamWon: "secondTeam")
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
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
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
                        
                        updateGames(teamWon: "firstTeam")
                    }
                } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 50 {
                    /*
                            Game finished Routine
                     */
                    
                    currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                    currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                    
                    currentMatch?.matchStatistics.currentGameInteger = 0
                    
                    updateGames(teamWon: "firstTeam")
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
                        
                        updateGames(teamWon: "secondTeam")
                    }
                } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 50 {
                    /*
                            Game finished Routine
                     */
                    
                    currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                    currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                    
                    currentMatch?.matchStatistics.currentGameInteger = 0
                    
                    updateGames(teamWon: "secondTeam")
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
    
    @IBAction func interruptedMatchContinueButtonTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        interruptionTimer?.invalidate()
        interruptedMatchView.isHidden = true
        currentMatch?.matchStatistics.matchInterruptedTimeInterval = TimeInterval()
        
        interactMatchButton.setTitle("Stop Match", for: .normal)
        interactMatchButton.backgroundColor = UIColor.systemRed
        currentMatch?.matchStatistics.matchRunning = true
        currentMatch?.matchStatistics.matchInterrupted = false
    }
    
    @IBAction func interruptedMatchReWarmupButtonTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    // MARK: - Functions
    func initLayout() {
        startOfPointButton.layer.cornerRadius = 10
        
        interruptedMatchView.layer.masksToBounds = true
        interruptedMatchView.layer.cornerRadius = 10
        
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
        
        updateSetView()
        
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
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
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
    
    func updateGames(teamWon: String) {
        if currentMatch?.matchStatistics.currentSetPlayed == 1 {
            if teamWon == "firstTeam" {
                currentMatch?.matchStatistics.gamesFirstSetFirstPlayer += 1
                
                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer == 6 && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer <= 4 {
                    currentMatch?.matchStatistics.currentSetPlayed = 2
                } else if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer == 7 && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == 5 {
                    currentMatch?.matchStatistics.currentSetPlayed = 2
                } else if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer == 6 && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == 6 {
                    /*
                        Tiebreak
                     */
                }
            } else {
                currentMatch?.matchStatistics.gamesFirstSetSecondPlayer += 1
                
                if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == 6 && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer <= 4 {
                    currentMatch?.matchStatistics.currentSetPlayed = 2
                } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == 7 && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer == 5 {
                    currentMatch?.matchStatistics.currentSetPlayed = 2
                } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == 6 && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer == 6 {
                    /*
                        Tiebreak
                     */
                }
            }
        } else if currentMatch?.matchStatistics.currentSetPlayed == 2 {
            if teamWon == "firstTeam" {
                currentMatch?.matchStatistics.gamesSecondSetFirstPlayer += 1
                
                if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer == 6 && currentMatch!.matchStatistics.gamesSecondSetSecondPlayer <= 4 {
                    currentMatch?.matchStatistics.currentSetPlayed = 3
                    
                    if currentMatch?.matchType.totalSets == 3 {
                        if (currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) && (currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) {
                            /*
                                Game Set Match first Team
                             */
                        }
                    }
                } else if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer == 7 && currentMatch!.matchStatistics.gamesSecondSetSecondPlayer == 5 {
                    currentMatch?.matchStatistics.currentSetPlayed = 3
                    
                    if currentMatch?.matchType.totalSets == 3 {
                        if (currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) && (currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) {
                            /*
                                Game Set Match first Team
                             */
                        }
                    }
                    
                } else if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer == 6 && currentMatch!.matchStatistics.gamesSecondSetSecondPlayer == 6 {
                    /*
                        Tiebreak
                     */
                }
            } else {
                currentMatch?.matchStatistics.gamesSecondSetSecondPlayer += 1
                
                if currentMatch!.matchStatistics.gamesSecondSetSecondPlayer == 6 && currentMatch!.matchStatistics.gamesSecondSetFirstPlayer <= 4 {
                    currentMatch?.matchStatistics.currentSetPlayed = 3
                    
                    if currentMatch?.matchType.totalSets == 3 {
                        if (currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) && (currentMatch!.matchStatistics.gamesSecondSetSecondPlayer > currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) {
                            /*
                                Game Set Match second Team
                             */
                        }
                    }
                } else if currentMatch!.matchStatistics.gamesSecondSetSecondPlayer == 7 && currentMatch!.matchStatistics.gamesSecondSetFirstPlayer == 5 {
                    currentMatch?.matchStatistics.currentSetPlayed = 3
                    
                    if currentMatch?.matchType.totalSets == 3 {
                        if (currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) && (currentMatch!.matchStatistics.gamesSecondSetSecondPlayer > currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) {
                            /*
                                Game Set Match second Team
                             */
                        }
                    }
                } else if currentMatch!.matchStatistics.gamesSecondSetSecondPlayer == 6 && currentMatch!.matchStatistics.gamesSecondSetFirstPlayer == 6 {
                    /*
                        Tiebreak
                     */
                }
            }
        } else if currentMatch?.matchStatistics.currentSetPlayed == 3 {
            if teamWon == "firstTeam" {
                currentMatch?.matchStatistics.gamesThirdSetFirstPlayer += 1
                
                if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer == 6 && currentMatch!.matchStatistics.gamesThirdSetSecondPlayer <= 4 {
                    currentMatch?.matchStatistics.currentSetPlayed = 2
                    
                    if currentMatch?.matchType.totalSets == 3 {
                        if (currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) && (currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) {
                            /*
                                Game Set Match first Team
                             */
                        }
                    }
                } else if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer == 7 && currentMatch!.matchStatistics.gamesThirdSetSecondPlayer == 5 {
                    currentMatch?.matchStatistics.currentSetPlayed = 2
                    
                    if currentMatch?.matchType.totalSets == 3 {
                        if (currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) && (currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) {
                            /*
                                Game Set Match first Team
                             */
                        }
                    }
                    
                } else if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer == 6 && currentMatch!.matchStatistics.gamesThirdSetSecondPlayer == 6 {
                    /*
                        Tiebreak
                     */
                }
            } else {
                currentMatch?.matchStatistics.gamesThirdSetSecondPlayer += 1
                
                if currentMatch!.matchStatistics.gamesThirdSetSecondPlayer == 6 && currentMatch!.matchStatistics.gamesThirdSetFirstPlayer <= 4 {
                    currentMatch?.matchStatistics.currentSetPlayed = 2
                    
                    if currentMatch?.matchType.totalSets == 3 {
                        if (currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) && (currentMatch!.matchStatistics.gamesSecondSetSecondPlayer > currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) {
                            /*
                                Game Set Match second Team
                             */
                        }
                    }
                } else if currentMatch!.matchStatistics.gamesThirdSetSecondPlayer == 7 && currentMatch!.matchStatistics.gamesThirdSetFirstPlayer == 5 {
                    currentMatch?.matchStatistics.currentSetPlayed = 2
                    
                    if currentMatch?.matchType.totalSets == 3 {
                        if (currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) && (currentMatch!.matchStatistics.gamesSecondSetSecondPlayer > currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) {
                            /*
                                Game Set Match second Team
                             */
                        }
                    }
                } else if currentMatch!.matchStatistics.gamesThirdSetSecondPlayer == 6 && currentMatch!.matchStatistics.gamesThirdSetFirstPlayer == 6 {
                    /*
                        Tiebreak
                     */
                }
            }
        }
        updateSetView()
    }
    
    func updateSetView() {
        if currentMatch?.matchStatistics.currentSetPlayed == 1 {
            firstTeamFifthScoreLabel.text = "\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)"
            secondTeamFifthScoreLabel.text = "\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)"
        } else if currentMatch?.matchStatistics.currentSetPlayed == 2 {
            firstTeamFifthScoreLabel.text = "\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)"
            secondTeamFifthScoreLabel.text = "\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)"
            
            firstTeamFourthScoreLabel.text = "\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)"
            secondTeamFourthScoreLabel.text = "\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)"
        } else if currentMatch?.matchStatistics.currentSetPlayed == 3 {
            firstTeamFifthScoreLabel.text = "\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)"
            secondTeamFifthScoreLabel.text = "\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)"
            
            firstTeamFourthScoreLabel.text = "\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)"
            secondTeamFourthScoreLabel.text = "\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)"
            
            firstTeamThirdScoreLabel.text = "\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)"
            secondTeamThirdScoreLabel.text = "\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)"
        } else if currentMatch?.matchStatistics.currentSetPlayed == 4 {
            firstTeamFifthScoreLabel.text = "\(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)"
            secondTeamFifthScoreLabel.text = "\(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)"
            
            firstTeamFourthScoreLabel.text = "\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)"
            secondTeamFourthScoreLabel.text = "\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)"
            
            firstTeamThirdScoreLabel.text = "\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)"
            secondTeamThirdScoreLabel.text = "\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)"
            
            firstTeamSecondScoreLabel.text = "\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)"
            secondTeamSecondScoreLabel.text = "\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)"
        } else if currentMatch?.matchStatistics.currentSetPlayed == 5 {
            firstTeamFifthScoreLabel.text = "\(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer)"
            secondTeamFifthScoreLabel.text = "\(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer)"
            
            firstTeamFourthScoreLabel.text = "\(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)"
            secondTeamFourthScoreLabel.text = "\(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)"
            
            firstTeamThirdScoreLabel.text = "\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)"
            secondTeamThirdScoreLabel.text = "\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)"
            
            firstTeamSecondScoreLabel.text = "\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)"
            secondTeamSecondScoreLabel.text = "\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)"
            
            firstTeamFifthScoreLabel.text = "\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)"
            secondTeamFifthScoreLabel.text = "\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)"
        }
    }
    
    @objc func startMatchTimer() {
        let now = NSDate()
        var remainingTimeInterval: TimeInterval = now.timeIntervalSince(currentMatch!.matchStatistics.matchRestartTimeStamp as Date)
        remainingTimeInterval = remainingTimeInterval + currentMatch!.matchStatistics.matchTimeInterval
                
        matchTimeLabel.text = "\(remainingTimeInterval.format(using: [.hour, .minute])!)"
    }
    
    @objc func startInterruptionTimer() {
        let now = NSDate()
        var remainingTimeInterval: TimeInterval = now.timeIntervalSince(currentMatch!.matchStatistics.matchInterruptedTimeStamp as Date)
        remainingTimeInterval = remainingTimeInterval + currentMatch!.matchStatistics.matchInterruptedTimeInterval
                
        interruptedMatchTimerLabel.text = "\(remainingTimeInterval.format(using: [.minute, .second])!)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "showStopMatchSegue":
            let destinationVC = segue.destination as! StopMatchViewController
            
            destinationVC.delegate = self
        case "showWarmupInfoFromMatchSegue":
            let destinationVC = segue.destination as! WarmupInfoViewController
            
            destinationVC.currentMatch = currentMatch
            
            destinationVC.delegate = self
        default:
            break
        }
    }
    
    func interruptMatch(interruption: Int) {
        timer?.invalidate()
        
        interactMatchButton.setTitle("Start Match", for: .normal)
        interactMatchButton.backgroundColor = UIColor.systemTeal
        
        currentMatch?.matchStatistics.matchInterrupted = true
        currentMatch?.matchStatistics.matchInterruptionReason = matchInterruptions[interruption]
        currentMatch?.matchStatistics.matchRunning = false
        currentMatch?.matchStatistics.matchFinishedTimeStamp = NSDate()
        
        let now = NSDate()
        var remainingTimeInterval: TimeInterval = now.timeIntervalSince(currentMatch!.matchStatistics.matchRestartTimeStamp as Date)
        remainingTimeInterval = remainingTimeInterval + currentMatch!.matchStatistics.matchTimeInterval
        
        currentMatch?.matchStatistics.matchTimeInterval = remainingTimeInterval
        
        currentMatch?.matchStatistics.matchInterruptedTimeStamp = NSDate()
        interruptionTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(startInterruptionTimer), userInfo: nil, repeats: true)
        
        interruptedMatchView.isHidden = false
        
        pointStarted = false
        startOfPointButton.isHidden = false
    }
    
    func suspendMatch(suspension: Int) {
        timer?.invalidate()
        
        interactMatchButton.setTitle("Start Match", for: .normal)
        interactMatchButton.backgroundColor = UIColor.systemTeal
        
        currentMatch?.matchStatistics.matchSuspended = true
        currentMatch?.matchStatistics.matchSuspensionReason = matchSuspensions[suspension]
        currentMatch?.matchStatistics.matchRunning = false
        currentMatch?.matchStatistics.matchFinishedTimeStamp = NSDate()
        
        let now = NSDate()
        var remainingTimeInterval: TimeInterval = now.timeIntervalSince(currentMatch!.matchStatistics.matchRestartTimeStamp as Date)
        remainingTimeInterval = remainingTimeInterval + currentMatch!.matchStatistics.matchTimeInterval
        
        currentMatch?.matchStatistics.matchTimeInterval = remainingTimeInterval
        
        delegate?.sendMatch(currentMatch: currentMatch!, selectedIndex: selectedIndex!)
        navigationController?.popViewController(animated: true)
    }
    
    func dismissWarmupInfo() {
        
    }

}
