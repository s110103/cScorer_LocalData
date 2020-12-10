//
//  SetTrueFalseViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 28.11.20.
//

import UIKit

protocol SetTrueFalseViewControllerDelegate {
    func sendTrueFalseData(selectedBool: Bool, currentHeading: String)
}

class SetTrueFalseViewController: UIViewController {
    
    // MARK: - Variables
    var selectedBool: Bool = false
    var currentHeading: String = ""
    var delegate: SetTrueFalseViewControllerDelegate?
    
    let circleUnselected = UIImage(systemName: "circle")
    let circleSelected = UIImage(systemName: "dot.circle")
    
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
        
        setTrueFalseLabel.text = currentHeading
        
        switch selectedBool {
        case true:
            setTrueButton.setImage(circleSelected, for: .normal)
            setFalseButton.setImage(circleUnselected, for: .normal)
        case false:
            setTrueButton.setImage(circleUnselected, for: .normal)
            setFalseButton.setImage(circleSelected, for: .normal)
        default:
            break
        }
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func selectorButtonTapped(_ sender: UIButton) {
        let title = sender.title(for: .normal)
        
        switch title {
        case "Ja":
            selectedBool = true
            setTrueButton.setImage(circleSelected, for: .normal)
            setFalseButton.setImage(circleUnselected, for: .normal)
            delegate?.sendTrueFalseData(selectedBool: selectedBool, currentHeading: currentHeading)
        case "Nein":
            selectedBool = false
            setTrueButton.setImage(circleUnselected, for: .normal)
            setFalseButton.setImage(circleSelected, for: .normal)
            delegate?.sendTrueFalseData(selectedBool: selectedBool, currentHeading: currentHeading)
        default:
            break
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
    

}
