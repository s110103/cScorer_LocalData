//
//  SetTiebreakPointsViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 28.11.20.
//

import UIKit

protocol SetTiebreakPointsViewControllerDelegate {
    func sendTiebreakPointsData(tiebreakPoints: Int)
}

class SetTiebreakPointsViewController: UIViewController {

    // MARK: - Variables
    var tiebreakPoints: Int = 0
    var delegate: SetTiebreakPointsViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var setTiebreakPointsView: UIView!
    @IBOutlet weak var setTiebreakPointsTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setTiebreakPointsView.layer.cornerRadius = 10
        setTiebreakPointsView.layer.masksToBounds = true
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions

}
