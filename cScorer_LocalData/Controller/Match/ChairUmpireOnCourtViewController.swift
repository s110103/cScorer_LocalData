//
//  ChairUmpireOnCourtViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 11.12.20.
//

import UIKit

protocol ChairUmpireOnCourtViewControllerDelegate {
    func sendSelectedMatchChairUmpire(currentMatch: Match, selectedIndex: Int)
    func sendEditMatchFromChairUmpire(currentMatch: Match, selectedIndex: Int)
}

class ChairUmpireOnCourtViewController: UIViewController, AddMatchViewControllerDelegate {
    
    // MARK: - Variables
    var selectedIndex: Int = 0
    var currentMatch: Match = Match()
    var delegate: ChairUmpireOnCourtViewControllerDelegate?
    var percentageDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition!
    
    // MARK: - Outlets
    @IBOutlet weak var firstTeamLabel: UILabel!
    @IBOutlet weak var secondTeamLabel: UILabel!
    @IBOutlet weak var chairUmpireOnCourtButton: UIButton!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        chairUmpireOnCourtButton.layer.cornerRadius = 10
        chairUmpireOnCourtButton.layer.masksToBounds = true
        
        initLabels()
        addGesture()
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func editMatchButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: false)
        delegate?.sendEditMatchFromChairUmpire(currentMatch: currentMatch, selectedIndex: selectedIndex)
    }
    @IBAction func chairUmpireOnCourtButtonTapped(_ sender: UIButton) {
        currentMatch.matchStatistics.chairUmpireOnCourt = true
        currentMatch.matchStatistics.chairUmpireOnCourtTimeStamp = NSDate()
        navigationController?.popViewController(animated: false)
        delegate?.sendSelectedMatchChairUmpire(currentMatch: currentMatch, selectedIndex: selectedIndex)
    }
    
    @IBAction func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        let percent = max(panGesture.translation(in: view).x, 0) / view.frame.width
        
        switch panGesture.state {
        case .began:
            navigationController?.delegate = self
            navigationController?.popViewController(animated: true)
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
    
    // MARK: - Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "editMatchChairUmpireSegue":
            let destinationVC = segue.destination as! AddMatchViewController
            
            destinationVC.match = currentMatch
            destinationVC.editingDistinctMatch = true
            destinationVC.indexOfMatch = selectedIndex
            
            destinationVC.delegate = self
        default:
            return
        }
    }
    
    func addGesture() {
        guard (navigationController?.viewControllers.count)! > 1 else {
            return
        }
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(AddMatchViewController.handlePanGesture(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func initLabels() {
        if currentMatch.matchType.matchType == 0 {
            firstTeamLabel.text = "\(currentMatch.firstTeamFirstPlayerSurname) \(currentMatch.firstTeamFirstPlayer)"
            secondTeamLabel.text = "\(currentMatch.secondTeamFirstPlayerSurname) \(currentMatch.secondTeamFirstPlayer)"
        } else {
            firstTeamLabel.text = "\(currentMatch.firstTeamFirstPlayerSurname) \(currentMatch.firstTeamFirstPlayer) \n \(currentMatch.firstTeamSecondPlayerSurname) \(currentMatch.firstTeamSecondPlayer)"
            secondTeamLabel.text = "\(currentMatch.secondTeamFirstPlayerSurname) \(currentMatch.secondTeamFirstPlayer) \n \(currentMatch.secondTeamSecondPlayerSurname) \(currentMatch.secondTeamSecondPlayer)"
        }
    }

}

extension ChairUmpireOnCourtViewController: UINavigationControllerDelegate {
    
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
    
    func sendMatch(match: Match, editingDistinctMatch: Bool, indexOfMatch: Int) {
        currentMatch = match
        selectedIndex = indexOfMatch
    }
}
