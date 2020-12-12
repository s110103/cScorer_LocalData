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
    
    var percentageDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition!
    
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
    
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        firstTeamFirstTopView.isUserInteractionEnabled = true
        firstTeamSecondTopView.isUserInteractionEnabled = true
        secondTeamFirstTopView.isUserInteractionEnabled = true
        firstTeamSecondTopView.isUserInteractionEnabled = true
        
        firstTeamFirstInitialLocation.x = firstTeamFirstTopView.frame.origin.x
        firstTeamFirstInitialLocation.y = firstTeamFirstTopView.frame.origin.y
        firstTeamSecondInitialLocation.x = firstTeamSecondTopView.frame.origin.x
        firstTeamSecondInitialLocation.y = firstTeamSecondTopView.frame.origin.y
        secondTeamFirstInitialLocation.x = secondTeamFirstTopView.frame.origin.x
        secondTeamFirstInitialLocation.y = secondTeamFirstTopView.frame.origin.y
        secondTeamSecondInitialLocation.x = secondTeamSecondTopView.frame.origin.x
        secondTeamSecondInitialLocation.y = secondTeamSecondTopView.frame.origin.y
        
        addGesture()
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
    
    @IBAction func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        if isDragging == false {
            let percent = max(panGesture.translation(in: view).x, 0) / view.frame.width
            
            switch panGesture.state {
            case .began:
                navigationController?.delegate = self
                navigationController?.popViewController(animated: true)
                delegate?.sendStartMatchData(currentMatch: currentMatch, selectedIndex: selectedIndex)
                
            case .changed:
                percentageDrivenInteractiveTransition.update(percent)
                
            case .ended:
                let velocity = panGesture.velocity(in: view).x
                    
                if percent > 0.5 || velocity > 1000 {
                    percentageDrivenInteractiveTransition.finish()
                } else {
                    percentageDrivenInteractiveTransition.cancel()
                }
                
            case .cancelled, .failed:
                percentageDrivenInteractiveTransition.cancel()
                
            default:
                break
            }
        }
    }
    
    // MARK: - Functions
    func addGesture() {
        guard (navigationController?.viewControllers.count)! > 1 else {
            return
        }
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(AddMatchViewController.handlePanGesture(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }

}




extension StartMatchViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
                
        let touchedLocation = touch.location(in: view)
        
        let location = touch.location(in: firstTeamFirstTopView)
        xOffset = location.x
        yOffset = location.y
        
        if firstTeamFirstTopView.bounds.contains(location) {
            isDragging = true
            finalLocation = touchedLocation
        }
        
        /*
         
         if touchedLocation.x >= firstTeamFirstTopView.frame.minX && touchedLocation.x <= firstTeamFirstTopView.frame.maxX && touchedLocation.y >= firstTeamFirstTopView.frame.minY && touchedLocation.y <= firstTeamFirstTopView.frame.maxY {
             
             print("First Player First View")
             
             let location = touch.location(in: firstTeamFirstTopView)
             xOffset = location.x
             yOffset = location.y
             
             
             
             
             if firstTeamFirstTopView.bounds.contains(location) {
                 isDragging = true
                 finalLocation = touchedLocation
                 currentView = firstTeamFirstTopView
             }
         }
         
         else if touchedLocation.x >= firstTeamSecondTopView.frame.minX && touchedLocation.x <= firstTeamSecondTopView.frame.maxX && touchedLocation.y >= firstTeamSecondTopView.frame.minY && touchedLocation.y <= firstTeamSecondTopView.frame.maxY {
            print("First Player Second View")
            
            let location = touch.location(in: firstTeamSecondTopView)
            xOffset = location.x
            yOffset = location.y
            finalLocation = touchedLocation
            
            isDragging = true
            currentView = firstTeamSecondTopView
        } else if touchedLocation.x >= secondTeamFirstTopView.frame.minX && touchedLocation.x <= secondTeamFirstTopView.frame.maxX && touchedLocation.y >= secondTeamFirstTopView.frame.minY && touchedLocation.y <= secondTeamFirstTopView.frame.maxY {
            print("Second Player First View")
            
            let location = touch.location(in: secondTeamFirstTopView)
            xOffset = location.x
            yOffset = location.y
            finalLocation = touchedLocation
            
            isDragging = true
            currentView = secondTeamFirstTopView
        } else if touchedLocation.x >= secondTeamSecondTopView.frame.minX && touchedLocation.x <= secondTeamSecondTopView.frame.maxX && touchedLocation.y >= secondTeamSecondTopView.frame.minY && touchedLocation.y <= secondTeamSecondTopView.frame.maxY {
            print("Second Player Second View")
            
            let location = touch.location(in: secondTeamSecondTopView)
            xOffset = location.x
            yOffset = location.y
            finalLocation = touchedLocation
            
            isDragging = true
            currentView = secondTeamSecondTopView
        } else if touchedLocation.x >= serverView.frame.minX && touchedLocation.x <= serverView.frame.maxX && touchedLocation.y >= serverView.frame.minY && touchedLocation.y <= serverView.frame.maxY {
            print("Server View")
            
            let location = touch.location(in: serverView)
            xOffset = location.x
            yOffset = location.y
            finalLocation = touchedLocation
            
            isDragging = true
            currentView = serverView
        }
         */
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging, let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: view)
        firstTeamFirstTopView.frame.origin.x = location.x - xOffset
        firstTeamFirstTopView.frame.origin.y = location.y - yOffset
        
        finalLocation = location
        
        /*
         if currentView != nil {
             print("not nil")
             let location = touch.location(in: view)
             currentView?.frame.origin.x = location.x - xOffset
             currentView?.frame.origin.y = location.y - yOffset
             
             finalLocation = location
         } else {
             print("nil")
         }
         */
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        if isDragging == true {
            isDragging = false
            
            if firstTeamFirstTargetView.frame.contains(finalLocation) {
                firstTeamFirstTopView.frame.origin.x = firstTeamSecondTargetView.frame.origin.x
                firstTeamFirstTopView.frame.origin.y = firstTeamSecondTargetView.frame.origin.y
            } else {
                if secondTeamFirstTargetView.frame.contains(finalLocation) {
                    firstTeamFirstTopView.frame.origin.x = secondTeamFirstTargetView.frame.origin.x
                    firstTeamFirstTopView.frame.origin.y = secondTeamFirstTargetView.frame.origin.y
                } else {
                    firstTeamFirstTopView.frame.origin.x = firstTeamFirstInitialLocation.x
                    firstTeamFirstTopView.frame.origin.y = firstTeamFirstInitialLocation.y
                }
            }
        }
        
        
        /*
         
         if isDragging == true {
             isDragging = false
             
             if firstTeamFirstTargetView.frame.contains(finalLocation) {
                 currentView?.frame.origin.x = firstTeamFirstTargetView.frame.origin.x
                 currentView?.frame.origin.y = firstTeamFirstTargetView.frame.origin.y
             }
         }
         
         else if firstTeamSecondTargetView.frame.contains(finalLocation) {
            currentView?.frame.origin.x = firstTeamSecondTargetView.frame.origin.x
            currentView?.frame.origin.y = firstTeamSecondTargetView.frame.origin.y
        } else if secondTeamFirstTargetView.frame.contains(finalLocation) {
            currentView?.frame.origin.x = secondTeamFirstTargetView.frame.origin.x
            currentView?.frame.origin.y = secondTeamFirstTargetView.frame.origin.y
        } else if secondTeamSecondTargetView.frame.contains(finalLocation) {
            currentView?.frame.origin.x = secondTeamSecondTargetView.frame.origin.x
            currentView?.frame.origin.y = secondTeamSecondTargetView.frame.origin.y
        } else {
            
        }
         */
        
    }
}

extension StartMatchViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideAnimatedTransitioning()
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        navigationController.delegate = nil
        
        if panGestureRecognizer.state == .began {
            percentageDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
            percentageDrivenInteractiveTransition.completionCurve = .easeOut
        } else {
            percentageDrivenInteractiveTransition = nil
        }
        
        return percentageDrivenInteractiveTransition
    }
}
