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

class MatchViewController: UIViewController, StopMatchViewControllerDelegate, WarmupInfoViewControllerDelegate, PlayerInteractionViewControllerDelegate, SelectPlayerViewControllerDelegate, SelectCodeViolationViewControllerDelegate, ClarifyCodeViolationViewControllerDelegate, ValidateCodeViolationViewControllerDelegate, ClarifyTimeViolationViewControllerDelegate, ValidateTimeViolationViewControllerDelegate {
    
    // MARK: - Variables
    var currentMatch: Match?
    var selectedIndex: Int?
    
    var pointStarted: Bool = false
    var firstFault: Bool = false
    var timer: Timer?
    var interruptionTimer: Timer?
    var readbackVisible: Bool = false
    var removeReadbackTask: DispatchWorkItem?
    var gameFinished: Bool = false
    var gameSetMatchIndication: Bool = false
    var setJustFinished: Bool = false
    var currentlyInChangeOfEnds: Bool = false
    var currentlyInSetbreak: Bool = false
    var justHadChangeOfEnds: Bool = false
    var noChangeOfEndsBreak: Bool = false
    var touchedObject: UIView?
    var selectedTeam: String = ""
    var selectedPlayer: String = ""
    var selectedViolation: Int = 0
    var selectedPenalty: Int = 0
    
    // Timer
    var shotclockTimerTime: Int = 25
    var shotclockTimerRunning: Bool = false
    var shotclockTimerInterrupted: Bool = false
    var shotclockTimer: Timer? = nil
    
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
    @IBOutlet weak var timerView: UIView!
    
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
    
    @IBOutlet weak var firstTeamScoreView: UIView!
    @IBOutlet weak var secondTeamScoreView: UIView!
    
    @IBOutlet weak var firstTeamLabel: UILabel!
    @IBOutlet weak var secondTeamLabel: UILabel!
    
    @IBOutlet weak var courtLeftFarLabel: UILabel!
    @IBOutlet weak var courtLeftNearLabel: UILabel!
    @IBOutlet weak var courtRightFarLabel: UILabel!
    @IBOutlet weak var courtRightNearLabel: UILabel!
    
    @IBOutlet weak var ballchangeIndicatorLabel: UILabel!
    
    @IBOutlet weak var firstTeamServerIndicatorView: UIView!
    @IBOutlet weak var secondTeamServerIndicatorView: UIView!
    
    @IBOutlet weak var readbackView: UIView!
    @IBOutlet weak var readbackLabel: UILabel!
    
    @IBOutlet weak var letButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var footfaultButton: UIButton!
    @IBOutlet weak var overruleButton: UIButton!
    @IBOutlet weak var faultButton: UIButton!
    @IBOutlet weak var netButton: UIButton!
    @IBOutlet weak var aceButton: UIButton!
    @IBOutlet weak var firstTeamPointButton: UIButton!
    @IBOutlet weak var secondTeamPointButton: UIButton!
    @IBOutlet weak var startOfPointButton: UIButton!
    @IBOutlet weak var firstTeamViolationView: UIView!
    @IBOutlet weak var firstTeamCVIndicator: UILabel!
    @IBOutlet weak var firstTeamTVIndicator: UILabel!
    @IBOutlet weak var firstTeamNameIndicator: UILabel!
    @IBOutlet weak var firstTeamUpperCVIndicator: UILabel!
    @IBOutlet weak var firstTeamUpperTVIndicator: UILabel!
    @IBOutlet weak var firstTeamUpperNameIndicator: UILabel!
    @IBOutlet weak var secondTeamViolationView: UIView!
    @IBOutlet weak var secondTeamCVIndicator: UILabel!
    @IBOutlet weak var secondTeamTVIndicator: UILabel!
    @IBOutlet weak var secondTeamNameIndicator: UILabel!
    @IBOutlet weak var secondTeamUpperCVIndicator: UILabel!
    @IBOutlet weak var secondTeamUpperTVIndicator: UILabel!
    @IBOutlet weak var secondTeamUpperNameIndicator: UILabel!
    
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
            
            triggerReadback(caller: "132", message: "MATCH STARTED", fontSize: 45)
            
