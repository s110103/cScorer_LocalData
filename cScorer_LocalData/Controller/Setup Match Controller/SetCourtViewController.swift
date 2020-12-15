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
        
        courtTextField.layer.cornerRadius = 5
        courtTextField.attributedPlaceholder = NSAttributedString(string: "Court", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        courtTextField.text = court
    }
    
    // MARK: - Functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        
        let court = courtTextField.text!
        
        if court != "" {
            delegate?.sendCourtData(court: court)
        } else {
            delegate?.sendCourtData(court: "-")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}
