//
//  EditDistinctTournamentDataViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 26.11.20.
//

import UIKit

protocol EditDistinctTournamendDataViewControllerDelegate {
    func sendDistinctTournamendDate(_dataType: String, _distinctTournamentData: String)
}

class EditDistinctTournamentDataViewController: UIViewController {
    
    // MARK: - Variables
    var selectedItem: String = ""
    var distinctTournamentData: String = ""
    var delegate: EditDistinctTournamendDataViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var tournamentDataLabel: UILabel!
    @IBOutlet weak var tournamentDataTextField: UITextField!
    @IBOutlet weak var tournamentDataView: UIView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tournamentDataView.layer.cornerRadius = 10
        tournamentDataView.layer.masksToBounds = true
        
        tournamentDataLabel.text = selectedItem
        tournamentDataTextField.text = distinctTournamentData
        tournamentDataTextField.placeholder = selectedItem
        
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        delegate?.sendDistinctTournamendDate(_dataType: selectedItem, _distinctTournamentData: tournamentDataTextField.text!)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions

}
