//
//  WarmupInfoViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 30.12.20.
//

import UIKit

protocol WarmupInfoViewControllerDelegate {
    func dismissWarmupInfo()
}

class WarmupInfoViewController: UIViewController {
    
    // MARK: - Variables
    var currentMatch: Match?
    var delegate: WarmupInfoViewControllerDelegate?
    
    // MARK: - Outlets

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    
    // MARK: - Functions

}
