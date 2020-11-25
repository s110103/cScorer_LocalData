//
//  SetCourtViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 21.11.20.
//

import UIKit

protocol SetCourtViewControllerDelegate {
    func sendCourtData(court: String)
}

class SetCourtViewController: UIViewController {
    
    // MARK: - Variables
    var court: String = ""
    var delegate: SetCourtViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var setCourtView: UIView!
    @IBOutlet weak var courtTextField: UITextField!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setCourtView.layer.cornerRadius = 10
        setCourtView.layer.masksToBounds = true
        
        courtTextField.text = court
    }
    
    // MARK: - Functions
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        delegate?.sendCourtData(court: courtTextField.text!)
        dismiss(animated: true, completion: nil)
    }
    
}