            if currentMatch?.matchStatistics.matchSuspended == true {
                interactMatchButton.backgroundColor = UIColor.systemRed
                interactMatchButton.setTitle("Stop Match", for: .normal)
                currentMatch?.matchStatistics.matchRestartTimeStamp = NSDate()
                currentMatch?.matchStatistics.matchRunning = true
                currentMatch?.matchStatistics.matchSuspended = false
                currentMatch?.matchStatistics.matchSuspensionReason = ""
                
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startMatchTimer), userInfo: nil, repeats: true)
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
                
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startMatchTimer), userInfo: nil, repeats: true)
            } else {
                interactMatchButton.backgroundColor = UIColor.systemRed
                interactMatchButton.setTitle("Stop Match", for: .normal)
                currentMatch?.matchStatistics.matchStartedTimeStamp = NSDate()
                currentMatch?.matchStatistics.matchRestartTimeStamp = NSDate()
                currentMatch?.matchStatistics.matchRunning = true
                
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startMatchTimer), userInfo: nil, repeats: true)
            }
        } else if interactMatchButton.title(for: .normal) == "Stop Match" {
            shotclockTimer?.invalidate()
            resetShotClock(withTime: 25)
            timer?.invalidate()
            resetChangeOfEndsShotClockData()
            let now = NSDate()
            var remainingTimeInterval: TimeInterval = now.timeIntervalSince(currentMatch!.matchStatistics.matchRestartTimeStamp as Date)
            remainingTimeInterval = remainingTimeInterval + currentMatch!.matchStatistics.matchTimeInterval
            
            currentMatch?.matchStatistics.matchTimeInterval = remainingTimeInterval
            
            performSegue(withIdentifier: "showStopMatchSegue", sender: self)
        } else if interactMatchButton.title(for: .normal) == "Exit" {
            delegate?.sendMatch(currentMatch: currentMatch!, selectedIndex: selectedIndex!)
            navigationController?.popViewController(animated: true)
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
        
        removeCurrentReadback()
        
        shotclockTimer?.invalidate()
        resetChangeOfEndsShotClockData()
        resetShotClock(withTime: 25)
                
        if currentMatch?.matchStatistics.matchRunning == false {
            if currentMatch?.matchStatistics.matchSuspended == true {
                interactMatchButton.backgroundColor = UIColor.systemRed
                interactMatchButton.setTitle("Stop Match", for: .normal)
                currentMatch?.matchStatistics.matchRestartTimeStamp = NSDate()
                currentMatch?.matchStatistics.matchRunning = true
                currentMatch?.matchStatistics.matchSuspended = false
                currentMatch?.matchStatistics.matchSuspensionReason = ""
                
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startMatchTimer), userInfo: nil, repeats: true)
            } else if currentMatch?.matchStatistics.matchInterrupted == true {
                interactMatchButton.backgroundColor = UIColor.systemRed
                interactMatchButton.setTitle("Stop Match", for: .normal)
                currentMatch?.matchStatistics.matchRestartTimeStamp = NSDate()
                currentMatch?.matchStatistics.matchRunning = true
                currentMatch?.matchStatistics.matchInterrupted = false
                currentMatch?.matchStatistics.matchInterruptionReason = ""
                
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startMatchTimer), userInfo: nil, repeats: true)
            } else {
                interactMatchButton.backgroundColor = UIColor.systemRed
                interactMatchButton.setTitle("Stop Match", for: .normal)
                currentMatch?.matchStatistics.matchStartedTimeStamp = NSDate()
                currentMatch?.matchStatistics.matchRestartTimeStamp = NSDate()
                currentMatch?.matchStatistics.matchRunning = true
                
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startMatchTimer), userInfo: nil, repeats: true)
            }
        }
    }
    
    @IBAction func aceButtonTapped(_ sender: UIButton) {
        if currentMatch?.matchStatistics.matchRunning == true {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
            pointStarted = false
            startOfPointButton.isHidden = false
            
            resetFaults()
            triggerReadback(caller: "242", message: "ACE", fontSize: 60)
            
            shotclockTimer?.invalidate()
            resetChangeOfEndsShotClockData()
            resetShotClock(withTime: 25)
            
            if currentMatch?.matchStatistics.isServer == "firstTeamFirst" || currentMatch?.matchStatistics.isServer == "firstTeamSecond" {
                endOfPoint(team: 0)
            } else {
                endOfPoint(team: 1)
            }
            
            var currentSet: Int = currentMatch!.matchStatistics.currentSetPlayed
            
            if setJustFinished == true {
                setJustFinished = false
                currentSet -= 1
            }
            
            if gameFinished == true && gameSetMatchIndication == false {
                switch currentSet {
                case 1:
                    if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                        triggerReadback(caller: "414", message: "ACE\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(caller: "416", message: "ACE\n\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)", fontSize: 100)
                    }
                case 2:
                    if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                        triggerReadback(caller: "420", message: "ACE\n\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(caller: "422", message: "ACE\n\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)", fontSize: 100)
                    }
                case 3:
                    if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                        triggerReadback(caller: "426", message: "ACE\n\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(caller: "428", message: "ACE\n\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)", fontSize: 100)
                    }
                case 4:
                    if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                        triggerReadback(caller: "432", message: "ACE\n\(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(caller: "434", message: "ACE\n\(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)", fontSize: 100)
                    }
                case 5:
                    if currentMatch!.matchStatistics.gamesFifthSetFirstPlayer > currentMatch!.matchStatistics.gamesFifthSetSecondPlayer {
                        triggerReadback(caller: "438", message: "ACE\n\(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(caller: "440", message: "ACE\n\(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer)", fontSize: 100)
                    }
                default:
                    break
                }
                gameFinished = false
            } else {
                triggerReadback(caller: "297", message: "ACE\n\(scoreLabel.text!)", fontSize: 100)
            }
        }
    }
    
    @IBAction func netButtonTaped(_ sender: UIButton) {
        if currentMatch?.matchStatistics.matchRunning == true {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
            pointStarted = false
            startOfPointButton.isHidden = false
            
            shotclockTimer?.invalidate()
            resetChangeOfEndsShotClockData()
            resetShotClock(withTime: 25)
        
            if firstFault == false {
                triggerReadback(caller: "273", message: "NET - FIRST SERVE", fontSize: 45)
            } else {
                triggerReadback(caller: "275", message: "NET - SECOND SERVE", fontSize: 45)
            }
        }
    }
    
    @IBAction func faultButtonTapped(_ sender: UIButton) {
        if currentMatch?.matchStatistics.matchRunning == true {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
            pointStarted = false
            startOfPointButton.isHidden = false
            
            shotclockTimer?.invalidate()
            resetChangeOfEndsShotClockData()
            resetShotClock(withTime: 25)
            
            var savedFault: Bool = false
            
            if firstFault == true {
                savedFault = true
            }
            
            if currentMatch?.matchStatistics.isServer == "firstTeamFirst" || currentMatch?.matchStatistics.isServer == "firstTeamSecond" {
                addFault(team: 0)
            } else {
                addFault(team: 1)
            }
            
            if savedFault == false {
                triggerReadback(caller: "309", message: "FAULT", fontSize: 60)
            } else {
                
                var currentSet: Int = currentMatch!.matchStatistics.currentSetPlayed
                
                if setJustFinished == true {
                    setJustFinished = false
                    currentSet -= 1
                }
                
                if gameFinished == true && gameSetMatchIndication == false {
                    switch currentSet {
                    case 1:
                        if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                            triggerReadback(caller: "414", message: "FAULT\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)", fontSize: 100)
                        } else {
                            triggerReadback(caller: "416", message: "FAULT\n\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)", fontSize: 100)
                        }
                    case 2:
                        if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                            triggerReadback(caller: "420", message: "FAULT\n\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)", fontSize: 100)
                        } else {
                            triggerReadback(caller: "422", message: "FAULT\n\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)", fontSize: 100)
                        }
                    case 3:
                        if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                            triggerReadback(caller: "426", message: "FAULT\n\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)", fontSize: 100)
                        } else {
                            triggerReadback(caller: "428", message: "FAULT\n\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)", fontSize: 100)
                        }
                    case 4:
                        if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                            triggerReadback(caller: "432", message: "FAULT\n\(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)", fontSize: 100)
                        } else {
                            triggerReadback(caller: "434", message: "FAULT\n\(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)", fontSize: 100)
                        }
                    case 5:
                        if currentMatch!.matchStatistics.gamesFifthSetFirstPlayer > currentMatch!.matchStatistics.gamesFifthSetSecondPlayer {
                            triggerReadback(caller: "438", message: "FAULT\n\(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer)", fontSize: 100)
                        } else {
                            triggerReadback(caller: "440", message: "FAULT\n\(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer)", fontSize: 100)
                        }
                    default:
                        break
                    }
                    gameFinished = false
                } else {
                    triggerReadback(caller: "392", message: "FAULT\n\(scoreLabel.text!)", fontSize: 100)
                }
            }
            
            savedFault = false
        }
    }
    
    @IBAction func overruleButtonTapped(_ sender: UIButton) {
        if currentMatch?.matchStatistics.matchRunning == true {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
            currentMatch?.matchStatistics.totalOverrules+=1
            
            triggerReadback(caller: "323", message: "OVERRULE", fontSize: 60)
        }
    }
    
    @IBAction func undoButtonTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    @IBAction func letButtonTapped(_ sender: UIButton) {
        if currentMatch?.matchStatistics.matchRunning == true {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
            pointStarted = false
            startOfPointButton.isHidden = false
            
            resetFaults()
            
            shotclockTimer?.invalidate()
            resetChangeOfEndsShotClockData()
            resetShotClock(withTime: 25)
            
            triggerReadback(caller: "348", message: "LET - REPLAY THE POINT", fontSize: 45)
        }
    }
    
    @IBAction func footfaultButtonTapped(_ sender: UIButton) {
        if currentMatch?.matchStatistics.matchRunning == true {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
            pointStarted = false
            startOfPointButton.isHidden = false
            
            shotclockTimer?.invalidate()
            resetChangeOfEndsShotClockData()
            resetShotClock(withTime: 25)
            
            var savedFault: Bool = false
            
            if firstFault == true {
                savedFault = true
            }
            
            if currentMatch?.matchStatistics.isServer == "firstTeamFirst" || currentMatch?.matchStatistics.isServer == "firstTeamSecond" {
                addFault(team: 0)
            } else {
                addFault(team: 1)
            }
            
            if savedFault == false {
                triggerReadback(caller: "309", message: "FOOTFAULT", fontSize: 60)
            } else {
                
                var currentSet: Int = currentMatch!.matchStatistics.currentSetPlayed
                
                if setJustFinished == true {
                    setJustFinished = false
                    currentSet -= 1
                }
                
                if gameFinished == true && gameSetMatchIndication == false {
                    switch currentSet {
                    case 1:
                        if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                            triggerReadback(caller: "414", message: "FOOTFAULT\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)", fontSize: 100)
                        } else {
                            triggerReadback(caller: "416", message: "FOOTFAULT\n\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)", fontSize: 100)
                        }
                    case 2:
                        if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                            triggerReadback(caller: "420", message: "FOOTFAULT\n\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)", fontSize: 100)
                        } else {
                            triggerReadback(caller: "422", message: "FOOTFAULT\n\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)", fontSize: 100)
                        }
                    case 3:
                        if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                            triggerReadback(caller: "426", message: "FOOTFAULT\n\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)", fontSize: 100)
                        } else {
                            triggerReadback(caller: "428", message: "FOOTFAULT\n\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)", fontSize: 100)
                        }
                    case 4:
                        if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                            triggerReadback(caller: "432", message: "FOOTFAULT\n\(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)", fontSize: 100)
                        } else {
                            triggerReadback(caller: "434", message: "FOOTFAULT\n\(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)", fontSize: 100)
                        }
                    case 5:
                        if currentMatch!.matchStatistics.gamesFifthSetFirstPlayer > currentMatch!.matchStatistics.gamesFifthSetSecondPlayer {
                            triggerReadback(caller: "438", message: "FOOTFAULT\n\(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer)", fontSize: 100)
                        } else {
                            triggerReadback(caller: "440", message: "FOOTFAULT\n\(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer)", fontSize: 100)
                        }
                    default:
                        break
                    }
                    gameFinished = false
                } else {
                    triggerReadback(caller: "392", message: "FOOTFAULT\n\(scoreLabel.text!)", fontSize: 100)
                }
            }
            savedFault = false
        }
    }
    
    @IBAction func firstTeamPointButtonTapped(_ sender: UIButton) {
        if currentMatch?.matchStatistics.matchRunning == true {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
            pointStarted = false
            startOfPointButton.isHidden = false
            
            resetFaults()
            
            shotclockTimer?.invalidate()
            resetChangeOfEndsShotClockData()
            resetShotClock(withTime: 25)

            if currentMatch?.matchStatistics.onLeftSide == "firstTeam" {
                endOfPoint(team: 0)
            } else {
                endOfPoint(team: 1)
            }
            
            var currentSet: Int = currentMatch!.matchStatistics.currentSetPlayed
            
            if setJustFinished == true {
                setJustFinished = false
                currentSet -= 1
            }
            
            if gameFinished == true && gameSetMatchIndication == false {
                switch currentSet {
                case 1:
                    if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                        triggerReadback(caller: "414", message: "\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(caller: "416", message: "\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)", fontSize: 100)
                    }
                case 2:
                    if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                        triggerReadback(caller: "420", message: "\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(caller: "422", message: "\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)", fontSize: 100)
                    }
                case 3:
                    if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                        triggerReadback(caller: "426", message: "\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(caller: "428", message: "\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)", fontSize: 100)
                    }
                case 4:
                    if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                        triggerReadback(caller: "432", message: "\(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(caller: "434", message: "\(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)", fontSize: 100)
                    }
                case 5:
                    if currentMatch!.matchStatistics.gamesFifthSetFirstPlayer > currentMatch!.matchStatistics.gamesFifthSetSecondPlayer {
                        triggerReadback(caller: "438", message: "\(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(caller: "440", message: "\(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer)", fontSize: 100)
                    }
                default:
                    break
                }
                gameFinished = false
            } else {
                if gameSetMatchIndication == false {
                    triggerReadback(caller: "447", message: scoreLabel.text!, fontSize: 100)
                }
            }
        }
    }
    
    @IBAction func secondTeamPointButtonTapped(_ sender: UIButton) {
        if currentMatch?.matchStatistics.matchRunning == true {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
            pointStarted = false
            startOfPointButton.isHidden = false
            
            resetFaults()
            
            shotclockTimer?.invalidate()
            resetChangeOfEndsShotClockData()
            resetShotClock(withTime: 25)
            
            if currentMatch?.matchStatistics.onRightSide == "firstTeam" {
                endOfPoint(team: 0)
            } else {
                endOfPoint(team: 1)
            }
            
            var currentSet: Int = currentMatch!.matchStatistics.currentSetPlayed
            
            if setJustFinished == true {
                setJustFinished = false
                currentSet -= 1
            }
            
            if gameFinished == true && gameSetMatchIndication == false {
                switch currentSet {
                case 1:
                    if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                        triggerReadback(caller: "478", message: "\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(caller: "480", message: "\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)", fontSize: 100)
                    }
                case 2:
                    if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                        triggerReadback(caller: "484", message: "\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(caller: "486", message: "\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)", fontSize: 100)
                    }
                case 3:
                    if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                        triggerReadback(caller: "490", message: "\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(caller: "492", message: "\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)", fontSize: 100)
                    }
                case 4:
                    if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                        triggerReadback(caller: "496", message: "\(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(caller: "498", message: "\(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)", fontSize: 100)
                    }
                case 5:
                    if currentMatch!.matchStatistics.gamesFifthSetFirstPlayer > currentMatch!.matchStatistics.gamesFifthSetSecondPlayer {
                        triggerReadback(caller: "502", message: "\(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(caller: "504", message: "\(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer)", fontSize: 100)
                    }
                default:
                    break
                }
                gameFinished = false
            } else {
                if gameSetMatchIndication == false {
                    triggerReadback(caller: "511", message: scoreLabel.text!, fontSize: 100)
                }
            }
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
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startMatchTimer), userInfo: nil, repeats: true)
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
        
        aceButton.layer.borderWidth = 1
        aceButton.layer.borderColor = UIColor.lightGray.cgColor
        netButton.layer.borderWidth = 1
        netButton.layer.borderColor = UIColor.lightGray.cgColor
        faultButton.layer.borderWidth = 1
        faultButton.layer.borderColor = UIColor.lightGray.cgColor
        overruleButton.layer.borderWidth = 1
        overruleButton.layer.borderColor = UIColor.lightGray.cgColor
        footfaultButton.layer.borderWidth = 1
        footfaultButton.layer.borderColor = UIColor.lightGray.cgColor
        
        readbackView.layer.cornerRadius = 10
        readbackView.layer.masksToBounds = true
        
        removeCurrentReadback()
        
        if currentMatch!.matchStatistics.isServer.starts(with: "firstTeam") {
            firstTeamServerIndicatorView.isHidden = false
            secondTeamServerIndicatorView.isHidden = true
        } else {
            firstTeamServerIndicatorView.isHidden = true
            secondTeamServerIndicatorView.isHidden = false
        }
        
        matchTimeLabel.text = "\(currentMatch!.matchStatistics.matchTimeInterval.format(using: [.hour, .minute])!)"
        
        let singleTapTimerView = UITapGestureRecognizer(target: self, action: #selector(singleTappedInTimerView))
        singleTapTimerView.numberOfTapsRequired = 1
        timerView.addGestureRecognizer(singleTapTimerView)
        
        let doubleTapTimerView = UITapGestureRecognizer(target: self, action: #selector(doubleTappedInTimerView))
        doubleTapTimerView.numberOfTapsRequired = 2
        timerView.addGestureRecognizer(doubleTapTimerView)
        
        if currentMatch?.matchStatistics.matchFinished == true {
            interactMatchButton.setTitle("Exit", for: .normal)
            interactMatchButton.backgroundColor = UIColor.systemGreen
        }
    }
    
    func initMatch() {
        currentMatch?.matchStatistics.isServer = "firstTeamFirst"
        currentMatch?.matchStatistics.onLeftSide = "firstTeam"
        currentMatch?.matchStatistics.onRightSide = "secondTeam"
        
        updateSetView()
        resetShotClock(withTime: 30)
        
        if currentMatch?.matchType.matchType == 0 {
            
            firstTeamLabel.text = "\(currentMatch!.firstTeamFirstPlayer), \(currentMatch!.firstTeamFirstPlayerSurname)"
            secondTeamLabel.text = "\(currentMatch!.secondTeamFirstPlayer), \(currentMatch!.secondTeamFirstPlayerSurname)"
            
            if (currentMatch!.matchStatistics.gamesFirstSetFirstPlayer == 0) && (currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == 0) {
                if (currentMatch!.matchStatistics.onLeftSide == "firstTeam") && (currentMatch!.matchStatistics.onRightSide == "secondTeam") {
                    
                    currentMatch?.matchStatistics.currentFirstPosition = "firstTeam"
                    currentMatch?.matchStatistics.currentSecondPosition = "secondTeam"
                    
                    currentMatch?.matchStatistics.currentLeftNear = "first"
                    currentMatch?.matchStatistics.currentRightFar = "first"
                    
                    courtLeftNearLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1))\(currentMatch!.firstTeamFirstPlayerSurname.prefix(1))"
                    courtLeftFarLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1))\(currentMatch!.firstTeamFirstPlayerSurname.prefix(1))"
                    
                    courtRightNearLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1))\(currentMatch!.secondTeamFirstPlayerSurname.prefix(1))"
                    courtRightFarLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1))\(currentMatch!.secondTeamFirstPlayerSurname.prefix(1))"
                    
                    firstTeamPointButton.setTitle("\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)", for: .normal)
                    secondTeamPointButton.setTitle("\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)", for: .normal)
                    
                    if currentMatch?.matchStatistics.isServer == "firstTeamFirst" {
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
                    
                    currentMatch?.matchStatistics.currentLeftNear = "first"
                    currentMatch?.matchStatistics.currentLeftFar = ""
                    currentMatch?.matchStatistics.currentRightFar = "first"
                    currentMatch?.matchStatistics.currentRightNear = ""
                    
                    courtRightNearLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1))\(currentMatch!.firstTeamFirstPlayerSurname.prefix(1))"
                    courtRightFarLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1))\(currentMatch!.firstTeamFirstPlayerSurname.prefix(1))"
                    
                    courtLeftNearLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1))\(currentMatch!.secondTeamFirstPlayerSurname.prefix(1))"
                    courtLeftFarLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1))\(currentMatch!.secondTeamFirstPlayerSurname.prefix(1))"
                    
                    firstTeamPointButton.setTitle("\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)", for: .normal)
                    secondTeamPointButton.setTitle("\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)", for: .normal)
                    
                    if currentMatch?.matchStatistics.isServer == "secondTeamFirst" {
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
            } else {
                if currentMatch?.matchStatistics.onLeftSide == "firstTeam" {
                    currentMatch?.matchStatistics.currentFirstPosition = "firstTeam"
                    currentMatch?.matchStatistics.currentSecondPosition = "secondTeam"
                    
                    currentMatch?.matchStatistics.currentLeftNear = "first"
                    currentMatch?.matchStatistics.currentLeftFar = ""
                    currentMatch?.matchStatistics.currentRightFar = "first"
                    currentMatch?.matchStatistics.currentRightNear = ""
                    
                    courtLeftNearLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1))\(currentMatch!.firstTeamFirstPlayerSurname.prefix(1))"
                    courtLeftFarLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1))\(currentMatch!.firstTeamFirstPlayerSurname.prefix(1))"
                    
                    courtRightNearLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1))\(currentMatch!.secondTeamFirstPlayerSurname.prefix(1))"
                    courtRightFarLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1))\(currentMatch!.secondTeamFirstPlayerSurname.prefix(1))"
                    
                    firstTeamPointButton.setTitle("\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)", for: .normal)
                    secondTeamPointButton.setTitle("\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)", for: .normal)
                    
                    if currentMatch?.matchStatistics.isServer == "firstTeamFirst" {
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
                    
                    currentMatch?.matchStatistics.currentLeftNear = "first"
                    currentMatch?.matchStatistics.currentLeftFar = ""
                    currentMatch?.matchStatistics.currentRightFar = "first"
                    currentMatch?.matchStatistics.currentRightNear = ""
                    
                    courtRightNearLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1))\(currentMatch!.firstTeamFirstPlayerSurname.prefix(1))"
                    courtRightFarLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1))\(currentMatch!.firstTeamFirstPlayerSurname.prefix(1))"
                    
                    firstTeamPointButton.setTitle("\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)", for: .normal)
                    secondTeamPointButton.setTitle("\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)", for: .normal)
                    
                    if currentMatch?.matchStatistics.isServer == "secondTeamFirst" {
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
        
        if currentMatch?.matchStatistics.matchFinished == true {
            startOfPointButton.isHidden = true
            pointStarted = false
            scoreLabel.text = "GAME SET MATCH"
            gameSetMatchIndication = true
            triggerReadback(caller: "747", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
        } else {
            startOfPointButton.isHidden = false
            pointStarted = false
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
    
    func updateBallChangeIndication() {
        
        let ballchangeAt = currentMatch?.matchType.ballChange
        
        switch ballchangeAt {
        case 0:
            ballchangeIndicatorLabel.text = "NA"
        case 1:
            // 7/9
            ballchangeIndicatorLabel.text = ""
        case 2:
            // 9/11
            ballchangeIndicatorLabel.text = ""
        case 3:
            // 11/13
            ballchangeIndicatorLabel.text = ""
        case 4:
            // 3. Satz
            ballchangeIndicatorLabel.text = ""
        default:
            break
        }
        
    }
    
    func updateSetView() {
        
        /*
                Update server Icon
         */
        
        if currentMatch!.matchStatistics.isServer.starts(with: "firstTeam") {
            firstTeamServerIndicatorView.isHidden = false
            secondTeamServerIndicatorView.isHidden = true
        } else {
            firstTeamServerIndicatorView.isHidden = true
            secondTeamServerIndicatorView.isHidden = false
        }
        
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
        case "selectPlayerSegue":
            let destinationVC = segue.destination as! SelectPlayerViewController
            
            destinationVC.currentMatch = currentMatch
            destinationVC.currentTeam = selectedTeam
            destinationVC.indexOfMatch = selectedIndex!
            
            destinationVC.delegate = self
        case "operatePlayerInteractionSegue":
            let destinationVC = segue.destination as! PlayerInteractionViewController
            
            destinationVC.currentMatch = currentMatch
            destinationVC.indexOfMatch = selectedIndex!
            destinationVC.targetPlayer = selectedPlayer
            
            destinationVC.delegate = self
        case "selectCodeViolationSegue":
            let destinationVC = segue.destination as! SelectCodeViolationViewController
            
            destinationVC.currentMatch = currentMatch
            destinationVC.indexOfMatch = selectedIndex!
            destinationVC.selectedPlayer = selectedPlayer
            
            destinationVC.delegate = self
        case "clarifyCodeViolationPenaltySegue":
            let destinationVC = segue.destination as! ClarifyCodeViolationViewController
            
            destinationVC.currentMatch = currentMatch
            destinationVC.indexOfMatch = selectedIndex!
            destinationVC.selectedPlayer = selectedPlayer
            destinationVC.selectedCodeViolation = selectedViolation
            
            destinationVC.delegate = self
        case "validateCodeViolationSegue":
            let destinationVC = segue.destination as! ValidateCodeViolationViewController
            
            destinationVC.currentMatch = currentMatch
            destinationVC.indexOfMatch = selectedIndex!
            destinationVC.selectedPlayer = selectedPlayer
            destinationVC.selectedCodeViolation = selectedViolation
            destinationVC.selectedPenalty = selectedPenalty
            
            destinationVC.delegate = self
        case "clarifyTimeViolationPenaltySegue":
            let destinationVC = segue.destination as! ClarifyTimeViolationViewController
            
            destinationVC.currentMatch = currentMatch
            destinationVC.indexOfMatch = selectedIndex!
            destinationVC.selectedPlayer = selectedPlayer
            
            destinationVC.delegate = self
        case "validateTimeViolationSegue":
            let destinationVC = segue.destination as! ValidateTimeViolationViewController
            
            destinationVC.currentMatch = currentMatch
            destinationVC.indexOfMatch = selectedIndex!
            destinationVC.selectedPlayer = selectedPlayer
            destinationVC.selectedPenalty = selectedPenalty
            
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
        currentMatch?.matchStatistics.matchInitiated = false
        
        let now = NSDate()
        var remainingTimeInterval: TimeInterval = now.timeIntervalSince(currentMatch!.matchStatistics.matchRestartTimeStamp as Date)
        remainingTimeInterval = remainingTimeInterval + currentMatch!.matchStatistics.matchTimeInterval
        
        currentMatch?.matchStatistics.matchTimeInterval = remainingTimeInterval
        
        delegate?.sendMatch(currentMatch: currentMatch!, selectedIndex: selectedIndex!)
        navigationController?.popViewController(animated: true)
    }
    
    func dismissWarmupInfo() {
        
    }
    
    // MARK: - Fault Logic
    
    func addFault(team: Int) {
        pointStarted = false
        startOfPointButton.isHidden = false
        
        if currentMatch?.matchStatistics.firstFault == false {
            currentMatch?.matchStatistics.firstFault = true
            firstFault = true
        } else {
            currentMatch?.matchStatistics.firstFault = false
            firstFault = false
            
            if team == 0 {
                endOfPoint(team: 1)
            } else {
                endOfPoint(team: 0)
            }
        }
    }
    
    // MARK: - End Of Point Logic
    
    func endOfPoint(team: Int) {
        var updatedScoreDisplay: Bool = false
        
        if currentMatch?.matchType.matchType == 0 {
            // MARK: - Singles
            currentMatch?.matchStatistics.currentGameInteger += 1
            
            if currentMatch?.matchStatistics.inTiebreak == false {
                // MARK: - Check for Deuce or other team Ad.
                
                if currentMatch?.matchStatistics.currentLeftFar == "first" {
                    currentMatch?.matchStatistics.currentLeftFar = ""
                    currentMatch?.matchStatistics.currentLeftNear = "first"
                } else {
                    currentMatch?.matchStatistics.currentLeftFar = "first"
                    currentMatch?.matchStatistics.currentLeftNear = ""
                }
                
                if currentMatch?.matchStatistics.currentRightFar == "first" {
                    currentMatch?.matchStatistics.currentRightFar = ""
                    currentMatch?.matchStatistics.currentRightNear = "first"
                } else {
                    currentMatch?.matchStatistics.currentRightFar = "first"
                    currentMatch?.matchStatistics.currentRightNear = ""
                }
                
                if team == 0 {
                    if currentMatch?.matchStatistics.currentGameSecondPlayer == 40 {
                        if currentMatch?.matchStatistics.currentGameFirstPlayer == 0 {
                            currentMatch?.matchStatistics.currentGameFirstPlayer = 15
                        } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 15 {
                            currentMatch?.matchStatistics.currentGameFirstPlayer = 30
                        } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 30 {
                            currentMatch?.matchStatistics.currentGameFirstPlayer = 40
                        } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 40 {
                            if currentMatch?.matchStatistics.currentGameSecondPlayer == 40 {
                                currentMatch?.matchStatistics.currentGameFirstPlayer = 50
                            } else {
                                currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                                currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                                
                                currentMatch?.matchStatistics.currentLeftNear = "first"
                                currentMatch?.matchStatistics.currentRightFar = "first"
                                
                                updateScoreDisplay()
                                reorientatePlayerLabels()
                                updatedScoreDisplay = true
                                
                                updateGames(teamWon: "firstTeam")
                            }
                        } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 50 {
                            currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                            currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                            
                            currentMatch?.matchStatistics.currentLeftNear = "first"
                            currentMatch?.matchStatistics.currentRightFar = "first"
                            
                            updateScoreDisplay()
                            reorientatePlayerLabels()
                            updatedScoreDisplay = true
                            
                            updateGames(teamWon: "firstTeam")
                        }
                    } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 50 {
                        currentMatch?.matchStatistics.currentGameSecondPlayer = 40
                    } else {
                        if currentMatch?.matchStatistics.currentGameFirstPlayer == 0 {
                            currentMatch?.matchStatistics.currentGameFirstPlayer = 15
                        } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 15 {
                            currentMatch?.matchStatistics.currentGameFirstPlayer = 30
                        } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 30 {
                            currentMatch?.matchStatistics.currentGameFirstPlayer = 40
                        } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 40 {
                            
                            if currentMatch?.matchStatistics.currentGameSecondPlayer == 40 {
                                currentMatch?.matchStatistics.currentGameFirstPlayer = 50
                            } else {
                                currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                                currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                                
                                currentMatch?.matchStatistics.currentLeftNear = "first"
                                currentMatch?.matchStatistics.currentRightFar = "first"
                                
                                updateScoreDisplay()
                                reorientatePlayerLabels()
                                updatedScoreDisplay = true
                                
                                updateGames(teamWon: "firstTeam")
                            }
                        } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 50 {
                            currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                            currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                            
                            currentMatch?.matchStatistics.currentLeftNear = "first"
                            currentMatch?.matchStatistics.currentRightFar = "first"
                            
                            updateScoreDisplay()
                            reorientatePlayerLabels()
                            updatedScoreDisplay = true
                            
                            updateGames(teamWon: "firstTeam")
                        }
                    }
                } else {
                    if currentMatch?.matchStatistics.currentGameFirstPlayer == 40 {
                        if currentMatch?.matchStatistics.currentGameSecondPlayer == 0 {
                            currentMatch?.matchStatistics.currentGameSecondPlayer = 15
                        } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 15 {
                            currentMatch?.matchStatistics.currentGameSecondPlayer = 30
                        } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 30 {
                            currentMatch?.matchStatistics.currentGameSecondPlayer = 40
                        } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 40 {
                            if currentMatch?.matchStatistics.currentGameFirstPlayer == 40 {
                                currentMatch?.matchStatistics.currentGameSecondPlayer = 50
                            } else {
                                currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                                currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                                
                                currentMatch?.matchStatistics.currentLeftNear = "first"
                                currentMatch?.matchStatistics.currentRightFar = "first"
                                
                                updateScoreDisplay()
                                reorientatePlayerLabels()
                                updatedScoreDisplay = true
                                
                                updateGames(teamWon: "secondTeam")
                            }
                        } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 50 {
                            currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                            currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                            
                            currentMatch?.matchStatistics.currentLeftNear = "first"
                            currentMatch?.matchStatistics.currentRightFar = "first"
                            
                            updateScoreDisplay()
                            reorientatePlayerLabels()
                            updatedScoreDisplay = true
                            
                            updateGames(teamWon: "secondTeam")
                        }
                    } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 50 {
                        currentMatch?.matchStatistics.currentGameFirstPlayer = 40
                    } else {
                        if currentMatch?.matchStatistics.currentGameSecondPlayer == 0 {
                            currentMatch?.matchStatistics.currentGameSecondPlayer = 15
                        } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 15 {
                            currentMatch?.matchStatistics.currentGameSecondPlayer = 30
                        } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 30 {
                            currentMatch?.matchStatistics.currentGameSecondPlayer = 40
                        } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 40 {
                            if currentMatch?.matchStatistics.currentGameFirstPlayer == 40 {
                                currentMatch?.matchStatistics.currentGameSecondPlayer = 50
                            } else {
                                currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                                currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                                
                                currentMatch?.matchStatistics.currentLeftNear = "first"
                                currentMatch?.matchStatistics.currentRightFar = "first"
                                
                                updateScoreDisplay()
                                reorientatePlayerLabels()
                                updatedScoreDisplay = true
                                
                                updateGames(teamWon: "secondTeam")
                            }
                        } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 50 {
                            currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                            currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                            
                            currentMatch?.matchStatistics.currentLeftNear = "first"
                            currentMatch?.matchStatistics.currentRightFar = "first"
                            
                            updateScoreDisplay()
                            reorientatePlayerLabels()
                            updatedScoreDisplay = true
                            
                            updateGames(teamWon: "secondTeam")
                        }
                    }
                }
                
                if updatedScoreDisplay == false {
                    updateScoreDisplay()
                    reorientatePlayerLabels()
                }
            } else {
                // Tiebreak scoring
                
                endOfTiebreakPointSingles(team: team)
            }
            
        } else {
            // MARK: - Doubles
        }
        
        visualizeViolations()
    }
    
    func endOfTiebreakPointSingles(team: Int) {
        if currentMatch?.matchStatistics.inTiebreak == true {
            
            var firstTeamPoints: Int = 0
            var secondTeamPoints: Int = 0
            var pointsToBePlayed: Int = 0
            
            switch currentMatch?.matchStatistics.currentSetPlayed {
            case 0:
                if team == 0 {
                    currentMatch?.matchStatistics.justTiebreakPointsFirstPlayer += 1
                } else {
                    currentMatch?.matchStatistics.justTiebreakPointsSecondPlayer += 1
                }
                
                firstTeamPoints = currentMatch!.matchStatistics.justTiebreakPointsFirstPlayer
                secondTeamPoints = currentMatch!.matchStatistics.justTiebreakPointsSecondPlayer
                
                if currentMatch?.matchType.tiebreakPoints != 0 {
                    pointsToBePlayed = currentMatch!.matchType.tiebreakPoints
                } else if currentMatch?.matchType.matchTiebreakPoints != 0{
                    pointsToBePlayed = currentMatch!.matchType.matchTiebreakPoints
                } else if currentMatch?.matchType.lastSetTiebreakPoints != 0 {
                    pointsToBePlayed = currentMatch!.matchType.lastSetTiebreakPoints
                }
            case 1:
                if team == 0 {
                    currentMatch?.matchStatistics.tiebreakFirstSetFirstPlayer += 1
                } else {
                    currentMatch?.matchStatistics.tiebreakFirstSetSecondPlayer += 1
                }
                
                firstTeamPoints = currentMatch!.matchStatistics.tiebreakFirstSetFirstPlayer
                secondTeamPoints = currentMatch!.matchStatistics.tiebreakFirstSetSecondPlayer
                
                if currentMatch?.matchType.totalSets == 1 {
                    pointsToBePlayed = currentMatch!.matchType.lastSetTiebreakPoints
                } else {
                    pointsToBePlayed = currentMatch!.matchType.tiebreakPoints
                }
            case 2:
                if team == 0 {
                    currentMatch?.matchStatistics.tiebreakSecondSetFirstPlayer += 1
                } else {
                    currentMatch?.matchStatistics.tiebreakSecondSetSecondPlayer += 1
                }
                
                firstTeamPoints = currentMatch!.matchStatistics.tiebreakSecondSetFirstPlayer
                secondTeamPoints = currentMatch!.matchStatistics.tiebreakSecondSetSecondPlayer
                
                pointsToBePlayed = currentMatch!.matchType.tiebreakPoints
            case 3:
                if team == 0 {
                    currentMatch?.matchStatistics.tiebreakThirdSetFirstPlayer += 1
                } else {
                    currentMatch?.matchStatistics.tiebreakThirdSetSecondPlayer += 1
                }
                
                firstTeamPoints = currentMatch!.matchStatistics.tiebreakThirdSetFirstPlayer
                secondTeamPoints = currentMatch!.matchStatistics.tiebreakThirdSetSecondPlayer
                
                if currentMatch?.matchType.totalSets == 3 {
                    pointsToBePlayed = currentMatch!.matchType.lastSetTiebreakPoints
                } else {
                    pointsToBePlayed = currentMatch!.matchType.tiebreakPoints
                }
            case 4:
                if team == 0 {
                    currentMatch?.matchStatistics.tiebreakFourthSetFirstPlayer += 1
                } else {
                    currentMatch?.matchStatistics.tiebreakFourthSetSecondPlayer += 1
                }
                
                firstTeamPoints = currentMatch!.matchStatistics.tiebreakFourthSetFirstPlayer
                secondTeamPoints = currentMatch!.matchStatistics.tiebreakFourthSetSecondPlayer
                
                pointsToBePlayed = currentMatch!.matchType.tiebreakPoints
            case 5:
                if team == 0 {
                    currentMatch?.matchStatistics.tiebreakFifthSetFirstPlayer += 1
                } else {
                    currentMatch?.matchStatistics.tiebreakFifthSetSecondPlayer += 1
                }
                
                firstTeamPoints = currentMatch!.matchStatistics.tiebreakFifthSetFirstPlayer
                secondTeamPoints = currentMatch!.matchStatistics.tiebreakFifthSetSecondPlayer
                
                if currentMatch?.matchType.totalSets == 3 {
                    pointsToBePlayed = currentMatch!.matchType.lastSetTiebreakPoints
                } else {
                    pointsToBePlayed = currentMatch!.matchType.tiebreakPoints
                }
            default:
                break
            }
            
            if firstTeamPoints + secondTeamPoints % 6 == 0 {
                // Switch sides
                
                if currentMatch?.matchStatistics.onLeftSide == "firstTeam" {
                    currentMatch?.matchStatistics.onLeftSide = "secondTeam"
                    currentMatch?.matchStatistics.onRightSide = "firstTeam"
                } else {
                    currentMatch?.matchStatistics.onLeftSide = "firstTeam"
                    currentMatch?.matchStatistics.onRightSide = "secondTeam"
                }
            }
            
            if firstTeamPoints + secondTeamPoints % 2 == 1 {
                // Switch Servers
                
                if currentMatch?.matchStatistics.isServer == "firstTeamFirst" {
                    currentMatch?.matchStatistics.isServer = "secondTeamFirst"
                } else {
                    currentMatch?.matchStatistics.isServer = "firstTeamFirst"
                }
            }
            
            if firstTeamPoints >= pointsToBePlayed && secondTeamPoints <= firstTeamPoints - 2 {
                // First Team won Tiebreak
                
                if currentMatch?.matchType.totalSets == 0 {
                    gameSetMatch()
                } else {
                    if team == 0 {
                        updateGames(teamWon: "firstTeam")
                    } else {
                        updateGames(teamWon: "secondTeam")
                    }
                }
            } else if secondTeamPoints >= pointsToBePlayed && firstTeamPoints <= secondTeamPoints - 2 {
                // Second Team won Tiebreak
                
                if currentMatch?.matchType.totalSets == 0 {
                    gameSetMatch()
                } else {
                    if team == 0 {
                        updateGames(teamWon: "firstTeam")
                    } else {
                        updateGames(teamWon: "secondTeam")
                    }
                }
            }
            
        }
    }
    
    func updateScoreDisplay() {
        if currentMatch?.matchStatistics.currentGameFirstPlayer == 40 && currentMatch?.matchStatistics.currentGameSecondPlayer == 40 {
            currentMatch?.matchStatistics.currentGame = "DEUCE"
        } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 50 {
            if currentMatch?.matchType.matchType == 0 {
                currentMatch?.matchStatistics.currentGame = "Ad. \(currentMatch!.firstTeamFirstPlayerSurname)"
            } else {
                currentMatch?.matchStatistics.currentGame = "Ad. \(currentMatch!.firstTeamFirstPlayerSurname), \(currentMatch!.firstTeamSecondPlayerSurname)"
            }
        } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 50 {
            if currentMatch?.matchType.matchType == 0 {
                currentMatch?.matchStatistics.currentGame = "Ad. \(currentMatch!.secondTeamFirstPlayerSurname)"
            } else {
                currentMatch?.matchStatistics.currentGame = "Ad. \(currentMatch!.secondTeamFirstPlayerSurname), \(currentMatch!.secondTeamSecondPlayerSurname)"
            }
        } else {
            if currentMatch?.matchStatistics.isServer == "firstTeamFirst" || currentMatch?.matchStatistics.isServer == "firstTeamSecond" {
                currentMatch?.matchStatistics.currentGame = "\(currentMatch!.matchStatistics.currentGameFirstPlayer)/\(currentMatch!.matchStatistics.currentGameSecondPlayer)"
            } else {
                currentMatch?.matchStatistics.currentGame = "\(currentMatch!.matchStatistics.currentGameSecondPlayer)/\(currentMatch!.matchStatistics.currentGameFirstPlayer)"
            }
        }
        
        scoreLabel.text = currentMatch?.matchStatistics.currentGame
    }
    
    func reorientatePlayerLabels() {
        
        if currentMatch?.matchType.matchType == 0 {
            //      Singles
            
            //      Logic to replace Server Tags
            if currentMatch?.matchStatistics.onLeftSide == "firstTeam" {
                // 1. Team links
                
                courtLeftFarLabel.layer.borderWidth = 0
                courtLeftNearLabel.layer.borderWidth = 0
                courtRightFarLabel.layer.borderWidth = 0
                courtRightNearLabel.layer.borderWidth = 0
                
                switch currentMatch?.matchStatistics.isServer {
                case "firstTeamFirst":
                    if currentMatch?.matchStatistics.currentLeftFar == "first" {
                        courtLeftFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftFarLabel.layer.borderWidth = 1
                        courtLeftNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftNearLabel.layer.borderWidth = 0
                    } else {
                        courtLeftFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftFarLabel.layer.borderWidth = 0
                        courtLeftNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftNearLabel.layer.borderWidth = 1
                    }
                case "secondTeamFirst":
                    if currentMatch?.matchStatistics.currentRightFar == "first" {
                        courtRightFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightFarLabel.layer.borderWidth = 1
                        courtRightNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightNearLabel.layer.borderWidth = 0
                    } else {
                        courtRightFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightFarLabel.layer.borderWidth = 0
                        courtRightNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightNearLabel.layer.borderWidth = 1
                    }
                default:
                    break
                }
            } else {
                // 2. Team Links
                
                switch currentMatch?.matchStatistics.isServer {
                case "secondTeamFirst":
                    if currentMatch?.matchStatistics.currentLeftFar == "first" {
                        courtLeftFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftFarLabel.layer.borderWidth = 1
                        courtLeftNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftNearLabel.layer.borderWidth = 0
                    } else {
                        courtLeftFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftFarLabel.layer.borderWidth = 0
                        courtLeftNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftNearLabel.layer.borderWidth = 1
                    }
                case "firstTeamFirst":
                    if currentMatch?.matchStatistics.currentRightFar == "first" {
                        courtRightFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightFarLabel.layer.borderWidth = 1
                        courtRightNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightNearLabel.layer.borderWidth = 0
                    } else {
                        courtRightFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightFarLabel.layer.borderWidth = 0
                        courtRightNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightNearLabel.layer.borderWidth = 1
                    }
                default:
                    break
                }
            }
            
            //      Logic to replace Player Labels
            if currentMatch?.matchStatistics.onLeftSide == "firstTeam" {
                
                courtLeftNearLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1))\(currentMatch!.firstTeamFirstPlayerSurname.prefix(1))"
                courtLeftFarLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1))\(currentMatch!.firstTeamFirstPlayerSurname.prefix(1))"
                
                courtRightNearLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1))\(currentMatch!.secondTeamFirstPlayerSurname.prefix(1))"
                courtRightFarLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1))\(currentMatch!.secondTeamFirstPlayerSurname.prefix(1))"
                
                firstTeamPointButton.setTitle("\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)", for: .normal)
                secondTeamPointButton.setTitle("\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)", for: .normal)
            } else {
                
                courtLeftNearLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1))\(currentMatch!.secondTeamFirstPlayerSurname.prefix(1))"
                courtLeftFarLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1))\(currentMatch!.secondTeamFirstPlayerSurname.prefix(1))"
                
                courtRightNearLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1))\(currentMatch!.firstTeamFirstPlayerSurname.prefix(1))"
                courtRightFarLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1))\(currentMatch!.firstTeamFirstPlayerSurname.prefix(1))"
                
                firstTeamPointButton.setTitle("\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)", for: .normal)
                secondTeamPointButton.setTitle("\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)", for: .normal)
            }
            
            if currentMatch?.matchStatistics.currentLeftFar == "first" {
                courtLeftFarLabel.isHidden = false
                courtLeftNearLabel.isHidden = true
            } else {
                courtLeftFarLabel.isHidden = true
                courtLeftNearLabel.isHidden = false
            }
            
            if currentMatch?.matchStatistics.currentRightFar == "first" {
                courtRightFarLabel.isHidden = false
                courtRightNearLabel.isHidden = true
            } else {
                courtRightFarLabel.isHidden = true
                courtRightNearLabel.isHidden = false
            }
        } else {
            //      Doubles
            
            //      Logic to replace ServerTags
            if currentMatch?.matchStatistics.onLeftSide == "firstTeam" {
                // 1. Team links
                
                switch currentMatch?.matchStatistics.isServer {
                case "firstTeamFirst":
                    if currentMatch?.matchStatistics.firstTeamFar == "first" {
                        courtLeftFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftFarLabel.layer.borderWidth = 1
                        courtLeftNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftNearLabel.layer.borderWidth = 0
                    } else {
                        courtLeftFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftFarLabel.layer.borderWidth = 0
                        courtLeftNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftNearLabel.layer.borderWidth = 1
                    }
                case "firstTeamSecond":
                    if currentMatch?.matchStatistics.firstTeamFar == "second" {
                        courtLeftFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftFarLabel.layer.borderWidth = 1
                        courtLeftNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftNearLabel.layer.borderWidth = 0
                    } else {
                        courtLeftFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftFarLabel.layer.borderWidth = 0
                        courtLeftNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftNearLabel.layer.borderWidth = 1
                    }
                case "secondTeamFirst":
                    if currentMatch?.matchStatistics.firstTeamFar == "first" {
                        courtRightFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightFarLabel.layer.borderWidth = 1
                        courtRightNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightNearLabel.layer.borderWidth = 0
                    } else {
                        courtRightFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightFarLabel.layer.borderWidth = 0
                        courtRightNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightNearLabel.layer.borderWidth = 1
                    }
                case "secondTeamSecond":
                    if currentMatch?.matchStatistics.firstTeamFar == "second" {
                        courtRightFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightFarLabel.layer.borderWidth = 1
                        courtRightNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightNearLabel.layer.borderWidth = 0
                    } else {
                        courtRightFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightFarLabel.layer.borderWidth = 0
                        courtRightNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightNearLabel.layer.borderWidth = 1
                    }
                default:
                    break
                }
            } else {
                // 2. Team Links
                
                switch currentMatch?.matchStatistics.isServer {
                case "secondTeamFirst":
                    if currentMatch?.matchStatistics.firstTeamFar == "first" {
                        courtLeftFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftFarLabel.layer.borderWidth = 1
                        courtLeftNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftNearLabel.layer.borderWidth = 0
                    } else {
                        courtLeftFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftFarLabel.layer.borderWidth = 0
                        courtLeftNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftNearLabel.layer.borderWidth = 1
                    }
                case "secondTeamSecond":
                    if currentMatch?.matchStatistics.firstTeamFar == "second" {
                        courtLeftFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftFarLabel.layer.borderWidth = 1
                        courtLeftNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftNearLabel.layer.borderWidth = 0
                    } else {
                        courtLeftFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftFarLabel.layer.borderWidth = 0
                        courtLeftNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtLeftNearLabel.layer.borderWidth = 1
                    }
                case "firstTeamFirst":
                    if currentMatch?.matchStatistics.firstTeamFar == "first" {
                        courtRightFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightFarLabel.layer.borderWidth = 1
                        courtRightNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightNearLabel.layer.borderWidth = 0
                    } else {
                        courtRightFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightFarLabel.layer.borderWidth = 0
                        courtRightNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightNearLabel.layer.borderWidth = 1
                    }
                case "firstTeamSecond":
                    if currentMatch?.matchStatistics.firstTeamFar == "second" {
                        courtRightFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightFarLabel.layer.borderWidth = 1
                        courtRightNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightNearLabel.layer.borderWidth = 0
                    } else {
                        courtRightFarLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightFarLabel.layer.borderWidth = 0
                        courtRightNearLabel.layer.borderColor = UIColor.systemTeal.cgColor
                        courtRightNearLabel.layer.borderWidth = 1
                    }
                default:
                    break
                }
            }
            
            // Logic to replace Labelnames
            if currentMatch?.matchStatistics.onLeftSide == "firstTeam" {
                if currentMatch?.matchStatistics.firstTeamFar == "first" {
                    courtLeftNearLabel.text = "\(currentMatch!.firstTeamSecondPlayer.prefix(1))\(currentMatch!.firstTeamSecondPlayerSurname.prefix(1))"
                    courtLeftFarLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1))\(currentMatch!.firstTeamFirstPlayerSurname.prefix(1))"
                } else {
                    courtLeftNearLabel.text = "\(currentMatch!.firstTeamSecondPlayer.prefix(1))\(currentMatch!.firstTeamSecondPlayerSurname.prefix(1))"
                    courtLeftFarLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1))\(currentMatch!.firstTeamFirstPlayerSurname.prefix(1))"
                }
                
                if currentMatch?.matchStatistics.secondTeamFar == "first" {
                    courtRightNearLabel.text = "\(currentMatch!.secondTeamSecondPlayer.prefix(1))\(currentMatch!.secondTeamSecondPlayerSurname.prefix(1))"
                    courtRightFarLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1))\(currentMatch!.secondTeamFirstPlayerSurname.prefix(1))"
                } else {
                    courtRightNearLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1))\(currentMatch!.secondTeamFirstPlayerSurname.prefix(1))"
                    courtRightFarLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1))\(currentMatch!.secondTeamFirstPlayerSurname.prefix(1))"
                }
            } else {
                
                if currentMatch?.matchStatistics.firstTeamFar == "first" {
                    courtRightNearLabel.text = "\(currentMatch!.firstTeamSecondPlayer.prefix(1))\(currentMatch!.firstTeamSecondPlayerSurname.prefix(1))"
                    courtRightFarLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1))\(currentMatch!.firstTeamFirstPlayerSurname.prefix(1))"
                } else {
                    courtRightNearLabel.text = "\(currentMatch!.firstTeamSecondPlayer.prefix(1))\(currentMatch!.firstTeamSecondPlayerSurname.prefix(1))"
                    courtRightFarLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1))\(currentMatch!.firstTeamFirstPlayerSurname.prefix(1))"
                }
                
                if currentMatch?.matchStatistics.secondTeamFar == "first" {
                    courtLeftNearLabel.text = "\(currentMatch!.secondTeamSecondPlayer.prefix(1))\(currentMatch!.secondTeamSecondPlayerSurname.prefix(1))"
                    courtLeftFarLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1))\(currentMatch!.secondTeamFirstPlayerSurname.prefix(1))"
                } else {
                    courtLeftNearLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1))\(currentMatch!.secondTeamFirstPlayerSurname.prefix(1))"
                    courtLeftFarLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1))\(currentMatch!.secondTeamFirstPlayerSurname.prefix(1))"
                }
            }
        }
    }
    
    func updateGames(teamWon: String) {
        
        gameFinished = true
        let gamesToBePlayed: Int = currentMatch!.matchType.gamesInSet
        let twoGamesDifference: Bool = currentMatch!.matchType.twoGameDifference
        let currentSet: Int = currentMatch!.matchStatistics.currentSetPlayed
        
        switch currentMatch?.matchStatistics.currentSetPlayed {
        case 1:
            if teamWon == "firstTeam" {
                currentMatch?.matchStatistics.gamesFirstSetFirstPlayer += 1
            } else {
                currentMatch?.matchStatistics.gamesFirstSetSecondPlayer += 1
            }
        case 2:
            if teamWon == "firstTeam" {
                currentMatch?.matchStatistics.gamesSecondSetFirstPlayer += 1
            } else {
                currentMatch?.matchStatistics.gamesSecondSetSecondPlayer += 1
            }
        case 3:
            if teamWon == "firstTeam" {
                currentMatch?.matchStatistics.gamesThirdSetFirstPlayer += 1
            } else {
                currentMatch?.matchStatistics.gamesThirdSetSecondPlayer += 1
            }
        case 4:
            if teamWon == "firstTeam" {
                currentMatch?.matchStatistics.gamesFourthSetFirstPlayer += 1
            } else {
                currentMatch?.matchStatistics.gamesFourthSetSecondPlayer += 1
            }
        case 5:
            if teamWon == "firstTeam" {
                currentMatch?.matchStatistics.gamesFifthSetFirstPlayer += 1
            } else {
                currentMatch?.matchStatistics.gamesFifthSetSecondPlayer += 1
            }
        default:
            break
        }
        
        if  currentMatch?.matchType.matchType == 0 {
            if currentMatch?.matchStatistics.isServer == "firstTeamFirst" {
                currentMatch?.matchStatistics.isServer = "secondTeamFirst"
            } else {
                currentMatch?.matchStatistics.isServer = "firstTeamFirst"
            }
        }
        
        if currentMatch?.matchStatistics.inTiebreak == false && currentMatch?.matchStatistics.matchTiebreak == false {
            var setSum = 0
            
            switch currentMatch?.matchStatistics.currentSetPlayed {
            case 1:
                setSum = currentMatch!.matchStatistics.gamesFirstSetFirstPlayer + currentMatch!.matchStatistics.gamesFirstSetSecondPlayer
            case 2:
                setSum = currentMatch!.matchStatistics.gamesSecondSetFirstPlayer + currentMatch!.matchStatistics.gamesSecondSetSecondPlayer
            case 3:
                setSum = currentMatch!.matchStatistics.gamesThirdSetFirstPlayer + currentMatch!.matchStatistics.gamesThirdSetSecondPlayer
            case 4:
                setSum = currentMatch!.matchStatistics.gamesFourthSetFirstPlayer + currentMatch!.matchStatistics.gamesFourthSetSecondPlayer
            case 5:
                setSum = currentMatch!.matchStatistics.gamesFifthSetFirstPlayer + currentMatch!.matchStatistics.gamesFifthSetSecondPlayer
            default:
                break
            }
            
            if setSum % 2 == 1 {
                // Switch
                if currentMatch?.matchStatistics.onLeftSide == "firstTeam" {
                    currentMatch?.matchStatistics.onLeftSide = "secondTeam"
                    currentMatch?.matchStatistics.onRightSide = "firstTeam"
                } else {
                    currentMatch?.matchStatistics.onLeftSide = "firstTeam"
                    currentMatch?.matchStatistics.onRightSide = "secondTeam"
                }
                
                if setSum == 1 {
                    currentlyInChangeOfEnds = true
                    noChangeOfEndsBreak = true
                    resetShotClock(withTime: 25)
                } else {
                    currentlyInChangeOfEnds = true
                    noChangeOfEndsBreak = false
                    resetShotClock(withTime: 60)
                }
            }
        } else {
            // Tiebreak changes
            var tiebreakPointSum = 0
            
            switch currentMatch?.matchStatistics.currentSetPlayed {
            case 1:
                tiebreakPointSum = currentMatch!.matchStatistics.tiebreakFirstSetFirstPlayer + currentMatch!.matchStatistics.tiebreakFirstSetSecondPlayer
            case 2:
                tiebreakPointSum = currentMatch!.matchStatistics.tiebreakSecondSetFirstPlayer + currentMatch!.matchStatistics.tiebreakSecondSetSecondPlayer
            case 3:
                tiebreakPointSum = currentMatch!.matchStatistics.tiebreakThirdSetFirstPlayer + currentMatch!.matchStatistics.tiebreakThirdSetSecondPlayer
            case 4:
                tiebreakPointSum = currentMatch!.matchStatistics.tiebreakFourthSetFirstPlayer + currentMatch!.matchStatistics.tiebreakFourthSetSecondPlayer
            case 5:
                tiebreakPointSum = currentMatch!.matchStatistics.tiebreakFifthSetFirstPlayer + currentMatch!.matchStatistics.tiebreakFifthSetSecondPlayer
            default:
                break
            }
            
            if tiebreakPointSum % 6 == 1 {
                // Switch
                if currentMatch?.matchStatistics.onLeftSide == "firstTeam" {
                    currentMatch?.matchStatistics.onLeftSide = "secondTeam"
                    currentMatch?.matchStatistics.onRightSide = "firstTeam"
                } else {
                    currentMatch?.matchStatistics.onLeftSide = "firstTeam"
                    currentMatch?.matchStatistics.onRightSide = "secondTeam"
                }
                
                currentlyInChangeOfEnds = true
                noChangeOfEndsBreak = true
                resetShotClock(withTime: 25)
            }
        }
        
        // MARK: - Check for Advantage Set
        
        if currentMatch?.matchType.advantageSet == 0 {
            // No Ad Set
            
            switch currentMatch?.matchType.totalSets {
            case 0:
                break
            case 1:
                // MARK: - One Set
                if currentMatch?.matchType.gamesInSet == 0 {
                    // Just tiebreak
                    currentMatch?.matchStatistics.inTiebreak = true
                } else {
                    if currentMatch?.matchStatistics.gamesFirstSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed {
                        // Tiebreak
                        currentMatch?.matchStatistics.inTiebreak = true
                    } else {
                        if twoGamesDifference == true {
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer <= currentMatch!.matchStatistics.gamesFirstSetFirstPlayer - 2 {
                                // First player won
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer <= currentMatch!.matchStatistics.gamesFirstSetSecondPlayer - 2 {
                                // Second player won
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else if currentMatch?.matchStatistics.gamesFirstSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        } else {
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                // First Player won
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer {
                                // Second Player won
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else if currentMatch?.matchStatistics.gamesFirstSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        }
                    }
                }
            case 3:
                // MARK: - Three Sets
                if currentMatch?.matchType.gamesInSet == 0 {
                    // Just tiebreak
                    currentMatch?.matchStatistics.inTiebreak = true
                } else {
                    switch currentSet {
                    case 1:
                        if twoGamesDifference == true {
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer <= currentMatch!.matchStatistics.gamesFirstSetFirstPlayer - 2 {
                                // First player won first Set
                                currentMatch?.matchStatistics.currentSetPlayed = 2
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer <= currentMatch!.matchStatistics.gamesFirstSetSecondPlayer - 2 {
                                // Second player won first Set
                                currentMatch?.matchStatistics.currentSetPlayed = 2
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch?.matchStatistics.gamesFirstSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        } else {
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                // First Player won first Set
                                currentMatch?.matchStatistics.currentSetPlayed = 2
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer {
                                // Second Player won first Set
                                currentMatch?.matchStatistics.currentSetPlayed = 2
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch?.matchStatistics.gamesFirstSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        }
                    case 2:
                        if twoGamesDifference == true {
                            if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetSecondPlayer <= currentMatch!.matchStatistics.gamesSecondSetFirstPlayer - 2 {
                                // First player won second Set
                                
                                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 3
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                            } else if currentMatch!.matchStatistics.gamesSecondSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetFirstPlayer <= currentMatch!.matchStatistics.gamesSecondSetSecondPlayer - 2 {
                                // Second player won second Set
                                
                                if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 3
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                            } else if currentMatch?.matchStatistics.gamesSecondSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesSecondSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        } else {
                            if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                // First Player won second Set
                                
                                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 3
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                            } else if currentMatch!.matchStatistics.gamesSecondSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetSecondPlayer > currentMatch!.matchStatistics.gamesSecondSetFirstPlayer {
                                // Second Player won second Set
                                
                                if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 3
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                            } else if currentMatch?.matchStatistics.gamesSecondSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesSecondSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        }
                    case 3:
                        if twoGamesDifference == true {
                            if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetSecondPlayer <= currentMatch!.matchStatistics.gamesThirdSetFirstPlayer - 2 {
                                // First player won second Set
                                
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else if currentMatch!.matchStatistics.gamesThirdSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetFirstPlayer <= currentMatch!.matchStatistics.gamesThirdSetSecondPlayer - 2 {
                                // Second player won second Set
                                
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else if currentMatch?.matchStatistics.gamesThirdSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesThirdSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        } else {
                            if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                // First Player won second Set
                                
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else if currentMatch!.matchStatistics.gamesThirdSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetSecondPlayer > currentMatch!.matchStatistics.gamesThirdSetFirstPlayer {
                                // Second Player won second Set
                                
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else if currentMatch?.matchStatistics.gamesThirdSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesThirdSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        }
                    default:
                        break
                    }
                }
            case 5:
                // MARK: - Five Sets
                if currentMatch?.matchType.gamesInSet == 0 {
                    // Just tiebreak
                    currentMatch?.matchStatistics.inTiebreak = true
                } else {
                    switch currentSet {
                    case 1:
                        if twoGamesDifference == true {
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer <= currentMatch!.matchStatistics.gamesFirstSetFirstPlayer - 2 {
                                // First player won first Set
                                currentMatch?.matchStatistics.currentSetPlayed = 2
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer <= currentMatch!.matchStatistics.gamesFirstSetSecondPlayer - 2 {
                                // Second player won first Set
                                currentMatch?.matchStatistics.currentSetPlayed = 2
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch?.matchStatistics.gamesFirstSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        } else {
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                // First Player won first Set
                                currentMatch?.matchStatistics.currentSetPlayed = 2
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer {
                                // Second Player won first Set
                                currentMatch?.matchStatistics.currentSetPlayed = 2
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch?.matchStatistics.gamesFirstSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        }
                    case 2:
                        if twoGamesDifference == true {
                            if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetSecondPlayer <= currentMatch!.matchStatistics.gamesSecondSetFirstPlayer - 2 {
                                // First player won second Set
                                
                                currentMatch?.matchStatistics.currentSetPlayed = 3
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch!.matchStatistics.gamesSecondSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetFirstPlayer <= currentMatch!.matchStatistics.gamesSecondSetSecondPlayer - 2 {
                                // Second player won second Set
                                
                                currentMatch?.matchStatistics.currentSetPlayed = 3
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch?.matchStatistics.gamesSecondSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesSecondSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        } else {
                            if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                // First Player won second Set
                                
                                currentMatch?.matchStatistics.currentSetPlayed = 3
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch!.matchStatistics.gamesSecondSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetSecondPlayer > currentMatch!.matchStatistics.gamesSecondSetFirstPlayer {
                                // Second Player won second Set
                                
                                currentMatch?.matchStatistics.currentSetPlayed = 3
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch?.matchStatistics.gamesSecondSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesSecondSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        }
                    case 3:
                        if twoGamesDifference == true {
                            if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetSecondPlayer <= currentMatch!.matchStatistics.gamesThirdSetFirstPlayer - 2 {
                                // First player won second Set
                                
                                var firstTeamWins = 0, secondTeamWins = 0
                                
                                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                
                                if firstTeamWins == 3 || secondTeamWins == 3 {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 4
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                                
                            } else if currentMatch!.matchStatistics.gamesThirdSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetFirstPlayer <= currentMatch!.matchStatistics.gamesThirdSetSecondPlayer - 2 {
                                // Second player won second Set
                                
                                var firstTeamWins = 0, secondTeamWins = 0
                                
                                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                
                                if firstTeamWins == 3 || secondTeamWins == 3 {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 4
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                            } else if currentMatch?.matchStatistics.gamesThirdSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesThirdSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        } else {
                            if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                // First Player won second Set
                                
                                var firstTeamWins = 0, secondTeamWins = 0
                                
                                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                
                                if firstTeamWins == 3 || secondTeamWins == 3 {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 4
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                            } else if currentMatch!.matchStatistics.gamesThirdSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetSecondPlayer > currentMatch!.matchStatistics.gamesThirdSetFirstPlayer {
                                // Second Player won second Set
                                
                                var firstTeamWins = 0, secondTeamWins = 0
                                
                                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                
                                if firstTeamWins == 3 || secondTeamWins == 3 {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 4
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                            } else if currentMatch?.matchStatistics.gamesThirdSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesThirdSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        }
                    case 4:
                        if twoGamesDifference == true {
                            if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFourthSetSecondPlayer <= currentMatch!.matchStatistics.gamesFourthSetFirstPlayer - 2 {
                                // First player won second Set
                                
                                var firstTeamWins = 0, secondTeamWins = 0
                                
                                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                
                                if firstTeamWins == 3 || secondTeamWins == 3 {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 5
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                                
                            } else if currentMatch!.matchStatistics.gamesFourthSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFourthSetFirstPlayer <= currentMatch!.matchStatistics.gamesFourthSetSecondPlayer - 2 {
                                // Second player won second Set
                                
                                var firstTeamWins = 0, secondTeamWins = 0
                                
                                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                
                                if firstTeamWins == 3 || secondTeamWins == 3 {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 5
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                            } else if currentMatch?.matchStatistics.gamesFourthSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesFourthSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        } else {
                            if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                                // First Player won second Set
                                
                                var firstTeamWins = 0, secondTeamWins = 0
                                
                                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                
                                if firstTeamWins == 3 || secondTeamWins == 3 {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 5
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                            } else if currentMatch!.matchStatistics.gamesFourthSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFourthSetSecondPlayer > currentMatch!.matchStatistics.gamesFourthSetFirstPlayer {
                                // Second Player won second Set
                                
                                var firstTeamWins = 0, secondTeamWins = 0
                                
                                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                
                                if firstTeamWins == 3 || secondTeamWins == 3 {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 5
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                            } else if currentMatch?.matchStatistics.gamesFourthSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesFourthSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        }
                    case 5:
                        if twoGamesDifference == true {
                            if currentMatch!.matchStatistics.gamesFifthSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFifthSetSecondPlayer <= currentMatch!.matchStatistics.gamesFifthSetFirstPlayer - 2 {
                                // First player won second Set
                                
                                gameSetMatch()
                                gameSetMatchIndication = true
                                
                            } else if currentMatch!.matchStatistics.gamesFifthSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFifthSetFirstPlayer <= currentMatch!.matchStatistics.gamesFifthSetSecondPlayer - 2 {
                                // Second player won second Set
                                
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else if currentMatch?.matchStatistics.gamesFifthSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesFifthSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        } else {
                            if currentMatch!.matchStatistics.gamesFifthSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFifthSetFirstPlayer > currentMatch!.matchStatistics.gamesFifthSetSecondPlayer {
                                // First Player won second Set
                                
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else if currentMatch!.matchStatistics.gamesFifthSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFifthSetSecondPlayer > currentMatch!.matchStatistics.gamesFifthSetFirstPlayer {
                                // Second Player won second Set
                                
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else if currentMatch?.matchStatistics.gamesFifthSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesFifthSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        }
                    default:
                        break
                    }
                }
            default:
                break
            }
        } else if currentMatch?.matchType.advantageSet == 1 {
            // MARK: - Last Set Ad Set
            
            switch currentMatch?.matchType.totalSets {
            case 0:
                break
            case 1:
                // MARK: - One Set
                if twoGamesDifference == true {
                    if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer <= currentMatch!.matchStatistics.gamesFirstSetFirstPlayer - 2 {
                        // First player won
                        gameSetMatch()
                        gameSetMatchIndication = true
                    } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer <= currentMatch!.matchStatistics.gamesFirstSetSecondPlayer - 2 {
                        // Second player won
                        gameSetMatch()
                        gameSetMatchIndication = true
                    }
                } else {
                    if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                        // First Player won
                        gameSetMatch()
                        gameSetMatchIndication = true
                    } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer {
                        // Second Player won
                        gameSetMatch()
                        gameSetMatchIndication = true
                    }
                }
            case 3:
                // MARK: - Three Sets
                if currentMatch?.matchType.gamesInSet == 0 {
                    // Just tiebreak
                    if currentMatch?.matchStatistics.currentSetPlayed != 3 {
                        currentMatch?.matchStatistics.inTiebreak = true
                    }
                } else {
                    switch currentSet {
                    case 1:
                        if twoGamesDifference == true {
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer <= currentMatch!.matchStatistics.gamesFirstSetFirstPlayer - 2 {
                                // First player won first Set
                                currentMatch?.matchStatistics.currentSetPlayed = 2
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer <= currentMatch!.matchStatistics.gamesFirstSetSecondPlayer - 2 {
                                // Second player won first Set
                                currentMatch?.matchStatistics.currentSetPlayed = 2
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch?.matchStatistics.gamesFirstSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        } else {
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                // First Player won first Set
                                currentMatch?.matchStatistics.currentSetPlayed = 2
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer {
                                // Second Player won first Set
                                currentMatch?.matchStatistics.currentSetPlayed = 2
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch?.matchStatistics.gamesFirstSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        }
                    case 2:
                        if twoGamesDifference == true {
                            if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetSecondPlayer <= currentMatch!.matchStatistics.gamesSecondSetFirstPlayer - 2 {
                                // First player won second Set
                                
                                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 3
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                            } else if currentMatch!.matchStatistics.gamesSecondSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetFirstPlayer <= currentMatch!.matchStatistics.gamesSecondSetSecondPlayer - 2 {
                                // Second player won second Set
                                
                                if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 3
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                            } else if currentMatch?.matchStatistics.gamesSecondSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesSecondSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        } else {
                            if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                // First Player won second Set
                                
                                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 3
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                            } else if currentMatch!.matchStatistics.gamesSecondSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetSecondPlayer > currentMatch!.matchStatistics.gamesSecondSetFirstPlayer {
                                // Second Player won second Set
                                
                                if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 3
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                            } else if currentMatch?.matchStatistics.gamesSecondSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesSecondSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        }
                    case 3:
                        if twoGamesDifference == true {
                            if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetSecondPlayer <= currentMatch!.matchStatistics.gamesThirdSetFirstPlayer - 2 {
                                // First player won second Set
                                
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else if currentMatch!.matchStatistics.gamesThirdSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetFirstPlayer <= currentMatch!.matchStatistics.gamesThirdSetSecondPlayer - 2 {
                                // Second player won second Set
                                
                                gameSetMatch()
                                gameSetMatchIndication = true
                            }
                        } else {
                            if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                // First Player won second Set
                                
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else if currentMatch!.matchStatistics.gamesThirdSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetSecondPlayer > currentMatch!.matchStatistics.gamesThirdSetFirstPlayer {
                                // Second Player won second Set
                                
                                gameSetMatch()
                                gameSetMatchIndication = true
                            }
                        }
                    default:
                        break
                    }
                }
            case 5:
                // MARK: - Five Sets
                if currentMatch?.matchType.gamesInSet == 0 {
                    // Just tiebreak
                    if currentMatch?.matchStatistics.currentSetPlayed != 5 {
                        currentMatch?.matchStatistics.inTiebreak = true
                    }
                } else {
                    switch currentSet {
                    case 1:
                        if twoGamesDifference == true {
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer <= currentMatch!.matchStatistics.gamesFirstSetFirstPlayer - 2 {
                                // First player won first Set
                                currentMatch?.matchStatistics.currentSetPlayed = 2
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer <= currentMatch!.matchStatistics.gamesFirstSetSecondPlayer - 2 {
                                // Second player won first Set
                                currentMatch?.matchStatistics.currentSetPlayed = 2
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch?.matchStatistics.gamesFirstSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        } else {
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                // First Player won first Set
                                currentMatch?.matchStatistics.currentSetPlayed = 2
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer {
                                // Second Player won first Set
                                currentMatch?.matchStatistics.currentSetPlayed = 2
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch?.matchStatistics.gamesFirstSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        }
                    case 2:
                        if twoGamesDifference == true {
                            if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetSecondPlayer <= currentMatch!.matchStatistics.gamesSecondSetFirstPlayer - 2 {
                                // First player won second Set
                                
                                currentMatch?.matchStatistics.currentSetPlayed = 3
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch!.matchStatistics.gamesSecondSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetFirstPlayer <= currentMatch!.matchStatistics.gamesSecondSetSecondPlayer - 2 {
                                // Second player won second Set
                                
                                currentMatch?.matchStatistics.currentSetPlayed = 3
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch?.matchStatistics.gamesSecondSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesSecondSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        } else {
                            if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                // First Player won second Set
                                
                                currentMatch?.matchStatistics.currentSetPlayed = 3
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch!.matchStatistics.gamesSecondSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetSecondPlayer > currentMatch!.matchStatistics.gamesSecondSetFirstPlayer {
                                // Second Player won second Set
                                
                                currentMatch?.matchStatistics.currentSetPlayed = 3
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            } else if currentMatch?.matchStatistics.gamesSecondSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesSecondSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        }
                    case 3:
                        if twoGamesDifference == true {
                            if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetSecondPlayer <= currentMatch!.matchStatistics.gamesThirdSetFirstPlayer - 2 {
                                // First player won second Set
                                
                                var firstTeamWins = 0, secondTeamWins = 0
                                
                                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                
                                if firstTeamWins == 3 || secondTeamWins == 3 {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 4
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                                
                            } else if currentMatch!.matchStatistics.gamesThirdSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetFirstPlayer <= currentMatch!.matchStatistics.gamesThirdSetSecondPlayer - 2 {
                                // Second player won second Set
                                
                                var firstTeamWins = 0, secondTeamWins = 0
                                
                                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                
                                if firstTeamWins == 3 || secondTeamWins == 3 {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 4
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                            } else if currentMatch?.matchStatistics.gamesThirdSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesThirdSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        } else {
                            if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                // First Player won second Set
                                
                                var firstTeamWins = 0, secondTeamWins = 0
                                
                                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                
                                if firstTeamWins == 3 || secondTeamWins == 3 {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 4
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                            } else if currentMatch!.matchStatistics.gamesThirdSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetSecondPlayer > currentMatch!.matchStatistics.gamesThirdSetFirstPlayer {
                                // Second Player won second Set
                                
                                var firstTeamWins = 0, secondTeamWins = 0
                                
                                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                
                                if firstTeamWins == 3 || secondTeamWins == 3 {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 4
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                            } else if currentMatch?.matchStatistics.gamesThirdSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesThirdSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        }
                    case 4:
                        if twoGamesDifference == true {
                            if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFourthSetSecondPlayer <= currentMatch!.matchStatistics.gamesFourthSetFirstPlayer - 2 {
                                // First player won second Set
                                
                                var firstTeamWins = 0, secondTeamWins = 0
                                
                                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                
                                if firstTeamWins == 3 || secondTeamWins == 3 {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 5
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                                
                            } else if currentMatch!.matchStatistics.gamesFourthSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFourthSetFirstPlayer <= currentMatch!.matchStatistics.gamesFourthSetSecondPlayer - 2 {
                                // Second player won second Set
                                
                                var firstTeamWins = 0, secondTeamWins = 0
                                
                                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                
                                if firstTeamWins == 3 || secondTeamWins == 3 {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 5
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                            } else if currentMatch?.matchStatistics.gamesFourthSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesFourthSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        } else {
                            if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                                // First Player won second Set
                                
                                var firstTeamWins = 0, secondTeamWins = 0
                                
                                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                
                                if firstTeamWins == 3 || secondTeamWins == 3 {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 5
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                            } else if currentMatch!.matchStatistics.gamesFourthSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFourthSetSecondPlayer > currentMatch!.matchStatistics.gamesFourthSetFirstPlayer {
                                // Second Player won second Set
                                
                                var firstTeamWins = 0, secondTeamWins = 0
                                
                                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                                    firstTeamWins += 1
                                } else {
                                    secondTeamWins += 1
                                }
                                
                                if firstTeamWins == 3 || secondTeamWins == 3 {
                                    gameSetMatch()
                                    gameSetMatchIndication = true
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 5
                                    setJustFinished = true
                                    currentlyInSetbreak = true
                                    resetShotClock(withTime: 90)
                                }
                            } else if currentMatch?.matchStatistics.gamesFourthSetFirstPlayer == gamesToBePlayed && currentMatch?.matchStatistics.gamesFourthSetSecondPlayer == gamesToBePlayed {
                                // Tiebreak to be played
                                currentMatch?.matchStatistics.inTiebreak = true
                            }
                        }
                    case 5:
                        if twoGamesDifference == true {
                            if currentMatch!.matchStatistics.gamesFifthSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFifthSetSecondPlayer <= currentMatch!.matchStatistics.gamesFifthSetFirstPlayer - 2 {
                                // First player won second Set
                                
                                gameSetMatch()
                                gameSetMatchIndication = true
                                
                            } else if currentMatch!.matchStatistics.gamesFifthSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFifthSetFirstPlayer <= currentMatch!.matchStatistics.gamesFifthSetSecondPlayer - 2 {
                                // Second player won second Set
                                
                                gameSetMatch()
                                gameSetMatchIndication = true
                            }
                        } else {
                            if currentMatch!.matchStatistics.gamesFifthSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFifthSetFirstPlayer > currentMatch!.matchStatistics.gamesFifthSetSecondPlayer {
                                // First Player won second Set
                                
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else if currentMatch!.matchStatistics.gamesFifthSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFifthSetSecondPlayer > currentMatch!.matchStatistics.gamesFifthSetFirstPlayer {
                                // Second Player won second Set
                                
                                gameSetMatch()
                                gameSetMatchIndication = true
                            }
                        }
                    default:
                        break
                    }
                }
            default:
                break
            }
        } else if currentMatch?.matchType.advantageSet == 2 {
            // MARK: - Every Set Ad Set
            
            switch currentMatch?.matchType.totalSets {
            case 0:
                break
            case 1:
                // MARK: - One Set
                if twoGamesDifference == true {
                    if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer <= currentMatch!.matchStatistics.gamesFirstSetFirstPlayer - 2 {
                        // First player won
                        gameSetMatch()
                        gameSetMatchIndication = true
                    } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer <= currentMatch!.matchStatistics.gamesFirstSetSecondPlayer - 2 {
                        // Second player won
                        gameSetMatch()
                        gameSetMatchIndication = true
                    }
                } else {
                    if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                        // First Player won
                        gameSetMatch()
                        gameSetMatchIndication = true
                    } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer {
                        // Second Player won
                        gameSetMatch()
                        gameSetMatchIndication = true
                    }
                }
            case 3:
                // MARK: - Three Sets
                switch currentSet {
                case 1:
                    if twoGamesDifference == true {
                        if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer <= currentMatch!.matchStatistics.gamesFirstSetFirstPlayer - 2 {
                            // First player won first Set
                            currentMatch?.matchStatistics.currentSetPlayed = 2
                            setJustFinished = true
                            currentlyInSetbreak = true
                            resetShotClock(withTime: 90)
                        } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer <= currentMatch!.matchStatistics.gamesFirstSetSecondPlayer - 2 {
                            // Second player won first Set
                            currentMatch?.matchStatistics.currentSetPlayed = 2
                            setJustFinished = true
                            currentlyInSetbreak = true
                            resetShotClock(withTime: 90)
                        }
                    } else {
                        if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                            // First Player won first Set
                            currentMatch?.matchStatistics.currentSetPlayed = 2
                            setJustFinished = true
                            currentlyInSetbreak = true
                            resetShotClock(withTime: 90)
                        } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer {
                            // Second Player won first Set
                            currentMatch?.matchStatistics.currentSetPlayed = 2
                            setJustFinished = true
                            currentlyInSetbreak = true
                            resetShotClock(withTime: 90)
                        }
                    }
                case 2:
                    if twoGamesDifference == true {
                        if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetSecondPlayer <= currentMatch!.matchStatistics.gamesSecondSetFirstPlayer - 2 {
                            // First player won second Set
                            
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else {
                                currentMatch?.matchStatistics.currentSetPlayed = 3
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            }
                        } else if currentMatch!.matchStatistics.gamesSecondSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetFirstPlayer <= currentMatch!.matchStatistics.gamesSecondSetSecondPlayer - 2 {
                            // Second player won second Set
                            
                            if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer {
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else {
                                currentMatch?.matchStatistics.currentSetPlayed = 3
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            }
                        }
                    } else {
                        if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                            // First Player won second Set
                            
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else {
                                currentMatch?.matchStatistics.currentSetPlayed = 3
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            }
                        } else if currentMatch!.matchStatistics.gamesSecondSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetSecondPlayer > currentMatch!.matchStatistics.gamesSecondSetFirstPlayer {
                            // Second Player won second Set
                            
                            if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer {
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else {
                                currentMatch?.matchStatistics.currentSetPlayed = 3
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            }
                        }
                    }
                case 3:
                    if twoGamesDifference == true {
                        if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetSecondPlayer <= currentMatch!.matchStatistics.gamesThirdSetFirstPlayer - 2 {
                            // First player won second Set
                            
                            gameSetMatch()
                            gameSetMatchIndication = true
                        } else if currentMatch!.matchStatistics.gamesThirdSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetFirstPlayer <= currentMatch!.matchStatistics.gamesThirdSetSecondPlayer - 2 {
                            // Second player won second Set
                            
                            gameSetMatch()
                            gameSetMatchIndication = true
                        }
                    } else {
                        if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                            // First Player won second Set
                            
                            gameSetMatch()
                            gameSetMatchIndication = true
                        } else if currentMatch!.matchStatistics.gamesThirdSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetSecondPlayer > currentMatch!.matchStatistics.gamesThirdSetFirstPlayer {
                            // Second Player won second Set
                            
                            gameSetMatch()
                            gameSetMatchIndication = true
                        }
                    }
                default:
                    break
                }
                
            case 5:
                // MARK: - Five Sets
                switch currentSet {
                case 1:
                    if twoGamesDifference == true {
                        if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer <= currentMatch!.matchStatistics.gamesFirstSetFirstPlayer - 2 {
                            // First player won first Set
                            currentMatch?.matchStatistics.currentSetPlayed = 2
                            setJustFinished = true
                            currentlyInSetbreak = true
                            resetShotClock(withTime: 90)
                        } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer <= currentMatch!.matchStatistics.gamesFirstSetSecondPlayer - 2 {
                            // Second player won first Set
                            currentMatch?.matchStatistics.currentSetPlayed = 2
                            setJustFinished = true
                            currentlyInSetbreak = true
                            resetShotClock(withTime: 90)
                        }
                    } else {
                        if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                            // First Player won first Set
                            currentMatch?.matchStatistics.currentSetPlayed = 2
                            setJustFinished = true
                            currentlyInSetbreak = true
                            resetShotClock(withTime: 90)
                        } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer {
                            // Second Player won first Set
                            currentMatch?.matchStatistics.currentSetPlayed = 2
                            setJustFinished = true
                            currentlyInSetbreak = true
                            resetShotClock(withTime: 90)
                        }
                    }
                case 2:
                    if twoGamesDifference == true {
                        if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetSecondPlayer <= currentMatch!.matchStatistics.gamesSecondSetFirstPlayer - 2 {
                            // First player won second Set
                            
                            currentMatch?.matchStatistics.currentSetPlayed = 3
                            setJustFinished = true
                            currentlyInSetbreak = true
                            resetShotClock(withTime: 90)
                        } else if currentMatch!.matchStatistics.gamesSecondSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetFirstPlayer <= currentMatch!.matchStatistics.gamesSecondSetSecondPlayer - 2 {
                            // Second player won second Set
                            
                            currentMatch?.matchStatistics.currentSetPlayed = 3
                            setJustFinished = true
                            currentlyInSetbreak = true
                            resetShotClock(withTime: 90)
                        }
                    } else {
                        if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                            // First Player won second Set
                            
                            currentMatch?.matchStatistics.currentSetPlayed = 3
                            setJustFinished = true
                            currentlyInSetbreak = true
                            resetShotClock(withTime: 90)
                        } else if currentMatch!.matchStatistics.gamesSecondSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetSecondPlayer > currentMatch!.matchStatistics.gamesSecondSetFirstPlayer {
                            // Second Player won second Set
                            
                            currentMatch?.matchStatistics.currentSetPlayed = 3
                            setJustFinished = true
                            currentlyInSetbreak = true
                            resetShotClock(withTime: 90)
                        }
                    }
                case 3:
                    if twoGamesDifference == true {
                        if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetSecondPlayer <= currentMatch!.matchStatistics.gamesThirdSetFirstPlayer - 2 {
                            // First player won second Set
                            
                            var firstTeamWins = 0, secondTeamWins = 0
                            
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            
                            if firstTeamWins == 3 || secondTeamWins == 3 {
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else {
                                currentMatch?.matchStatistics.currentSetPlayed = 4
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            }
                            
                        } else if currentMatch!.matchStatistics.gamesThirdSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetFirstPlayer <= currentMatch!.matchStatistics.gamesThirdSetSecondPlayer - 2 {
                            // Second player won second Set
                            
                            var firstTeamWins = 0, secondTeamWins = 0
                            
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            
                            if firstTeamWins == 3 || secondTeamWins == 3 {
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else {
                                currentMatch?.matchStatistics.currentSetPlayed = 4
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            }
                        }
                    } else {
                        if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                            // First Player won second Set
                            
                            var firstTeamWins = 0, secondTeamWins = 0
                            
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            
                            if firstTeamWins == 3 || secondTeamWins == 3 {
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else {
                                currentMatch?.matchStatistics.currentSetPlayed = 4
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            }
                        } else if currentMatch!.matchStatistics.gamesThirdSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetSecondPlayer > currentMatch!.matchStatistics.gamesThirdSetFirstPlayer {
                            // Second Player won second Set
                            
                            var firstTeamWins = 0, secondTeamWins = 0
                            
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            
                            if firstTeamWins == 3 || secondTeamWins == 3 {
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else {
                                currentMatch?.matchStatistics.currentSetPlayed = 4
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            }
                        }
                    }
                case 4:
                    if twoGamesDifference == true {
                        if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFourthSetSecondPlayer <= currentMatch!.matchStatistics.gamesFourthSetFirstPlayer - 2 {
                            // First player won second Set
                            
                            var firstTeamWins = 0, secondTeamWins = 0
                            
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            
                            if firstTeamWins == 3 || secondTeamWins == 3 {
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else {
                                currentMatch?.matchStatistics.currentSetPlayed = 5
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            }
                            
                        } else if currentMatch!.matchStatistics.gamesFourthSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFourthSetFirstPlayer <= currentMatch!.matchStatistics.gamesFourthSetSecondPlayer - 2 {
                            // Second player won second Set
                            
                            var firstTeamWins = 0, secondTeamWins = 0
                            
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            
                            if firstTeamWins == 3 || secondTeamWins == 3 {
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else {
                                currentMatch?.matchStatistics.currentSetPlayed = 5
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            }
                        }
                    } else {
                        if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                            // First Player won second Set
                            
                            var firstTeamWins = 0, secondTeamWins = 0
                            
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            
                            if firstTeamWins == 3 || secondTeamWins == 3 {
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else {
                                currentMatch?.matchStatistics.currentSetPlayed = 5
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            }
                        } else if currentMatch!.matchStatistics.gamesFourthSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFourthSetSecondPlayer > currentMatch!.matchStatistics.gamesFourthSetFirstPlayer {
                            // Second Player won second Set
                            
                            var firstTeamWins = 0, secondTeamWins = 0
                            
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                                firstTeamWins += 1
                            } else {
                                secondTeamWins += 1
                            }
                            
                            if firstTeamWins == 3 || secondTeamWins == 3 {
                                gameSetMatch()
                                gameSetMatchIndication = true
                            } else {
                                currentMatch?.matchStatistics.currentSetPlayed = 5
                                setJustFinished = true
                                currentlyInSetbreak = true
                                resetShotClock(withTime: 90)
                            }
                        }
                    }
                case 5:
                    if twoGamesDifference == true {
                        if currentMatch!.matchStatistics.gamesFifthSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFifthSetSecondPlayer <= currentMatch!.matchStatistics.gamesFifthSetFirstPlayer - 2 {
                            // First player won second Set
                            
                            gameSetMatch()
                            gameSetMatchIndication = true
                            
                        } else if currentMatch!.matchStatistics.gamesFifthSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFifthSetFirstPlayer <= currentMatch!.matchStatistics.gamesFifthSetSecondPlayer - 2 {
                            // Second player won second Set
                            
                            gameSetMatch()
                            gameSetMatchIndication = true
                        }
                    } else {
                        if currentMatch!.matchStatistics.gamesFifthSetFirstPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFifthSetFirstPlayer > currentMatch!.matchStatistics.gamesFifthSetSecondPlayer {
                            // First Player won second Set
                            
                            gameSetMatch()
                            gameSetMatchIndication = true
                        } else if currentMatch!.matchStatistics.gamesFifthSetSecondPlayer >= gamesToBePlayed && currentMatch!.matchStatistics.gamesFifthSetSecondPlayer > currentMatch!.matchStatistics.gamesFifthSetFirstPlayer {
                            // Second Player won second Set
                            
                            gameSetMatch()
                            gameSetMatchIndication = true
                        }
                    }
                default:
                    break
                }
                
            default:
                break
            }
        }
        
        /*
        if currentMatch?.matchStatistics.currentSetPlayed == 1 {
            if teamWon == "firstTeam" {
                currentMatch?.matchStatistics.gamesFirstSetFirstPlayer += 1
                
                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer == 6 && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer <= 4 {
                    
                    if currentMatch?.matchType.totalSets == 1 {
                        gameSetMatch()
                    } else {
                        currentMatch?.matchStatistics.currentSetPlayed = 2
                    }
                } else if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer == 7 && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == 5 {
                    if currentMatch?.matchType.totalSets == 1 {
                        gameSetMatch()
                    } else {
                        currentMatch?.matchStatistics.currentSetPlayed = 2
                    }
                } else if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer == 6 && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == 6 {
                    /*
                        Tiebreak
                     */
                    
                    currentMatch?.matchStatistics.inTiebreak = true
                }
            } else {
                currentMatch?.matchStatistics.gamesFirstSetSecondPlayer += 1
                
                if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == 6 && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer <= 4 {
                    if currentMatch?.matchType.totalSets == 1 {
                        gameSetMatch()
                    } else {
                        currentMatch?.matchStatistics.currentSetPlayed = 2
                    }
                } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == 7 && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer == 5 {
                    if currentMatch?.matchType.totalSets == 1 {
                        gameSetMatch()
                    } else {
                        currentMatch?.matchStatistics.currentSetPlayed = 2
                    }
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

                    if currentMatch?.matchType.totalSets == 2 {
                        gameSetMatch()
                    } else {
                        currentMatch?.matchStatistics.currentSetPlayed = 3
                    }
                    
                    if currentMatch?.matchType.totalSets == 3 {
                        if (currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) && (currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) {
                            gameSetMatch()
                        }
                    }
                } else if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer == 7 && currentMatch!.matchStatistics.gamesSecondSetSecondPlayer == 5 {
                    if currentMatch?.matchType.totalSets == 2 {
                        gameSetMatch()
                    } else {
                        currentMatch?.matchStatistics.currentSetPlayed = 3
                    }
                    
                    if currentMatch?.matchType.totalSets == 3 {
                        if (currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) && (currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) {
                            gameSetMatch()
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
                    if currentMatch?.matchType.totalSets == 2 {
                        gameSetMatch()
                    } else {
                        currentMatch?.matchStatistics.currentSetPlayed = 3
                    }
                    
                    if currentMatch?.matchType.totalSets == 3 {
                        if (currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) && (currentMatch!.matchStatistics.gamesSecondSetSecondPlayer > currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) {
                            gameSetMatch()
                        }
                    }
                } else if currentMatch!.matchStatistics.gamesSecondSetSecondPlayer == 7 && currentMatch!.matchStatistics.gamesSecondSetFirstPlayer == 5 {
                    if currentMatch?.matchType.totalSets == 2 {
                        gameSetMatch()
                    } else {
                        currentMatch?.matchStatistics.currentSetPlayed = 3
                    }
                    
                    if currentMatch?.matchType.totalSets == 3 {
                        if (currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) && (currentMatch!.matchStatistics.gamesSecondSetSecondPlayer > currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) {
                            gameSetMatch()
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
                    if currentMatch?.matchType.totalSets == 3 {
                        gameSetMatch()
                    } else {
                        currentMatch?.matchStatistics.currentSetPlayed = 4
                    }
                    
                    if currentMatch?.matchType.totalSets == 3 {
                        if (currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) && (currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) {
                            gameSetMatch()
                        }
                    }
                } else if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer == 7 && currentMatch!.matchStatistics.gamesThirdSetSecondPlayer == 5 {
                    if currentMatch?.matchType.totalSets == 3 {
                        gameSetMatch()
                    } else {
                        currentMatch?.matchStatistics.currentSetPlayed = 4
                    }
                    
                    if currentMatch?.matchType.totalSets == 3 {
                        if (currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) && (currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) {
                            gameSetMatch()
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
                    if currentMatch?.matchType.totalSets == 3 {
                        gameSetMatch()
                    } else {
                        currentMatch?.matchStatistics.currentSetPlayed = 4
                    }
                    
                    if currentMatch?.matchType.totalSets == 3 {
                        if (currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) && (currentMatch!.matchStatistics.gamesSecondSetSecondPlayer > currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) {
                            gameSetMatch()
                        }
                    }
                } else if currentMatch!.matchStatistics.gamesThirdSetSecondPlayer == 7 && currentMatch!.matchStatistics.gamesThirdSetFirstPlayer == 5 {
                    if currentMatch?.matchType.totalSets == 3 {
                        gameSetMatch()
                    } else {
                        currentMatch?.matchStatistics.currentSetPlayed = 4
                    }
                    
                    if currentMatch?.matchType.totalSets == 3 {
                        if (currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) && (currentMatch!.matchStatistics.gamesSecondSetSecondPlayer > currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) {
                            gameSetMatch()
                        }
                    }
                } else if currentMatch!.matchStatistics.gamesThirdSetSecondPlayer == 6 && currentMatch!.matchStatistics.gamesThirdSetFirstPlayer == 6 {
                    /*
                        Tiebreak
                     */
                }
            }
        }
        
         */
        
        updateSetView()
        reorientatePlayerLabels()
         
    }
    
    func resetFaults() {
        firstFault = false
        currentMatch?.matchStatistics.firstFault = false
    }
    
    func triggerReadback(caller: String, message: String, fontSize: Int) {
        self.removeCurrentReadback()
        readbackVisible = true
        removeReadbackTask = DispatchWorkItem { self.removeCurrentReadback() }
        
        readbackView.alpha = 0.0
        readbackView.isHidden = false
        
        readbackLabel.font = readbackLabel.font.withSize(CGFloat(fontSize))
        readbackLabel.text = message
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
            self.readbackView.alpha = 0.9
        })
        
        if gameSetMatchIndication == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: removeReadbackTask!)
            
        }
    }
    
    func removeCurrentReadback() {
        
        if removeReadbackTask?.isCancelled == false{
            removeReadbackTask!.cancel()
        }
        
        if readbackVisible == true {
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
                self.readbackView.alpha = 0.0
            })
        }
        
    }
    
    @objc func shotclockTimerFired() {
        if shotclockTimerTime != 0 {
            shotclockTimerTime = shotclockTimerTime-1
            timerLabel.text = String(format: "%02d", shotclockTimerTime)
        } else {
            if currentlyInChangeOfEnds == true || currentlyInSetbreak == true{
                if noChangeOfEndsBreak == true {
                    justHadChangeOfEnds = false
                    currentlyInChangeOfEnds = false
                    currentlyInSetbreak = false
                    noChangeOfEndsBreak = false
                    shotclockTimer?.invalidate()
                    resetShotClock(withTime: 30)
                } else {
                    justHadChangeOfEnds = true
                    currentlyInChangeOfEnds = false
                    currentlyInSetbreak = false
                    noChangeOfEndsBreak = false
                    shotclockTimer?.invalidate()
                    resetShotClock(withTime: 30)
                }
            } else if justHadChangeOfEnds == true {
                justHadChangeOfEnds = false
                currentlyInChangeOfEnds = false
                currentlyInSetbreak = false
                noChangeOfEndsBreak = false
                shotclockTimer?.invalidate()
                resetShotClock(withTime: 25)
            } else {
                shotclockTimer?.invalidate()
                shotclockTimerRunning = false
                shotclockTimerInterrupted = false
                shotclockTimerTime = 25
            }
        }
    }
    
    @objc func singleTappedInTimerView(sender: UITapGestureRecognizer) {
        
        if sender.state == .recognized {
            
            timerLabel.text = String(format: "%02d", shotclockTimerTime)
            if shotclockTimerRunning == true {
                if shotclockTimerInterrupted == true {
                    shotclockTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(shotclockTimerFired), userInfo: nil, repeats: true)
                    shotclockTimerRunning = true
                    shotclockTimerInterrupted = false
                } else {
                    shotclockTimer?.invalidate()
                    if shotclockTimerTime != 0 {
                        shotclockTimerInterrupted = true
                    } else {
                        
                        if currentlyInChangeOfEnds == true || currentlyInSetbreak == true{
                            if noChangeOfEndsBreak == true {
                                justHadChangeOfEnds = false
                                currentlyInChangeOfEnds = false
                                currentlyInSetbreak = false
                                noChangeOfEndsBreak = false
                                resetShotClock(withTime: 30)
                            } else {
                                justHadChangeOfEnds = true
                                currentlyInChangeOfEnds = false
                                currentlyInSetbreak = false
                                noChangeOfEndsBreak = false
                                resetShotClock(withTime: 30)
                            }
                        } else if justHadChangeOfEnds == true {
                            justHadChangeOfEnds = false
                            currentlyInChangeOfEnds = false
                            currentlyInSetbreak = false
                            noChangeOfEndsBreak = false
                            resetShotClock(withTime: 25)
                        } else {
                            resetShotClock(withTime: 25)
                        }
                    }
                }
            } else {
                shotclockTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(shotclockTimerFired), userInfo: nil, repeats: true)
                shotclockTimerRunning = true
                shotclockTimerInterrupted = false
            }
        }
    }
    
    @objc func doubleTappedInTimerView(sender: UITapGestureRecognizer) {
        
        if sender.state == .recognized {
            
            if shotclockTimerRunning == true {
                if shotclockTimerInterrupted == true || currentlyInSetbreak == true{
                    if currentlyInChangeOfEnds == true {
                        if noChangeOfEndsBreak == true {
                            justHadChangeOfEnds = false
                            currentlyInChangeOfEnds = false
                            currentlyInSetbreak = false
                            noChangeOfEndsBreak = false
                            resetShotClock(withTime: 30)
                        } else {
                            justHadChangeOfEnds = true
                            currentlyInChangeOfEnds = false
                            currentlyInSetbreak = false
                            noChangeOfEndsBreak = false
                            resetShotClock(withTime: 30)
                        }
                    } else if justHadChangeOfEnds == true {
                        justHadChangeOfEnds = false
                        currentlyInChangeOfEnds = false
                        currentlyInSetbreak = false
                        noChangeOfEndsBreak = false
                        resetShotClock(withTime: 25)
                    } else {
                        resetShotClock(withTime: 25)
                    }
                } else {
                    shotclockTimer?.invalidate()
                    if currentlyInChangeOfEnds == true || currentlyInSetbreak == true{
                        if noChangeOfEndsBreak == true {
                            justHadChangeOfEnds = false
                            currentlyInChangeOfEnds = false
                            currentlyInSetbreak = false
                            noChangeOfEndsBreak = false
                            resetShotClock(withTime: 30)
                        } else {
                            justHadChangeOfEnds = true
                            currentlyInChangeOfEnds = false
                            currentlyInSetbreak = false
                            noChangeOfEndsBreak = false
                            resetShotClock(withTime: 30)
                        }
                    } else if justHadChangeOfEnds == true {
                        justHadChangeOfEnds = false
                        currentlyInChangeOfEnds = false
                        currentlyInSetbreak = false
                        noChangeOfEndsBreak = false
                        resetShotClock(withTime: 25)
                    } else {
                        resetShotClock(withTime: 25)
                    }
                }
            } else {
                if currentlyInChangeOfEnds == true || currentlyInSetbreak == true {
                    if noChangeOfEndsBreak == true {
                        justHadChangeOfEnds = false
                        currentlyInChangeOfEnds = false
                        currentlyInSetbreak = false
                        noChangeOfEndsBreak = false
                        resetShotClock(withTime: 30)
                    } else {
                        justHadChangeOfEnds = true
                        currentlyInChangeOfEnds = false
                        currentlyInSetbreak = false
                        noChangeOfEndsBreak = false
                        resetShotClock(withTime: 30)
                    }
                } else if justHadChangeOfEnds == true {
                    justHadChangeOfEnds = false
                    currentlyInChangeOfEnds = false
                    currentlyInSetbreak = false
                    noChangeOfEndsBreak = false
                    resetShotClock(withTime: 25)
                } else {
                    resetShotClock(withTime: 25)
                }
            }
        }
    }
    
    func resetShotClock(withTime: Int) {
        shotclockTimerInterrupted = false
        shotclockTimerRunning = false
        shotclockTimerTime = withTime
        timerLabel.text = "\(withTime)"
    }
    
    func resetChangeOfEndsShotClockData() {
        currentlyInChangeOfEnds = false
        currentlyInSetbreak = false
        noChangeOfEndsBreak = false
        justHadChangeOfEnds = false
    }
    
    func gameSetMatch() {
        switch currentMatch?.matchType.totalSets {
        case 1:
            currentMatch!.matchStatistics.matchFinishedTimeStamp = NSDate()
            currentMatch?.matchStatistics.matchFinished = true
            
            timer?.invalidate()
            let now = NSDate()
            var remainingTimeInterval: TimeInterval = now.timeIntervalSince(currentMatch!.matchStatistics.matchRestartTimeStamp as Date)
            remainingTimeInterval = remainingTimeInterval + currentMatch!.matchStatistics.matchTimeInterval
            
            currentMatch?.matchStatistics.matchTimeInterval = remainingTimeInterval
            
            currentMatch!.matchStatistics.matchRunning = false
            currentMatch!.matchStatistics.matchSuspended = false
            currentMatch!.matchStatistics.matchInterrupted = false
            pointStarted = false
            startOfPointButton.isHidden = true
            interactMatchButton.setTitle("Exit", for: .normal)
            interactMatchButton.backgroundColor = UIColor.systemGreen
            gameSetMatchIndication = true
            
            scoreLabel.text = "GAME SET MATCH"
            
            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                if currentMatch?.matchType.matchType == 0 {
                    currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.firstTeamFirstPlayer) \(currentMatch!.firstTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)"
                    triggerReadback(caller: "1904", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                } else {
                    currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.firstTeamFirstPlayerSurname) &  \(currentMatch!.firstTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)"
                    triggerReadback(caller: "1906", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                }
            } else {
                if currentMatch?.matchType.matchType == 0 {
                    currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.secondTeamFirstPlayer) \(currentMatch!.secondTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)"
                    triggerReadback(caller: "1910", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                } else {
                    currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.secondTeamFirstPlayerSurname) &  \(currentMatch!.secondTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)"
                    triggerReadback(caller: "1912", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                }
            }
        case 3:
            currentMatch!.matchStatistics.matchFinishedTimeStamp = NSDate()
            currentMatch?.matchStatistics.matchFinished = true
            
            timer?.invalidate()
            let now = NSDate()
            var remainingTimeInterval: TimeInterval = now.timeIntervalSince(currentMatch!.matchStatistics.matchRestartTimeStamp as Date)
            remainingTimeInterval = remainingTimeInterval + currentMatch!.matchStatistics.matchTimeInterval
            
            currentMatch?.matchStatistics.matchTimeInterval = remainingTimeInterval
            
            currentMatch!.matchStatistics.matchRunning = false
            currentMatch!.matchStatistics.matchSuspended = false
            currentMatch!.matchStatistics.matchInterrupted = false
            pointStarted = false
            startOfPointButton.isHidden = true
            interactMatchButton.setTitle("Exit", for: .normal)
            interactMatchButton.backgroundColor = UIColor.systemGreen
            gameSetMatchIndication = true
            
            scoreLabel.text = "GAME SET MATCH"
            
            if currentMatch?.matchStatistics.currentSetPlayed == 2 {
                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer && currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                    // First team winner
                    
                    if currentMatch?.matchType.matchType == 0 {
                        currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.firstTeamFirstPlayer) \(currentMatch!.firstTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)"
                        triggerReadback(caller: "1931", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                    } else {
                        currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.firstTeamFirstPlayerSurname) &  \(currentMatch!.firstTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)"
                        triggerReadback(caller: "1934", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                    }
                } else if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer < currentMatch!.matchStatistics.gamesFirstSetSecondPlayer && currentMatch!.matchStatistics.gamesSecondSetFirstPlayer < currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                    // Second team winner
                    
                    if currentMatch?.matchType.matchType == 0 {
                        currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.secondTeamFirstPlayer) \(currentMatch!.secondTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)"
                        triggerReadback(caller: "1942", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                    } else {
                        currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.secondTeamFirstPlayerSurname) &  \(currentMatch!.secondTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)"
                        triggerReadback(caller: "1944", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                    }
                }
            } else if currentMatch?.matchStatistics.currentSetPlayed == 3 {
                var firstTeamWins = 0, secondTeamWins = 0
                
                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                    firstTeamWins += 1
                } else {
                    secondTeamWins += 1
                }
                if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                    firstTeamWins += 1
                } else {
                    secondTeamWins += 1
                }
                if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                    firstTeamWins += 1
                } else {
                    secondTeamWins += 1
                }
                
                if firstTeamWins > secondTeamWins {
                    if currentMatch?.matchType.matchType == 0 {
                        currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.firstTeamFirstPlayer) \(currentMatch!.firstTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)"
                        triggerReadback(caller: "1968", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                    } else {
                        currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.firstTeamFirstPlayerSurname) &  \(currentMatch!.firstTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)"
                        triggerReadback(caller: "1970", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                    }
                } else {
                    if currentMatch?.matchType.matchType == 0 {
                        currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.secondTeamFirstPlayer) \(currentMatch!.secondTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)"
                        triggerReadback(caller: "1974", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                    } else {
                        currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.secondTeamFirstPlayerSurname) &  \(currentMatch!.secondTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)"
                        triggerReadback(caller: "1976", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                    }
                }
            }
        case 5:
            currentMatch!.matchStatistics.matchFinishedTimeStamp = NSDate()
            currentMatch?.matchStatistics.matchFinished = true
            
            timer?.invalidate()
            let now = NSDate()
            var remainingTimeInterval: TimeInterval = now.timeIntervalSince(currentMatch!.matchStatistics.matchRestartTimeStamp as Date)
            remainingTimeInterval = remainingTimeInterval + currentMatch!.matchStatistics.matchTimeInterval
            
            currentMatch?.matchStatistics.matchTimeInterval = remainingTimeInterval
            
            currentMatch!.matchStatistics.matchRunning = false
            currentMatch!.matchStatistics.matchSuspended = false
            currentMatch!.matchStatistics.matchInterrupted = false
            pointStarted = false
            startOfPointButton.isHidden = true
            interactMatchButton.setTitle("Exit", for: .normal)
            interactMatchButton.backgroundColor = UIColor.systemGreen
            gameSetMatchIndication = true
            
            scoreLabel.text = "GAME SET MATCH"
            
            switch currentMatch!.matchStatistics.currentSetPlayed {
            case 3:
                var firstTeamWins = 0, secondTeamWins = 0
                
                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                    firstTeamWins += 1
                } else {
                    secondTeamWins += 1
                }
                if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                    firstTeamWins += 1
                } else {
                    secondTeamWins += 1
                }
                if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                    firstTeamWins += 1
                } else {
                    secondTeamWins += 1
                }
                
                if firstTeamWins > secondTeamWins {
                    if currentMatch?.matchType.matchType == 0 {
                        currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.firstTeamFirstPlayer) \(currentMatch!.firstTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)"
                        triggerReadback(caller: "2012", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                    } else {
                        currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.firstTeamFirstPlayerSurname) &  \(currentMatch!.firstTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)"
                        triggerReadback(caller: "2014", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                    }
                } else {
                    if currentMatch?.matchType.matchType == 0 {
                        currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.secondTeamFirstPlayer) \(currentMatch!.secondTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)"
                        triggerReadback(caller: "2018", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                    } else {
                        currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.secondTeamFirstPlayerSurname) &  \(currentMatch!.secondTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)"
                        triggerReadback(caller: "2020", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                    }
                }
            case 4:
                var firstTeamWins = 0, secondTeamWins = 0
                
                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                    firstTeamWins += 1
                } else {
                    secondTeamWins += 1
                }
                if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                    firstTeamWins += 1
                } else {
                    secondTeamWins += 1
                }
                if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                    firstTeamWins += 1
                } else {
                    secondTeamWins += 1
                }
                if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                    firstTeamWins += 1
                } else {
                    secondTeamWins += 1
                }
                
                if firstTeamWins > secondTeamWins {
                    if currentMatch?.matchType.matchType == 0 {
                        currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.firstTeamFirstPlayer) \(currentMatch!.firstTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer) \(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)"
                        triggerReadback(caller: "2049", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                    } else {
                        currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.firstTeamFirstPlayerSurname) &  \(currentMatch!.firstTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer) \(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)"
                        triggerReadback(caller: "2051", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                    }
                } else {
                    if currentMatch?.matchType.matchType == 0 {
                        currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.secondTeamFirstPlayer) \(currentMatch!.secondTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer) \(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)"
                        triggerReadback(caller: "2055", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                    } else {
                        currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.secondTeamFirstPlayerSurname) &  \(currentMatch!.secondTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer) \(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)"
                        triggerReadback(caller: "2057", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                    }
                }
            case 5:
                var firstTeamWins = 0, secondTeamWins = 0
                
                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                    firstTeamWins += 1
                } else {
                    secondTeamWins += 1
                }
                if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                    firstTeamWins += 1
                } else {
                    secondTeamWins += 1
                }
                if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                    firstTeamWins += 1
                } else {
                    secondTeamWins += 1
                }
                if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                    firstTeamWins += 1
                } else {
                    secondTeamWins += 1
                }
                if currentMatch!.matchStatistics.gamesFifthSetFirstPlayer > currentMatch!.matchStatistics.gamesFifthSetSecondPlayer {
                    firstTeamWins += 1
                } else {
                    secondTeamWins += 1
                }
                
                if firstTeamWins > secondTeamWins {
                    if currentMatch?.matchType.matchType == 0 {
                        currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.firstTeamFirstPlayer) \(currentMatch!.firstTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer) \(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer) \(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer)"
                        triggerReadback(caller: "2091", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                    } else {
                        currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.firstTeamFirstPlayerSurname) &  \(currentMatch!.firstTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer) \(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer) \(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer)"
                        triggerReadback(caller: "2093", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                    }
                } else {
                    if currentMatch?.matchType.matchType == 0 {
                        currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.secondTeamFirstPlayer) \(currentMatch!.secondTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer) \(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer) \(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer)"
                        triggerReadback(caller: "2097", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                    } else {
                        currentMatch?.matchStatistics.winnerPhrase = "\(currentMatch!.secondTeamFirstPlayerSurname) &  \(currentMatch!.secondTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer) \(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer) \(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer)"
                        triggerReadback(caller: "2099", message: currentMatch!.matchStatistics.winnerPhrase, fontSize: 45)
                    }
                }
            default:
                break
            }
        default:
            break
        }
    }
    
    func operatePlayerInteraction(player: String) {
        
        if currentMatch?.matchType.matchType == 1 {
            performSegue(withIdentifier: "selectPlayerSegue", sender: self)
        } else {
            selectedPlayer = player
            performSegue(withIdentifier: "operatePlayerInteractionSegue", sender: self)
        }
    }
    
    func openCodeViolation(player: String) {
        selectedPlayer = player
        performSegue(withIdentifier: "selectCodeViolationSegue", sender: self)
    }
    
    func openTimeViolation(player: String) {
        selectedPlayer = player
        performSegue(withIdentifier: "clarifyTimeViolationPenaltySegue", sender: self)
    }
    
    func returnSelectedPlayer(player: String, furtherAction: String) {
        if furtherAction == "operatePlayerInteraction" {
            selectedPlayer = player
            
            performSegue(withIdentifier: "operatePlayerInteractionSegue", sender: self)
        }
    }
    
    func selctCodeViolation(player: String, violation: Int) {
        selectedPlayer = player
        selectedViolation = violation
        
        performSegue(withIdentifier: "clarifyCodeViolationPenaltySegue", sender: self)
    }
    
    func clarifyCodeViolation(player: String, violation: Int, penalty: Int) {
        selectedPlayer = player
        selectedViolation = violation
        selectedPenalty = penalty
        
        performSegue(withIdentifier: "validateCodeViolationSegue", sender: self)
    }
    
    func validateCodeViolation(player: String, violation: Int, penalty: Int) {
        /*
                Handle Code Violation
         */
        
        switch penalty {
        case 0:
            /*
                Warning
             */
            
            switch player {
            case "firstTeamFirstPlayer":
                currentMatch?.matchStatistics.firstTeamFirstPlayerCodeViolations += 1
                currentMatch?.matchStatistics.firstTeamFirstPlayerCodeViolationDescriptions.append(violation)
                currentMatch?.matchStatistics.firstTeamFirstPlayerCodeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.firstTeamFirstPlayerCodeViolationScoreStamps.append(evaluateCurrentScoreStamp())
            case "firstTeamSecondPlayer":
                currentMatch?.matchStatistics.firstTeamSecondPlayerCodeViolations += 1
                currentMatch?.matchStatistics.firstTeamSecondPlayerCodeViolationDescriptions.append(violation)
                currentMatch?.matchStatistics.firstTeamSecondPlayerCodeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.firstTeamSecondPlayerCodeViolationScoreStamps.append(evaluateCurrentScoreStamp())
            case "secondTeamFirstPlayer":
                currentMatch?.matchStatistics.secondTeamFirstPlayerCodeViolations += 1
                currentMatch?.matchStatistics.secondTeamFirstPlayerCodeViolationDescriptions.append(violation)
                currentMatch?.matchStatistics.secondTeamFirstPlayerCodeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.secondTeamFirstPlayerCodeViolationScoreStamps.append(evaluateCurrentScoreStamp())
            case "secondTeamSecondPlayer":
                currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolations += 1
                currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolationDescriptions.append(violation)
                currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolationScoreStamps.append(evaluateCurrentScoreStamp())
            default:
                break
            }
        case 1:
            /*
                Point Penalty
            */
        
            switch player {
            case "firstTeamFirstPlayer":
                currentMatch?.matchStatistics.firstTeamFirstPlayerCodeViolations += 1
                currentMatch?.matchStatistics.firstTeamFirstPlayerCodeViolationDescriptions.append(violation)
                currentMatch?.matchStatistics.firstTeamFirstPlayerCodeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.firstTeamFirstPlayerCodeViolationScoreStamps.append(evaluateCurrentScoreStamp())
                endOfPoint(team: 1)
            case "firstTeamSecondPlayer":
                currentMatch?.matchStatistics.firstTeamSecondPlayerCodeViolations += 1
                currentMatch?.matchStatistics.firstTeamSecondPlayerCodeViolationDescriptions.append(violation)
                currentMatch?.matchStatistics.firstTeamSecondPlayerCodeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.firstTeamSecondPlayerCodeViolationScoreStamps.append(evaluateCurrentScoreStamp())
                endOfPoint(team: 1)
            case "secondTeamFirstPlayer":
                currentMatch?.matchStatistics.secondTeamFirstPlayerCodeViolations += 1
                currentMatch?.matchStatistics.secondTeamFirstPlayerCodeViolationDescriptions.append(violation)
                currentMatch?.matchStatistics.secondTeamFirstPlayerCodeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.secondTeamFirstPlayerCodeViolationScoreStamps.append(evaluateCurrentScoreStamp())
                endOfPoint(team: 0)
            case "secondTeamSecondPlayer":
                currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolations += 1
                currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolationDescriptions.append(violation)
                currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolationScoreStamps.append(evaluateCurrentScoreStamp())
                endOfPoint(team: 0)
            default:
                break
            }
        case 2:
            /*
                Game Penalty
            */
        
            switch player {
            case "firstTeamFirstPlayer":
                currentMatch?.matchStatistics.firstTeamFirstPlayerCodeViolations += 1
                currentMatch?.matchStatistics.firstTeamFirstPlayerCodeViolationDescriptions.append(violation)
                currentMatch?.matchStatistics.firstTeamFirstPlayerCodeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.firstTeamFirstPlayerCodeViolationScoreStamps.append(evaluateCurrentScoreStamp())
                updateGames(teamWon: "secondTeam")
            case "firstTeamSecondPlayer":
                currentMatch?.matchStatistics.firstTeamSecondPlayerCodeViolations += 1
                currentMatch?.matchStatistics.firstTeamSecondPlayerCodeViolationDescriptions.append(violation)
                currentMatch?.matchStatistics.firstTeamSecondPlayerCodeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.firstTeamSecondPlayerCodeViolationScoreStamps.append(evaluateCurrentScoreStamp())
                updateGames(teamWon: "secondTeam")
            case "secondTeamFirstPlayer":
                currentMatch?.matchStatistics.secondTeamFirstPlayerCodeViolations += 1
                currentMatch?.matchStatistics.secondTeamFirstPlayerCodeViolationDescriptions.append(violation)
                currentMatch?.matchStatistics.secondTeamFirstPlayerCodeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.secondTeamFirstPlayerCodeViolationScoreStamps.append(evaluateCurrentScoreStamp())
                updateGames(teamWon: "firstTeam")
            case "secondTeamSecondPlayer":
                currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolations += 1
                currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolationDescriptions.append(violation)
                currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolationScoreStamps.append(evaluateCurrentScoreStamp())
                updateGames(teamWon: "firstTeam")
            default:
                break
            }
        case 3:
            /*
                Default
            */
        
            switch player {
            case "firstTeamFirstPlayer":
                currentMatch?.matchStatistics.firstTeamFirstPlayerCodeViolations += 1
                currentMatch?.matchStatistics.firstTeamFirstPlayerCodeViolationDescriptions.append(violation)
                currentMatch?.matchStatistics.firstTeamFirstPlayerCodeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.firstTeamFirstPlayerCodeViolationScoreStamps.append(evaluateCurrentScoreStamp())
                defaultPlayer(player: player)
            case "firstTeamSecondPlayer":
                currentMatch?.matchStatistics.firstTeamSecondPlayerCodeViolations += 1
                currentMatch?.matchStatistics.firstTeamSecondPlayerCodeViolationDescriptions.append(violation)
                currentMatch?.matchStatistics.firstTeamSecondPlayerCodeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.firstTeamSecondPlayerCodeViolationScoreStamps.append(evaluateCurrentScoreStamp())
                defaultPlayer(player: player)
            case "secondTeamFirstPlayer":
                currentMatch?.matchStatistics.secondTeamFirstPlayerCodeViolations += 1
                currentMatch?.matchStatistics.secondTeamFirstPlayerCodeViolationDescriptions.append(violation)
                currentMatch?.matchStatistics.secondTeamFirstPlayerCodeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.secondTeamFirstPlayerCodeViolationScoreStamps.append(evaluateCurrentScoreStamp())
                defaultPlayer(player: player)
            case "secondTeamSecondPlayer":
                currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolations += 1
                currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolationDescriptions.append(violation)
                currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolationScoreStamps.append(evaluateCurrentScoreStamp())
                defaultPlayer(player: player)
            default:
                break
            }
        default:
            break
        }
        
        visualizeViolations()
        
        selectedPlayer = ""
        selectedViolation = 0
        selectedPenalty = 0
    }
    
    func clarifyTimeViolation(player: String, penalty: Int) {
        selectedPlayer = player
        selectedPenalty = penalty
        
        performSegue(withIdentifier: "validateTimeViolationSegue", sender: self)
    }
    
    func validateTimeViolation(player: String, penalty: Int) {
        /*
                Handle Time Violation
         */
        
        switch penalty {
        case 0:
            /*
                Warning
             */
            
            switch player {
            case "firstTeamFirstPlayer":
                currentMatch?.matchStatistics.firstTeamFirstPlayerTimeViolations += 1
                currentMatch?.matchStatistics.firstTeamFirstPlayerTimeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.firstTeamFirstPlayerTimeViolationScoreStamps.append(evaluateCurrentScoreStamp())
            case "firstTeamSecondPlayer":
                currentMatch?.matchStatistics.firstTeamSecondPlayerTimeViolations += 1
                currentMatch?.matchStatistics.firstTeamSecondPlayerTimeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.firstTeamSecondPlayerTimeViolationScoreStamps.append(evaluateCurrentScoreStamp())
            case "secondTeamFirstPlayer":
                currentMatch?.matchStatistics.secondTeamFirstPlayerTimeViolations += 1
                currentMatch?.matchStatistics.secondTeamFirstPlayerTimeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.secondTeamFirstPlayerTimeViolationScoreStamps.append(evaluateCurrentScoreStamp())
            case "secondTeamSecondPlayer":
                currentMatch?.matchStatistics.secondTeamSecondPlayerTimeViolations += 1
                currentMatch?.matchStatistics.secondTeamSecondPlayerTimeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.secondTeamSecondPlayerTimeViolationScoreStamps.append(evaluateCurrentScoreStamp())
            default:
                break
            }
        case 1:
            /*
                Loss of Serve
            */
        
            switch player {
            case "firstTeamFirstPlayer":
                currentMatch?.matchStatistics.firstTeamFirstPlayerTimeViolations += 1
                currentMatch?.matchStatistics.firstTeamFirstPlayerTimeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.firstTeamFirstPlayerTimeViolationScoreStamps.append(evaluateCurrentScoreStamp())
                
                pointStarted = false
                startOfPointButton.isHidden = false
                
                shotclockTimer?.invalidate()
                resetChangeOfEndsShotClockData()
                resetShotClock(withTime: 25)
                
                var savedFault: Bool = false
                
                if firstFault == true {
                    savedFault = true
                }
                
                if currentMatch?.matchStatistics.isServer == "firstTeamFirst" || currentMatch?.matchStatistics.isServer == "firstTeamSecond" {
                    addFault(team: 0)
                }
                
                if savedFault == false {
                    triggerReadback(caller: "309", message: "Time Violation - Loss of Serve", fontSize: 60)
                } else {
                    
                    var currentSet: Int = currentMatch!.matchStatistics.currentSetPlayed
                    
                    if setJustFinished == true {
                        setJustFinished = false
                        currentSet -= 1
                    }
                    
                    if gameFinished == true && gameSetMatchIndication == false {
                        switch currentSet {
                        case 1:
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                triggerReadback(caller: "414", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)", fontSize: 100)
                            } else {
                                triggerReadback(caller: "416", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)", fontSize: 100)
                            }
                        case 2:
                            if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                triggerReadback(caller: "420", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)", fontSize: 100)
                            } else {
                                triggerReadback(caller: "422", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)", fontSize: 100)
                            }
                        case 3:
                            if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                triggerReadback(caller: "426", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)", fontSize: 100)
                            } else {
                                triggerReadback(caller: "428", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)", fontSize: 100)
                            }
                        case 4:
                            if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                                triggerReadback(caller: "432", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)", fontSize: 100)
                            } else {
                                triggerReadback(caller: "434", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)", fontSize: 100)
                            }
                        case 5:
                            if currentMatch!.matchStatistics.gamesFifthSetFirstPlayer > currentMatch!.matchStatistics.gamesFifthSetSecondPlayer {
                                triggerReadback(caller: "438", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer)", fontSize: 100)
                            } else {
                                triggerReadback(caller: "440", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer)", fontSize: 100)
                            }
                        default:
                            break
                        }
                        gameFinished = false
                    } else {
                        triggerReadback(caller: "392", message: "TV: LoS\n\(scoreLabel.text!)", fontSize: 100)
                    }
                }
                savedFault = false
                
            case "firstTeamSecondPlayer":
                currentMatch?.matchStatistics.firstTeamSecondPlayerTimeViolations += 1
                currentMatch?.matchStatistics.firstTeamSecondPlayerTimeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.firstTeamSecondPlayerTimeViolationScoreStamps.append(evaluateCurrentScoreStamp())
                
                pointStarted = false
                startOfPointButton.isHidden = false
                
                shotclockTimer?.invalidate()
                resetChangeOfEndsShotClockData()
                resetShotClock(withTime: 25)
                
                var savedFault: Bool = false
                
                if firstFault == true {
                    savedFault = true
                }
                
                if currentMatch?.matchStatistics.isServer == "firstTeamFirst" || currentMatch?.matchStatistics.isServer == "firstTeamSecond" {
                    addFault(team: 0)
                }
                
                if savedFault == false {
                    triggerReadback(caller: "309", message: "Time Violation - Loss of Serve", fontSize: 60)
                } else {
                    
                    var currentSet: Int = currentMatch!.matchStatistics.currentSetPlayed
                    
                    if setJustFinished == true {
                        setJustFinished = false
                        currentSet -= 1
                    }
                    
                    if gameFinished == true && gameSetMatchIndication == false {
                        switch currentSet {
                        case 1:
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                triggerReadback(caller: "414", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)", fontSize: 100)
                            } else {
                                triggerReadback(caller: "416", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)", fontSize: 100)
                            }
                        case 2:
                            if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                triggerReadback(caller: "420", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)", fontSize: 100)
                            } else {
                                triggerReadback(caller: "422", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)", fontSize: 100)
                            }
                        case 3:
                            if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                triggerReadback(caller: "426", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)", fontSize: 100)
                            } else {
                                triggerReadback(caller: "428", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)", fontSize: 100)
                            }
                        case 4:
                            if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                                triggerReadback(caller: "432", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)", fontSize: 100)
                            } else {
                                triggerReadback(caller: "434", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)", fontSize: 100)
                            }
                        case 5:
                            if currentMatch!.matchStatistics.gamesFifthSetFirstPlayer > currentMatch!.matchStatistics.gamesFifthSetSecondPlayer {
                                triggerReadback(caller: "438", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer)", fontSize: 100)
                            } else {
                                triggerReadback(caller: "440", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer)", fontSize: 100)
                            }
                        default:
                            break
                        }
                        gameFinished = false
                    } else {
                        triggerReadback(caller: "392", message: "TV: LoS\n\(scoreLabel.text!)", fontSize: 100)
                    }
                }
                savedFault = false
            case "secondTeamFirstPlayer":
                currentMatch?.matchStatistics.secondTeamFirstPlayerTimeViolations += 1
                currentMatch?.matchStatistics.secondTeamFirstPlayerTimeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.secondTeamFirstPlayerTimeViolationScoreStamps.append(evaluateCurrentScoreStamp())
                
                pointStarted = false
                startOfPointButton.isHidden = false
                
                shotclockTimer?.invalidate()
                resetChangeOfEndsShotClockData()
                resetShotClock(withTime: 25)
                
                var savedFault: Bool = false
                
                if firstFault == true {
                    savedFault = true
                }
                
                if currentMatch?.matchStatistics.isServer == "secondTeamFirst" || currentMatch?.matchStatistics.isServer == "secondTeamSecond" {
                    addFault(team: 1)
                }
                
                if savedFault == false {
                    triggerReadback(caller: "309", message: "Time Violation - Loss of Serve", fontSize: 60)
                } else {
                    
                    var currentSet: Int = currentMatch!.matchStatistics.currentSetPlayed
                    
                    if setJustFinished == true {
                        setJustFinished = false
                        currentSet -= 1
                    }
                    
                    if gameFinished == true && gameSetMatchIndication == false {
                        switch currentSet {
                        case 1:
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                triggerReadback(caller: "414", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)", fontSize: 100)
                            } else {
                                triggerReadback(caller: "416", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)", fontSize: 100)
                            }
                        case 2:
                            if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                triggerReadback(caller: "420", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)", fontSize: 100)
                            } else {
                                triggerReadback(caller: "422", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)", fontSize: 100)
                            }
                        case 3:
                            if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                triggerReadback(caller: "426", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)", fontSize: 100)
                            } else {
                                triggerReadback(caller: "428", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)", fontSize: 100)
                            }
                        case 4:
                            if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                                triggerReadback(caller: "432", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)", fontSize: 100)
                            } else {
                                triggerReadback(caller: "434", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)", fontSize: 100)
                            }
                        case 5:
                            if currentMatch!.matchStatistics.gamesFifthSetFirstPlayer > currentMatch!.matchStatistics.gamesFifthSetSecondPlayer {
                                triggerReadback(caller: "438", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer)", fontSize: 100)
                            } else {
                                triggerReadback(caller: "440", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer)", fontSize: 100)
                            }
                        default:
                            break
                        }
                        gameFinished = false
                    } else {
                        triggerReadback(caller: "392", message: "TV: LoS\n\(scoreLabel.text!)", fontSize: 100)
                    }
                }
                savedFault = false
            case "secondTeamSecondPlayer":
                currentMatch?.matchStatistics.secondTeamSecondPlayerTimeViolations += 1
                currentMatch?.matchStatistics.secondTeamSecondPlayerTimeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.secondTeamSecondPlayerTimeViolationScoreStamps.append(evaluateCurrentScoreStamp())
                
                pointStarted = false
                startOfPointButton.isHidden = false
                
                shotclockTimer?.invalidate()
                resetChangeOfEndsShotClockData()
                resetShotClock(withTime: 25)
                
                var savedFault: Bool = false
                
                if firstFault == true {
                    savedFault = true
                }
                
                if currentMatch?.matchStatistics.isServer == "secondTeamFirst" || currentMatch?.matchStatistics.isServer == "secondTeamSecond" {
                    addFault(team: 1)
                }
                
                if savedFault == false {
                    triggerReadback(caller: "309", message: "Time Violation - Loss of Serve", fontSize: 60)
                } else {
                    
                    var currentSet: Int = currentMatch!.matchStatistics.currentSetPlayed
                    
                    if setJustFinished == true {
                        setJustFinished = false
                        currentSet -= 1
                    }
                    
                    if gameFinished == true && gameSetMatchIndication == false {
                        switch currentSet {
                        case 1:
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                triggerReadback(caller: "414", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)", fontSize: 100)
                            } else {
                                triggerReadback(caller: "416", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)", fontSize: 100)
                            }
                        case 2:
                            if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                triggerReadback(caller: "420", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)", fontSize: 100)
                            } else {
                                triggerReadback(caller: "422", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)", fontSize: 100)
                            }
                        case 3:
                            if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                triggerReadback(caller: "426", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)", fontSize: 100)
                            } else {
                                triggerReadback(caller: "428", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)", fontSize: 100)
                            }
                        case 4:
                            if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                                triggerReadback(caller: "432", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)", fontSize: 100)
                            } else {
                                triggerReadback(caller: "434", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)", fontSize: 100)
                            }
                        case 5:
                            if currentMatch!.matchStatistics.gamesFifthSetFirstPlayer > currentMatch!.matchStatistics.gamesFifthSetSecondPlayer {
                                triggerReadback(caller: "438", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer)", fontSize: 100)
                            } else {
                                triggerReadback(caller: "440", message: "TV: LoS\n\(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer)", fontSize: 100)
                            }
                        default:
                            break
                        }
                        gameFinished = false
                    } else {
                        triggerReadback(caller: "392", message: "TV: LoS\n\(scoreLabel.text!)", fontSize: 100)
                    }
                }
                savedFault = false
            default:
                break
            }
        case 2:
            /*
                Point Penalty
            */
        
            switch player {
            case "firstTeamFirstPlayer":
                currentMatch?.matchStatistics.firstTeamFirstPlayerTimeViolations += 1
                currentMatch?.matchStatistics.firstTeamFirstPlayerTimeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.firstTeamFirstPlayerTimeViolationScoreStamps.append(evaluateCurrentScoreStamp())
                endOfPoint(team: 1)
            case "firstTeamSecondPlayer":
                currentMatch?.matchStatistics.firstTeamSecondPlayerTimeViolations += 1
                currentMatch?.matchStatistics.firstTeamSecondPlayerTimeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.firstTeamSecondPlayerTimeViolationScoreStamps.append(evaluateCurrentScoreStamp())
                endOfPoint(team: 1)
            case "secondTeamFirstPlayer":
                currentMatch?.matchStatistics.secondTeamFirstPlayerTimeViolations += 1
                currentMatch?.matchStatistics.secondTeamFirstPlayerTimeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.secondTeamFirstPlayerTimeViolationScoreStamps.append(evaluateCurrentScoreStamp())
                endOfPoint(team: 0)
            case "secondTeamSecondPlayer":
                currentMatch?.matchStatistics.secondTeamSecondPlayerTimeViolations += 1
                currentMatch?.matchStatistics.secondTeamSecondPlayerTimeViolationPenalties.append(penalty)
                currentMatch?.matchStatistics.secondTeamSecondPlayerTimeViolationScoreStamps.append(evaluateCurrentScoreStamp())
                endOfPoint(team: 0)
            default:
                break
            }
        default:
            break
        }
        
        visualizeViolations()
        
        selectedPlayer = ""
        selectedViolation = 0
        selectedPenalty = 0
    }
    
    func evaluateCurrentScoreStamp() -> ScoreStamp {
        let currentScoreStamp: ScoreStamp = ScoreStamp()
        
        switch currentMatch?.matchStatistics.currentSetPlayed {
        case 0:
            /*
                    No Set
            */
        
            if currentMatch?.matchStatistics.inTiebreak == true || currentMatch?.matchStatistics.matchTiebreak == true {
                currentScoreStamp.currentSet = 0
                currentScoreStamp.firstTeamCurrentTiebreakScore = currentMatch!.matchStatistics.justTiebreakPointsFirstPlayer
                currentScoreStamp.secondTeamCurrentTiebreakScore = currentMatch!.matchStatistics.justTiebreakPointsSecondPlayer
            }
        case 1:
            if currentMatch?.matchStatistics.inTiebreak == true || currentMatch?.matchStatistics.matchTiebreak == true {
                currentScoreStamp.currentSet = 1
                currentScoreStamp.firstTeamCurrentTiebreakScore = currentMatch!.matchStatistics.tiebreakFirstSetFirstPlayer
                currentScoreStamp.secondTeamCurrentTiebreakScore = currentMatch!.matchStatistics.tiebreakFirstSetSecondPlayer
            } else {
                currentScoreStamp.currentSet = 1
                currentScoreStamp.firstTeamCurrentGameScore = currentMatch!.matchStatistics.gamesFirstSetFirstPlayer
                currentScoreStamp.secondTeamCurrentGameScore = currentMatch!.matchStatistics.gamesFirstSetSecondPlayer
                currentScoreStamp.firstTeamCurrentInGameScore = currentMatch!.matchStatistics.currentGameFirstPlayer
                currentScoreStamp.secondTeamCurrentInGameScore = currentMatch!.matchStatistics.currentGameSecondPlayer
            }
        case 2:
            if currentMatch?.matchStatistics.inTiebreak == true || currentMatch?.matchStatistics.matchTiebreak == true {
                currentScoreStamp.currentSet = 2
                currentScoreStamp.firstTeamCurrentTiebreakScore = currentMatch!.matchStatistics.tiebreakSecondSetFirstPlayer
                currentScoreStamp.secondTeamCurrentTiebreakScore = currentMatch!.matchStatistics.tiebreakSecondSetSecondPlayer
            } else {
                currentScoreStamp.currentSet = 2
                currentScoreStamp.firstTeamCurrentGameScore = currentMatch!.matchStatistics.gamesSecondSetFirstPlayer
                currentScoreStamp.secondTeamCurrentGameScore = currentMatch!.matchStatistics.gamesSecondSetSecondPlayer
                currentScoreStamp.firstTeamCurrentInGameScore = currentMatch!.matchStatistics.currentGameFirstPlayer
                currentScoreStamp.secondTeamCurrentInGameScore = currentMatch!.matchStatistics.currentGameSecondPlayer
            }
        case 3:
            if currentMatch?.matchStatistics.inTiebreak == true || currentMatch?.matchStatistics.matchTiebreak == true {
                currentScoreStamp.currentSet = 3
                currentScoreStamp.firstTeamCurrentTiebreakScore = currentMatch!.matchStatistics.tiebreakThirdSetFirstPlayer
                currentScoreStamp.secondTeamCurrentTiebreakScore = currentMatch!.matchStatistics.tiebreakThirdSetSecondPlayer
            } else {
                currentScoreStamp.currentSet = 3
                currentScoreStamp.firstTeamCurrentGameScore = currentMatch!.matchStatistics.gamesThirdSetFirstPlayer
                currentScoreStamp.secondTeamCurrentGameScore = currentMatch!.matchStatistics.gamesThirdSetSecondPlayer
                currentScoreStamp.firstTeamCurrentInGameScore = currentMatch!.matchStatistics.currentGameFirstPlayer
                currentScoreStamp.secondTeamCurrentInGameScore = currentMatch!.matchStatistics.currentGameSecondPlayer
            }
        case 4:
            if currentMatch?.matchStatistics.inTiebreak == true || currentMatch?.matchStatistics.matchTiebreak == true {
                currentScoreStamp.currentSet = 4
                currentScoreStamp.firstTeamCurrentTiebreakScore = currentMatch!.matchStatistics.tiebreakFourthSetFirstPlayer
                currentScoreStamp.secondTeamCurrentTiebreakScore = currentMatch!.matchStatistics.tiebreakFourthSetSecondPlayer
            } else {
                currentScoreStamp.currentSet = 4
                currentScoreStamp.firstTeamCurrentGameScore = currentMatch!.matchStatistics.gamesFourthSetFirstPlayer
                currentScoreStamp.secondTeamCurrentGameScore = currentMatch!.matchStatistics.gamesFourthSetSecondPlayer
                currentScoreStamp.firstTeamCurrentInGameScore = currentMatch!.matchStatistics.currentGameFirstPlayer
                currentScoreStamp.secondTeamCurrentInGameScore = currentMatch!.matchStatistics.currentGameSecondPlayer
            }
        case 5:
            if currentMatch?.matchStatistics.inTiebreak == true || currentMatch?.matchStatistics.matchTiebreak == true {
                currentScoreStamp.currentSet = 5
                currentScoreStamp.firstTeamCurrentTiebreakScore = currentMatch!.matchStatistics.tiebreakFifthSetFirstPlayer
                currentScoreStamp.secondTeamCurrentTiebreakScore = currentMatch!.matchStatistics.tiebreakFifthSetSecondPlayer
            } else {
                currentScoreStamp.currentSet = 5
                currentScoreStamp.firstTeamCurrentGameScore = currentMatch!.matchStatistics.gamesFifthSetFirstPlayer
                currentScoreStamp.secondTeamCurrentGameScore = currentMatch!.matchStatistics.gamesFifthSetSecondPlayer
                currentScoreStamp.firstTeamCurrentInGameScore = currentMatch!.matchStatistics.currentGameFirstPlayer
                currentScoreStamp.secondTeamCurrentInGameScore = currentMatch!.matchStatistics.currentGameSecondPlayer
            }
        default:
            break
        }
        
        return currentScoreStamp
    }
    
    func defaultPlayer(player: String) {
        /*
                Default Player routine
         */
    }
    
    func visualizeViolations() {
        if currentMatch?.matchType.matchType == 0 {
            
            firstTeamNameIndicator.isHidden = true
            firstTeamUpperCVIndicator.isHidden = true
            firstTeamUpperTVIndicator.isHidden = true
            firstTeamUpperNameIndicator.isHidden = true
            
            secondTeamNameIndicator.isHidden = true
            secondTeamUpperCVIndicator.isHidden = true
            secondTeamUpperTVIndicator.isHidden = true
            secondTeamUpperNameIndicator.isHidden = true
            
            if currentMatch?.matchStatistics.onLeftSide == "firstTeam" {
                if currentMatch?.matchStatistics.firstTeamFirstPlayerCodeViolations != 0 || currentMatch?.matchStatistics.firstTeamFirstPlayerTimeViolations != 0 {
                    
                    firstTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerCodeViolations)"
                    firstTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerTimeViolations)"
                    
                    firstTeamCVIndicator.isHidden = false
                    firstTeamTVIndicator.isHidden = false
                } else {
                    firstTeamCVIndicator.isHidden = true
                    firstTeamTVIndicator.isHidden = true
                }
                
                if currentMatch?.matchStatistics.secondTeamFirstPlayerCodeViolations != 0 || currentMatch?.matchStatistics.secondTeamFirstPlayerTimeViolations != 0 {
                    
                    secondTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerCodeViolations)"
                    secondTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerTimeViolations)"
                    
                    secondTeamCVIndicator.isHidden = false
                    secondTeamTVIndicator.isHidden = false
                } else {
                    secondTeamCVIndicator.isHidden = true
                    secondTeamTVIndicator.isHidden = true
                }
            } else {
                if currentMatch?.matchStatistics.firstTeamFirstPlayerCodeViolations != 0 || currentMatch?.matchStatistics.firstTeamFirstPlayerTimeViolations != 0 {
                    
                    secondTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerCodeViolations)"
                    secondTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerTimeViolations)"
                    
                    secondTeamCVIndicator.isHidden = false
                    secondTeamTVIndicator.isHidden = false
                } else {
                    secondTeamCVIndicator.isHidden = true
                    secondTeamTVIndicator.isHidden = true
                }
                
                if currentMatch?.matchStatistics.secondTeamFirstPlayerCodeViolations != 0 || currentMatch?.matchStatistics.secondTeamFirstPlayerTimeViolations != 0 {
                    
                    firstTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerCodeViolations)"
                    firstTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerTimeViolations)"
                    
                    firstTeamCVIndicator.isHidden = false
                    firstTeamTVIndicator.isHidden = false
                } else {
                    firstTeamCVIndicator.isHidden = true
                    firstTeamTVIndicator.isHidden = true
                }
            }
        } else {
            /*
                    Doubles
             */
            
            /*
                    First Team
             */
            if currentMatch?.matchStatistics.onLeftSide == "firstTeam" {
                if currentMatch?.matchStatistics.firstTeamFirstPlayerCodeViolations != 0 || currentMatch?.matchStatistics.firstTeamFirstPlayerTimeViolations != 0 {
                    // First Player has CV/TV
                    
                    if currentMatch?.matchStatistics.firstTeamSecondPlayerCodeViolations != 0 || currentMatch?.matchStatistics.firstTeamSecondPlayerTimeViolations != 0 {
                        // Both players have CVs/TVs
                        
                        if ((firstTeamNameIndicator.text?.contains(currentMatch!.firstTeamFirstPlayerSurname)) != nil) {
                            firstTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerCodeViolations)"
                            firstTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerTimeViolations)"
                            firstTeamNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)"
                            currentMatch?.matchStatistics.firstTeamFirstPlayerViolationLower = true
                            
                            firstTeamUpperCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerCodeViolations)"
                            firstTeamUpperTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerTimeViolations)"
                            firstTeamUpperNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamSecondPlayerSurname)"
                            currentMatch?.matchStatistics.firstTeamSecondPlayerViolationLower = false
                        } else if ((firstTeamNameIndicator.text?.contains(currentMatch!.firstTeamSecondPlayerSurname)) != nil) {
                            firstTeamUpperCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerCodeViolations)"
                            firstTeamUpperTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerTimeViolations)"
                            firstTeamUpperNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)"
                            currentMatch?.matchStatistics.firstTeamFirstPlayerViolationLower = false
                            
                            firstTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerCodeViolations)"
                            firstTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerTimeViolations)"
                            firstTeamNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamSecondPlayerSurname)"
                            currentMatch?.matchStatistics.firstTeamSecondPlayerViolationLower = true
                        } else {
                            if currentMatch?.matchStatistics.firstTeamFirstPlayerViolationLower != currentMatch?.matchStatistics.firstTeamSecondPlayerViolationLower {
                                
                                if currentMatch?.matchStatistics.firstTeamFirstPlayerViolationLower == true {
                                    firstTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerCodeViolations)"
                                    firstTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerTimeViolations)"
                                    firstTeamNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)"
                                    currentMatch?.matchStatistics.firstTeamFirstPlayerViolationLower = true
                                    
                                    firstTeamUpperCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerCodeViolations)"
                                    firstTeamUpperTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerTimeViolations)"
                                    firstTeamUpperNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamSecondPlayerSurname)"
                                    currentMatch?.matchStatistics.firstTeamSecondPlayerViolationLower = false
                                } else {
                                    firstTeamUpperCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerCodeViolations)"
                                    firstTeamUpperTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerTimeViolations)"
                                    firstTeamUpperNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)"
                                    currentMatch?.matchStatistics.firstTeamFirstPlayerViolationLower = false
                                    
                                    firstTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerCodeViolations)"
                                    firstTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerTimeViolations)"
                                    firstTeamNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamSecondPlayerSurname)"
                                    currentMatch?.matchStatistics.firstTeamSecondPlayerViolationLower = true
                                }
                            } else {
                                firstTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerCodeViolations)"
                                firstTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerTimeViolations)"
                                firstTeamNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)"
                                currentMatch?.matchStatistics.firstTeamFirstPlayerViolationLower = true
                                
                                firstTeamUpperCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerCodeViolations)"
                                firstTeamUpperTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerTimeViolations)"
                                firstTeamUpperNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamSecondPlayerSurname)"
                                currentMatch?.matchStatistics.firstTeamSecondPlayerViolationLower = false
                            }
                        }
                    } else {
                        firstTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerCodeViolations)"
                        firstTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerTimeViolations)"
                        firstTeamNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)"
                    }
                } else {
                    if currentMatch?.matchStatistics.firstTeamSecondPlayerCodeViolations != 0 || currentMatch?.matchStatistics.firstTeamSecondPlayerTimeViolations != 0 {
                        firstTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerCodeViolations)"
                        firstTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerTimeViolations)"
                        firstTeamNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamSecondPlayerSurname)"
                    }
                }
                
                /*
                        Second Team
                 */
                
                if currentMatch?.matchStatistics.secondTeamFirstPlayerCodeViolations != 0 || currentMatch?.matchStatistics.secondTeamFirstPlayerTimeViolations != 0 {
                    // First Player has CV/TV
                    
                    if currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolations != 0 || currentMatch?.matchStatistics.secondTeamSecondPlayerTimeViolations != 0 {
                        // Both players have CVs/TVs
                        
                        if ((secondTeamNameIndicator.text?.contains(currentMatch!.secondTeamFirstPlayerSurname)) != nil) {
                            secondTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerCodeViolations)"
                            secondTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerTimeViolations)"
                            secondTeamNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)"
                            currentMatch?.matchStatistics.secondTeamFirstPlayerViolationLower = true
                            
                            secondTeamUpperCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerCodeViolations)"
                            secondTeamUpperTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerTimeViolations)"
                            secondTeamUpperNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamSecondPlayerSurname)"
                            currentMatch?.matchStatistics.secondTeamSecondPlayerViolationLower = false
                        } else if ((secondTeamNameIndicator.text?.contains(currentMatch!.secondTeamSecondPlayerSurname)) != nil) {
                            secondTeamUpperCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerCodeViolations)"
                            secondTeamUpperTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerTimeViolations)"
                            secondTeamUpperNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)"
                            currentMatch?.matchStatistics.secondTeamFirstPlayerViolationLower = false
                            
                            secondTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerCodeViolations)"
                            secondTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerTimeViolations)"
                            secondTeamNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamSecondPlayerSurname)"
                            currentMatch?.matchStatistics.secondTeamSecondPlayerViolationLower = true
                        } else {
                            if currentMatch?.matchStatistics.secondTeamFirstPlayerViolationLower != currentMatch?.matchStatistics.secondTeamSecondPlayerViolationLower {
                                
                                if currentMatch?.matchStatistics.secondTeamFirstPlayerViolationLower == true {
                                    secondTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerCodeViolations)"
                                    secondTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerTimeViolations)"
                                    secondTeamNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)"
                                    currentMatch?.matchStatistics.secondTeamFirstPlayerViolationLower = true
                                    
                                    secondTeamUpperCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerCodeViolations)"
                                    secondTeamUpperTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerTimeViolations)"
                                    secondTeamUpperNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamSecondPlayerSurname)"
                                    currentMatch?.matchStatistics.secondTeamSecondPlayerViolationLower = false
                                } else {
                                    secondTeamUpperCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerCodeViolations)"
                                    secondTeamUpperTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerTimeViolations)"
                                    secondTeamUpperNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)"
                                    currentMatch?.matchStatistics.secondTeamFirstPlayerViolationLower = false
                                    
                                    secondTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerCodeViolations)"
                                    secondTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerTimeViolations)"
                                    secondTeamNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamSecondPlayerSurname)"
                                    currentMatch?.matchStatistics.secondTeamSecondPlayerViolationLower = true
                                }
                            } else {
                                secondTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerCodeViolations)"
                                secondTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerTimeViolations)"
                                secondTeamNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)"
                                currentMatch?.matchStatistics.secondTeamFirstPlayerViolationLower = true
                                
                                secondTeamUpperCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerCodeViolations)"
                                secondTeamUpperTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerTimeViolations)"
                                secondTeamUpperNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamSecondPlayerSurname)"
                                currentMatch?.matchStatistics.secondTeamSecondPlayerViolationLower = false
                            }
                        }
                    } else {
                        secondTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerCodeViolations)"
                        secondTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerTimeViolations)"
                        secondTeamNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)"
                    }
                } else {
                    if currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolations != 0 || currentMatch?.matchStatistics.secondTeamSecondPlayerTimeViolations != 0 {
                        secondTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerCodeViolations)"
                        secondTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerTimeViolations)"
                        secondTeamNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamSecondPlayerSurname)"
                    }
                }
            } else {
                /*
                        First Team
                 */
                if currentMatch?.matchStatistics.firstTeamFirstPlayerCodeViolations != 0 || currentMatch?.matchStatistics.firstTeamFirstPlayerTimeViolations != 0 {
                    // First Player has CV/TV
                    
                    if currentMatch?.matchStatistics.firstTeamSecondPlayerCodeViolations != 0 || currentMatch?.matchStatistics.firstTeamSecondPlayerTimeViolations != 0 {
                        // Both players have CVs/TVs
                        
                        if ((secondTeamNameIndicator.text?.contains(currentMatch!.firstTeamFirstPlayerSurname)) != nil) {
                            secondTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerCodeViolations)"
                            secondTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerTimeViolations)"
                            secondTeamNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)"
                            currentMatch?.matchStatistics.firstTeamFirstPlayerViolationLower = true
                            
                            secondTeamUpperCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerCodeViolations)"
                            secondTeamUpperTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerTimeViolations)"
                            secondTeamUpperNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamSecondPlayerSurname)"
                            currentMatch?.matchStatistics.firstTeamSecondPlayerViolationLower = false
                        } else if ((secondTeamNameIndicator.text?.contains(currentMatch!.firstTeamSecondPlayerSurname)) != nil) {
                            secondTeamUpperCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerCodeViolations)"
                            secondTeamUpperTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerTimeViolations)"
                            secondTeamUpperNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)"
                            currentMatch?.matchStatistics.firstTeamFirstPlayerViolationLower = false
                            
                            secondTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerCodeViolations)"
                            secondTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerTimeViolations)"
                            secondTeamNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamSecondPlayerSurname)"
                            currentMatch?.matchStatistics.firstTeamSecondPlayerViolationLower = true
                        } else {
                            if currentMatch?.matchStatistics.firstTeamFirstPlayerViolationLower != currentMatch?.matchStatistics.firstTeamSecondPlayerViolationLower {
                                
                                if currentMatch?.matchStatistics.firstTeamFirstPlayerViolationLower == true {
                                    secondTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerCodeViolations)"
                                    secondTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerTimeViolations)"
                                    secondTeamNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)"
                                    currentMatch?.matchStatistics.firstTeamFirstPlayerViolationLower = true
                                    
                                    secondTeamUpperCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerCodeViolations)"
                                    secondTeamUpperTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerTimeViolations)"
                                    secondTeamUpperNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamSecondPlayerSurname)"
                                    currentMatch?.matchStatistics.firstTeamSecondPlayerViolationLower = false
                                } else {
                                    secondTeamUpperCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerCodeViolations)"
                                    secondTeamUpperTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerTimeViolations)"
                                    secondTeamUpperNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)"
                                    currentMatch?.matchStatistics.firstTeamFirstPlayerViolationLower = false
                                    
                                    secondTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerCodeViolations)"
                                    secondTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerTimeViolations)"
                                    secondTeamNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamSecondPlayerSurname)"
                                    currentMatch?.matchStatistics.firstTeamSecondPlayerViolationLower = true
                                }
                            } else {
                                secondTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerCodeViolations)"
                                secondTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerTimeViolations)"
                                secondTeamNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)"
                                currentMatch?.matchStatistics.firstTeamFirstPlayerViolationLower = true
                                
                                secondTeamUpperCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerCodeViolations)"
                                secondTeamUpperTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerTimeViolations)"
                                secondTeamUpperNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamSecondPlayerSurname)"
                                currentMatch?.matchStatistics.firstTeamSecondPlayerViolationLower = false
                            }
                        }
                    } else {
                        secondTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerCodeViolations)"
                        secondTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamFirstPlayerTimeViolations)"
                        secondTeamNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)"
                    }
                } else {
                    if currentMatch?.matchStatistics.firstTeamSecondPlayerCodeViolations != 0 || currentMatch?.matchStatistics.firstTeamSecondPlayerTimeViolations != 0 {
                        secondTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerCodeViolations)"
                        secondTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.firstTeamSecondPlayerTimeViolations)"
                        secondTeamNameIndicator.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamSecondPlayerSurname)"
                    }
                }
                
                /*
                        Second Team
                 */
                
                if currentMatch?.matchStatistics.secondTeamFirstPlayerCodeViolations != 0 || currentMatch?.matchStatistics.secondTeamFirstPlayerTimeViolations != 0 {
                    // First Player has CV/TV
                    
                    if currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolations != 0 || currentMatch?.matchStatistics.secondTeamSecondPlayerTimeViolations != 0 {
                        // Both players have CVs/TVs
                        
                        if ((firstTeamNameIndicator.text?.contains(currentMatch!.secondTeamFirstPlayerSurname)) != nil) {
                            firstTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerCodeViolations)"
                            firstTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerTimeViolations)"
                            firstTeamNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)"
                            currentMatch?.matchStatistics.secondTeamFirstPlayerViolationLower = true
                            
                            firstTeamUpperCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerCodeViolations)"
                            firstTeamUpperTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerTimeViolations)"
                            firstTeamUpperNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamSecondPlayerSurname)"
                            currentMatch?.matchStatistics.secondTeamSecondPlayerViolationLower = false
                        } else if ((firstTeamNameIndicator.text?.contains(currentMatch!.secondTeamSecondPlayerSurname)) != nil) {
                            firstTeamUpperCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerCodeViolations)"
                            firstTeamUpperTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerTimeViolations)"
                            firstTeamUpperNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)"
                            currentMatch?.matchStatistics.secondTeamFirstPlayerViolationLower = false
                            
                            firstTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerCodeViolations)"
                            firstTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerTimeViolations)"
                            firstTeamNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamSecondPlayerSurname)"
                            currentMatch?.matchStatistics.secondTeamSecondPlayerViolationLower = true
                        } else {
                            if currentMatch?.matchStatistics.secondTeamFirstPlayerViolationLower != currentMatch?.matchStatistics.secondTeamSecondPlayerViolationLower {
                                
                                if currentMatch?.matchStatistics.secondTeamFirstPlayerViolationLower == true {
                                    firstTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerCodeViolations)"
                                    firstTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerTimeViolations)"
                                    firstTeamNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)"
                                    currentMatch?.matchStatistics.secondTeamFirstPlayerViolationLower = true
                                    
                                    firstTeamUpperCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerCodeViolations)"
                                    firstTeamUpperTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerTimeViolations)"
                                    firstTeamUpperNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamSecondPlayerSurname)"
                                    currentMatch?.matchStatistics.secondTeamSecondPlayerViolationLower = false
                                } else {
                                    firstTeamUpperCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerCodeViolations)"
                                    firstTeamUpperTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerTimeViolations)"
                                    firstTeamUpperNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)"
                                    currentMatch?.matchStatistics.secondTeamFirstPlayerViolationLower = false
                                    
                                    firstTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerCodeViolations)"
                                    firstTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerTimeViolations)"
                                    firstTeamNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamSecondPlayerSurname)"
                                    currentMatch?.matchStatistics.secondTeamSecondPlayerViolationLower = true
                                }
                            } else {
                                firstTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerCodeViolations)"
                                firstTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerTimeViolations)"
                                firstTeamNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)"
                                currentMatch?.matchStatistics.secondTeamFirstPlayerViolationLower = true
                                
                                firstTeamUpperCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerCodeViolations)"
                                firstTeamUpperTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerTimeViolations)"
                                firstTeamUpperNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamSecondPlayerSurname)"
                                currentMatch?.matchStatistics.secondTeamSecondPlayerViolationLower = false
                            }
                        }
                    } else {
                        firstTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerCodeViolations)"
                        firstTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamFirstPlayerTimeViolations)"
                        firstTeamNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)"
                    }
                } else {
                    if currentMatch?.matchStatistics.secondTeamSecondPlayerCodeViolations != 0 || currentMatch?.matchStatistics.secondTeamSecondPlayerTimeViolations != 0 {
                        firstTeamCVIndicator.text = "CV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerCodeViolations)"
                        firstTeamTVIndicator.text = "TV: \(currentMatch!.matchStatistics.secondTeamSecondPlayerTimeViolations)"
                        firstTeamNameIndicator.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamSecondPlayerSurname)"
                    }
                }
            }
        }
    }
    
    func openMedicalTimeOut(player: String) {
        return
    }
    
    func openToilettBreak(player: String) {
        return
    }
    
    func openChangeOfAttire(player: String) {
        return
    }
    
    func openRetirement(player: String) {
        return
    }
}

