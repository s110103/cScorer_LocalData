//
//  SetPlayerNameViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 21.11.20.
//

import UIKit

protocol SetPlayerNameViewControllerDelegate {
    func sendPlayerNameData(selectedPlayer: String, selectedPlayerName: String, selectedPlayerSurname: String)
}

class SetPlayerNameViewController: UIViewController {
    
    // MARK: - Variables
    var selectedPlayer: String = ""
    var selectedPlayerName: String = ""
    var selectedPlayerSurname: String = ""
    var delegate: SetPlayerNameViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var setPlayerNameView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var setPlayerHeadingLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setPlayerNameView.layer.cornerRadius = 10
        setPlayerNameView.layer.masksToBounds = true
        
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Vorname", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        surnameTextField.attributedPlaceholder = NSAttributedString(string: "Nachname", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        setPlayerHeadingLabel.text = "Spieler \(selectedPlayer)"
        nameTextField.text = selectedPlayerName
        surnameTextField.text = selectedPlayerSurname
        
        view.endEditing(true)
    }
    
    // MARK: - Functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        delegate?.sendPlayerNameData(selectedPlayer: selectedPlayer, selectedPlayerName: nameTextField.text!, selectedPlayerSurname: surnameTextField.text!)
        dismiss(animated: true, completion: nil)
    }
}
