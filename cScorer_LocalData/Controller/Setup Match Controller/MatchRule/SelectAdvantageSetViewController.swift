//
//  SelectAdvantageSetViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 28.11.20.
//

import UIKit

protocol SelectAdvantageSetViewControllerDelegate {
    func sendAdvantageSetData(advantageSet: Int)
}

class SelectAdvantageSetViewController: UIViewController {
    
    // MARK: - Variables
    var advantageSet: Int = 0
    var delegate: SelectAdvantageSetViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var advantageSetView: UIView!
    @IBOutlet weak var advantageSetTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        advantageSetView.layer.cornerRadius = 10
        advantageSetView.layer.masksToBounds = true
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions

}
