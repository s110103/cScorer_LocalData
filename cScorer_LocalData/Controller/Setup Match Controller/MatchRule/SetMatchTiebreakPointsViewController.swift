//
//  SetMatchTiebreakPointsViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 28.11.20.
//

import UIKit

protocol SetMatchTiebreakPointsViewControllerDelegate {
    func sendMatchTiebreakPointsData(matchTiebreakPoints: Int)
}

class SetMatchTiebreakPointsViewController: UIViewController {

    // MARK: - Variables
    var matchTiebreakPoints: Int = 0
    var delegate: SetMatchTiebreakPointsViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var setMatchTiebreakPointsView: UIView!
    @IBOutlet weak var setMatchTiebreakPointsTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setMatchTiebreakPointsView.layer.cornerRadius = 10
        setMatchTiebreakPointsView.layer.masksToBounds = true
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions

}
