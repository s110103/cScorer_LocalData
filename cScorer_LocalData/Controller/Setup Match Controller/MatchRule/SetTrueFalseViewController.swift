//
//  SetTrueFalseViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 28.11.20.
//

import UIKit

protocol SetTrueFalseViewControllerDelegate {
    func sendTrueFalseData(selectedBool: Bool)
}

class SetTrueFalseViewController: UIViewController {
    
    // MARK: - Variables
    var selectedBool: Bool = false
    var delegate: SetTrueFalseViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var setTrueFalseView: UIView!
    @IBOutlet weak var setTrueFalseLabel: UILabel!
    @IBOutlet weak var setTrueButton: UIButton!
    @IBOutlet weak var setFalseButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setTrueFalseView.layer.cornerRadius = 10
        setTrueFalseView.layer.masksToBounds = true
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func selectorButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
    

}
