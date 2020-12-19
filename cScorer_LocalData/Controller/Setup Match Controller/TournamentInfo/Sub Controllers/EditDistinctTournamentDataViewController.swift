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
    
    var activeTextField: UITextField? = nil
    
    // MARK: - Outlets
    @IBOutlet weak var tournamentDataLabel: UILabel!
    @IBOutlet weak var tournamentDataTextField: UITextField!
    @IBOutlet weak var tournamentDataView: UIView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddPlayerViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddPlayerViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        tournamentDataView.layer.cornerRadius = 10
        tournamentDataView.layer.masksToBounds = true
        
        tournamentDataTextField.layer.cornerRadius = 5
        tournamentDataTextField.attributedPlaceholder = NSAttributedString(string: selectedItem, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
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
}

extension EditDistinctTournamentDataViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
}
