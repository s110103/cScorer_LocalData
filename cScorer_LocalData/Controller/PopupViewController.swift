//
//  PopupViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 13.11.20.
//

import UIKit

class PopupViewController: UIViewController {
    
    @IBOutlet weak var popupView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        popupView.layer.cornerRadius = 10
        popupView.layer.masksToBounds = true
    }

    @IBAction func closePopupButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
