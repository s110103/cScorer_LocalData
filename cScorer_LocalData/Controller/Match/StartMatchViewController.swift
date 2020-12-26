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
    var xGlobalOffset: CGFloat = 0
    var yGlobalOffset: CGFloat = 0
    var playerViewWidth: CGFloat = 0
    var playerViewHeight: CGFloat = 0
    var currentView: UIView?
    var currentBottomView: UIView?
    var currentTargetView: UIView?
    
    var firstTeamFirstInitialLocation: CGPoint = CGPoint(x: 0, y: 0)
    var firstTeamSecondInitialLocation: CGPoint = CGPoint(x: 0, y: 0)
    var secondTeamFirstInitialLocation: CGPoint = CGPoint(x: 0, y: 0)
    var secondTeamSecondInitialLocation: CGPoint = CGPoint(x: 0, y: 0)
    var serverInitialLocation: CGPoint = CGPoint(x: 0, y: 0)
    
    var containsPlayerFirstTeamFirstTarget: Bool = false
    var containtsPlayerFirstTeamSecondTarget: Bool = false
    var containsPlayerSecondTeamFirstTarget: Bool = false
    var containsPlayerSecondTeamSecondTarget: Bool = false
    
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
                                    
            switch currentMatch.matchStatistics.firstTeamSecondPlayerPosition {
            case 0:
                firstTeamSecondTopView!.frame.origin.x = firstTeamSecondBottomView.frame.origin.x
                firstTeamSecondTopView!.frame.origin.y = firstTeamSecondBottomView.frame.origin.y
            case 1:
                firstTeamSecondTopView!.frame.origin.x = firstTeamFirstTargetBottomView.frame.origin.x
                firstTeamSecondTopView!.frame.origin.y = firstTeamFirstTargetBottomView.frame.origin.y
            case 2:
                firstTeamSecondTopView!.frame.origin.x = firstTeamSecondTargetBottomView.frame.origin.x
                firstTeamSecondTopView!.frame.origin.y = firstTeamSecondTargetBottomView.frame.origin.y
            case 3:
                firstTeamSecondTopView!.frame.origin.x = secondTeamFirstTargetBottomView.frame.origin.x
                firstTeamSecondTopView!.frame.origin.y = secondTeamFirstTargetBottomView.frame.origin.y
            case 4:
                firstTeamSecondTopView!.frame.origin.x = secondTeamSecondTargetBottomView.frame.origin.x
                firstTeamSecondTopView!.frame.origin.y = secondTeamSecondTargetBottomView.frame.origin.y
            default:
                break
            }
            
            switch currentMatch.matchStatistics.secondTeamSecondPlayerPosition {
            case 0:
                secondTeamSecondTopView!.frame.origin.x = secondTeamSecondBottomView.frame.origin.x
                secondTeamSecondTopView!.frame.origin.y = secondTeamSecondBottomView.frame.origin.y
            case 1:
                secondTeamSecondTopView!.frame.origin.x = firstTeamFirstTargetBottomView.frame.origin.x
                secondTeamSecondTopView!.frame.origin.y = firstTeamFirstTargetBottomView.frame.origin.y
            case 2:
                secondTeamSecondTopView!.frame.origin.x = firstTeamSecondTargetBottomView.frame.origin.x
                secondTeamSecondTopView!.frame.origin.y = firstTeamSecondTargetBottomView.frame.origin.y
            case 3:
                secondTeamSecondTopView!.frame.origin.x = secondTeamFirstTargetBottomView.frame.origin.x
                secondTeamSecondTopView!.frame.origin.y = secondTeamFirstTargetBottomView.frame.origin.y
            case 4:
                secondTeamSecondTopView!.frame.origin.x = secondTeamSecondTargetBottomView.frame.origin.x
                secondTeamSecondTopView!.frame.origin.y = secondTeamSecondTargetBottomView.frame.origin.y
            default:
                break
            }
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
        
        firstTeamFirstTargetBottomView.layer.borderWidth = 0
        firstTeamSecondTargetBottomView.layer.borderWidth = 0
        secondTeamFirstTargetBottomView.layer.borderWidth = 0
        secondTeamSecondTargetBottomView.layer.borderWidth = 0
        
        firstTeamFirstTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
        firstTeamSecondTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
        secondTeamFirstTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
        secondTeamSecondTargetBottomView.layer.borderColor = UIColor(ciColor: .green).cgColor
        
        
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
        firstTeamFirstTargetBottomView.layer.cornerRadius = 5
        
        firstTeamSecondTopView.layer.cornerRadius = 5
        firstTeamSecondBottomView.layer.cornerRadius = 5
        firstTeamSecondTargetBottomView.layer.cornerRadius = 5
        
        secondTeamFirstTopView.layer.cornerRadius = 5
        secondTeamFirstBottomView.layer.cornerRadius = 5
        secondTeamFirstTargetBottomView.layer.cornerRadius = 5
        
        secondTeamSecondTopView.layer.cornerRadius = 5
        secondTeamSecondBottomView.layer.cornerRadius = 5
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
        
        print(row)
        
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
}

















