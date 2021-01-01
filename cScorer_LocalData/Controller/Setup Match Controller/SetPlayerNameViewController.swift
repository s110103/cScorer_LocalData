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
    
    var activeTextField: UITextField? = nil
    
    // MARK: - Outlets
    @IBOutlet weak var setPlayerNameView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var setPlayerHeadingLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddPlayerViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddPlayerViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setPlayerNameView.layer.cornerRadius = 10
        setPlayerNameView.layer.masksToBounds = true
        
        nameTextField.layer.cornerRadius = 5
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Vorname", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        surnameTextField.layer.cornerRadius = 5
        surnameTextField.attributedPlaceholder = NSAttributedString(string: "Nachname", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        setPlayerHeadingLabel.text = "Spieler \(selectedPlayer)"
        nameTextField.text = selectedPlayerName
        surnameTextField.text = selectedPlayerSurname
        
        view.endEditing(true)
    }

    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        nameTextField.text = removeBlankspaces(input: nameTextField.text!)
        surnameTextField.text = removeBlankspaces(input: surnameTextField.text!)
        delegate?.sendPlayerNameData(selectedPlayer: selectedPlayer, selectedPlayerName: nameTextField.text!, selectedPlayerSurname: surnameTextField.text!)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
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
    
    func removeBlankspaces(input: String) -> String {
        var temporaryString: String = input
        if temporaryString.hasPrefix(" ") {
            temporaryString = String(temporaryString.dropFirst())
            temporaryString = removeBlankspaces(input: temporaryString)
        }
        
        if temporaryString.hasSuffix(" ") {
            temporaryString = String(temporaryString.dropLast())
            temporaryString = removeBlankspaces(input: temporaryString)
        }
        
        return temporaryString
    }
}

extension SetPlayerNameViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
}
