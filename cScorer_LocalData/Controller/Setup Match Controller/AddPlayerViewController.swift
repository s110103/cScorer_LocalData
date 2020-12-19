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
    
    var activeTextField: UITextField? = nil
    
    // MARK: - Outlets
    @IBOutlet weak var addPlayerNameTextField: UITextField!
    @IBOutlet weak var addPlayerSurnameTextField: UITextField!
    @IBOutlet weak var addPlayerAbbreviationTextField: UITextField!
    @IBOutlet weak var addPlayerOriginTextField: UITextField!
    @IBOutlet weak var addPlayerClubTextField: UITextField!
    @IBOutlet weak var addPlayerGenderSegmentControl: UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var addPlayerStackView: UIStackView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddPlayerViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddPlayerViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

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
    @objc func keyboardWillShow(notification: NSNotification) {
        
      guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
        return
      }

      var shouldMoveViewUp = false

      if let activeTextField = activeTextField {

        let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY;
        
        let topOfKeyboard = self.view.frame.height - keyboardSize.height
        
        if bottomOfTextField > topOfKeyboard {
          shouldMoveViewUp = true
        }
      }

      if(shouldMoveViewUp) {
        self.view.frame.origin.y = 0 - keyboardSize.height
        
      }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        view.endEditing(true)
    }
    
    func initObjects() {
        
        addPlayerStackView.isUserInteractionEnabled = true
        let tapInStackView = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        addPlayerStackView.addGestureRecognizer(tapInStackView)
        
        addPlayerNameTextField.delegate = self
        addPlayerSurnameTextField.delegate = self
        addPlayerAbbreviationTextField.delegate = self
        addPlayerOriginTextField.delegate = self
        addPlayerClubTextField.delegate = self
        
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

extension AddPlayerViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
}
