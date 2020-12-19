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
    
    var activeTextField: UITextField? = nil
    
    // MARK: - Outlets
    @IBOutlet weak var setCourtView: UIView!
    @IBOutlet weak var courtTextField: UITextField!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddPlayerViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddPlayerViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setCourtView.layer.cornerRadius = 10
        setCourtView.layer.masksToBounds = true
        
        courtTextField.layer.cornerRadius = 5
        courtTextField.attributedPlaceholder = NSAttributedString(string: "Court", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        courtTextField.text = court
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

extension SetCourtViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
}
