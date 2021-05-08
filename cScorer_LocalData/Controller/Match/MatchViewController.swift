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
    var readbackVisible: Bool = false
    var removeReadbackTask: DispatchWorkItem?
    var gameFinished: Bool = false
    
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
            
            triggerReadback(message: "MATCH STARTED", fontSize: 45)
            
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
            shotclockTimer?.invalidate()
            shotclockTimerRunning = false
            shotclockTimerInterrupted = false
            shotclockTimerTime = 25
            timerLabel.text = "00:25"
            
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
        
        removeCurrentReadback()
        
        shotclockTimer?.invalidate()
        shotclockTimerRunning = false
        shotclockTimerInterrupted = false
        shotclockTimerTime = 25
        timerLabel.text = "00:25"
        
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
        if currentMatch?.matchStatistics.matchRunning == true {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
            pointStarted = false
            startOfPointButton.isHidden = false
            
            resetFaults()
            triggerReadback(message: "ACE", fontSize: 60)
            
            shotclockTimer?.invalidate()
            shotclockTimerRunning = false
            shotclockTimerInterrupted = false
            shotclockTimerTime = 25
            timerLabel.text = "00:25"
            
            if currentMatch?.matchStatistics.isServer == "firstTeamFirst" || currentMatch?.matchStatistics.isServer == "firsTeamSecond" {
                endOfPoint(team: 0)
            } else {
                endOfPoint(team: 1)
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
            shotclockTimerRunning = false
            shotclockTimerInterrupted = false
            shotclockTimerTime = 25
            timerLabel.text = "00:25"
        
            if firstFault == false {
                triggerReadback(message: "NET - FIRST SERVE", fontSize: 45)
            } else {
                triggerReadback(message: "NET - SECOND SERVE", fontSize: 45)
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
            shotclockTimerRunning = false
            shotclockTimerInterrupted = false
            shotclockTimerTime = 25
            timerLabel.text = "00:25"
            
            var savedFault: Bool = false
            
            if firstFault == true {
                savedFault = true
            }
            
            if currentMatch?.matchStatistics.isServer == "firstTeamFirst" || currentMatch?.matchStatistics.isServer == "firsTeamSecond" {
                addFault(team: 0)
            } else {
                addFault(team: 1)
            }
            
            if savedFault == true {
                triggerReadback(message: "FAULT \n \(scoreLabel.text!)", fontSize: 45)
            } else {
                triggerReadback(message: "FAULT", fontSize: 60)
            }
            
            savedFault = false
        }
    }
    
    @IBAction func overruleButtonTapped(_ sender: UIButton) {
        if currentMatch?.matchStatistics.matchRunning == true {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
            currentMatch?.matchStatistics.totalOverrules+=1
            
            triggerReadback(message: "OVERRULE", fontSize: 60)
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
            shotclockTimerRunning = false
            shotclockTimerInterrupted = false
            shotclockTimerTime = 25
            timerLabel.text = "00:25"
            
            triggerReadback(message: "LET - REPLAY THE POINT", fontSize: 45)
        }
    }
    
    @IBAction func footfaultButtonTapped(_ sender: UIButton) {
        if currentMatch?.matchStatistics.matchRunning == true {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
            pointStarted = false
            startOfPointButton.isHidden = false
            
            shotclockTimer?.invalidate()
            shotclockTimerRunning = false
            shotclockTimerInterrupted = false
            shotclockTimerTime = 25
            timerLabel.text = "00:25"
            
            var savedFault: Bool = false
            
            if firstFault == true {
                savedFault = true
            }
            
            if currentMatch?.matchStatistics.isServer == "firstTeamFirst" || currentMatch?.matchStatistics.isServer == "firsTeamSecond" {
                addFault(team: 0)
            } else {
                addFault(team: 1)
            }
            
            if savedFault == true {
                triggerReadback(message: "FAULT \n \(scoreLabel.text!)", fontSize: 45)
            } else {
                triggerReadback(message: "FAULT", fontSize: 60)
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
            shotclockTimerRunning = false
            shotclockTimerInterrupted = false
            shotclockTimerTime = 25
            timerLabel.text = "00:25"

            if currentMatch?.matchStatistics.onLeftSide == "firstTeam" {
                endOfPoint(team: 0)
            } else {
                endOfPoint(team: 1)
            }
            
            if gameFinished == true {
                switch currentMatch?.matchStatistics.currentSetPlayed {
                case 1:
                    if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                        triggerReadback(message: "\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(message: "\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)", fontSize: 100)
                    }
                case 2:
                    if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                        triggerReadback(message: "\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(message: "\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)", fontSize: 100)
                    }
                case 3:
                    if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                        triggerReadback(message: "\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(message: "\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)", fontSize: 100)
                    }
                case 4:
                    if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                        triggerReadback(message: "\(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(message: "\(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)", fontSize: 100)
                    }
                case 5:
                    if currentMatch!.matchStatistics.gamesFifthSetFirstPlayer > currentMatch!.matchStatistics.gamesFifthSetSecondPlayer {
                        triggerReadback(message: "\(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(message: "\(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer)", fontSize: 100)
                    }
                default:
                    break
                }
                gameFinished = false
            } else {
                triggerReadback(message: scoreLabel.text!, fontSize: 100)
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
            shotclockTimerRunning = false
            shotclockTimerInterrupted = false
            shotclockTimerTime = 25
            timerLabel.text = "00:25"
            
            if currentMatch?.matchStatistics.onRightSide == "firstTeam" {
                endOfPoint(team: 0)
            } else {
                endOfPoint(team: 1)
            }
            
            if gameFinished == true {
                switch currentMatch?.matchStatistics.currentSetPlayed {
                case 1:
                    if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                        triggerReadback(message: "\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(message: "\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)", fontSize: 100)
                    }
                case 2:
                    if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                        triggerReadback(message: "\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(message: "\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)", fontSize: 100)
                    }
                case 3:
                    if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                        triggerReadback(message: "\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(message: "\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)", fontSize: 100)
                    }
                case 4:
                    if currentMatch!.matchStatistics.gamesFourthSetFirstPlayer > currentMatch!.matchStatistics.gamesFourthSetSecondPlayer {
                        triggerReadback(message: "\(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(message: "\(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)", fontSize: 100)
                    }
                case 5:
                    if currentMatch!.matchStatistics.gamesFifthSetFirstPlayer > currentMatch!.matchStatistics.gamesFifthSetSecondPlayer {
                        triggerReadback(message: "\(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer) - \(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer)", fontSize: 100)
                    } else {
                        triggerReadback(message: "\(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer) - \(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer)", fontSize: 100)
                    }
                default:
                    break
                }
                gameFinished = false
            } else {
                triggerReadback(message: scoreLabel.text!, fontSize: 100)
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
        
    }
    
    func initMatch() {
        startOfPointButton.isHidden = false
        
        currentMatch?.matchStatistics.isServer = "firstTeamFirst"
        currentMatch?.matchStatistics.onLeftSide = "firstTeam"
        currentMatch?.matchStatistics.onRightSide = "secondTeam"
        
        updateSetView()
        
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
        
        currentMatch?.matchStatistics.matchTimeInterval = remainingTimeInterval
                
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
    
    // MARK: - End Of Point Logic
    
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
    
    func endOfPoint(team: Int) {
        print(team)
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
                                
                                updateGames(teamWon: "firstTeam")
                            }
                        } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 50 {
                            currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                            currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                            
                            currentMatch?.matchStatistics.currentLeftNear = "first"
                            currentMatch?.matchStatistics.currentRightFar = "first"
                            
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
                                
                                updateGames(teamWon: "firstTeam")
                            }
                        } else if currentMatch?.matchStatistics.currentGameFirstPlayer == 50 {
                            currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                            currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                            
                            currentMatch?.matchStatistics.currentLeftNear = "first"
                            currentMatch?.matchStatistics.currentRightFar = "first"
                            
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
                                
                                updateGames(teamWon: "secondTeam")
                            }
                        } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 50 {
                            currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                            currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                            
                            currentMatch?.matchStatistics.currentLeftNear = "first"
                            currentMatch?.matchStatistics.currentRightFar = "first"
                            
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
                                
                                updateGames(teamWon: "secondTeam")
                            }
                        } else if currentMatch?.matchStatistics.currentGameSecondPlayer == 50 {
                            currentMatch?.matchStatistics.currentGameFirstPlayer = 0
                            currentMatch?.matchStatistics.currentGameSecondPlayer = 0
                            
                            currentMatch?.matchStatistics.currentLeftNear = "first"
                            currentMatch?.matchStatistics.currentRightFar = "first"
                            
                            updateGames(teamWon: "secondTeam")
                        }
                    }
                }
                
                updateScoreDisplay()
                reorientatePlayerLabels()
            }
            
        } else {
            // MARK: - Doubles
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
    
    func endGame(team: Int) {
        
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
            }
        } else {
            // Tiebreak changes
        }
        
        if currentMatch?.matchType.advantageSet == 0 {
            // No Ad Set
            print("no ad set")
            
            switch currentMatch?.matchType.totalSets {
            case 0:
                print("no set")
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
                            } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer <= currentMatch!.matchStatistics.gamesFirstSetSecondPlayer - 2 {
                                // Second player won
                                gameSetMatch()
                            }
                        } else {
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                // First Player won
                                gameSetMatch()
                            } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer {
                                // Second Player won
                                gameSetMatch()
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
                            } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer <= currentMatch!.matchStatistics.gamesFirstSetSecondPlayer - 2 {
                                // Second player won first Set
                                currentMatch?.matchStatistics.currentSetPlayed = 2
                            }
                        } else {
                            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                // First Player won first Set
                                currentMatch?.matchStatistics.currentSetPlayed = 2
                            } else if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer {
                                // Second Player won first Set
                                currentMatch?.matchStatistics.currentSetPlayed = 2
                            }
                        }
                    case 2:
                        if twoGamesDifference == true {
                            if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetSecondPlayer <= currentMatch!.matchStatistics.gamesSecondSetFirstPlayer - 2 {
                                // First player won second Set
                                
                                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                    gameSetMatch()
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 3
                                }
                            } else if currentMatch!.matchStatistics.gamesSecondSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetFirstPlayer <= currentMatch!.matchStatistics.gamesSecondSetSecondPlayer - 2 {
                                // Second player won second Set
                                
                                if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer {
                                    gameSetMatch()
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 3
                                }
                            }
                        } else {
                            if currentMatch!.matchStatistics.gamesSecondSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                                // First Player won second Set
                                
                                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                                    gameSetMatch()
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 3
                                }
                            } else if currentMatch!.matchStatistics.gamesSecondSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesSecondSetSecondPlayer > currentMatch!.matchStatistics.gamesSecondSetFirstPlayer {
                                // Second Player won second Set
                                
                                if currentMatch!.matchStatistics.gamesFirstSetSecondPlayer > currentMatch!.matchStatistics.gamesFirstSetFirstPlayer {
                                    gameSetMatch()
                                } else {
                                    currentMatch?.matchStatistics.currentSetPlayed = 3
                                }
                            }
                        }
                    case 3:
                        if twoGamesDifference == true {
                            if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetSecondPlayer <= currentMatch!.matchStatistics.gamesThirdSetFirstPlayer - 2 {
                                // First player won second Set
                                
                                gameSetMatch()
                            } else if currentMatch!.matchStatistics.gamesThirdSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetFirstPlayer <= currentMatch!.matchStatistics.gamesThirdSetSecondPlayer - 2 {
                                // Second player won second Set
                                
                                gameSetMatch()
                            }
                        } else {
                            if currentMatch!.matchStatistics.gamesThirdSetFirstPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetFirstPlayer > currentMatch!.matchStatistics.gamesThirdSetSecondPlayer {
                                // First Player won second Set
                                
                                gameSetMatch()
                            } else if currentMatch!.matchStatistics.gamesThirdSetSecondPlayer == gamesToBePlayed && currentMatch!.matchStatistics.gamesThirdSetSecondPlayer > currentMatch!.matchStatistics.gamesThirdSetFirstPlayer {
                                // Second Player won second Set
                                
                                gameSetMatch()
                            }
                        }
                    default:
                        break
                    }
                }
            case 5:
                // MARK: - Five Sets
                print("test")
            default:
                break
            }
        } else if currentMatch?.matchType.advantageSet == 1 {
            // Last Set Ad Set
        } else if currentMatch?.matchType.advantageSet == 2 {
            // Every Set Ad Set
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
    
    func triggerReadback(message: String, fontSize: Int) {
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: removeReadbackTask!)
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
            timerLabel.text = String(format: "00:%02d", shotclockTimerTime)
        } else {
            shotclockTimer?.invalidate()
            shotclockTimerRunning = false
            shotclockTimerInterrupted = false
            shotclockTimerTime = 25
        }
    }
    
    @objc func singleTappedInTimerView() {
        timerLabel.text = String(format: "00:%02d", shotclockTimerTime)
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
                    shotclockTimerInterrupted = false
                    shotclockTimerRunning = false
                    shotclockTimerTime = 25
                    timerLabel.text = "00:25"
                }
            }
        } else {
            shotclockTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(shotclockTimerFired), userInfo: nil, repeats: true)
            shotclockTimerRunning = true
            shotclockTimerInterrupted = false
        }
    }
    
    @objc func doubleTappedInTimerView() {
        if shotclockTimerRunning == true {
            if shotclockTimerInterrupted == true {
                shotclockTimerInterrupted = false
                shotclockTimerRunning = false
                shotclockTimerTime = 25
                timerLabel.text = "00:25"
            } else {
                shotclockTimer?.invalidate()
                shotclockTimerInterrupted = false
                shotclockTimerRunning = false
                shotclockTimerTime = 25
                timerLabel.text = "00:25"
            }
        } else {
            shotclockTimerInterrupted = false
            shotclockTimerRunning = false
            shotclockTimerTime = 25
            timerLabel.text = "00:25"
        }
    }
    
    func gameSetMatch() {
        print("called")
        switch currentMatch?.matchType.totalSets {
        case 1:
            print("1")
            currentMatch?.matchStatistics.matchFinishedTimeStamp = NSDate()
            timer?.invalidate()
            currentMatch?.matchStatistics.matchRunning = false
            currentMatch?.matchStatistics.matchSuspended = false
            currentMatch?.matchStatistics.matchInterrupted = false
            
            scoreLabel.text = "GAME SET MATCH"
            
            if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer {
                if currentMatch?.matchType.matchType == 0 {
                    triggerReadback(message: "\(currentMatch!.firstTeamFirstPlayer) \(currentMatch!.firstTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)", fontSize: 45)
                } else {
                    triggerReadback(message: "\(currentMatch!.firstTeamFirstPlayerSurname) &  \(currentMatch!.firstTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)", fontSize: 45)
                }
            } else {
                if currentMatch?.matchType.matchType == 0 {
                    triggerReadback(message: "\(currentMatch!.secondTeamFirstPlayer) \(currentMatch!.secondTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)", fontSize: 45)
                } else {
                    triggerReadback(message: "\(currentMatch!.secondTeamFirstPlayerSurname) &  \(currentMatch!.secondTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)", fontSize: 45)
                }
            }
        case 3:
            print("3")
            currentMatch?.matchStatistics.matchFinishedTimeStamp = NSDate()
            timer?.invalidate()
            currentMatch?.matchStatistics.matchRunning = false
            currentMatch?.matchStatistics.matchSuspended = false
            currentMatch?.matchStatistics.matchInterrupted = false
            
            scoreLabel.text = "GAME SET MATCH"
            
            if currentMatch?.matchStatistics.currentSetPlayed == 2 {
                if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer > currentMatch!.matchStatistics.gamesFirstSetSecondPlayer && currentMatch!.matchStatistics.gamesSecondSetFirstPlayer > currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                    // First team winner
                    
                    if currentMatch?.matchType.matchType == 0 {
                        triggerReadback(message: "\(currentMatch!.firstTeamFirstPlayer) \(currentMatch!.firstTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)", fontSize: 45)
                    } else {
                        triggerReadback(message: "\(currentMatch!.firstTeamFirstPlayerSurname) &  \(currentMatch!.firstTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)", fontSize: 45)
                    }
                } else if currentMatch!.matchStatistics.gamesFirstSetFirstPlayer < currentMatch!.matchStatistics.gamesFirstSetSecondPlayer && currentMatch!.matchStatistics.gamesSecondSetFirstPlayer < currentMatch!.matchStatistics.gamesSecondSetSecondPlayer {
                    // Second team winner
                    
                    if currentMatch?.matchType.matchType == 0 {
                        triggerReadback(message: "\(currentMatch!.secondTeamFirstPlayer) \(currentMatch!.secondTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)", fontSize: 45)
                    } else {
                        triggerReadback(message: "\(currentMatch!.secondTeamFirstPlayerSurname) &  \(currentMatch!.secondTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)", fontSize: 45)
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
                        triggerReadback(message: "\(currentMatch!.firstTeamFirstPlayer) \(currentMatch!.firstTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)", fontSize: 45)
                    } else {
                        triggerReadback(message: "\(currentMatch!.firstTeamFirstPlayerSurname) &  \(currentMatch!.firstTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)", fontSize: 45)
                    }
                } else {
                    if currentMatch?.matchType.matchType == 0 {
                        triggerReadback(message: "\(currentMatch!.secondTeamFirstPlayer) \(currentMatch!.secondTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)", fontSize: 45)
                    } else {
                        triggerReadback(message: "\(currentMatch!.secondTeamFirstPlayerSurname) &  \(currentMatch!.secondTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)", fontSize: 45)
                    }
                }
            }
        case 5:
            print("5")
            currentMatch?.matchStatistics.matchFinishedTimeStamp = NSDate()
            timer?.invalidate()
            currentMatch?.matchStatistics.matchRunning = false
            currentMatch?.matchStatistics.matchSuspended = false
            currentMatch?.matchStatistics.matchInterrupted = false
            
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
                        triggerReadback(message: "\(currentMatch!.firstTeamFirstPlayer) \(currentMatch!.firstTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)", fontSize: 45)
                    } else {
                        triggerReadback(message: "\(currentMatch!.firstTeamFirstPlayerSurname) &  \(currentMatch!.firstTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)", fontSize: 45)
                    }
                } else {
                    if currentMatch?.matchType.matchType == 0 {
                        triggerReadback(message: "\(currentMatch!.secondTeamFirstPlayer) \(currentMatch!.secondTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)", fontSize: 45)
                    } else {
                        triggerReadback(message: "\(currentMatch!.secondTeamFirstPlayerSurname) &  \(currentMatch!.secondTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)", fontSize: 45)
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
                        triggerReadback(message: "\(currentMatch!.firstTeamFirstPlayer) \(currentMatch!.firstTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer) \(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)", fontSize: 45)
                    } else {
                        triggerReadback(message: "\(currentMatch!.firstTeamFirstPlayerSurname) &  \(currentMatch!.firstTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer) \(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)", fontSize: 45)
                    }
                } else {
                    if currentMatch?.matchType.matchType == 0 {
                        triggerReadback(message: "\(currentMatch!.secondTeamFirstPlayer) \(currentMatch!.secondTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer) \(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)", fontSize: 45)
                    } else {
                        triggerReadback(message: "\(currentMatch!.secondTeamFirstPlayerSurname) &  \(currentMatch!.secondTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer) \(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)", fontSize: 45)
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
                        triggerReadback(message: "\(currentMatch!.firstTeamFirstPlayer) \(currentMatch!.firstTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer) \(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer) \(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer)", fontSize: 45)
                    } else {
                        triggerReadback(message: "\(currentMatch!.firstTeamFirstPlayerSurname) &  \(currentMatch!.firstTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer) \(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer) \(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer) \(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer) \(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer)-\(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer)", fontSize: 45)
                    }
                } else {
                    if currentMatch?.matchType.matchType == 0 {
                        triggerReadback(message: "\(currentMatch!.secondTeamFirstPlayer) \(currentMatch!.secondTeamFirstPlayerSurname)\n\(currentMatch!.matchStatistics.gamesFirstSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFirstSetFirstPlayer) \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer) \(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer) \(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer)", fontSize: 45)
                    } else {
                        triggerReadback(message: "\(currentMatch!.secondTeamFirstPlayerSurname) &  \(currentMatch!.secondTeamSecondPlayerSurname)\n\(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesSecondSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesSecondSetFirstPlayer) \(currentMatch!.matchStatistics.gamesThirdSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesThirdSetFirstPlayer) \(currentMatch!.matchStatistics.gamesFourthSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFourthSetFirstPlayer) \(currentMatch!.matchStatistics.gamesFifthSetSecondPlayer)-\(currentMatch!.matchStatistics.gamesFifthSetFirstPlayer)", fontSize: 45)
                    }
                }
            default:
                break
            }
        default:
            break
        }
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
    }
}
