//
//  SetAmountOfGamesViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 28.11.20.
//

import UIKit

protocol SetAmountOfGamesViewControllerDelegate {
    func sendAmountOfGamesData(amountOfGames: Int)
}

class SetAmountOfGamesViewController: UIViewController {

    // MARK: - Variables
    var amountOfGames: Int = 0
    var delegate: SetAmountOfGamesViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var setGamesView: UIView!
    @IBOutlet weak var setGamesTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setGamesView.layer.cornerRadius = 10
        setGamesView.layer.masksToBounds = true
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions

}