extension MatchViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super .touchesBegan(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        let touchedPoint: CGPoint = touch.location(in: view)
        
        /*
                Check if readbackView was touched
         */
        
        if touchedPoint.x >= readbackView.frame.minX && touchedPoint.x <= readbackView.frame.maxX && touchedPoint.y >= readbackView.frame.minY && touchedPoint.y <= readbackView.frame.maxY {
            if readbackVisible == true {
                removeCurrentReadback()
            }
        }
        
        /*
                Check if first Team score was touched
         */
        
        if touchedPoint.x >= firstTeamScoreView.frame.minX && touchedPoint.x <= firstTeamScoreView.frame.maxX && touchedPoint.y >= firstTeamScoreView.frame.minY && touchedPoint.y <= firstTeamScoreView.frame.maxY {
            if readbackVisible == true {
                removeCurrentReadback()
            }
            
            touchedObject = firstTeamScoreView
            touchedObject?.backgroundColor = UIColor.init(red: 0/255, green: 35/255, blue: 33/255, alpha: 1)
                        
            selectedTeam = "firstTeam"

            if currentMatch?.matchType.matchType == 0 {
                if touchedObject != nil {
                    touchedObject?.backgroundColor = UIColor.init(red: 0/255, green: 23/255, blue: 21/255, alpha: 1)
                    touchedObject = nil
                }
                
                operatePlayerInteraction(player: "firstTeamFirstPlayer")
            } else {
                if touchedObject != nil {
                    touchedObject?.backgroundColor = UIColor.init(red: 0/255, green: 23/255, blue: 21/255, alpha: 1)
                    touchedObject = nil
                }
                
                performSegue(withIdentifier: "selectPlayerSegue", sender: self)
            }
        }
        
        /*
                Check if second Team score was touched
         */
        
        if touchedPoint.x >= secondTeamScoreView.frame.minX && touchedPoint.x <= secondTeamScoreView.frame.maxX && touchedPoint.y >= secondTeamScoreView.frame.minY && touchedPoint.y <= secondTeamScoreView.frame.maxY {
            if readbackVisible == true {
                removeCurrentReadback()
            }
            
            touchedObject = secondTeamScoreView
            touchedObject?.backgroundColor = UIColor.init(red: 0/255, green: 35/255, blue: 33/255, alpha: 1)
            
            selectedTeam = "secondTeam"

            if currentMatch?.matchType.matchType == 0 {
                if touchedObject != nil {
                    touchedObject?.backgroundColor = UIColor.init(red: 0/255, green: 23/255, blue: 21/255, alpha: 1)
                    touchedObject = nil
                }
                
                operatePlayerInteraction(player: "secondTeamFirstPlayer")
            } else {
                if touchedObject != nil {
                    touchedObject?.backgroundColor = UIColor.init(red: 0/255, green: 23/255, blue: 21/255, alpha: 1)
                    touchedObject = nil
                }
                
                performSegue(withIdentifier: "selectPlayerSegue", sender: self)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
                
        if touchedObject != nil {
            touchedObject?.backgroundColor = UIColor.init(red: 0/255, green: 23/255, blue: 21/255, alpha: 1)
            touchedObject = nil
        }
    }
}
