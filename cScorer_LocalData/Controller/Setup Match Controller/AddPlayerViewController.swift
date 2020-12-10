//
//  AddPlayerViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 02.12.20.
//

import UIKit
import ProgressHUD

protocol AddPlayerViewControlerDelegate {
    func sendAddPlayerData(newPlayer: Player)
}

class AddPlayerViewController: UIViewController {
    
    // MARK: - Variables
    var newPlayer: Player = Player()
    var delegate: AddPlayerViewControlerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var addPlayerNameTextField: UITextField!
    @IBOutlet weak var addPlayerSurnameTextField: UITextField!
    @IBOutlet weak var addPlayerAbbreviationTextField: UITextField!
    @IBOutlet weak var addPlayerOriginTextField: UITextField!
    @IBOutlet weak var addPlayerClubTextField: UITextField!
    @IBOutlet weak var addPlayerGenderSegmentControl: UISegmentedControl!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        if addPlayerNameTextField.text != "" || addPlayerSurnameTextField.text != "" {
            newPlayer.firstName = addPlayerNameTextField.text!
            newPlayer.surName = addPlayerSurnameTextField.text!
            newPlayer.abbreviation = addPlayerAbbreviationTextField.text!
            newPlayer.country = addPlayerOriginTextField.text!
            newPlayer.tennisClub = addPlayerClubTextField.text!
            newPlayer.gender = addPlayerGenderSegmentControl.selectedSegmentIndex
            
            delegate?.sendAddPlayerData(newPlayer: newPlayer)
            
            dismiss(animated: true, completion: nil)
        } else {
            ProgressHUD.show("Name fehlt!", icon: .failed, interaction: false)
        }
    }
    
    // MARK: - Functions

}