extension StartMatchViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        
        guard let touch = touches.first else {
            return
        }
        
        let touchedPoint: CGPoint = touch.location(in: view)
        
        if touchedPoint.x >= firstTeamSecondBottomView.frame.minX && touchedPoint.x <= firstTeamSecondBottomView.frame.maxX && touchedPoint.y >= firstTeamSecondBottomView.frame.minY && touchedPoint.y <= firstTeamSecondBottomView.frame.maxY {
            
            let touchInView: CGPoint = touch.location(in: firstTeamSecondBottomView)
            
            isDragging = true
            firstTeamSecondTopView.isHidden = true
            dummyView.isHidden = false
            
            firstTeamSecondTargetTopView.isHidden = false
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchedPoint: CGPoint = touch.location(in: view)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        firstTeamSecondTopView.isHidden = false
        dummyView.isHidden = true
    }
    
    func sendMatch(match: Match, editingDistinctMatch: Bool, indexOfMatch: Int) {
        currentMatch = match
        selectedIndex = indexOfMatch
    }
    
    /*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        
        guard let touch = touches.first else {
            return
        }
        
        containsPlayerFirstTeamFirstTarget = true

        let touchedLocation: CGPoint = touch.location(in: view)
        
        if receiveViewTouchedIn(touchedLocation: touchedLocation) != nil{
            
            let touchedView: UIView = receiveViewTouchedIn(touchedLocation: touchedLocation)!
            xOffset = touch.location(in: touchedView).x
            yOffset = touch.location(in: touchedView).y
                        
            if touchedView == firstTeamFirstTopView || touchedView == firstTeamSecondTopView || touchedView == secondTeamFirstTopView || touchedView == secondTeamSecondTopView {
                isDragging = true
                currentView = touchedView
                view.bringSubviewToFront(touchedView)
                
            } else if touchedView == serverView {
                isDragging = true
                isDraggingServer = true
                currentView = touchedView
                view.bringSubviewToFront(currentView!)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let currentLocation: CGPoint = touch.location(in: view)
        
        if isDragging == true && currentView != nil {
            
            if isDraggingServer == true {
                
                currentView?.frame.origin.x = currentLocation.x - xOffset
                currentView?.frame.origin.y = currentLocation.y - yOffset
                
                if receiveViewTouchedIn(touchedLocation: currentLocation) != nil {
                    switch receiveViewTouchedIn(touchedLocation: currentLocation) {
                    case firstTeamFirstTargetView:
                        if containsPlayerFirstTeamFirstTarget == true {
                            serverView.isHidden = true
                            firstTeamFirstTargetView.layer.borderWidth = 2
                            firstTeamFirstTargetView.layer.borderColor = UIColor(red:14/255, green:245/255, blue:219/255, alpha: 1).cgColor
                        } else {
                            firstTeamFirstTargetView.layer.borderWidth = 0
                            firstTeamFirstTargetView.layer.borderColor = UIColor(ciColor: .green).cgColor
                            serverView.isHidden = false
                        }
                    default:
                        serverView.isHidden = false
                    }
                }
            } else {
                currentView?.frame.origin.x = currentLocation.x - xGlobalOffset - xOffset
                currentView?.frame.origin.y = currentLocation.y - yGlobalOffset - yOffset
                
                if receiveViewTouchedIn(touchedLocation: currentLocation) != nil {
                    switch receiveViewTouchedIn(touchedLocation: currentLocation) {
                    case firstTeamFirstTargetView:
                        currentTargetView = firstTeamFirstTargetView
                    case firstTeamSecondTargetView:
                        currentTargetView = firstTeamSecondTargetView
                    case secondTeamFirstTargetView:
                        currentTargetView = secondTeamFirstTargetView
                    case secondTeamSecondTargetView:
                        currentTargetView = secondTeamSecondTargetView
                    default:
                        currentTargetView = nil
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        serverView.isHidden = false
        isDraggingServer = false
        
        if currentView != serverView {
            if currentBottomView != nil {
                
                if currentTargetView != nil {
                    currentView?.removeFromSuperview()
                    currentTargetView?.addSubview(currentView!)
                    view.bringSubviewToFront(currentView!)

                } else {
                    currentView?.removeFromSuperview()
                    currentBottomView?.addSubview(currentView!)
                    view.bringSubviewToFront(currentView!)
                }
                
                currentView?.backgroundColor = UIColor(red:0/255, green:66/255, blue:60/255, alpha: 1)
            }
        }
        
        if currentView == firstTeamFirstTopView {
            currentView?.frame.origin.x = 0
            currentView?.frame.origin.y = 0
        } else if currentView == firstTeamSecondTopView {
            currentView?.frame.origin.x = 0
            currentView?.frame.origin.y = 0
        } else if currentView == secondTeamFirstTopView {
            currentView?.frame.origin.x = 0
            currentView?.frame.origin.y = 0
        } else if currentView == secondTeamSecondTopView {
            currentView?.frame.origin.x = 0
            currentView?.frame.origin.y = 0
        } else if currentView == serverView {
            serverView.frame.origin.x = serverInitialLocation.x
            serverView.frame.origin.y = serverInitialLocation.y
        }
        
        currentView = nil
        currentBottomView = nil
    }
    
    func receiveViewTouchedIn(touchedLocation: CGPoint) -> UIView? {
        var touchedView: UIView? = nil
        
        if touchedLocation.x >= firstTeamFirstBottomView.frame.minX && touchedLocation.x <= firstTeamFirstBottomView.frame.maxX && touchedLocation.y >= firstTeamFirstBottomView.frame.minY && touchedLocation.y <= firstTeamFirstBottomView.frame.maxY {
            touchedView = firstTeamFirstTopView
            currentBottomView = firstTeamFirstBottomView
        } else if touchedLocation.x >= firstTeamSecondBottomView.frame.minX && touchedLocation.x <= firstTeamSecondBottomView.frame.maxX && touchedLocation.y >= firstTeamSecondBottomView.frame.minY && touchedLocation.y <= firstTeamSecondBottomView.frame.maxY {
            touchedView = firstTeamSecondTopView
            currentBottomView = firstTeamSecondBottomView
        } else if touchedLocation.x >= secondTeamFirstBottomView.frame.minX && touchedLocation.x <= secondTeamFirstBottomView.frame.maxX && touchedLocation.y >= secondTeamFirstBottomView.frame.minY && touchedLocation.y <= secondTeamFirstBottomView.frame.maxY {
            touchedView = secondTeamFirstTopView
            currentBottomView = secondTeamFirstBottomView
        } else if touchedLocation.x >= secondTeamSecondBottomView.frame.minX && touchedLocation.x <= secondTeamSecondBottomView.frame.maxX && touchedLocation.y >= secondTeamSecondBottomView.frame.minY && touchedLocation.y <= secondTeamSecondBottomView.frame.maxY {
            touchedView = secondTeamSecondTopView
            currentBottomView = secondTeamSecondBottomView
        } else if touchedLocation.x >= serverView.frame.minX && touchedLocation.x <= serverView.frame.maxX && touchedLocation.y >= serverView.frame.minY && touchedLocation.y <= serverView.frame.maxY {
            touchedView = serverView
            xGlobalOffset = serverView.frame.origin.x
            yGlobalOffset = serverView.frame.origin.y
        } else if touchedLocation.x >= firstTeamFirstTargetView.frame.minX && touchedLocation.x <= firstTeamFirstTargetView.frame.maxX && touchedLocation.y >= firstTeamFirstTargetView.frame.minY && touchedLocation.y <= firstTeamFirstTargetView.frame.maxY {
            touchedView = firstTeamFirstTargetView
        } else if touchedLocation.x >= firstTeamSecondTargetView.frame.minX && touchedLocation.x <= firstTeamSecondTargetView.frame.maxX && touchedLocation.y >= firstTeamSecondTargetView.frame.minY && touchedLocation.y <= firstTeamSecondTargetView.frame.maxY {
            touchedView = firstTeamSecondTargetView
        } else if touchedLocation.x >= secondTeamFirstTargetView.frame.minX && touchedLocation.x <= secondTeamFirstTargetView.frame.maxX && touchedLocation.y >= secondTeamFirstTargetView.frame.minY && touchedLocation.y <= secondTeamFirstTargetView.frame.maxY {
            touchedView = secondTeamFirstTargetView
        } else if touchedLocation.x >= secondTeamSecondTargetView.frame.minX && touchedLocation.x <= secondTeamSecondTopView.frame.maxX && touchedLocation.y >= secondTeamSecondTargetView.frame.minY && touchedLocation.y <= secondTeamSecondTargetView.frame.maxY {
            touchedView = secondTeamSecondTargetView
        }
        
        if currentBottomView != nil {
            xGlobalOffset = currentBottomView!.frame.origin.x
            yGlobalOffset = currentBottomView!.frame.origin.y
        }
        
        return touchedView
    }
    
    func sendMatch(match: Match, editingDistinctMatch: Bool, indexOfMatch: Int) {
        currentMatch = match
        selectedIndex = indexOfMatch
    }
 
 */
}
