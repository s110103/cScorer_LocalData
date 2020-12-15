//
//  AddPlayerViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 02.12.20.
//

import UIKit
import ProgressHUD

protocol AddPlayerViewControlerDelegate {
    func sendAddPlayerData(newPlayer: Player, editPlayer: Bool, indexOfPlayer: Int)
}

class AddPlayerViewController: UIViewController {
    
    // MARK: - Variables
    var editPlayer: Bool = false
    var indexOfPlayer: Int = 0
    var currentPlayer: Player = Player()
    var delegate: AddPlayerViewControlerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var addPlayerNameTextField: UITextField!
    @IBOutlet weak var addPlayerSurnameTextField: UITextField!
    @IBOutlet weak var addPlayerAbbreviationTextField: UITextField!
    @IBOutlet weak var addPlayerOriginTextField: UITextField!
    @IBOutlet weak var addPlayerClubTextField: UITextField!
    @IBOutlet weak var addPlayerGenderSegmentControl: UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initObjects()
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        if addPlayerNameTextField.text != "" || addPlayerSurnameTextField.text != "" {
            currentPlayer.firstName = addPlayerNameTextField.text!
            currentPlayer.surName = addPlayerSurnameTextField.text!
            currentPlayer.abbreviation = addPlayerAbbreviationTextField.text!
            currentPlayer.country = addPlayerOriginTextField.text!
            currentPlayer.tennisClub = addPlayerClubTextField.text!
            currentPlayer.gender = addPlayerGenderSegmentControl.selectedSegmentIndex
            
            delegate?.sendAddPlayerData(newPlayer: currentPlayer, editPlayer: editPlayer, indexOfPlayer: indexOfPlayer)
            
            dismiss(animated: true, completion: nil)
        } else {
            ProgressHUD.show("Name fehlt!", icon: .failed, interaction: false)
        }
    }
    
    // MARK: - Functions
    func initObjects() {
        addPlayerNameTextField.layer.cornerRadius = 5
        addPlayerNameTextField.attributedPlaceholder = NSAttributedString(string: "Vorname", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        addPlayerSurnameTextField.layer.cornerRadius = 5
        addPlayerSurnameTextField.attributedPlaceholder = NSAttributedString(string: "Nachname", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        addPlayerAbbreviationTextField.layer.cornerRadius = 5
        addPlayerAbbreviationTextField.attributedPlaceholder = NSAttributedString(string: "Kürzel", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        addPlayerOriginTextField.layer.cornerRadius = 5
        addPlayerOriginTextField.attributedPlaceholder = NSAttributedString(string: "Herkunftsland", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        addPlayerClubTextField.layer.cornerRadius = 5
        addPlayerClubTextField.attributedPlaceholder = NSAttributedString(string: "Tennisclub", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        saveButton.layer.cornerRadius = 5
        
        if editPlayer == true {
            addPlayerNameTextField.text = currentPlayer.firstName
            addPlayerSurnameTextField.text = currentPlayer.surName
            addPlayerAbbreviationTextField.text = currentPlayer.abbreviation
            addPlayerOriginTextField.text = currentPlayer.country
            addPlayerClubTextField.text = currentPlayer.tennisClub
            addPlayerGenderSegmentControl.selectedSegmentIndex = currentPlayer.gender
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}
