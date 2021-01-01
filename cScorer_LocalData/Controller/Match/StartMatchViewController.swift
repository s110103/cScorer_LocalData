//
//  StartMatchViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 12.12.20.
//

import UIKit
import ProgressHUD

protocol StartMatchViewControllerDelegate {
    func sendStartMatchData(currentMatch: Match, selectedIndex: Int)
    func sendEditMatchFromStartMatch(currentMatch: Match, selectedIndex: Int)
}

class StartMatchViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, AddMatchViewControllerDelegate {
    
    // MARK: - Variables
    var selectedIndex: Int = 0
    var currentMatch: Match = Match()
    var delegate: StartMatchViewControllerDelegate?
        
    var isDragging: Bool = false
    var isDraggingServer: Bool = false
    var draggingPlayer: String = ""
    var finalLocation: CGPoint = CGPoint(x: 0, y: 0)
    var xOffset: CGFloat = 0
    var yOffset: CGFloat = 0
    var playerViewWidth: CGFloat = 0
    var playerViewHeight: CGFloat = 0
    var currentView: String?
    var currentPlayerName: String?
    var usingDummyView: Bool = false
    var isDummyServer: Bool = false
    var placeHolderServer: Bool = false
    var isEditingTossTextField: Bool = false
    var isEditingChoiceTextField: Bool = false
    
    var firstTeamFirstInitialLocation: CGPoint = CGPoint(x: 0, y: 0)
    var firstTeamSecondInitialLocation: CGPoint = CGPoint(x: 0, y: 0)
    var secondTeamFirstInitialLocation: CGPoint = CGPoint(x: 0, y: 0)
    var secondTeamSecondInitialLocation: CGPoint = CGPoint(x: 0, y: 0)
    var serverInitialLocation: CGPoint = CGPoint(x: 0, y: 0)
    var dummyViewInitialLocation: CGPoint = CGPoint(x: 0, y: 0)
    
    var containsPlayerFirstTeamFirstTarget: String = ""
    var containsPlayerFirstTeamSecondTarget: String = ""
    var containsPlayerSecondTeamFirstTarget: String = ""
    var containsPlayerSecondTeamSecondTarget: String = ""
    
    var containsServerFirstTeamFirst: Bool = false
    var containsServerFirstTeamSecond: Bool = false
    var containsServerSecondTeamFirst: Bool = false
    var containsServerSecondTeamSecond: Bool = false
    
    var pickerViewToss: UIPickerView = UIPickerView()
    var pickerViewChoice: UIPickerView = UIPickerView()
    
    var teamNames: [String] = []
    
    /*
        Timer
     */
    
    var timer: Timer?
    
    // MARK: - Outlets
    @IBOutlet weak var firstTeamFirstTopView: UIView!
    @IBOutlet weak var firstTeamFirstBottomView: UIView!
    @IBOutlet weak var firstTeamSecondTopView: UIView!
    @IBOutlet weak var firstTeamSecondBottomView: UIView!
    
    @IBOutlet weak var secondTeamFirstTopView: UIView!
    @IBOutlet weak var secondTeamFirstBottomView: UIView!
    @IBOutlet weak var secondTeamSecondTopView: UIView!
    @IBOutlet weak var secondTeamSecondBottomView: UIView!
    
    @IBOutlet weak var firstTeamFirstTopLabel: UILabel!
    @IBOutlet weak var firstTeamFirstBottomLabel: UILabel!
    @IBOutlet weak var firstTeamSecondTopLabel: UILabel!
    @IBOutlet weak var firstTeamSecondBottomLabel: UILabel!
    
    @IBOutlet weak var secondTeamFirstTopLabel: UILabel!
    @IBOutlet weak var secondTeamFirstBottomLabel: UILabel!
    @IBOutlet weak var secondTeamSecondTopLabel: UILabel!
    @IBOutlet weak var secondTeamSecondBottomLabel: UILabel!
    
    @IBOutlet weak var serverView: UIView!
    
    @IBOutlet weak var firstTeamFirstTargetBottomView: UIView!
    @IBOutlet weak var firstTeamSecondTargetBottomView: UIView!
    @IBOutlet weak var secondTeamFirstTargetBottomView: UIView!
    @IBOutlet weak var secondTeamSecondTargetBottomView: UIView!
    
    @IBOutlet weak var firstTeamFirstTargetTopView: UIView!
    @IBOutlet weak var firstTeamSecondTargetTopView: UIView!
    @IBOutlet weak var secondTeamFirstTargetTopView: UIView!
    @IBOutlet weak var secondTeamSecondTargetTopView: UIView!
    
    @IBOutlet weak var firstTeamFirstTargetTopLabel: UILabel!
    @IBOutlet weak var firstTeamSecondTargetTopLabel: UILabel!
    @IBOutlet weak var secondTeamFirstTargetTopLabel: UILabel!
    @IBOutlet weak var secondTeamSecondTargetTopLabel: UILabel!
    
    
    @IBOutlet weak var dummyView: UIView!
    @IBOutlet weak var dummyLabel: UILabel!
    
    @IBOutlet weak var tossWinnerTextField: UITextField!
    @IBOutlet weak var choiceMakerTextField: UITextField!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var warmupButton: UIButton!
    @IBOutlet weak var startMatchButton: UIButton!
        
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        pickerViewToss.delegate = self
        pickerViewToss.dataSource = self
        pickerViewChoice.delegate = self
        pickerViewChoice.dataSource = self
        
