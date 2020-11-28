//
//  SetTiebreakAtViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 28.11.20.
//

import UIKit

protocol SetTiebreakAtViewControllerDelegate {
    func sendTiebreakAtData(tiebreakAt: Int)
}

class SetTiebreakAtViewController: UIViewController {

    // MARK: - Variables
    var tiebreakAt: Int = 0
    var delegate: SetTiebreakAtViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var setTiebreakAtView: UIView!
    @IBOutlet weak var setTiebreakAtTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setTiebreakAtView.layer.cornerRadius = 10
        setTiebreakAtView.layer.masksToBounds = true
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions

}
