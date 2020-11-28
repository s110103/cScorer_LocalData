//
//  SetTiebreakPointsLastSetViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 28.11.20.
//

import UIKit

protocol SetTiebreakPointsLastSetViewControllerDelegate {
    func sendTiebreakPointsLastSetData(tiebreakPointsLastSet: Int)
}

class SetTiebreakPointsLastSetViewController: UIViewController {
    
    // MARK: - Variables
    var tiebreakPointsLastSet: Int = 0
    var delegate: SetTiebreakPointsLastSetViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var setTiebreakPointsLastSetView: UIView!
    @IBOutlet weak var setTiebreakPointsLastSetTableView: UITableView!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setTiebreakPointsLastSetView.layer.cornerRadius = 10
        setTiebreakPointsLastSetView.layer.masksToBounds = true
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions

}