        initPlayers()
        initObjects()
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
        delegate?.sendStartMatchData(currentMatch: currentMatch, selectedIndex: selectedIndex)
    }
    @IBAction func infoButtonTapped(_ sender: UIButton) {
    }
    @IBAction func editMatchButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: false)
        delegate?.sendEditMatchFromStartMatch(currentMatch: currentMatch, selectedIndex: selectedIndex)
    }
    @IBAction func startButtonTapped(_ sender: UIButton) {
    }
    @IBAction func warmupButtonTapped(_ sender: UIButton) {
        
        restartButton.isHidden = false
        
        if warmupButton.title(for: .normal) == "Warmup"{
            currentMatch.matchStatistics.warmupStartedTimeStamp = NSDate()
            currentMatch.matchStatistics.warmupTimerRunning = true
            
            warmupButton.setTitle("Stop", for: .normal)
            
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startWarmupTimer), userInfo: nil, repeats: true)
        } else if warmupButton.title(for: .normal) == "Stop"{
            currentMatch.matchStatistics.warmupFinishedTimeStamp = NSDate()
            currentMatch.matchStatistics.warmupTimerRunning = false
            
            timer?.invalidate()
            
            warmupButton.setTitle("Neustart", for: .normal)
        } else if warmupButton.title(for: .normal) == "Neustart"{
            currentMatch.matchStatistics.warmupFinishedTimeStamp = NSDate()
            currentMatch.matchStatistics.warmupTimerRunning = true
                        
            warmupButton.setTitle("Stop", for: .normal)
        }
    }
    @IBAction func restartButtonTapped(_ sender: UIButton) {
        
        if currentMatch.matchStatistics.warmupTimerRunning == false {
            restartButton.isHidden = true
            timerLabel.text = "00:00:00"
            warmupButton.setTitle("Warmup", for: .normal)
        }
        currentMatch.matchStatistics.warmupStartedTimeStamp = NSDate()
    }
    
    // MARK: - Functions
    @objc func startWarmupTimer() {
        let now = NSDate()
        let remainingTimeInterval: TimeInterval = now.timeIntervalSince(currentMatch.matchStatistics.warmupStartedTimeStamp as Date)
                
        timerLabel.text = "\(remainingTimeInterval.format(using: [.hour, .minute, .second])!)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "editMatchSetupSegue":
            let destinationVC = segue.destination as! AddMatchViewController
            
            destinationVC.match = currentMatch
            destinationVC.editingDistinctMatch = true
            destinationVC.indexOfMatch = selectedIndex
            
            destinationVC.delegate = self
        default:
            return
        }
    }
    
    func initPlayers() {
        if currentMatch.matchType.matchType == 0 {
            
            teamNames.removeAll()
            teamNames.append("\(currentMatch.firstTeamFirstPlayerSurname) \(currentMatch.firstTeamFirstPlayer.prefix(1)).")
            teamNames.append("\(currentMatch.secondTeamFirstPlayerSurname) \(currentMatch.secondTeamFirstPlayer.prefix(1)).")
            
            firstTeamFirstTopView.isHidden = true
            firstTeamFirstBottomView.isHidden = true
            secondTeamFirstTopView.isHidden = true
            secondTeamFirstBottomView.isHidden = true
            
            firstTeamSecondTopView.isHidden = false
            firstTeamSecondBottomView.isHidden = false
            secondTeamSecondTopView.isHidden = false
            secondTeamSecondBottomView.isHidden = false
            
            firstTeamSecondTopLabel.text = "\(currentMatch.firstTeamFirstPlayerSurname) \(currentMatch.firstTeamFirstPlayer.prefix(1))."
            firstTeamSecondBottomLabel.text = "\(currentMatch.firstTeamFirstPlayerSurname) \(currentMatch.firstTeamFirstPlayer.prefix(1))."
            
            secondTeamSecondTopLabel.text = "\(currentMatch.secondTeamFirstPlayerSurname) \(currentMatch.secondTeamFirstPlayer.prefix(1))."
            secondTeamSecondBottomLabel.text = "\(currentMatch.secondTeamFirstPlayerSurname) \(currentMatch.secondTeamFirstPlayer.prefix(1))."
            
        } else {
            teamNames.removeAll()
            teamNames.append("\(currentMatch.firstTeamFirstPlayerSurname) \(currentMatch.firstTeamFirstPlayer.prefix(1)) & \(currentMatch.firstTeamSecondPlayerSurname) \(currentMatch.firstTeamSecondPlayer.prefix(1))")
            teamNames.append("\(currentMatch.secondTeamFirstPlayerSurname) \(currentMatch.secondTeamFirstPlayer.prefix(1)) & \(currentMatch.secondTeamSecondPlayerSurname) \(currentMatch.secondTeamSecondPlayer.prefix(1))")
            
            firstTeamFirstTopView.isHidden = false
            firstTeamFirstBottomView.isHidden = false
            secondTeamFirstTopView.isHidden = false
            secondTeamFirstBottomView.isHidden = false
            
            firstTeamSecondTopView.isHidden = false
            firstTeamSecondBottomView.isHidden = false
            secondTeamSecondTopView.isHidden = false
            secondTeamSecondBottomView.isHidden = false
            
            firstTeamFirstTopLabel.text = "\(currentMatch.firstTeamFirstPlayerSurname) \(currentMatch.firstTeamFirstPlayer.prefix(1))."
            firstTeamFirstBottomLabel.text = "\(currentMatch.firstTeamFirstPlayerSurname) \(currentMatch.firstTeamFirstPlayer.prefix(1))."
            
            firstTeamSecondTopLabel.text = "\(currentMatch.firstTeamSecondPlayerSurname) \(currentMatch.firstTeamSecondPlayer.prefix(1))."
            firstTeamSecondBottomLabel.text = "\(currentMatch.firstTeamSecondPlayerSurname) \(currentMatch.firstTeamSecondPlayer.prefix(1))."
            
            secondTeamFirstTopLabel.text = "\(currentMatch.secondTeamFirstPlayerSurname) \(currentMatch.secondTeamFirstPlayer.prefix(1))."
            secondTeamSecondBottomLabel.text = "\(currentMatch.secondTeamFirstPlayerSurname) \(currentMatch.secondTeamFirstPlayer.prefix(1))."
            
            secondTeamSecondTopLabel.text = "\(currentMatch.secondTeamSecondPlayerSurname) \(currentMatch.secondTeamSecondPlayer.prefix(1))."
            secondTeamSecondBottomLabel.text = "\(currentMatch.secondTeamSecondPlayerSurname) \(currentMatch.secondTeamSecondPlayer.prefix(1))."
        }
    }
    
    func initObjects() {
        firstTeamFirstTopView.isUserInteractionEnabled = true
        firstTeamSecondTopView.isUserInteractionEnabled = true
        secondTeamFirstTopView.isUserInteractionEnabled = true
        firstTeamSecondTopView.isUserInteractionEnabled = true
        serverView.isUserInteractionEnabled = true
        
        firstTeamFirstInitialLocation.x = firstTeamFirstTopView.frame.origin.x
        firstTeamFirstInitialLocation.y = firstTeamFirstTopView.frame.origin.y
        firstTeamSecondInitialLocation.x = firstTeamSecondTopView.frame.origin.x
        firstTeamSecondInitialLocation.y = firstTeamSecondTopView.frame.origin.y
        secondTeamFirstInitialLocation.x = secondTeamFirstTopView.frame.origin.x
        secondTeamFirstInitialLocation.y = secondTeamFirstTopView.frame.origin.y
        secondTeamSecondInitialLocation.x = secondTeamSecondTopView.frame.origin.x
        secondTeamSecondInitialLocation.y = secondTeamSecondTopView.frame.origin.y
        serverInitialLocation.x = serverView.frame.origin.x
        serverInitialLocation.y = serverView.frame.origin.y
        dummyViewInitialLocation.x = dummyView.frame.origin.x
        dummyViewInitialLocation.y = dummyView.frame.origin.y
        
        firstTeamFirstTargetBottomView.layer.borderWidth = 0
        firstTeamSecondTargetBottomView.layer.borderWidth = 0
        secondTeamFirstTargetBottomView.layer.borderWidth = 0
        secondTeamSecondTargetBottomView.layer.borderWidth = 0
        
        firstTeamFirstTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
        firstTeamSecondTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
        secondTeamFirstTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
        secondTeamSecondTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
        
        firstTeamFirstTargetTopView.isHidden = true
        firstTeamSecondTargetTopView.isHidden = true
        secondTeamFirstTargetTopView.isHidden = true
        secondTeamSecondTargetTopView.isHidden = true
        
        tossWinnerTextField.layer.borderWidth = 1
        tossWinnerTextField.layer.cornerRadius = 5
        tossWinnerTextField.layer.borderColor = UIColor(ciColor: .white).cgColor
        tossWinnerTextField.attributedPlaceholder = NSAttributedString(string: "Wahlgewinner", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        tossWinnerTextField.inputView = pickerViewToss
        
        choiceMakerTextField.layer.borderWidth = 1
        choiceMakerTextField.layer.cornerRadius = 5
        choiceMakerTextField.layer.borderColor = UIColor(ciColor: .white).cgColor
        choiceMakerTextField.attributedPlaceholder = NSAttributedString(string: "Entscheidung", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        choiceMakerTextField.inputView = pickerViewChoice
        
        serverView.layer.borderWidth = 2
        serverView.layer.cornerRadius = 5
        serverView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
        
        firstTeamFirstTopView.layer.cornerRadius = 5
        firstTeamFirstBottomView.layer.cornerRadius = 5
        firstTeamFirstTargetTopView.layer.cornerRadius = 5
        firstTeamFirstTargetBottomView.layer.cornerRadius = 5
        
        firstTeamSecondTopView.layer.cornerRadius = 5
        firstTeamSecondBottomView.layer.cornerRadius = 5
        firstTeamSecondTargetTopView.layer.cornerRadius = 5
        firstTeamSecondTargetBottomView.layer.cornerRadius = 5
        
        secondTeamFirstTopView.layer.cornerRadius = 5
        secondTeamFirstBottomView.layer.cornerRadius = 5
        secondTeamFirstTargetTopView.layer.cornerRadius = 5
        secondTeamFirstTargetBottomView.layer.cornerRadius = 5
        
        secondTeamSecondTopView.layer.cornerRadius = 5
        secondTeamSecondBottomView.layer.cornerRadius = 5
        secondTeamSecondTargetTopView.layer.cornerRadius = 5
        secondTeamSecondTargetBottomView.layer.cornerRadius = 5
        
        dummyView.layer.cornerRadius = 5
        dummyView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
        dummyView.layer.borderWidth = 0
        
        let wonTossRow: Int = currentMatch.matchStatistics.wonToss
        let madeChoiceRow: Int = currentMatch.matchStatistics.madeChoice
        
        if wonTossRow != 0 {
            self.pickerViewToss.selectRow(wonTossRow-1, inComponent: 0, animated: true)
            self.pickerView(self.pickerViewToss, didSelectRow: wonTossRow-1, inComponent: 0)
        }
        
        if madeChoiceRow != 0 {
            self.pickerViewChoice.selectRow(madeChoiceRow-1, inComponent: 0, animated: true)
            self.pickerView(self.pickerViewChoice, didSelectRow: madeChoiceRow-1, inComponent: 0)
        }
        
        playerViewWidth = firstTeamFirstTopView.frame.maxX - firstTeamFirstTopView.frame.minX
        playerViewHeight = firstTeamFirstTopView.frame.maxY - firstTeamFirstTopView.frame.minY
        
        startMatchButton.layer.cornerRadius = 5
        warmupButton.layer.cornerRadius = 5
        restartButton.layer.cornerRadius = 5
        
        if currentMatch.matchStatistics.warmupTimerRunning == false {
            restartButton.isHidden = true
        }
    }
        
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return teamNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
                
        if pickerView == pickerViewToss {
            
            var title: String = ""
            
            title = teamNames[row]
            currentMatch.matchStatistics.wonToss = row+1
            
            tossWinnerTextField.text = title
            tossWinnerTextField.resignFirstResponder()
        } else if pickerView == pickerViewChoice {
            
            var title: String = ""
            
            title = teamNames[row]
            currentMatch.matchStatistics.madeChoice = row+1
            
            choiceMakerTextField.text = title
            choiceMakerTextField.resignFirstResponder()
        }
    }
        
    // MARK: - touches BEGAN
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if tossWinnerTextField.isFirstResponder == true {
            tossWinnerTextField.text = teamNames[pickerViewToss.selectedRow(inComponent: 0)]
        }
        if choiceMakerTextField.isFirstResponder == true {
            choiceMakerTextField.text = teamNames[pickerViewChoice.selectedRow(inComponent: 0)]
        }
        
        view.endEditing(true)
        
        guard let touch = touches.first else {
            return
        }
        
        let touchedPoint: CGPoint = touch.location(in: view)
        
        let touchedView = receiveViewTouchedIn(touchedPoint: touchedPoint)
        
        if touchedView != "" {
            switch touchedView {
            case "firstTeamFirstBottomView":
                if firstTeamFirstTopView.isHidden == false {
                    currentView = touchedView
                }
            case "firstTeamSecondBottomView":
                if firstTeamSecondTopView.isHidden == false {
                    currentView = touchedView
                }
            case "secondTeamFirstBottomView":
                if secondTeamFirstTopView.isHidden == false {
                    currentView = touchedView
                }
            case "secondTeamSecondBottomView":
                if secondTeamSecondTopView.isHidden == false {
                    currentView = touchedView
                }
            case "firstTeamFirstTargetBottomView":
                if firstTeamFirstTargetTopView.isHidden == false {
                    currentView = touchedView
                }
            case "firstTeamSecondTargetBottomView":
                if firstTeamSecondTargetTopView.isHidden == false {
                    currentView = touchedView
                }
            case "secondTeamFirstTargetBottomView":
                if secondTeamFirstTargetTopView.isHidden == false {
                    currentView = touchedView
                }
            case "secondTeamSecondTargetBottomView":
                if secondTeamSecondTargetTopView.isHidden == false {
                    currentView = touchedView
                }
            case "serverView":
                currentView = touchedView
            default:
                currentView = ""
            }
        }
        
        if currentView != "" && currentView != "serverView" {
            
            if containsServerFirstTeamFirst == true {
                firstTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                firstTeamSecondTargetTopView.layer.borderColor = UIColor(ciColor: .green).cgColor
                secondTeamFirstTargetTopView.layer.borderColor = UIColor(ciColor: .green).cgColor
                secondTeamSecondTargetTopView.layer.borderColor = UIColor(ciColor: .green).cgColor
                
                firstTeamFirstTargetBottomView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                firstTeamSecondTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
                secondTeamFirstTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
                secondTeamSecondTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
            } else if containsServerFirstTeamSecond == true {
                firstTeamFirstTargetTopView.layer.borderColor = UIColor(ciColor: .green).cgColor
                firstTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                secondTeamFirstTargetTopView.layer.borderColor = UIColor(ciColor: .green).cgColor
                secondTeamSecondTargetTopView.layer.borderColor = UIColor(ciColor: .green).cgColor
                
                firstTeamFirstTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
                firstTeamSecondTargetBottomView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                secondTeamFirstTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
                secondTeamSecondTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
            } else if containsServerSecondTeamFirst == true {
                firstTeamFirstTargetTopView.layer.borderColor = UIColor(ciColor: .green).cgColor
                firstTeamSecondTargetTopView.layer.borderColor = UIColor(ciColor: .green).cgColor
                secondTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                secondTeamSecondTargetTopView.layer.borderColor = UIColor(ciColor: .green).cgColor
                
                firstTeamFirstTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
                firstTeamSecondTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
                secondTeamFirstTargetBottomView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                secondTeamSecondTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
            } else if containsServerSecondTeamSecond == true {
                firstTeamFirstTargetTopView.layer.borderColor = UIColor(ciColor: .green).cgColor
                firstTeamSecondTargetTopView.layer.borderColor = UIColor(ciColor: .green).cgColor
                secondTeamFirstTargetTopView.layer.borderColor = UIColor(ciColor: .green).cgColor
                secondTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                
                firstTeamFirstTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
                firstTeamSecondTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
                secondTeamFirstTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
                secondTeamSecondTargetBottomView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
            } else {
                firstTeamFirstTargetTopView.layer.borderColor = UIColor(ciColor: .green).cgColor
                firstTeamSecondTargetTopView.layer.borderColor = UIColor(ciColor: .green).cgColor
                secondTeamFirstTargetTopView.layer.borderColor = UIColor(ciColor: .green).cgColor
                secondTeamSecondTargetTopView.layer.borderColor = UIColor(ciColor: .green).cgColor
                
                firstTeamFirstTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
                firstTeamSecondTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
                secondTeamFirstTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
                secondTeamSecondTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
            }
            
            switch currentView {
            case "firstTeamFirstBottomView":
                let touchInView: CGPoint = touch.location(in: firstTeamFirstBottomView)
                
                isDragging = true
                firstTeamFirstTopView.isHidden = true
                
                xOffset = touchInView.x
                yOffset = touchInView.y
                
                dummyLabel.text = "\(firstTeamFirstTopLabel!.text ?? "nA")"
                dummyView.frame.origin.x = touchedPoint.x - xOffset
                dummyView.frame.origin.y = touchedPoint.y - yOffset
                
                if containsServerFirstTeamFirst == true {
                    dummyView.layer.borderWidth = 2
                    isDummyServer = true
                    containsServerFirstTeamFirst = false
                }
                
                dummyView.isHidden = false
                usingDummyView = true
            case "firstTeamSecondBottomView":
                let touchInView: CGPoint = touch.location(in: firstTeamSecondBottomView)
                
                isDragging = true
                firstTeamSecondTopView.isHidden = true
                
                xOffset = touchInView.x
                yOffset = touchInView.y
                
                dummyLabel.text = "\(firstTeamSecondTopLabel!.text ?? "nA")"
                dummyView.frame.origin.x = touchedPoint.x - xOffset
                dummyView.frame.origin.y = touchedPoint.y - yOffset
                
                if containsServerFirstTeamSecond == true {
                    dummyView.layer.borderWidth = 2
                    isDummyServer = true
                    containsServerFirstTeamSecond = false
                }
                
                dummyView.isHidden = false
                usingDummyView = true
            case "secondTeamFirstBottomView":
                let touchInView: CGPoint = touch.location(in: secondTeamFirstBottomView)
                
                isDragging = true
                secondTeamFirstTopView.isHidden = true
                
                xOffset = touchInView.x
                yOffset = touchInView.y
                
                dummyLabel.text = "\(secondTeamFirstTopLabel!.text ?? "nA")"
                dummyView.frame.origin.x = touchedPoint.x - xOffset
                dummyView.frame.origin.y = touchedPoint.y - yOffset
                
                if containsServerSecondTeamFirst == true {
                    dummyView.layer.borderWidth = 2
                    isDummyServer = true
                    containsServerSecondTeamFirst = false
                }
                
                dummyView.isHidden = false
                usingDummyView = true
            case "secondTeamSecondBottomView":
                let touchInView: CGPoint = touch.location(in: secondTeamSecondBottomView)
                
                isDragging = true
                secondTeamSecondTopView.isHidden = true
                
                xOffset = touchInView.x
                yOffset = touchInView.y
                
                dummyLabel.text = "\(secondTeamSecondTopLabel!.text ?? "nA")"
                dummyView.frame.origin.x = touchedPoint.x - xOffset
                dummyView.frame.origin.y = touchedPoint.y - yOffset
                
                if containsServerSecondTeamSecond == true {
                    dummyView.layer.borderWidth = 2
                    isDummyServer = true
                    containsServerSecondTeamSecond = false
                }
                
                dummyView.isHidden = false
                usingDummyView = true
            case "firstTeamFirstTargetBottomView":
                if containsPlayerFirstTeamFirstTarget != "" {
                    let touchInView: CGPoint = touch.location(in: firstTeamFirstTargetBottomView)
                    
                    isDragging = true
                    firstTeamFirstTargetTopView.isHidden = true
                    
                    xOffset = touchInView.x
                    yOffset = touchInView.y
                    
                    dummyLabel.text = "\(firstTeamFirstTargetTopLabel!.text ?? "nA")"
                    dummyView.frame.origin.x = touchedPoint.x - xOffset
                    dummyView.frame.origin.y = touchedPoint.y - yOffset
                    
                    if containsServerFirstTeamFirst == true {
                        dummyView.layer.borderWidth = 2
                        isDummyServer = true
                        containsServerFirstTeamFirst = false
                    }
                    
                    dummyView.isHidden = false
                    usingDummyView = true
                    
                    currentView = containsPlayerFirstTeamFirstTarget
                    containsPlayerFirstTeamFirstTarget = ""
                }
            case "firstTeamSecondTargetBottomView":
                if containsPlayerFirstTeamSecondTarget != "" {
                    let touchInView: CGPoint = touch.location(in: firstTeamSecondTargetBottomView)
                    
                    isDragging = true
                    firstTeamSecondTargetTopView.isHidden = true
                    
                    xOffset = touchInView.x
                    yOffset = touchInView.y
                    
                    dummyLabel.text = "\(firstTeamSecondTargetTopLabel!.text ?? "nA")"
                    dummyView.frame.origin.x = touchedPoint.x - xOffset
                    dummyView.frame.origin.y = touchedPoint.y - yOffset
                    
                    if containsServerFirstTeamSecond == true {
                        dummyView.layer.borderWidth = 2
                        isDummyServer = true
                        containsServerFirstTeamSecond = false
                    }
                    
                    dummyView.isHidden = false
                    usingDummyView = true
                    
                    currentView = containsPlayerFirstTeamSecondTarget
                    containsPlayerFirstTeamSecondTarget = ""
                }
            case "secondTeamFirstTargetBottomView":
                if containsPlayerSecondTeamFirstTarget != "" {
                    let touchInView: CGPoint = touch.location(in: secondTeamFirstTargetBottomView)
                    
                    isDragging = true
                    secondTeamFirstTargetTopView.isHidden = true
                    
                    xOffset = touchInView.x
                    yOffset = touchInView.y
                    
                    dummyLabel.text = "\(secondTeamFirstTargetTopLabel!.text ?? "nA")"
                    dummyView.frame.origin.x = touchedPoint.x - xOffset
                    dummyView.frame.origin.y = touchedPoint.y - yOffset
                    
                    if containsServerSecondTeamFirst == true {
                        dummyView.layer.borderWidth = 2
                        isDummyServer = true
                        containsServerSecondTeamFirst = false
                    }
                    
                    dummyView.isHidden = false
                    usingDummyView = true
                    
                    currentView = containsPlayerSecondTeamFirstTarget
                    containsPlayerSecondTeamFirstTarget = ""
                }
            case "secondTeamSecondTargetBottomView":
                if containsPlayerSecondTeamSecondTarget != "" {
                    let touchInView: CGPoint = touch.location(in: secondTeamSecondTargetBottomView)
                    
                    isDragging = true
                    secondTeamSecondTargetTopView.isHidden = true
                    
                    xOffset = touchInView.x
                    yOffset = touchInView.y
                    
                    dummyLabel.text = "\(secondTeamSecondTargetTopLabel!.text ?? "nA")"
                    dummyView.frame.origin.x = touchedPoint.x - xOffset
                    dummyView.frame.origin.y = touchedPoint.y - yOffset
                    
                    if containsServerSecondTeamSecond == true {
                        dummyView.layer.borderWidth = 2
                        isDummyServer = true
                        containsServerSecondTeamSecond = false
                    }
                    
                    dummyView.isHidden = false
                    usingDummyView = true
                    
                    currentView = containsPlayerSecondTeamSecondTarget
                    containsPlayerSecondTeamSecondTarget = ""
                }
            default:
                break
            }
            
            view.bringSubviewToFront(dummyView)
        } else if currentView != "" && currentView == "serverView" {
                        
            firstTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
            firstTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
            secondTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
            secondTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
            
            firstTeamFirstTargetBottomView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
            firstTeamSecondTargetBottomView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
            secondTeamFirstTargetBottomView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
            secondTeamSecondTargetBottomView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
            
            let touchInView: CGPoint = touch.location(in: serverView)
            
            xOffset = touchInView.x
            yOffset = touchInView.y
            
            isDraggingServer = true
            view.bringSubviewToFront(serverView)
        }
    }
    
    // MARK: - touches MOVED
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchedPoint: CGPoint = touch.location(in: view)
        
        if isDragging == true {
            if usingDummyView == true {
                
                let touchedView = receiveViewTouchedIn(touchedPoint: touchedPoint)
                
                switch touchedView {
                case "firstTeamFirstTargetBottomView":
                    if containsServerFirstTeamFirst == true {
                        firstTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        firstTeamFirstTargetTopView.layer.borderWidth = 2
                        
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    } else if containsServerFirstTeamSecond == true {
                        firstTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        firstTeamSecondTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 1
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 1
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    } else if containsServerSecondTeamFirst == true {
                        secondTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        secondTeamFirstTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 1
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 1
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    } else if containsServerSecondTeamSecond == true {
                        secondTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        secondTeamSecondTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 1
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 1
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
                    } else {
                        firstTeamFirstTargetTopView.layer.borderWidth = 1
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 1
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    }
                case "firstTeamSecondTargetBottomView":
                    if containsServerFirstTeamFirst == true {
                        firstTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        firstTeamFirstTargetTopView.layer.borderWidth = 2
                        
                        firstTeamSecondTargetTopView.layer.borderWidth = 1
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamSecondTargetBottomView.layer.borderWidth = 1
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    } else if containsServerFirstTeamSecond == true {
                        firstTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        firstTeamSecondTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    } else if containsServerSecondTeamFirst == true {
                        secondTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        secondTeamFirstTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        firstTeamSecondTargetTopView.layer.borderWidth = 1
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        firstTeamSecondTargetBottomView.layer.borderWidth = 1
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    } else if containsServerSecondTeamSecond == true {
                        secondTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        secondTeamSecondTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        firstTeamSecondTargetTopView.layer.borderWidth = 1
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        firstTeamSecondTargetBottomView.layer.borderWidth = 1
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
                    } else {
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        firstTeamSecondTargetTopView.layer.borderWidth = 1
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        firstTeamSecondTargetBottomView.layer.borderWidth = 1
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    }
                case "secondTeamFirstTargetBottomView":
                    if containsServerFirstTeamFirst == true {
                        firstTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        firstTeamFirstTargetTopView.layer.borderWidth = 2
                        
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 1
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 1
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    } else if containsServerFirstTeamSecond == true {
                        firstTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        firstTeamSecondTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 1
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 1
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    } else if containsServerSecondTeamFirst == true {
                        secondTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        secondTeamFirstTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    } else if containsServerSecondTeamSecond == true {
                        secondTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        secondTeamSecondTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 1
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 1
                    } else {
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 1
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 1
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    }
                case "secondTeamSecondTargetBottomView":
                    if containsServerFirstTeamFirst == true {
                        firstTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        firstTeamFirstTargetTopView.layer.borderWidth = 2
                        
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 1
                        
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 1
                    } else if containsServerFirstTeamSecond == true {
                        firstTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        firstTeamSecondTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 1
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 1
                    } else if containsServerSecondTeamFirst == true {
                        secondTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        secondTeamFirstTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 1
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 1
                    } else if containsServerSecondTeamSecond == true {
                        secondTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        secondTeamSecondTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
                    } else {
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 1
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 1
                    }
                default:
                    if containsServerFirstTeamFirst == true {
                        firstTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        firstTeamFirstTargetTopView.layer.borderWidth = 2
                        
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    } else if containsServerFirstTeamSecond == true {
                        firstTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        firstTeamSecondTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    } else if containsServerSecondTeamFirst == true {
                        secondTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        secondTeamFirstTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    } else if containsServerSecondTeamSecond == true {
                        secondTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        secondTeamSecondTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
                    } else {
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    }
                }
                
                dummyView.frame.origin.x = touchedPoint.x - xOffset
                dummyView.frame.origin.y = touchedPoint.y - yOffset
            } else {
                isDragging = false
                currentView = ""
            }
        }
        
        if isDraggingServer == true {
            
            let touchedView = receiveViewTouchedIn(touchedPoint: touchedPoint)
            
            switch touchedView {
            case "firstTeamFirstTargetBottomView":
                if containsPlayerFirstTeamFirstTarget != "" {
                    firstTeamFirstTargetTopView.layer.borderWidth = 2
                    firstTeamSecondTargetTopView.layer.borderWidth = 0
                    secondTeamFirstTargetTopView.layer.borderWidth = 0
                    secondTeamSecondTargetTopView.layer.borderWidth = 0
                    
                    firstTeamFirstTargetBottomView.layer.borderWidth = 2
                    firstTeamSecondTargetBottomView.layer.borderWidth = 0
                    secondTeamFirstTargetBottomView.layer.borderWidth = 0
                    secondTeamSecondTargetBottomView.layer.borderWidth = 0
                }
            case "firstTeamSecondTargetBottomView":
                if containsPlayerFirstTeamSecondTarget != "" {
                    firstTeamFirstTargetTopView.layer.borderWidth = 0
                    firstTeamSecondTargetTopView.layer.borderWidth = 2
                    secondTeamFirstTargetTopView.layer.borderWidth = 0
                    secondTeamSecondTargetTopView.layer.borderWidth = 0
                    
                    firstTeamFirstTargetBottomView.layer.borderWidth = 0
                    firstTeamSecondTargetBottomView.layer.borderWidth = 2
                    secondTeamFirstTargetBottomView.layer.borderWidth = 0
                    secondTeamSecondTargetBottomView.layer.borderWidth = 0
                }
            case "secondTeamFirstTargetBottomView":
                if containsPlayerSecondTeamFirstTarget != "" {
                    firstTeamFirstTargetTopView.layer.borderWidth = 0
                    firstTeamSecondTargetTopView.layer.borderWidth = 0
                    secondTeamFirstTargetTopView.layer.borderWidth = 2
                    secondTeamSecondTargetTopView.layer.borderWidth = 0
                    
                    firstTeamFirstTargetBottomView.layer.borderWidth = 0
                    firstTeamSecondTargetBottomView.layer.borderWidth = 0
                    secondTeamFirstTargetBottomView.layer.borderWidth = 2
                    secondTeamSecondTargetBottomView.layer.borderWidth = 0
                }
            case "secondTeamSecondTargetBottomView":
                if containsPlayerSecondTeamSecondTarget != "" {
                    firstTeamFirstTargetTopView.layer.borderWidth = 0
                    firstTeamSecondTargetTopView.layer.borderWidth = 0
                    secondTeamFirstTargetTopView.layer.borderWidth = 0
                    secondTeamSecondTargetTopView.layer.borderWidth = 2
                    
                    firstTeamFirstTargetBottomView.layer.borderWidth = 0
                    firstTeamSecondTargetBottomView.layer.borderWidth = 0
                    secondTeamFirstTargetBottomView.layer.borderWidth = 0
                    secondTeamSecondTargetBottomView.layer.borderWidth = 2
                }
            default:
                if containsServerFirstTeamFirst == true {
                    firstTeamFirstTargetTopView.layer.borderWidth = 2
                    firstTeamSecondTargetTopView.layer.borderWidth = 0
                    secondTeamFirstTargetTopView.layer.borderWidth = 0
                    secondTeamSecondTargetTopView.layer.borderWidth = 0
                    
                    firstTeamFirstTargetBottomView.layer.borderWidth = 2
                    firstTeamSecondTargetBottomView.layer.borderWidth = 0
                    secondTeamFirstTargetBottomView.layer.borderWidth = 0
                    secondTeamSecondTargetBottomView.layer.borderWidth = 0
                } else if containsServerFirstTeamSecond == true {
                    firstTeamFirstTargetTopView.layer.borderWidth = 0
                    firstTeamSecondTargetTopView.layer.borderWidth = 2
                    secondTeamFirstTargetTopView.layer.borderWidth = 0
                    secondTeamSecondTargetTopView.layer.borderWidth = 0
                    
                    firstTeamFirstTargetBottomView.layer.borderWidth = 0
                    firstTeamSecondTargetBottomView.layer.borderWidth = 2
                    secondTeamFirstTargetBottomView.layer.borderWidth = 0
                    secondTeamSecondTargetBottomView.layer.borderWidth = 0
                } else if containsServerSecondTeamFirst == true {
                    firstTeamFirstTargetTopView.layer.borderWidth = 0
                    firstTeamSecondTargetTopView.layer.borderWidth = 0
                    secondTeamFirstTargetTopView.layer.borderWidth = 2
                    secondTeamSecondTargetTopView.layer.borderWidth = 0
                    
                    firstTeamFirstTargetBottomView.layer.borderWidth = 0
                    firstTeamSecondTargetBottomView.layer.borderWidth = 0
                    secondTeamFirstTargetBottomView.layer.borderWidth = 2
                    secondTeamSecondTargetBottomView.layer.borderWidth = 0
                } else if containsServerSecondTeamSecond == true {
                    firstTeamFirstTargetTopView.layer.borderWidth = 0
                    firstTeamSecondTargetTopView.layer.borderWidth = 0
                    secondTeamFirstTargetTopView.layer.borderWidth = 0
                    secondTeamSecondTargetTopView.layer.borderWidth = 2
                    
                    firstTeamFirstTargetBottomView.layer.borderWidth = 0
                    firstTeamSecondTargetBottomView.layer.borderWidth = 0
                    secondTeamFirstTargetBottomView.layer.borderWidth = 0
                    secondTeamSecondTargetBottomView.layer.borderWidth = 2
                } else {
                    firstTeamFirstTargetTopView.layer.borderWidth = 0
                    firstTeamSecondTargetTopView.layer.borderWidth = 0
                    secondTeamFirstTargetTopView.layer.borderWidth = 0
                    secondTeamSecondTargetTopView.layer.borderWidth = 0
                    
                    firstTeamFirstTargetBottomView.layer.borderWidth = 0
                    firstTeamSecondTargetBottomView.layer.borderWidth = 0
                    secondTeamFirstTargetBottomView.layer.borderWidth = 0
                    secondTeamSecondTargetBottomView.layer.borderWidth = 0
                }
            }
                        
            serverView.frame.origin.x = touchedPoint.x - xOffset
            serverView.frame.origin.y = touchedPoint.y - yOffset
        }
    }
    
    // MARK: - touches ENDED
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchedPoint: CGPoint = touch.location(in: view)
        var replacedServer: Bool = false
        
        if containsServerFirstTeamFirst == true {
            firstTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
            firstTeamFirstTargetTopView.layer.borderWidth = 2

            firstTeamSecondTargetTopView.layer.borderWidth = 0
            secondTeamFirstTargetTopView.layer.borderWidth = 0
            secondTeamSecondTargetTopView.layer.borderWidth = 0
            
            firstTeamSecondTargetBottomView.layer.borderWidth = 0
            secondTeamFirstTargetBottomView.layer.borderWidth = 0
            secondTeamSecondTargetBottomView.layer.borderWidth = 0
        } else if containsServerFirstTeamSecond == true {
            firstTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
            firstTeamSecondTargetTopView.layer.borderWidth = 2

            firstTeamFirstTargetTopView.layer.borderWidth = 0
            secondTeamFirstTargetTopView.layer.borderWidth = 0
            secondTeamSecondTargetTopView.layer.borderWidth = 0
            
            firstTeamFirstTargetBottomView.layer.borderWidth = 0
            secondTeamFirstTargetBottomView.layer.borderWidth = 0
            secondTeamSecondTargetBottomView.layer.borderWidth = 0
        } else if containsServerSecondTeamFirst == true {
            secondTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
            secondTeamFirstTargetTopView.layer.borderWidth = 2

            firstTeamFirstTargetTopView.layer.borderWidth = 0
            firstTeamSecondTargetTopView.layer.borderWidth = 0
            secondTeamSecondTargetTopView.layer.borderWidth = 0
            
            firstTeamFirstTargetBottomView.layer.borderWidth = 0
            firstTeamSecondTargetBottomView.layer.borderWidth = 0
            secondTeamSecondTargetBottomView.layer.borderWidth = 0
        } else if containsServerSecondTeamSecond == true {
            secondTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
            secondTeamSecondTargetTopView.layer.borderWidth = 2

            firstTeamFirstTargetTopView.layer.borderWidth = 0
            firstTeamSecondTargetTopView.layer.borderWidth = 0
            secondTeamFirstTargetTopView.layer.borderWidth = 0
            
            firstTeamFirstTargetBottomView.layer.borderWidth = 0
            firstTeamSecondTargetBottomView.layer.borderWidth = 0
            secondTeamFirstTargetBottomView.layer.borderWidth = 0
        } else {
            firstTeamFirstTargetTopView.layer.borderWidth = 0
            firstTeamSecondTargetTopView.layer.borderWidth = 0
            secondTeamFirstTargetTopView.layer.borderWidth = 0
            secondTeamSecondTargetTopView.layer.borderWidth = 0
            
            firstTeamFirstTargetBottomView.layer.borderWidth = 0
            firstTeamSecondTargetBottomView.layer.borderWidth = 0
            secondTeamFirstTargetBottomView.layer.borderWidth = 0
            secondTeamSecondTargetBottomView.layer.borderWidth = 0
        }
        
        if isDragging == true && currentView != ""{
            if usingDummyView == true {
                
                let touchedView = receiveViewTouchedIn(touchedPoint: touchedPoint)
                                
                switch touchedView {
                case "firstTeamFirstTargetBottomView":
                    
                    if containsServerFirstTeamFirst == true {
                        containsServerFirstTeamFirst = false
                        currentMatch.matchStatistics.isServer = ""
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                    }
                    
                    if isDummyServer == true {
                        containsServerFirstTeamFirst = true
                        currentMatch.matchStatistics.isServer = "firstTeamFirst"
                        firstTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        firstTeamFirstTargetTopView.layer.borderWidth = 2
                    }
                    
                    let trimmedPlayerIndex = currentView!.dropLast(10)
                    currentMatch.matchStatistics.firstTeamFar = "\(trimmedPlayerIndex)"
                    
                    if currentView!.starts(with: "first") {
                        currentMatch.matchStatistics.onLeftSide = "firstTeam"
                        currentMatch.matchStatistics.onRightSide = "secondTeam"
                    } else if currentView!.starts(with: "second") {
                        currentMatch.matchStatistics.onLeftSide = "secondTeam"
                        currentMatch.matchStatistics.onRightSide = "firstTeam"
                    }
                    
                    if currentMatch.matchType.matchType == 0 {
                        ProgressHUD.show("Falsche Seite für Standardmatch", icon: .failed, interaction: true)
                    } else {
                        /*
                         doubles
                         */
                        
                        
                        if currentView!.starts(with: "firstTeamFirst") {
                            
                            switch containsPlayerFirstTeamSecondTarget {
                            case "firstTeamFirstBottomView":
                                firstTeamFirstTopView.isHidden = true
                            case "firstTeamSecondBottomView":
                                firstTeamSecondTopView.isHidden = true
                            case "secondTeamFirstBottomView":
                                secondTeamFirstTopView.isHidden = false
                            case "secondTeamSecondBottomView":
                                secondTeamSecondTopView.isHidden = false
                            default:
                                break
                            }
                            
                            firstTeamFirstTopView.isHidden = true
                            firstTeamSecondTopView.isHidden = true
                            
                            containsPlayerFirstTeamSecondTarget = "firstTeamSecondBottomView"
                            firstTeamSecondTargetTopLabel.text = firstTeamSecondTopLabel.text
                            firstTeamSecondTargetTopView.isHidden = false
                            
                            currentMatch.matchStatistics.firstTeamNear = "firstTeamSecond"
                        } else if currentView!.starts(with: "firstTeamSecond") {
                            
                            switch containsPlayerFirstTeamSecondTarget {
                            case "firstTeamFirstBottomView":
                                firstTeamFirstTopView.isHidden = true
                            case "firstTeamSecondBottomView":
                                firstTeamSecondTopView.isHidden = true
                            case "secondTeamFirstBottomView":
                                secondTeamFirstTopView.isHidden = false
                            case "secondTeamSecondBottomView":
                                secondTeamSecondTopView.isHidden = false
                            default:
                                break
                            }
                            
                            firstTeamFirstTopView.isHidden = true
                            firstTeamSecondTopView.isHidden = true
                            
                            containsPlayerFirstTeamSecondTarget = "firstTeamFirstBottomView"
                            firstTeamSecondTargetTopLabel.text = firstTeamFirstTopLabel.text
                            firstTeamSecondTargetTopView.isHidden = false
                            
                            currentMatch.matchStatistics.firstTeamNear = "firstTeamFirst"
                        } else if currentView!.starts(with: "secondTeamFirst") {
                            
                            switch containsPlayerFirstTeamSecondTarget {
                            case "firstTeamFirstBottomView":
                                firstTeamFirstTopView.isHidden = false
                            case "firstTeamSecondBottomView":
                                firstTeamSecondTopView.isHidden = false
                            case "secondTeamFirstBottomView":
                                secondTeamFirstTopView.isHidden = true
                            case "secondTeamSecondBottomView":
                                secondTeamSecondTopView.isHidden = true
                            default:
                                break
                            }
                            
                            secondTeamFirstTopView.isHidden = true
                            secondTeamSecondTopView.isHidden = true
                            
                            containsPlayerFirstTeamSecondTarget = "secondTeamSecondBottomView"
                            firstTeamSecondTargetTopLabel.text = secondTeamSecondTopLabel.text
                            firstTeamSecondTargetTopView.isHidden = false
                            
                            currentMatch.matchStatistics.firstTeamNear = "secondTeamSecond"
                        } else if currentView!.starts(with: "secondTeamSecond") {
                            
                            switch containsPlayerFirstTeamSecondTarget {
                            case "firstTeamFirstBottomView":
                                firstTeamFirstTopView.isHidden = false
                            case "firstTeamSecondBottomView":
                                firstTeamSecondTopView.isHidden = false
                            case "secondTeamFirstBottomView":
                                secondTeamFirstTopView.isHidden = true
                            case "secondTeamSecondBottomView":
                                secondTeamSecondTopView.isHidden = true
                            default:
                                break
                            }
                            
                            secondTeamFirstTopView.isHidden = true
                            secondTeamSecondTopView.isHidden = true
                            
                            containsPlayerFirstTeamSecondTarget = "secondTeamFirstBottomView"
                            firstTeamSecondTargetTopLabel.text = secondTeamFirstTopLabel.text
                            firstTeamSecondTargetTopView.isHidden = false
                            
                            currentMatch.matchStatistics.firstTeamNear = "secondTeamFirst"
                        }
                    }
                    
                    switch containsPlayerFirstTeamFirstTarget {
                    case "firstTeamFirstBottomView":
                        firstTeamFirstTopView.isHidden = false
                        containsPlayerFirstTeamFirstTarget = currentView!
                        firstTeamFirstTargetTopLabel.text = dummyLabel.text
                        firstTeamFirstTargetTopView.isHidden = false
                    case "firstTeamSecondBottomView":
                        firstTeamSecondTopView.isHidden = false
                        containsPlayerFirstTeamFirstTarget = currentView!
                        firstTeamFirstTargetTopLabel.text = dummyLabel.text
                        firstTeamFirstTargetTopView.isHidden = false
                    case "secondTeamFirstBottomView":
                        secondTeamFirstTopView.isHidden = false
                        containsPlayerFirstTeamFirstTarget = currentView!
                        firstTeamFirstTargetTopLabel.text = dummyLabel.text
                        firstTeamFirstTargetTopView.isHidden = false
                    case "secondTeamSecondBottomView":
                        secondTeamSecondTopView.isHidden = false
                        containsPlayerFirstTeamFirstTarget = currentView!
                        firstTeamFirstTargetTopLabel.text = dummyLabel.text
                        firstTeamFirstTargetTopView.isHidden = false
                    case "":
                        containsPlayerFirstTeamFirstTarget = currentView!
                        firstTeamFirstTargetTopLabel.text = dummyLabel.text
                        firstTeamFirstTargetTopView.isHidden = false
                        
                        switch currentView {
                        case "firstTeamFirstBottomView":
                            firstTeamFirstTopView.isHidden = true
                        case "firstTeamSecondBottomView":
                            firstTeamSecondTopView.isHidden = true
                        case "secondTeamFirstBottomView":
                            secondTeamFirstTopView.isHidden = true
                        case "secondTeamSecondBottomView":
                            secondTeamSecondTopView.isHidden = true
                        default:
                            break
                        }
                    default:
                        containsPlayerFirstTeamFirstTarget = currentView!
                        firstTeamFirstTargetTopLabel.text = dummyLabel.text
                        firstTeamFirstTargetTopView.isHidden = false
                        
                        switch currentView {
                        case "firstTeamFirstBottomView":
                            firstTeamFirstTopView.isHidden = true
                        case "firstTeamSecondBottomView":
                            firstTeamSecondTopView.isHidden = true
                        case "secondTeamFirstBottomView":
                            secondTeamFirstTopView.isHidden = true
                        case "secondTeamSecondBottomView":
                            secondTeamSecondTopView.isHidden = true
                        default:
                            break
                        }
                    }
                case "firstTeamSecondTargetBottomView":
                    
                    placeHolderServer = containsServerFirstTeamSecond
                    
                    if containsServerFirstTeamSecond == true {
                        containsServerFirstTeamSecond = false
                        currentMatch.matchStatistics.isServer = ""
                        
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                    }
                    
                    if isDummyServer == true {
                        containsServerFirstTeamSecond = true
                        currentMatch.matchStatistics.isServer = "firstTeamSecond"
                        firstTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        firstTeamSecondTargetTopView.layer.borderWidth = 2
                    }
                    
                    let trimmedPlayerIndex = currentView!.dropLast(10)
                    currentMatch.matchStatistics.firstTeamNear = "\(trimmedPlayerIndex)"
                    
                    if currentView!.starts(with: "first") {
                        currentMatch.matchStatistics.onLeftSide = "firstTeam"
                        currentMatch.matchStatistics.onRightSide = "secondTeam"
                    } else if currentView!.starts(with: "second") {
                        currentMatch.matchStatistics.onLeftSide = "secondTeam"
                        currentMatch.matchStatistics.onRightSide = "firstTeam"
                    }
                    
                    if currentMatch.matchType.matchType == 0 {
                        /*
                            Singles
                         */
                        
                        if containsPlayerSecondTeamFirstTarget == "" {
                            if currentView!.starts(with: "firstTeamSecond") {
                                firstTeamSecondTopView.isHidden = true
                                secondTeamSecondTopView.isHidden = true
                                
                                containsPlayerSecondTeamFirstTarget = "secondTeamSecondBottomView"
                                secondTeamFirstTargetTopLabel.text = secondTeamSecondTopLabel.text
                                secondTeamFirstTargetTopView.isHidden = false
                                
                                currentMatch.matchStatistics.secondTeamFar = "secondTeamSecond"
                                
                                if placeHolderServer == true {
                                    replacedServer = true
                                    containsServerFirstTeamSecond = false
                                    containsServerSecondTeamFirst = true
                                    
                                    secondTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                                    secondTeamFirstTargetTopView.layer.borderWidth = 2
                                    
                                    firstTeamSecondTargetTopView.layer.borderWidth = 0
                                }
                            } else if currentView!.starts(with: "secondTeamSecond") {
                                replacedServer = true
                                firstTeamSecondTopView.isHidden = true
                                secondTeamSecondTopView.isHidden = true
                                
                                containsPlayerSecondTeamFirstTarget = "firstTeamSecondBottomView"
                                secondTeamFirstTargetTopLabel.text = firstTeamSecondTopLabel.text
                                secondTeamFirstTargetTopView.isHidden = false
                                
                                currentMatch.matchStatistics.secondTeamFar = "firstTeamSecond"
                                
                                if placeHolderServer == true {
                                    containsServerFirstTeamSecond = false
                                    containsServerSecondTeamFirst = true
                                    
                                    secondTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                                    secondTeamFirstTargetTopView.layer.borderWidth = 2
                                    
                                    firstTeamSecondTargetTopView.layer.borderWidth = 0
                                }
                            }
                        }
                    } else {
                        /*
                            Doubles
                         */
                        
                        
                        if currentView!.starts(with: "firstTeamFirst") {
                            
                            switch containsPlayerFirstTeamFirstTarget {
                            case "firstTeamFirstBottomView":
                                firstTeamFirstTopView.isHidden = true
                            case "firstTeamSecondBottomView":
                                firstTeamSecondTopView.isHidden = true
                            case "secondTeamFirstBottomView":
                                secondTeamFirstTopView.isHidden = false
                            case "secondTeamSecondBottomView":
                                secondTeamSecondTopView.isHidden = false
                            default:
                                break
                            }
                            
                            firstTeamFirstTopView.isHidden = true
                            firstTeamSecondTopView.isHidden = true
                            
                            containsPlayerFirstTeamFirstTarget = "firstTeamSecondBottomView"
                            firstTeamFirstTargetTopLabel.text = firstTeamFirstTopLabel.text
                            firstTeamFirstTargetTopView.isHidden = false
                            
                            currentMatch.matchStatistics.secondTeamNear = "firstTeamSecond"
                        } else if currentView!.starts(with: "firstTeamSecond") {
                            
                            switch containsPlayerFirstTeamFirstTarget {
                            case "firstTeamFirstBottomView":
                                firstTeamFirstTopView.isHidden = true
                            case "firstTeamSecondBottomView":
                                firstTeamSecondTopView.isHidden = true
                            case "secondTeamFirstBottomView":
                                secondTeamFirstTopView.isHidden = false
                            case "secondTeamSecondBottomView":
                                secondTeamSecondTopView.isHidden = false
                            default:
                                break
                            }
                            
                            firstTeamFirstTopView.isHidden = true
                            firstTeamSecondTopView.isHidden = true
                            
                            containsPlayerFirstTeamFirstTarget = "firstTeamFirstBottomView"
                            firstTeamFirstTargetTopLabel.text = firstTeamFirstTopLabel.text
                            firstTeamFirstTargetTopView.isHidden = false
                            
                            currentMatch.matchStatistics.firstTeamFar = "firstTeamFirst"
                        } else if currentView!.starts(with: "secondTeamFirst") {
                            
                            switch containsPlayerFirstTeamFirstTarget {
                            case "firstTeamFirstBottomView":
                                firstTeamFirstTopView.isHidden = false
                            case "firstTeamSecondBottomView":
                                firstTeamSecondTopView.isHidden = false
                            case "secondTeamFirstBottomView":
                                secondTeamFirstTopView.isHidden = true
                            case "secondTeamSecondBottomView":
                                secondTeamSecondTopView.isHidden = true
                            default:
                                break
                            }
                            
                            secondTeamFirstTopView.isHidden = true
                            secondTeamSecondTopView.isHidden = true
                            
                            containsPlayerFirstTeamFirstTarget = "secondTeamSecondBottomView"
                            firstTeamFirstTargetTopLabel.text = secondTeamSecondTopLabel.text
                            firstTeamFirstTargetTopView.isHidden = false
                            
                            currentMatch.matchStatistics.firstTeamFar = "secondTeamSecond"
                        } else if currentView!.starts(with: "secondTeamSecond") {
                            
                            switch containsPlayerFirstTeamFirstTarget {
                            case "firstTeamFirstBottomView":
                                firstTeamFirstTopView.isHidden = false
                            case "firstTeamSecondBottomView":
                                firstTeamSecondTopView.isHidden = false
                            case "secondTeamFirstBottomView":
                                secondTeamFirstTopView.isHidden = true
                            case "secondTeamSecondBottomView":
                                secondTeamSecondTopView.isHidden = true
                            default:
                                break
                            }
                            
                            secondTeamFirstTopView.isHidden = true
                            secondTeamSecondTopView.isHidden = true
                            
                            containsPlayerFirstTeamFirstTarget = "secondTeamFirstBottomView"
                            firstTeamFirstTargetTopLabel.text = secondTeamFirstTopLabel.text
                            firstTeamFirstTargetTopView.isHidden = false
                            
                            currentMatch.matchStatistics.firstTeamFar = "secondTeamFirst"
                        }
                    }
                    
                    switch containsPlayerFirstTeamSecondTarget {
                    case "firstTeamFirstBottomView":
                        firstTeamFirstTopView.isHidden = false
                        containsPlayerFirstTeamSecondTarget = currentView!
                        firstTeamSecondTargetTopLabel.text = dummyLabel.text
                        firstTeamSecondTargetTopView.isHidden = false
                    case "firstTeamSecondBottomView":
                        if currentMatch.matchType.matchType == 0 {
                            if currentView!.starts(with: "secondTeamSecond") {
                                firstTeamSecondTopView.isHidden = true
                                containsPlayerFirstTeamSecondTarget = currentView!
                                firstTeamSecondTargetTopLabel.text = dummyLabel.text
                                firstTeamSecondTargetTopView.isHidden = false
                                
                                containsPlayerSecondTeamFirstTarget = "firstTeamSecondBottomView"
                                secondTeamFirstTargetTopLabel.text = firstTeamSecondTopLabel!.text
                                secondTeamFirstTargetTopView.isHidden = false
                                
                                if replacedServer == false {
                                    if containsServerSecondTeamFirst == true {
                                        containsServerSecondTeamFirst = false
                                        containsServerFirstTeamSecond = true
                                        firstTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                                        firstTeamSecondTargetTopView.layer.borderWidth = 2
                                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                                        
                                        currentMatch.matchStatistics.isServer = "firstTeamSecond"
                                    }
                                }
                            } else {
                                firstTeamSecondTopView.isHidden = false
                                containsPlayerFirstTeamSecondTarget = currentView!
                                firstTeamSecondTargetTopLabel.text = dummyLabel.text
                                firstTeamSecondTargetTopView.isHidden = false
                            }
                        } else {
                            firstTeamSecondTopView.isHidden = false
                            containsPlayerFirstTeamSecondTarget = currentView!
                            firstTeamSecondTargetTopLabel.text = dummyLabel.text
                            firstTeamSecondTargetTopView.isHidden = false
                        }
                    case "secondTeamFirstBottomView":
                        secondTeamFirstTopView.isHidden = false
                        containsPlayerFirstTeamSecondTarget = currentView!
                        firstTeamSecondTargetTopLabel.text = dummyLabel.text
                        firstTeamSecondTargetTopView.isHidden = false
                    case "secondTeamSecondBottomView":
                        if currentMatch.matchType.matchType == 0 {
                            if currentView!.starts(with: "firstTeamSecond") {
                                secondTeamSecondTopView.isHidden = true
                                containsPlayerFirstTeamSecondTarget = currentView!
                                firstTeamSecondTargetTopLabel.text = dummyLabel.text
                                firstTeamSecondTargetTopView.isHidden = false
                                
                                containsPlayerSecondTeamFirstTarget = "secondTeamSecondBottomView"
                                secondTeamFirstTargetTopLabel.text = secondTeamSecondTopLabel!.text
                                secondTeamFirstTargetTopView.isHidden = false
                                
                                if replacedServer == false {
                                    if containsServerSecondTeamFirst == true {
                                        containsServerSecondTeamFirst = false
                                        containsServerFirstTeamSecond = true
                                        firstTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                                        firstTeamSecondTargetTopView.layer.borderWidth = 2
                                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                                        
                                        currentMatch.matchStatistics.isServer = "secondTeamSecond"
                                    }
                                }
                            } else {
                                secondTeamSecondTopView.isHidden = false
                                containsPlayerFirstTeamSecondTarget = currentView!
                                firstTeamSecondTargetTopLabel.text = dummyLabel.text
                                firstTeamSecondTargetTopView.isHidden = false
                            }
                        } else {
                            secondTeamSecondTopView.isHidden = false
                            containsPlayerFirstTeamSecondTarget = currentView!
                            firstTeamSecondTargetTopLabel.text = dummyLabel.text
                            firstTeamSecondTargetTopView.isHidden = false
                        }
                    case "":
                        containsPlayerFirstTeamSecondTarget = currentView!
                        firstTeamSecondTargetTopLabel.text = dummyLabel.text
                        firstTeamSecondTargetTopView.isHidden = false
                        
                        switch currentView {
                        case "firstTeamFirstBottomView":
                            firstTeamFirstTopView.isHidden = true
                        case "firstTeamSecondBottomView":
                            firstTeamSecondTopView.isHidden = true
                        case "secondTeamFirstBottomView":
                            secondTeamFirstTopView.isHidden = true
                        case "secondTeamSecondBottomView":
                            secondTeamSecondTopView.isHidden = true
                        default:
                            break
                        }
                    default:
                        containsPlayerFirstTeamSecondTarget = currentView!
                        firstTeamSecondTargetTopLabel.text = dummyLabel.text
                        firstTeamSecondTargetTopView.isHidden = false
                        
                        switch currentView {
                        case "firstTeamFirstBottomView":
                            firstTeamFirstTopView.isHidden = true
                        case "firstTeamSecondBottomView":
                            firstTeamSecondTopView.isHidden = true
                        case "secondTeamFirstBottomView":
                            secondTeamFirstTopView.isHidden = true
                        case "secondTeamSecondBottomView":
                            secondTeamSecondTopView.isHidden = true
                        default:
                            break
                        }
                    }
                case "secondTeamFirstTargetBottomView":
                    
                    placeHolderServer = containsServerSecondTeamFirst
                    
                    if containsServerSecondTeamFirst == true {
                        containsServerSecondTeamFirst = false
                        currentMatch.matchStatistics.isServer = ""
                        
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
                    }
                    
                    if isDummyServer == true {
                        containsServerSecondTeamFirst = true
                        currentMatch.matchStatistics.isServer = "secondTeamFirst"
                        secondTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        secondTeamFirstTargetTopView.layer.borderWidth = 2
                    }
                    
                    let trimmedPlayerIndex = currentView!.dropLast(10)
                    currentMatch.matchStatistics.secondTeamFar = "\(trimmedPlayerIndex)"
                    
                    if currentView!.starts(with: "first") {
                        currentMatch.matchStatistics.onLeftSide = "secondTeam"
                        currentMatch.matchStatistics.onRightSide = "firstTeam"
                    } else if currentView!.starts(with: "second") {
                        currentMatch.matchStatistics.onLeftSide = "firstTeam"
                        currentMatch.matchStatistics.onRightSide = "secondTeam"
                    }
                    
                    if currentMatch.matchType.matchType == 0 {
                        /*
                            Singles
                         */
                        
                        if containsPlayerFirstTeamSecondTarget == "" {
                            if currentView!.starts(with: "firstTeamSecond") {
                                firstTeamSecondTopView.isHidden = true
                                secondTeamSecondTopView.isHidden = true
                                
                                containsPlayerFirstTeamSecondTarget = "secondTeamSecondBottomView"
                                firstTeamSecondTargetTopLabel.text = secondTeamSecondTopLabel.text
                                firstTeamSecondTargetTopView.isHidden = false
                                
                                currentMatch.matchStatistics.firstTeamNear = "secondTeamSecond"
                                
                                if placeHolderServer == true {
                                    replacedServer = true
                                    containsServerSecondTeamFirst = false
                                    containsServerFirstTeamSecond = true
                                    
                                    firstTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                                    firstTeamSecondTargetTopView.layer.borderWidth = 2
                                    
                                    secondTeamFirstTargetTopView.layer.borderWidth = 0
                                }
                            } else if currentView!.starts(with: "secondTeamSecond") {
                                
                                firstTeamSecondTopView.isHidden = true
                                secondTeamSecondTopView.isHidden = true
                                
                                containsPlayerSecondTeamFirstTarget = "firstTeamSecondBottomView"
                                secondTeamFirstTargetTopLabel.text = firstTeamSecondTopLabel.text
                                secondTeamFirstTargetTopView.isHidden = false
                                
                                currentMatch.matchStatistics.firstTeamNear = "firstTeamSecond"
                                
                                if placeHolderServer == true {
                                    replacedServer = true
                                    containsServerSecondTeamFirst = false
                                    containsServerFirstTeamSecond = true
                                    
                                    firstTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                                    firstTeamSecondTargetTopView.layer.borderWidth = 2
                                    
                                    secondTeamFirstTargetTopView.layer.borderWidth = 0
                                }
                            }
                        }
                    } else {
                        /*
                            Doubles
                         */
                        
                        
                        if currentView!.starts(with: "firstTeamFirst") {
                            
                            switch containsPlayerSecondTeamSecondTarget {
                            case "firstTeamFirstBottomView":
                                firstTeamFirstTopView.isHidden = true
                            case "firstTeamSecondBottomView":
                                firstTeamSecondTopView.isHidden = true
                            case "secondTeamFirstBottomView":
                                secondTeamFirstTopView.isHidden = false
                            case "secondTeamSecondBottomView":
                                secondTeamSecondTopView.isHidden = false
                            default:
                                break
                            }
                            
                            firstTeamFirstTopView.isHidden = true
                            firstTeamSecondTopView.isHidden = true
                            
                            containsPlayerSecondTeamSecondTarget = "firstTeamSecondBottomView"
                            secondTeamSecondTargetTopLabel.text = firstTeamSecondTopLabel.text
                            secondTeamSecondTargetTopView.isHidden = false
                            
                            currentMatch.matchStatistics.secondTeamNear = "firstTeamSecond"
                        } else if currentView!.starts(with: "firstTeamSecond") {
                            
                            switch containsPlayerSecondTeamSecondTarget {
                            case "firstTeamFirstBottomView":
                                firstTeamFirstTopView.isHidden = true
                            case "firstTeamSecondBottomView":
                                firstTeamSecondTopView.isHidden = true
                            case "secondTeamFirstBottomView":
                                secondTeamFirstTopView.isHidden = false
                            case "secondTeamSecondBottomView":
                                secondTeamSecondTopView.isHidden = false
                            default:
                                break
                            }
                            
                            firstTeamFirstTopView.isHidden = true
                            firstTeamSecondTopView.isHidden = true
                            
                            containsPlayerSecondTeamSecondTarget = "firstTeamFirstBottomView"
                            secondTeamSecondTargetTopLabel.text = firstTeamFirstTopLabel.text
                            secondTeamSecondTargetTopView.isHidden = false
                            
                            currentMatch.matchStatistics.secondTeamNear = "firstTeamFirst"
                        } else if currentView!.starts(with: "secondTeamFirst") {
                            
                            switch containsPlayerSecondTeamSecondTarget {
                            case "firstTeamFirstBottomView":
                                firstTeamFirstTopView.isHidden = false
                            case "firstTeamSecondBottomView":
                                firstTeamSecondTopView.isHidden = false
                            case "secondTeamFirstBottomView":
                                secondTeamFirstTopView.isHidden = true
                            case "secondTeamSecondBottomView":
                                secondTeamSecondTopView.isHidden = true
                            default:
                                break
                            }
                            
                            secondTeamFirstTopView.isHidden = true
                            secondTeamSecondTopView.isHidden = true
                            
                            containsPlayerSecondTeamSecondTarget = "secondTeamSecondBottomView"
                            secondTeamSecondTargetTopLabel.text = secondTeamSecondTopLabel.text
                            secondTeamSecondTargetTopView.isHidden = false
                            
                            currentMatch.matchStatistics.secondTeamNear = "secondTeamSecond"
                        } else if currentView!.starts(with: "secondTeamSecond") {
                            
                            switch containsPlayerSecondTeamSecondTarget {
                            case "firstTeamFirstBottomView":
                                firstTeamFirstTopView.isHidden = false
                            case "firstTeamSecondBottomView":
                                firstTeamSecondTopView.isHidden = false
                            case "secondTeamFirstBottomView":
                                secondTeamFirstTopView.isHidden = true
                            case "secondTeamSecondBottomView":
                                secondTeamSecondTopView.isHidden = true
                            default:
                                break
                            }
                            
                            secondTeamFirstTopView.isHidden = true
                            secondTeamSecondTopView.isHidden = true
                            
                            containsPlayerSecondTeamSecondTarget = "secondTeamFirstBottomView"
                            secondTeamSecondTargetTopLabel.text = secondTeamFirstTopLabel.text
                            secondTeamSecondTargetTopView.isHidden = false
                            
                            currentMatch.matchStatistics.secondTeamNear = "secondTeamFirst"
                        }
                    }
                    
                    switch containsPlayerSecondTeamFirstTarget {
                    case "firstTeamFirstBottomView":
                        firstTeamFirstTopView.isHidden = false
                        containsPlayerSecondTeamFirstTarget = currentView!
                        secondTeamFirstTargetTopLabel.text = dummyLabel.text
                        secondTeamFirstTargetTopView.isHidden = false
                    case "firstTeamSecondBottomView":
                        if currentMatch.matchType.matchType == 0 {
                            if currentView!.starts(with: "secondTeamSecond") {
                                firstTeamSecondTopView.isHidden = true
                                containsPlayerSecondTeamFirstTarget = currentView!
                                secondTeamFirstTargetTopLabel.text = dummyLabel.text
                                secondTeamFirstTargetTopView.isHidden = false
                                
                                containsPlayerFirstTeamSecondTarget = "firstTeamSecondBottomView"
                                firstTeamSecondTargetTopLabel.text = firstTeamSecondTopLabel!.text
                                firstTeamSecondTargetTopView.isHidden = false
                                
                                if replacedServer == false {
                                    if containsServerFirstTeamSecond == true {
                                        containsServerFirstTeamSecond = false
                                        containsServerSecondTeamFirst = true
                                        secondTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                                        secondTeamFirstTargetTopView.layer.borderWidth = 2
                                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                                        
                                        currentMatch.matchStatistics.isServer = "firstTeamSecond"
                                    }
                                }
                            } else {
                                firstTeamSecondTopView.isHidden = false
                                containsPlayerSecondTeamFirstTarget = currentView!
                                secondTeamFirstTargetTopLabel.text = dummyLabel.text
                                secondTeamFirstTargetTopView.isHidden = false
                            }
                        } else {
                            firstTeamSecondTopView.isHidden = false
                            containsPlayerSecondTeamFirstTarget = currentView!
                            secondTeamFirstTargetTopLabel.text = dummyLabel.text
                            secondTeamFirstTargetTopView.isHidden = false
                        }
                    case "secondTeamFirstBottomView":
                        secondTeamFirstTopView.isHidden = false
                        containsPlayerSecondTeamFirstTarget = currentView!
                        secondTeamFirstTargetTopLabel.text = dummyLabel.text
                        secondTeamFirstTargetTopView.isHidden = false
                    case "secondTeamSecondBottomView":
                        if currentMatch.matchType.matchType == 0 {
                            if currentView!.starts(with: "firstTeamSecond") {
                                secondTeamSecondTopView.isHidden = true
                                containsPlayerSecondTeamFirstTarget = currentView!
                                secondTeamFirstTargetTopLabel.text = dummyLabel.text
                                secondTeamFirstTargetTopView.isHidden = false
                                
                                containsPlayerFirstTeamSecondTarget = "secondTeamSecondBottomView"
                                firstTeamSecondTargetTopLabel.text = secondTeamSecondTopLabel!.text
                                firstTeamSecondTargetTopView.isHidden = false
                                
                                if replacedServer == false {
                                    if containsServerFirstTeamSecond == true {
                                        containsServerFirstTeamSecond = false
                                        containsServerSecondTeamFirst = true
                                        secondTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                                        secondTeamFirstTargetTopView.layer.borderWidth = 2
                                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                                        
                                        currentMatch.matchStatistics.isServer = "secondTeamSecond"
                                    }
                                }
                            } else {
                                secondTeamSecondTopView.isHidden = false
                                containsPlayerSecondTeamFirstTarget = currentView!
                                secondTeamFirstTargetTopLabel.text = dummyLabel.text
                                secondTeamFirstTargetTopView.isHidden = false
                            }
                        } else {
                            secondTeamSecondTopView.isHidden = false
                            containsPlayerSecondTeamFirstTarget = currentView!
                            secondTeamFirstTargetTopLabel.text = dummyLabel.text
                            secondTeamFirstTargetTopView.isHidden = false
                        }
                    case "":
                        containsPlayerSecondTeamFirstTarget = currentView!
                        secondTeamFirstTargetTopLabel.text = dummyLabel.text
                        secondTeamFirstTargetTopView.isHidden = false
                        
                        switch currentView {
                        case "firstTeamFirstBottomView":
                            firstTeamFirstTopView.isHidden = true
                        case "firstTeamSecondBottomView":
                            firstTeamSecondTopView.isHidden = true
                        case "secondTeamFirstBottomView":
                            secondTeamFirstTopView.isHidden = true
                        case "secondTeamSecondBottomView":
                            secondTeamSecondTopView.isHidden = true
                        default:
                            break
                        }
                    default:
                        containsPlayerSecondTeamFirstTarget = currentView!
                        secondTeamFirstTargetTopLabel.text = dummyLabel.text
                        secondTeamFirstTargetTopView.isHidden = false
                        
                        switch currentView {
                        case "firstTeamFirstBottomView":
                            firstTeamFirstTopView.isHidden = true
                        case "firstTeamSecondBottomView":
                            firstTeamSecondTopView.isHidden = true
                        case "secondTeamFirstBottomView":
                            secondTeamFirstTopView.isHidden = true
                        case "secondTeamSecondBottomView":
                            secondTeamSecondTopView.isHidden = true
                        default:
                            break
                        }
                    }
                case "secondTeamSecondTargetBottomView":
                    
                    if containsServerSecondTeamSecond == true {
                        containsServerSecondTeamSecond = false
                        currentMatch.matchStatistics.isServer = ""
                        
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    }
                    
                    if isDummyServer == true {
                        containsServerSecondTeamSecond = true
                        currentMatch.matchStatistics.isServer = "secondTeamSecond"
                        secondTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        secondTeamSecondTargetTopView.layer.borderWidth = 2
                    }
                    
                    let trimmedPlayerIndex = currentView!.dropLast(10)
                    currentMatch.matchStatistics.secondTeamNear = "\(trimmedPlayerIndex)"
                    
                    if currentView!.starts(with: "first") {
                        currentMatch.matchStatistics.onLeftSide = "secondTeam"
                        currentMatch.matchStatistics.onRightSide = "firstTeam"
                    } else if currentView!.starts(with: "second") {
                        currentMatch.matchStatistics.onLeftSide = "firstTeam"
                        currentMatch.matchStatistics.onRightSide = "secondTeam"
                    }
                    
                    if currentMatch.matchType.matchType == 0 {
                        ProgressHUD.show("Falsche Seite für Standardmatch", icon: .failed, interaction: true)
                    } else {
                        /*
                         doubles
                         */
                        
                        
                        if currentView!.starts(with: "firstTeamFirst") {
                            
                            switch containsPlayerSecondTeamFirstTarget {
                            case "firstTeamFirstBottomView":
                                firstTeamFirstTopView.isHidden = true
                            case "firstTeamSecondBottomView":
                                firstTeamSecondTopView.isHidden = true
                            case "secondTeamFirstBottomView":
                                secondTeamFirstTopView.isHidden = false
                            case "secondTeamSecondBottomView":
                                secondTeamSecondTopView.isHidden = false
                            default:
                                break
                            }
                            
                            firstTeamFirstTopView.isHidden = true
                            firstTeamSecondTopView.isHidden = true
                            
                            containsPlayerSecondTeamFirstTarget = "firstTeamSecondBottomView"
                            secondTeamFirstTargetTopLabel.text = firstTeamSecondTopLabel.text
                            secondTeamFirstTargetTopView.isHidden = false
                            
                            currentMatch.matchStatistics.secondTeamFar = "firstTeamSecond"
                        } else if currentView!.starts(with: "firstTeamSecond") {
                            
                            switch containsPlayerSecondTeamFirstTarget {
                            case "firstTeamFirstBottomView":
                                firstTeamFirstTopView.isHidden = true
                            case "firstTeamSecondBottomView":
                                firstTeamSecondTopView.isHidden = true
                            case "secondTeamFirstBottomView":
                                secondTeamFirstTopView.isHidden = false
                            case "secondTeamSecondBottomView":
                                secondTeamSecondTopView.isHidden = false
                            default:
                                break
                            }
                            
                            firstTeamFirstTopView.isHidden = true
                            firstTeamSecondTopView.isHidden = true
                            
                            containsPlayerSecondTeamFirstTarget = "firstTeamFirstBottomView"
                            secondTeamFirstTargetTopLabel.text = firstTeamFirstTopLabel.text
                            secondTeamFirstTargetTopView.isHidden = false
                            
                            currentMatch.matchStatistics.secondTeamFar = "firstTeamFirst"
                        } else if currentView!.starts(with: "secondTeamFirst") {
                            
                            switch containsPlayerSecondTeamFirstTarget {
                            case "firstTeamFirstBottomView":
                                firstTeamFirstTopView.isHidden = false
                            case "firstTeamSecondBottomView":
                                firstTeamSecondTopView.isHidden = false
                            case "secondTeamFirstBottomView":
                                secondTeamFirstTopView.isHidden = true
                            case "secondTeamSecondBottomView":
                                secondTeamSecondTopView.isHidden = true
                            default:
                                break
                            }
                            
                            secondTeamFirstTopView.isHidden = true
                            secondTeamSecondTopView.isHidden = true
                            
                            containsPlayerSecondTeamFirstTarget = "secondTeamSecondBottomView"
                            secondTeamFirstTargetTopLabel.text = secondTeamSecondTopLabel.text
                            secondTeamFirstTargetTopView.isHidden = false
                            
                            currentMatch.matchStatistics.secondTeamFar = "secondTeamSecond"
                        } else if currentView!.starts(with: "secondTeamSecond") {
                            
                            switch containsPlayerSecondTeamFirstTarget {
                            case "firstTeamFirstBottomView":
                                firstTeamFirstTopView.isHidden = false
                            case "firstTeamSecondBottomView":
                                firstTeamSecondTopView.isHidden = false
                            case "secondTeamFirstBottomView":
                                secondTeamFirstTopView.isHidden = true
                            case "secondTeamSecondBottomView":
                                secondTeamSecondTopView.isHidden = true
                            default:
                                break
                            }
                            
                            secondTeamFirstTopView.isHidden = true
                            secondTeamSecondTopView.isHidden = true
                            
                            containsPlayerSecondTeamFirstTarget = "secondTeamFirstBottomView"
                            secondTeamFirstTargetTopLabel.text = secondTeamFirstTopLabel.text
                            secondTeamFirstTargetTopView.isHidden = false
                            
                            currentMatch.matchStatistics.secondTeamFar = "secondTeamFirst"
                        }
                    }
                    
                    switch containsPlayerSecondTeamSecondTarget {
                    case "firstTeamFirstBottomView":
                        firstTeamFirstTopView.isHidden = false
                        containsPlayerSecondTeamSecondTarget = currentView!
                        secondTeamSecondTargetTopLabel.text = dummyLabel.text
                        secondTeamSecondTargetTopView.isHidden = false
                    case "firstTeamSecondBottomView":
                        firstTeamSecondTopView.isHidden = false
                        containsPlayerSecondTeamSecondTarget = currentView!
                        secondTeamSecondTargetTopLabel.text = dummyLabel.text
                        secondTeamSecondTargetTopView.isHidden = false
                    case "secondTeamFirstBottomView":
                        secondTeamFirstTopView.isHidden = false
                        containsPlayerSecondTeamSecondTarget = currentView!
                        secondTeamSecondTargetTopLabel.text = dummyLabel.text
                        secondTeamSecondTargetTopView.isHidden = false
                    case "secondTeamSecondBottomView":
                        secondTeamSecondTopView.isHidden = false
                        containsPlayerSecondTeamSecondTarget = currentView!
                        secondTeamSecondTargetTopLabel.text = dummyLabel.text
                        secondTeamSecondTargetTopView.isHidden = false
                    case "":
                        containsPlayerSecondTeamSecondTarget = currentView!
                        secondTeamSecondTargetTopLabel.text = dummyLabel.text
                        secondTeamSecondTargetTopView.isHidden = false
                        
                        switch currentView {
                        case "firstTeamFirstBottomView":
                            firstTeamFirstTopView.isHidden = true
                        case "firstTeamSecondBottomView":
                            firstTeamSecondTopView.isHidden = true
                        case "secondTeamFirstBottomView":
                            secondTeamFirstTopView.isHidden = true
                        case "secondTeamSecondBottomView":
                            secondTeamSecondTopView.isHidden = true
                        default:
                            break
                        }
                    default:
                        containsPlayerSecondTeamSecondTarget = currentView!
                        secondTeamSecondTargetTopLabel.text = dummyLabel.text
                        secondTeamSecondTargetTopView.isHidden = false
                        
                        switch currentView {
                        case "firstTeamFirstBottomView":
                            firstTeamFirstTopView.isHidden = true
                        case "firstTeamSecondBottomView":
                            firstTeamSecondTopView.isHidden = true
                        case "secondTeamFirstBottomView":
                            secondTeamFirstTopView.isHidden = true
                        case "secondTeamSecondBottomView":
                            secondTeamSecondTopView.isHidden = true
                        default:
                            break
                        }
                    }
                default:
                    switch currentView {
                    case "firstTeamFirstBottomView":
                        firstTeamFirstTopView.isHidden = false
                    case "firstTeamSecondBottomView":
                        firstTeamSecondTopView.isHidden = false
                    case "secondTeamFirstBottomView":
                        secondTeamFirstTopView.isHidden = false
                    case "secondTeamSecondBottomView":
                        secondTeamSecondTopView.isHidden = false
                    default:
                        isDragging = false
                        usingDummyView = false
                    }
                }
                
                dummyView.isHidden = true
                dummyView.frame.origin.x = dummyViewInitialLocation.x
                dummyView.frame.origin.y = dummyViewInitialLocation.y
                dummyView.layer.borderWidth = 0
                dummyLabel.text = ""
                
                isDragging = false
                usingDummyView = false
                isDummyServer = false
                currentView = ""
            }
        }
        
        if isDraggingServer == true {
            
            let touchedView = receiveViewTouchedIn(touchedPoint: touchedPoint)
            
            switch touchedView {
            case "firstTeamFirstTargetBottomView":
                if containsPlayerFirstTeamFirstTarget != "" {
                    containsServerFirstTeamFirst = true
                    containsServerFirstTeamSecond = false
                    containsServerSecondTeamFirst = false
                    containsServerSecondTeamSecond = false
                    
                    firstTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                    firstTeamFirstTargetTopView.layer.borderWidth = 2
                    
                    firstTeamSecondTargetTopView.layer.borderWidth = 0
                    secondTeamFirstTargetTopView.layer.borderWidth = 0
                    secondTeamSecondTargetTopView.layer.borderWidth = 0
                    
                    firstTeamSecondTargetBottomView.layer.borderWidth = 0
                    secondTeamFirstTargetBottomView.layer.borderWidth = 0
                    secondTeamSecondTargetBottomView.layer.borderWidth = 0
                                        
                    let trimmedPlayerIndex = containsPlayerFirstTeamFirstTarget.dropLast(10)
                    currentMatch.matchStatistics.isServer = "\(trimmedPlayerIndex)"
                }
            case "firstTeamSecondTargetBottomView":
                if containsPlayerFirstTeamSecondTarget != "" {
                    containsServerFirstTeamFirst = false
                    containsServerFirstTeamSecond = true
                    containsServerSecondTeamFirst = false
                    containsServerSecondTeamSecond = false
                    
                    firstTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                    firstTeamSecondTargetTopView.layer.borderWidth = 2
                    
                    firstTeamFirstTargetTopView.layer.borderWidth = 0
                    secondTeamFirstTargetTopView.layer.borderWidth = 0
                    secondTeamSecondTargetTopView.layer.borderWidth = 0
                    
                    firstTeamFirstTargetBottomView.layer.borderWidth = 0
                    secondTeamFirstTargetBottomView.layer.borderWidth = 0
                    secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    
                    let trimmedPlayerIndex = containsPlayerFirstTeamSecondTarget.dropLast(10)
                    currentMatch.matchStatistics.isServer = "\(trimmedPlayerIndex)"
                }
            case "secondTeamFirstTargetBottomView":
                if containsPlayerSecondTeamFirstTarget != "" {
                    containsServerFirstTeamFirst = false
                    containsServerFirstTeamSecond = false
                    containsServerSecondTeamFirst = true
                    containsServerSecondTeamSecond = false
                    
                    secondTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                    secondTeamFirstTargetTopView.layer.borderWidth = 2
                    
                    firstTeamFirstTargetTopView.layer.borderWidth = 0
                    firstTeamSecondTargetTopView.layer.borderWidth = 0
                    secondTeamSecondTargetTopView.layer.borderWidth = 0
                    
                    firstTeamFirstTargetBottomView.layer.borderWidth = 0
                    firstTeamSecondTargetBottomView.layer.borderWidth = 0
                    secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    
                    let trimmedPlayerIndex = containsPlayerSecondTeamFirstTarget.dropLast(10)
                    currentMatch.matchStatistics.isServer = "\(trimmedPlayerIndex)"
                }
            case "secondTeamSecondTargetBottomView":
                if containsPlayerSecondTeamSecondTarget != "" {
                    containsServerFirstTeamFirst = false
                    containsServerFirstTeamSecond = false
                    containsServerSecondTeamFirst = false
                    containsServerSecondTeamSecond = true
                    
                    secondTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                    secondTeamSecondTargetTopView.layer.borderWidth = 2
                    
                    firstTeamFirstTargetTopView.layer.borderWidth = 0
                    firstTeamSecondTargetTopView.layer.borderWidth = 0
                    secondTeamFirstTargetTopView.layer.borderWidth = 0
                    
                    firstTeamFirstTargetBottomView.layer.borderWidth = 0
                    firstTeamSecondTargetBottomView.layer.borderWidth = 0
                    secondTeamFirstTargetBottomView.layer.borderWidth = 0
                    
                    let trimmedPlayerIndex = containsPlayerSecondTeamSecondTarget.dropLast(10)
                    currentMatch.matchStatistics.isServer = "\(trimmedPlayerIndex)"
                }
            default:
                break
            }
            serverView.frame.origin.x = serverInitialLocation.x
            serverView.frame.origin.y = serverInitialLocation.y
            isDraggingServer = false
            currentView = ""
        }
    }
    
    func receiveViewTouchedIn(touchedPoint: CGPoint) -> String {
        var touchedView: String = ""
        
        if touchedPoint.x >= firstTeamFirstBottomView.frame.minX && touchedPoint.x <= firstTeamFirstBottomView.frame.maxX && touchedPoint.y >= firstTeamFirstBottomView.frame.minY && touchedPoint.y <= firstTeamFirstBottomView.frame.maxY {
            touchedView = "firstTeamFirstBottomView"
        } else if touchedPoint.x >= firstTeamSecondBottomView.frame.minX && touchedPoint.x <= firstTeamSecondBottomView.frame.maxX && touchedPoint.y >= firstTeamSecondBottomView.frame.minY && touchedPoint.y <= firstTeamSecondBottomView.frame.maxY {
            touchedView = "firstTeamSecondBottomView"
        } else if touchedPoint.x >= secondTeamFirstBottomView.frame.minX && touchedPoint.x <= secondTeamFirstBottomView.frame.maxX && touchedPoint.y >= secondTeamFirstBottomView.frame.minY && touchedPoint.y <= secondTeamFirstBottomView.frame.maxY {
            touchedView = "secondTeamFirstBottomView"
        } else if touchedPoint.x >= secondTeamSecondBottomView.frame.minX && touchedPoint.x <= secondTeamSecondBottomView.frame.maxX && touchedPoint.y >= secondTeamSecondBottomView.frame.minY && touchedPoint.y <= secondTeamSecondBottomView.frame.maxY {
            touchedView = "secondTeamSecondBottomView"
        } else if touchedPoint.x >= firstTeamFirstTargetBottomView.frame.minX && touchedPoint.x <= firstTeamFirstTargetBottomView.frame.maxX && touchedPoint.y >= firstTeamFirstTargetBottomView.frame.minY && touchedPoint.y <= firstTeamFirstTargetBottomView.frame.maxY {
            touchedView = "firstTeamFirstTargetBottomView"
        } else if touchedPoint.x >= firstTeamSecondTargetBottomView.frame.minX && touchedPoint.x <= firstTeamSecondTargetBottomView.frame.maxX && touchedPoint.y >= firstTeamSecondTargetBottomView.frame.minY && touchedPoint.y <= firstTeamSecondTargetBottomView.frame.maxY {
            touchedView = "firstTeamSecondTargetBottomView"
        } else if touchedPoint.x >= secondTeamFirstTargetBottomView.frame.minX && touchedPoint.x <= secondTeamFirstTargetBottomView.frame.maxX && touchedPoint.y >= secondTeamFirstTargetBottomView.frame.minY && touchedPoint.y <= secondTeamFirstTargetBottomView.frame.maxY {
            touchedView = "secondTeamFirstTargetBottomView"
        } else if touchedPoint.x >= secondTeamSecondTargetBottomView.frame.minX && touchedPoint.x <= secondTeamSecondTargetBottomView.frame.maxX && touchedPoint.y >= secondTeamSecondTargetBottomView.frame.minY && touchedPoint.y <= secondTeamSecondTargetBottomView.frame.maxY {
            touchedView = "secondTeamSecondTargetBottomView"
        } else if touchedPoint.x >= serverView.frame.minX && touchedPoint.x <= serverView.frame.maxX && touchedPoint.y >= serverView.frame.minY && touchedPoint.y <= serverView.frame.maxY {
            touchedView = "serverView"
        }
        
        return touchedView
    }
    
    func sendMatch(match: Match, editingDistinctMatch: Bool, indexOfMatch: Int, forceStart: Bool) {
        currentMatch = match
        selectedIndex = indexOfMatch
    }
}
