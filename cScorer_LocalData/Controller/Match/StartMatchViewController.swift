//
//  StartMatchViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 12.12.20.
//

import UIKit

protocol StartMatchViewControllerDelegate {
    func sendStartMatchData(currentMatch: Match, selectedIndex: Int)
}

class StartMatchViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    var currentView: UIView?
    
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
    
    @IBOutlet weak var firstTeamFirstTargetView: UIView!
    @IBOutlet weak var firstTeamSecondTargetView: UIView!
    @IBOutlet weak var secondTeamFirstTargetView: UIView!
    @IBOutlet weak var secondTeamSecondTargetView: UIView!
    
    @IBOutlet weak var tossWinnerTextField: UITextField!
    @IBOutlet weak var choiceMakerTextField: UITextField!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var warmupButton: UIButton!
    @IBOutlet weak var startMatchButton: UIButton!
    
    // MARK: - Constraint Outlets
    
    @IBOutlet weak var firstTeamFirstTopViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstTeamFirstTopViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstTeamSecondTopViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstTeamSecondTopViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondTeamFirstTopViewTopConstraint: NSLayoutConstraint!
    
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
    }
    @IBAction func startButtonTapped(_ sender: UIButton) {
    }
    @IBAction func warmupButtonTapped(_ sender: UIButton) {
    }
    @IBAction func restartButtonTapped(_ sender: UIButton) {
    }
    
    // MARK: - Functions
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
                firstTeamSecondTopView!.frame.origin.x = firstTeamFirstTargetView.frame.origin.x
                firstTeamSecondTopView!.frame.origin.y = firstTeamFirstTargetView.frame.origin.y
            case 2:
                firstTeamSecondTopView!.frame.origin.x = firstTeamSecondTargetView.frame.origin.x
                firstTeamSecondTopView!.frame.origin.y = firstTeamSecondTargetView.frame.origin.y
            case 3:
                firstTeamSecondTopView!.frame.origin.x = secondTeamFirstTargetView.frame.origin.x
                firstTeamSecondTopView!.frame.origin.y = secondTeamFirstTargetView.frame.origin.y
            case 4:
                firstTeamSecondTopView!.frame.origin.x = secondTeamSecondTargetView.frame.origin.x
                firstTeamSecondTopView!.frame.origin.y = secondTeamSecondTargetView.frame.origin.y
            default:
                break
            }
            
            switch currentMatch.matchStatistics.secondTeamSecondPlayerPosition {
            case 0:
                secondTeamSecondTopView!.frame.origin.x = secondTeamSecondBottomView.frame.origin.x
                secondTeamSecondTopView!.frame.origin.y = secondTeamSecondBottomView.frame.origin.y
            case 1:
                secondTeamSecondTopView!.frame.origin.x = firstTeamFirstTargetView.frame.origin.x
                secondTeamSecondTopView!.frame.origin.y = firstTeamFirstTargetView.frame.origin.y
            case 2:
                secondTeamSecondTopView!.frame.origin.x = firstTeamSecondTargetView.frame.origin.x
                secondTeamSecondTopView!.frame.origin.y = firstTeamSecondTargetView.frame.origin.y
            case 3:
                secondTeamSecondTopView!.frame.origin.x = secondTeamFirstTargetView.frame.origin.x
                secondTeamSecondTopView!.frame.origin.y = secondTeamFirstTargetView.frame.origin.y
            case 4:
                secondTeamSecondTopView!.frame.origin.x = secondTeamSecondTargetView.frame.origin.x
                secondTeamSecondTopView!.frame.origin.y = secondTeamSecondTargetView.frame.origin.y
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
        
        firstTeamFirstTargetView.layer.borderWidth = 0
        firstTeamSecondTargetView.layer.borderWidth = 0
        secondTeamFirstTargetView.layer.borderWidth = 0
        secondTeamSecondTargetView.layer.borderWidth = 0
        
        firstTeamFirstTargetView.layer.borderColor = UIColor(ciColor: .green).cgColor
        firstTeamSecondTargetView.layer.borderColor = UIColor(ciColor: .green).cgColor
        secondTeamFirstTargetView.layer.borderColor = UIColor(ciColor: .green).cgColor
        secondTeamSecondTargetView.layer.borderColor = UIColor(ciColor: .green).cgColor
        
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
        firstTeamFirstTargetView.layer.cornerRadius = 5
        
        firstTeamSecondTopView.layer.cornerRadius = 5
        firstTeamSecondBottomView.layer.cornerRadius = 5
        firstTeamSecondTargetView.layer.cornerRadius = 5
        
        secondTeamFirstTopView.layer.cornerRadius = 5
        secondTeamFirstBottomView.layer.cornerRadius = 5
        secondTeamFirstTargetView.layer.cornerRadius = 5
        
        secondTeamSecondTopView.layer.cornerRadius = 5
        secondTeamSecondBottomView.layer.cornerRadius = 5
        secondTeamSecondTargetView.layer.cornerRadius = 5
        
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
    
    /*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        
        guard let touch = touches.first else {
            return
        }
                
        let touchedLocation = touch.location(in: view)
        
        if touchedLocation.x >= firstTeamFirstTopView.frame.minX && touchedLocation.x <= firstTeamFirstTopView.frame.maxX && touchedLocation.y >= firstTeamFirstTopView.frame.minY && touchedLocation.y <= firstTeamFirstTopView.frame.maxY {
            
            let location = touch.location(in: firstTeamFirstTopView)
            xOffset = location.x
            yOffset = location.y
                    
            if firstTeamFirstTopView.bounds.contains(location) {
                isDragging = true
                finalLocation = touchedLocation
                currentView = firstTeamFirstTopView
            }
        }else if touchedLocation.x >= firstTeamSecondTopView.frame.minX && touchedLocation.x <= firstTeamSecondTopView.frame.maxX && touchedLocation.y >= firstTeamSecondTopView.frame.minY && touchedLocation.y <= firstTeamSecondTopView.frame.maxY {
            
            let location = touch.location(in: firstTeamSecondTopView)
            xOffset = location.x
            yOffset = location.y
            finalLocation = touchedLocation
            
            if firstTeamFirstTopView.bounds.contains(location) {
                isDragging = true
                finalLocation = touchedLocation
                currentView = firstTeamSecondTopView
            }
            
        } else if touchedLocation.x >= secondTeamFirstTopView.frame.minX && touchedLocation.x <= secondTeamFirstTopView.frame.maxX && touchedLocation.y >= secondTeamFirstTopView.frame.minY && touchedLocation.y <= secondTeamFirstTopView.frame.maxY {
            
            let location = touch.location(in: secondTeamFirstTopView)
            xOffset = location.x
            yOffset = location.y
            finalLocation = touchedLocation
            
            if secondTeamFirstTopView.bounds.contains(location) {
                isDragging = true
                finalLocation = touchedLocation
                currentView = secondTeamFirstTopView
            }
        } else if touchedLocation.x >= secondTeamSecondTopView.frame.minX && touchedLocation.x <= secondTeamSecondTopView.frame.maxX && touchedLocation.y >= secondTeamSecondTopView.frame.minY && touchedLocation.y <= secondTeamSecondTopView.frame.maxY {
            
            let location = touch.location(in: secondTeamSecondTopView)
            xOffset = location.x
            yOffset = location.y
            finalLocation = touchedLocation
            
            if secondTeamSecondTopView.bounds.contains(location) {
                isDragging = true
                finalLocation = touchedLocation
                currentView = secondTeamSecondTopView
            }
        } else if touchedLocation.x >= serverView.frame.minX && touchedLocation.x <= serverView.frame.maxX && touchedLocation.y >= serverView.frame.minY && touchedLocation.y <= serverView.frame.maxY {
            
            let location = touch.location(in: serverView)
            xOffset = location.x
            yOffset = location.y
            finalLocation = touchedLocation
            
            if serverView.bounds.contains(location) {
                isDragging = true
                finalLocation = touchedLocation
                currentView = serverView
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging, let touch = touches.first, currentView != nil else {
            return
        }
                
        let location = touch.location(in: view)
        currentView!.frame.origin.x = location.x - xOffset
        currentView!.frame.origin.y = location.y - yOffset
        
        finalLocation = location
        
        if firstTeamFirstTargetView.frame.contains(finalLocation) {
            firstTeamFirstTargetView.layer.borderWidth = 1
            firstTeamSecondTargetView.layer.borderWidth = 0
            secondTeamFirstTargetView.layer.borderWidth = 0
            secondTeamSecondTargetView.layer.borderWidth = 0
        } else if firstTeamSecondTargetView.frame.contains(finalLocation) {
            firstTeamFirstTargetView.layer.borderWidth = 0
            firstTeamSecondTargetView.layer.borderWidth = 1
            secondTeamFirstTargetView.layer.borderWidth = 0
            secondTeamSecondTargetView.layer.borderWidth = 0
        } else if secondTeamFirstTargetView.frame.contains(finalLocation) {
            firstTeamFirstTargetView.layer.borderWidth = 0
            firstTeamSecondTargetView.layer.borderWidth = 0
            secondTeamFirstTargetView.layer.borderWidth = 1
            secondTeamSecondTargetView.layer.borderWidth = 0
        } else if secondTeamSecondTargetView.frame.contains(finalLocation) {
            firstTeamFirstTargetView.layer.borderWidth = 0
            firstTeamSecondTargetView.layer.borderWidth = 0
            secondTeamFirstTargetView.layer.borderWidth = 0
            secondTeamSecondTargetView.layer.borderWidth = 1
        } else {
            firstTeamFirstTargetView.layer.borderWidth = 0
            firstTeamSecondTargetView.layer.borderWidth = 0
            secondTeamFirstTargetView.layer.borderWidth = 0
            secondTeamSecondTargetView.layer.borderWidth = 0
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isDragging == true && currentView != nil {
            isDragging = false
            
            firstTeamFirstTargetView.layer.borderWidth = 0
            firstTeamSecondTargetView.layer.borderWidth = 0
            secondTeamFirstTargetView.layer.borderWidth = 0
            secondTeamSecondTargetView.layer.borderWidth = 0
            
            if firstTeamFirstTargetView.frame.contains(finalLocation) {
                switch currentView {
                case firstTeamFirstTopView:
                    firstTeamFirstTopView!.frame.origin.x = firstTeamFirstTargetView.frame.origin.x
                    firstTeamFirstTopView!.frame.origin.y = firstTeamFirstTargetView.frame.origin.y
                    currentMatch.matchStatistics.firstTeamFirstPlayerPosition = 1
                case firstTeamSecondTopView:
                    firstTeamSecondTopView!.frame.origin.x = firstTeamFirstTargetView.frame.origin.x
                    firstTeamSecondTopView!.frame.origin.y = firstTeamFirstTargetView.frame.origin.y
                    currentMatch.matchStatistics.firstTeamSecondPlayerPosition = 1
                case secondTeamFirstTopView:
                    secondTeamFirstTopView!.frame.origin.x = firstTeamFirstTargetView.frame.origin.x
                    secondTeamFirstTopView!.frame.origin.y = firstTeamFirstTargetView.frame.origin.y
                    currentMatch.matchStatistics.secondTeamFirstPlayerPosition = 1
                case secondTeamSecondTopView:
                    secondTeamSecondTopView!.frame.origin.x = firstTeamFirstTargetView.frame.origin.x
                    secondTeamSecondTopView!.frame.origin.y = firstTeamFirstTargetView.frame.origin.y
                    currentMatch.matchStatistics.secondTeamSecondPlayerPosition = 1
                default:
                    break
                }
            } else if firstTeamSecondTargetView.frame.contains(finalLocation) {
                switch currentView {
                case firstTeamFirstTopView:
                    firstTeamFirstTopView!.frame.origin.x = firstTeamSecondTargetView.frame.origin.x
                    firstTeamFirstTopView!.frame.origin.y = firstTeamSecondTargetView.frame.origin.y
                    currentMatch.matchStatistics.firstTeamFirstPlayerPosition = 2
                case firstTeamSecondTopView:
                    firstTeamSecondTopView!.frame.origin.x = firstTeamSecondTargetView.frame.origin.x
                    firstTeamSecondTopView!.frame.origin.y = firstTeamSecondTargetView.frame.origin.y
                    currentMatch.matchStatistics.firstTeamSecondPlayerPosition = 2
                case secondTeamFirstTopView:
                    secondTeamFirstTopView!.frame.origin.x = firstTeamSecondTargetView.frame.origin.x
                    secondTeamFirstTopView!.frame.origin.y = firstTeamSecondTargetView.frame.origin.y
                    currentMatch.matchStatistics.secondTeamFirstPlayerPosition = 2
                case secondTeamSecondTopView:
                    secondTeamSecondTopView!.frame.origin.x = firstTeamSecondTargetView.frame.origin.x
                    secondTeamSecondTopView!.frame.origin.y = firstTeamSecondTargetView.frame.origin.y
                    currentMatch.matchStatistics.secondTeamSecondPlayerPosition = 2
                default:
                    break
                }
            } else if secondTeamFirstTargetView.frame.contains(finalLocation) {
                switch currentView {
                case firstTeamFirstTopView:
                    firstTeamFirstTopView!.frame.origin.x = secondTeamFirstTargetView.frame.origin.x
                    firstTeamFirstTopView!.frame.origin.y = secondTeamFirstTargetView.frame.origin.y
                    currentMatch.matchStatistics.firstTeamFirstPlayerPosition = 3
                case firstTeamSecondTopView:
                    firstTeamSecondTopView!.frame.origin.x = secondTeamFirstTargetView.frame.origin.x
                    firstTeamSecondTopView!.frame.origin.y = secondTeamFirstTargetView.frame.origin.y
                    currentMatch.matchStatistics.firstTeamSecondPlayerPosition = 3
                case secondTeamFirstTopView:
                    secondTeamFirstTopView!.frame.origin.x = secondTeamFirstTargetView.frame.origin.x
                    secondTeamFirstTopView!.frame.origin.y = secondTeamFirstTargetView.frame.origin.y
                    currentMatch.matchStatistics.secondTeamFirstPlayerPosition = 3
                case secondTeamSecondTopView:
                    secondTeamSecondTopView!.frame.origin.x = secondTeamFirstTargetView.frame.origin.x
                    secondTeamSecondTopView!.frame.origin.y = secondTeamFirstTargetView.frame.origin.y
                    currentMatch.matchStatistics.secondTeamSecondPlayerPosition = 3
                default:
                    break
                }
            } else if secondTeamSecondTargetView.frame.contains(finalLocation) {
                switch currentView {
                case firstTeamFirstTopView:
                    firstTeamFirstTopView!.frame.origin.x = secondTeamSecondTargetView.frame.origin.x
                    firstTeamFirstTopView!.frame.origin.y = secondTeamSecondTargetView.frame.origin.y
                    currentMatch.matchStatistics.firstTeamFirstPlayerPosition = 4
                case firstTeamSecondTopView:
                    firstTeamSecondTopView!.frame.origin.x = secondTeamSecondTargetView.frame.origin.x
                    firstTeamSecondTopView!.frame.origin.y = secondTeamSecondTargetView.frame.origin.y
                    currentMatch.matchStatistics.firstTeamSecondPlayerPosition = 4
                case secondTeamFirstTopView:
                    secondTeamFirstTopView!.frame.origin.x = secondTeamSecondTargetView.frame.origin.x
                    secondTeamFirstTopView!.frame.origin.y = secondTeamSecondTargetView.frame.origin.y
                    currentMatch.matchStatistics.secondTeamFirstPlayerPosition = 4
                case secondTeamSecondTopView:
                    secondTeamSecondTopView!.frame.origin.x = secondTeamSecondTargetView.frame.origin.x
                    secondTeamSecondTopView!.frame.origin.y = secondTeamSecondTargetView.frame.origin.y
                    currentMatch.matchStatistics.secondTeamSecondPlayerPosition = 4
                default:
                    break
                }
            } else {
                
                switch currentView {
                    case firstTeamFirstTopView:
                        firstTeamFirstTopView.frame.origin.x = firstTeamFirstInitialLocation.x
                        firstTeamFirstTopView.frame.origin.y = firstTeamFirstInitialLocation.y
                        currentMatch.matchStatistics.firstTeamFirstPlayerPosition = 0
                    case firstTeamSecondTopView:
                        firstTeamSecondTopView.frame.origin.x = firstTeamSecondInitialLocation.x
                        firstTeamSecondTopView.frame.origin.y = firstTeamSecondInitialLocation.y
                        currentMatch.matchStatistics.firstTeamSecondPlayerPosition = 0
                    case secondTeamFirstTopView:
                        secondTeamFirstTopView.frame.origin.x = secondTeamFirstInitialLocation.x
                        secondTeamFirstTopView.frame.origin.y = secondTeamFirstInitialLocation.y
                        currentMatch.matchStatistics.secondTeamFirstPlayerPosition = 0
                    case secondTeamSecondTopView:
                        secondTeamSecondTopView.frame.origin.x = secondTeamSecondInitialLocation.x
                        secondTeamSecondTopView.frame.origin.y = secondTeamSecondInitialLocation.y
                        currentMatch.matchStatistics.secondTeamSecondPlayerPosition = 0
                    case serverView:
                        serverView.frame.origin.x = serverInitialLocation.x
                        serverView.frame.origin.y = serverInitialLocation.y
                    default:
                        break
                }
            }
            currentView = nil
        }
    }
 */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        
        guard let touch = touches.first else {
            return
        }
        
        containsPlayerFirstTeamFirstTarget = true

        let touchedLocation: CGPoint = touch.location(in: view)
        
        if receiveViewTouchedIn(touchedLocation: touchedLocation) != nil {
            let touchedView: UIView = receiveViewTouchedIn(touchedLocation: touchedLocation)!
            xOffset = touch.location(in: touchedView).x
            yOffset = touch.location(in: touchedView).y
            
            if touchedView == firstTeamFirstTopView || touchedView == firstTeamSecondTopView || touchedView == secondTeamFirstTopView || touchedView == secondTeamSecondTopView {
                isDragging = true
                currentView = touchedView
                //view.bringSubviewToFront(currentView!)
            } else if touchedView == serverView {
                isDragging = true
                isDraggingServer = true
                currentView = touchedView
                //view.bringSubviewToFront(currentView!)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let currentLocation: CGPoint = touch.location(in: view)
        
        if isDragging == true {
            currentView?.frame.origin.x = currentLocation.x - xOffset
            currentView?.frame.origin.y = currentLocation.y - yOffset
            
            if currentView == firstTeamFirstTopView {
                firstTeamFirstTopViewTopConstraint.constant = currentLocation.y - yOffset - firstTeamFirstInitialLocation.y
                firstTeamFirstTopViewLeadingConstraint.constant = currentLocation.x - xOffset - firstTeamFirstInitialLocation.x
                firstTeamFirstTopView.updateConstraints()
            }
            
            if isDraggingServer == true {
                
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
                
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        serverView.isHidden = false
    }
    
    func receiveViewTouchedIn(touchedLocation: CGPoint) -> UIView? {
        var touchedView: UIView? = nil
        
        if touchedLocation.x >= firstTeamFirstTopView.frame.minX && touchedLocation.x <= firstTeamFirstTopView.frame.maxX && touchedLocation.y >= firstTeamFirstTopView.frame.minY && touchedLocation.y <= firstTeamFirstTopView.frame.maxY {
            touchedView = firstTeamFirstTopView
        } else if touchedLocation.x >= firstTeamSecondTopView.frame.minX && touchedLocation.x <= firstTeamSecondTopView.frame.maxX && touchedLocation.y >= firstTeamSecondTopView.frame.minY && touchedLocation.y <= firstTeamSecondTopView.frame.maxY {
            touchedView = firstTeamSecondTopView
        } else if touchedLocation.x >= secondTeamFirstTopView.frame.minX && touchedLocation.x <= secondTeamFirstTopView.frame.maxX && touchedLocation.y >= secondTeamFirstTopView.frame.minY && touchedLocation.y <= secondTeamFirstTopView.frame.maxY {
            touchedView = secondTeamFirstTopView
        } else if touchedLocation.x >= secondTeamSecondTopView.frame.minX && touchedLocation.x <= secondTeamSecondTopView.frame.maxX && touchedLocation.y >= secondTeamSecondTopView.frame.minY && touchedLocation.y <= secondTeamSecondTopView.frame.maxY {
            touchedView = secondTeamSecondTopView
        } else if touchedLocation.x >= serverView.frame.minX && touchedLocation.x <= serverView.frame.maxX && touchedLocation.y >= serverView.frame.minY && touchedLocation.y <= serverView.frame.maxY {
            touchedView = serverView
        } else if touchedLocation.x >= firstTeamFirstTargetView.frame.minX && touchedLocation.x <= firstTeamFirstTargetView.frame.maxX && touchedLocation.y >= firstTeamFirstTargetView.frame.minY && touchedLocation.y <= firstTeamFirstTargetView.frame.maxY {
            touchedView = firstTeamFirstTargetView
        } else if touchedLocation.x >= firstTeamSecondTargetView.frame.minX && touchedLocation.x <= firstTeamSecondTargetView.frame.maxX && touchedLocation.y >= firstTeamSecondTargetView.frame.minY && touchedLocation.y <= firstTeamSecondTargetView.frame.maxY {
            touchedView = firstTeamSecondTargetView
        } else if touchedLocation.x >= secondTeamFirstTargetView.frame.minX && touchedLocation.x <= secondTeamFirstTargetView.frame.maxX && touchedLocation.y >= secondTeamFirstTargetView.frame.minY && touchedLocation.y <= secondTeamFirstTargetView.frame.maxY {
            touchedView = secondTeamFirstTargetView
        } else if touchedLocation.x >= secondTeamSecondTargetView.frame.minX && touchedLocation.x <= secondTeamSecondTopView.frame.maxX && touchedLocation.y >= secondTeamSecondTargetView.frame.minY && touchedLocation.y <= secondTeamSecondTargetView.frame.maxY {
            touchedView = secondTeamSecondTargetView
        }
        
        return touchedView
    }
}
