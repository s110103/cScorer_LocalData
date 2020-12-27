//
//  StartMatchViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 12.12.20.
//

import UIKit

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
            
            firstTeamSecondTopLabel.text = teamNames[0]
            firstTeamSecondBottomLabel.text = teamNames[0]
            
            secondTeamSecondTopLabel.text = teamNames[1]
            secondTeamSecondBottomLabel.text = teamNames[1]
            
        } else {
            teamNames.removeAll()
            teamNames.append("\(currentMatch.firstTeamFirstPlayerSurname) \(currentMatch.firstTeamFirstPlayer.prefix(1)) & \(currentMatch.firstTeamSecondPlayerSurname) \(currentMatch.firstTeamSecondPlayer.prefix(1))")
            teamNames.append("\(currentMatch.secondTeamFirstPlayerSurname) \(currentMatch.secondTeamFirstPlayer.prefix(1)) & \(currentMatch.secondTeamSecondPlayerSurname) \(currentMatch.secondTeamSecondPlayer.prefix(1))")
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
    
    /*
        touches
     */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
            case "serverView":
                currentView = touchedView
            default:
                currentView = ""
            }
        }
        
        if currentView != "" && currentView != "serverView" {
            
            firstTeamFirstTargetTopView.layer.borderColor = UIColor(ciColor: .green).cgColor
            firstTeamSecondTargetTopView.layer.borderColor = UIColor(ciColor: .green).cgColor
            secondTeamFirstTargetTopView.layer.borderColor = UIColor(ciColor: .green).cgColor
            secondTeamSecondTargetTopView.layer.borderColor = UIColor(ciColor: .green).cgColor
            
            firstTeamFirstTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
            firstTeamSecondTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
            secondTeamFirstTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
            secondTeamSecondTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
            
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
                
                dummyView.isHidden = false
                usingDummyView = true
            default:
                break
            }
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
        }
    }
    
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
                    }
                    if containsServerFirstTeamSecond == true {
                        firstTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        firstTeamSecondTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 1
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 1
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    }
                    if containsServerSecondTeamFirst == true {
                        secondTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        secondTeamFirstTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 1
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 1
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    }
                    if containsServerSecondTeamSecond == true {
                        secondTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        secondTeamSecondTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 1
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 1
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
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
                    }
                    if containsServerFirstTeamSecond == true {
                        firstTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        firstTeamSecondTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    }
                    if containsServerSecondTeamFirst == true {
                        secondTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        secondTeamFirstTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        firstTeamSecondTargetTopView.layer.borderWidth = 1
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        firstTeamSecondTargetBottomView.layer.borderWidth = 1
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    }
                    if containsServerSecondTeamSecond == true {
                        secondTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        secondTeamSecondTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        firstTeamSecondTargetTopView.layer.borderWidth = 1
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        firstTeamSecondTargetBottomView.layer.borderWidth = 1
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
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
                    }
                    if containsServerFirstTeamSecond == true {
                        firstTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        firstTeamSecondTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 1
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 1
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    }
                    if containsServerSecondTeamFirst == true {
                        secondTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        secondTeamFirstTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    }
                    if containsServerSecondTeamSecond == true {
                        secondTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        secondTeamSecondTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 1
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 1
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
                    }
                    if containsServerFirstTeamSecond == true {
                        firstTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        firstTeamSecondTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 1
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 1
                    }
                    if containsServerSecondTeamFirst == true {
                        secondTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        secondTeamFirstTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 1
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 1
                    }
                    if containsServerSecondTeamSecond == true {
                        secondTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        secondTeamSecondTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
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
                    }
                    if containsServerFirstTeamSecond == true {
                        firstTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        firstTeamSecondTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    }
                    if containsServerSecondTeamFirst == true {
                        secondTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        secondTeamFirstTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamSecondTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamSecondTargetBottomView.layer.borderWidth = 0
                    }
                    if containsServerSecondTeamSecond == true {
                        secondTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        secondTeamSecondTargetTopView.layer.borderWidth = 2
                        
                        firstTeamFirstTargetTopView.layer.borderWidth = 0
                        firstTeamSecondTargetTopView.layer.borderWidth = 0
                        secondTeamFirstTargetTopView.layer.borderWidth = 0
                        
                        firstTeamFirstTargetBottomView.layer.borderWidth = 0
                        firstTeamSecondTargetBottomView.layer.borderWidth = 0
                        secondTeamFirstTargetBottomView.layer.borderWidth = 0
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
                firstTeamFirstTargetTopView.layer.borderWidth = 2
                firstTeamSecondTargetTopView.layer.borderWidth = 0
                secondTeamFirstTargetTopView.layer.borderWidth = 0
                secondTeamSecondTargetTopView.layer.borderWidth = 0
                
                firstTeamFirstTargetBottomView.layer.borderWidth = 2
                firstTeamSecondTargetBottomView.layer.borderWidth = 0
                secondTeamFirstTargetBottomView.layer.borderWidth = 0
                secondTeamSecondTargetBottomView.layer.borderWidth = 0
            case "firstTeamSecondTargetBottomView":
                firstTeamFirstTargetTopView.layer.borderWidth = 0
                firstTeamSecondTargetTopView.layer.borderWidth = 2
                secondTeamFirstTargetTopView.layer.borderWidth = 0
                secondTeamSecondTargetTopView.layer.borderWidth = 0
                
                firstTeamFirstTargetBottomView.layer.borderWidth = 0
                firstTeamSecondTargetBottomView.layer.borderWidth = 2
                secondTeamFirstTargetBottomView.layer.borderWidth = 0
                secondTeamSecondTargetBottomView.layer.borderWidth = 0
            case "secondTeamFirstTargetBottomView":
                firstTeamFirstTargetTopView.layer.borderWidth = 0
                firstTeamSecondTargetTopView.layer.borderWidth = 0
                secondTeamFirstTargetTopView.layer.borderWidth = 2
                secondTeamSecondTargetTopView.layer.borderWidth = 0
                
                firstTeamFirstTargetBottomView.layer.borderWidth = 0
                firstTeamSecondTargetBottomView.layer.borderWidth = 0
                secondTeamFirstTargetBottomView.layer.borderWidth = 2
                secondTeamSecondTargetBottomView.layer.borderWidth = 0
            case "secondTeamSecondTargetBottomView":
                firstTeamFirstTargetTopView.layer.borderWidth = 0
                firstTeamSecondTargetTopView.layer.borderWidth = 0
                secondTeamFirstTargetTopView.layer.borderWidth = 0
                secondTeamSecondTargetTopView.layer.borderWidth = 2
                
                firstTeamFirstTargetBottomView.layer.borderWidth = 0
                firstTeamSecondTargetBottomView.layer.borderWidth = 0
                secondTeamFirstTargetBottomView.layer.borderWidth = 0
                secondTeamSecondTargetBottomView.layer.borderWidth = 2
            default:
                firstTeamFirstTargetTopView.layer.borderWidth = 0
                firstTeamSecondTargetTopView.layer.borderWidth = 0
                secondTeamFirstTargetTopView.layer.borderWidth = 0
                secondTeamSecondTargetTopView.layer.borderWidth = 0
                
                firstTeamFirstTargetBottomView.layer.borderWidth = 0
                firstTeamSecondTargetBottomView.layer.borderWidth = 0
                secondTeamFirstTargetBottomView.layer.borderWidth = 0
                secondTeamSecondTargetBottomView.layer.borderWidth = 0
            }
            
            serverView.frame.origin.x = touchedPoint.x - xOffset
            serverView.frame.origin.y = touchedPoint.y - yOffset
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchedPoint: CGPoint = touch.location(in: view)
        
        firstTeamFirstTargetTopView.layer.borderWidth = 0
        firstTeamSecondTargetTopView.layer.borderWidth = 0
        secondTeamFirstTargetTopView.layer.borderWidth = 0
        secondTeamSecondTargetTopView.layer.borderWidth = 0
        
        firstTeamFirstTargetBottomView.layer.borderWidth = 0
        firstTeamSecondTargetBottomView.layer.borderWidth = 0
        secondTeamFirstTargetBottomView.layer.borderWidth = 0
        secondTeamSecondTargetBottomView.layer.borderWidth = 0
        
        if isDragging == true && currentView != ""{
            if usingDummyView == true {
                
                let touchedView = receiveViewTouchedIn(touchedPoint: touchedPoint)
                                
                switch touchedView {
                case "firstTeamFirstTargetBottomView":
                    switch containsPlayerFirstTeamFirstTarget {
                    case "firstTeamFirstBottomView":
                        firstTeamFirstTopView.isHidden = true
                        containsPlayerFirstTeamFirstTarget = currentView!
                        firstTeamFirstTargetTopLabel.text = dummyLabel.text
                        firstTeamFirstTargetTopView.isHidden = false
                    case "firstTeamSecondBottomView":
                        firstTeamSecondTopView.isHidden = true
                        containsPlayerFirstTeamFirstTarget = currentView!
                        firstTeamFirstTargetTopLabel.text = dummyLabel.text
                        firstTeamFirstTargetTopView.isHidden = false
                    case "secondTeamFirstBottomView":
                        secondTeamFirstTopView.isHidden = true
                        containsPlayerFirstTeamFirstTarget = currentView!
                        firstTeamFirstTargetTopLabel.text = dummyLabel.text
                        firstTeamFirstTargetTopView.isHidden = false
                    case "secondTeamSecondBottomView":
                        secondTeamSecondTopView.isHidden = true
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
                    switch containsPlayerFirstTeamSecondTarget {
                    case "firstTeamFirstBottomView":
                        firstTeamFirstTopView.isHidden = true
                        containsPlayerFirstTeamSecondTarget = currentView!
                        firstTeamSecondTargetTopLabel.text = dummyLabel.text
                        firstTeamSecondTargetTopView.isHidden = false
                    case "firstTeamSecondBottomView":
                        firstTeamSecondTopView.isHidden = true
                        containsPlayerFirstTeamSecondTarget = currentView!
                        firstTeamSecondTargetTopLabel.text = dummyLabel.text
                        firstTeamSecondTargetTopView.isHidden = false
                    case "secondTeamFirstBottomView":
                        secondTeamFirstTopView.isHidden = true
                        containsPlayerFirstTeamSecondTarget = currentView!
                        firstTeamSecondTargetTopLabel.text = dummyLabel.text
                        firstTeamSecondTargetTopView.isHidden = false
                    case "secondTeamSecondBottomView":
                        secondTeamSecondTopView.isHidden = true
                        containsPlayerFirstTeamSecondTarget = currentView!
                        firstTeamSecondTargetTopLabel.text = dummyLabel.text
                        firstTeamSecondTargetTopView.isHidden = false
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
                    switch containsPlayerSecondTeamFirstTarget {
                    case "firstTeamFirstBottomView":
                        firstTeamFirstTopView.isHidden = true
                        containsPlayerSecondTeamFirstTarget = currentView!
                        secondTeamFirstTargetTopLabel.text = dummyLabel.text
                        secondTeamFirstTargetTopView.isHidden = false
                    case "firstTeamSecondBottomView":
                        firstTeamSecondTopView.isHidden = true
                        containsPlayerSecondTeamFirstTarget = currentView!
                        secondTeamFirstTargetTopLabel.text = dummyLabel.text
                        secondTeamFirstTargetTopView.isHidden = false
                    case "secondTeamFirstBottomView":
                        secondTeamFirstTopView.isHidden = true
                        containsPlayerSecondTeamFirstTarget = currentView!
                        secondTeamFirstTargetTopLabel.text = dummyLabel.text
                        secondTeamFirstTargetTopView.isHidden = false
                    case "secondTeamSecondBottomView":
                        secondTeamSecondTopView.isHidden = true
                        containsPlayerSecondTeamFirstTarget = currentView!
                        secondTeamFirstTargetTopLabel.text = dummyLabel.text
                        secondTeamFirstTargetTopView.isHidden = false
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
                    switch containsPlayerSecondTeamSecondTarget {
                    case "firstTeamFirstBottomView":
                        firstTeamFirstTopView.isHidden = true
                        containsPlayerSecondTeamSecondTarget = currentView!
                        secondTeamSecondTargetTopLabel.text = dummyLabel.text
                        secondTeamSecondTargetTopView.isHidden = false
                    case "firstTeamSecondBottomView":
                        firstTeamSecondTopView.isHidden = true
                        containsPlayerSecondTeamSecondTarget = currentView!
                        secondTeamSecondTargetTopLabel.text = dummyLabel.text
                        secondTeamSecondTargetTopView.isHidden = false
                    case "secondTeamFirstBottomView":
                        secondTeamFirstTopView.isHidden = true
                        containsPlayerSecondTeamSecondTarget = currentView!
                        secondTeamSecondTargetTopLabel.text = dummyLabel.text
                        secondTeamSecondTargetTopView.isHidden = false
                    case "secondTeamSecondBottomView":
                        secondTeamSecondTopView.isHidden = true
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
                dummyLabel.text = ""
                
                isDragging = false
                usingDummyView = false
                currentView = ""
            }
        }
        
        if isDraggingServer == true {
            
            let touchedView = receiveViewTouchedIn(touchedPoint: touchedPoint)
            
            switch touchedView {
            case "firstTeamFirstTargetBottomView":
                containsServerFirstTeamFirst = true
                containsServerFirstTeamSecond = false
                containsServerSecondTeamFirst = false
                containsServerFirstTeamSecond = false
                
                firstTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                firstTeamFirstTargetTopView.layer.borderWidth = 2
            case "firstTeamSecondTargetBottomView":
                containsServerFirstTeamFirst = false
                containsServerFirstTeamSecond = true
                containsServerSecondTeamFirst = false
                containsServerFirstTeamSecond = false
                
                firstTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                firstTeamSecondTargetTopView.layer.borderWidth = 2
            case "secondTeamFirstTargetBottomView":
                containsServerFirstTeamFirst = false
                containsServerFirstTeamSecond = false
                containsServerSecondTeamFirst = true
                containsServerFirstTeamSecond = false
                
                secondTeamFirstTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                secondTeamFirstTargetTopView.layer.borderWidth = 2
            case "secondTeamSecondTargetBottomView":
                containsServerFirstTeamFirst = false
                containsServerFirstTeamSecond = false
                containsServerSecondTeamFirst = false
                containsServerFirstTeamSecond = true
                
                secondTeamSecondTargetTopView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                secondTeamSecondTargetTopView.layer.borderWidth = 2
            default:
                break
            }
            
            serverView.frame.origin.x = serverInitialLocation.x
            serverView.frame.origin.y = serverInitialLocation.y
            isDraggingServer = false
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
    
    func sendMatch(match: Match, editingDistinctMatch: Bool, indexOfMatch: Int) {
        currentMatch = match
        selectedIndex = indexOfMatch
    }
}
