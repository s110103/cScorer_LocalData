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

class StartMatchViewController: UIViewController {
    
    // MARK: - Variables
    var selectedIndex: Int = 0
    var currentMatch: Match = Match()
    var delegate: StartMatchViewControllerDelegate?
        
    var isDragging: Bool = false
    var draggingPlayer: String = ""
    var finalLocation: CGPoint = CGPoint(x: 0, y: 0)
    var xOffset: CGFloat = 0
    var yOffset: CGFloat = 0
    var currentView: UIView?
    
    var firstTeamFirstInitialLocation: CGPoint = CGPoint(x: 0, y: 0)
    var firstTeamSecondInitialLocation: CGPoint = CGPoint(x: 0, y: 0)
    var secondTeamFirstInitialLocation: CGPoint = CGPoint(x: 0, y: 0)
    var secondTeamSecondInitialLocation: CGPoint = CGPoint(x: 0, y: 0)
    var serverInitialLocation: CGPoint = CGPoint(x: 0, y: 0)
    
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
        
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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

}




extension StartMatchViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isDragging == true && currentView != nil {
            isDragging = false
            
            if firstTeamFirstTargetView.frame.contains(finalLocation) {
                currentView!.frame.origin.x = firstTeamFirstTargetView.frame.origin.x
                currentView!.frame.origin.y = firstTeamFirstTargetView.frame.origin.y
            } else if firstTeamSecondTargetView.frame.contains(finalLocation) {
                currentView!.frame.origin.x = firstTeamSecondTargetView.frame.origin.x
                currentView!.frame.origin.y = firstTeamSecondTargetView.frame.origin.y
            } else if secondTeamFirstTargetView.frame.contains(finalLocation) {
                currentView!.frame.origin.x = secondTeamFirstTargetView.frame.origin.x
                currentView!.frame.origin.y = secondTeamFirstTargetView.frame.origin.y
            } else if secondTeamSecondTargetView.frame.contains(finalLocation) {
                currentView!.frame.origin.x = secondTeamSecondTargetView.frame.origin.x
                currentView!.frame.origin.y = secondTeamSecondTargetView.frame.origin.y
            } else {
                
                
                if currentView == firstTeamFirstTopView {
                    firstTeamFirstTopView.frame.origin.x = firstTeamFirstInitialLocation.x
                    firstTeamFirstTopView.frame.origin.y = firstTeamFirstInitialLocation.y
                } else if currentView == firstTeamSecondTopView {
                    firstTeamSecondTopView.frame.origin.x = firstTeamSecondInitialLocation.x
                    firstTeamSecondTopView.frame.origin.y = firstTeamSecondInitialLocation.y
                } else if currentView == secondTeamFirstTopView {
                    secondTeamFirstTopView.frame.origin.x = secondTeamFirstInitialLocation.x
                    secondTeamFirstTopView.frame.origin.y = secondTeamFirstInitialLocation.y
                } else if currentView == secondTeamSecondTopView {
                    secondTeamSecondTopView.frame.origin.x = secondTeamSecondInitialLocation.x
                    secondTeamSecondTopView.frame.origin.y = secondTeamSecondInitialLocation.y
                } else if currentView == serverView {
                    serverView.frame.origin.x = serverInitialLocation.x
                    serverView.frame.origin.y = serverInitialLocation.y
                }
                currentView = nil
            }
        }
    }
}
