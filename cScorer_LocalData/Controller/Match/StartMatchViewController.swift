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
    
    // MARK: - Outlets

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    
    // MARK: - Functions

}
