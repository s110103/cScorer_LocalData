//
//  SetAmountOfSetsViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 28.11.20.
//

import UIKit

protocol SetAmountOfSetsViewControllerDelegate {
    func sendAmountOfSetsData(amountOfSets: Int)
}

class SetAmountOfSetsViewController: UIViewController {

    // MARK: - Variables
    var amountOfSets: Int = 0
    var delegate: SetAmountOfSetsViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var setSetsView: UIView!
    @IBOutlet weak var setSetsTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setSetsView.layer.cornerRadius = 10
        setSetsView.layer.masksToBounds = true
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions

}
