//
//  SelectMatchTypeViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 13.11.20.
//

import UIKit

protocol SelectMatchTypeViewControllerDelegate {
    func sendMatchType(matchType: Int)
}

class SelectMatchTypeViewController: UIViewController {
    
    // MARK: - Variables
    var matchType: Int = 0
    var delegate: SelectMatchTypeViewControllerDelegate?
    
    let circleUnselected = UIImage(systemName: "circle")
    let circleSelected = UIImage(systemName: "dot.circle")
    
    // MARK: - Outlets
    @IBOutlet weak var singlesButton: UIButton!
    @IBOutlet weak var doublesButton: UIButton!
    @IBOutlet weak var matchTypeView: UIView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        matchTypeView.layer.cornerRadius = 10
        matchTypeView.layer.masksToBounds = true
        
        switch matchType {
        case 0:
            singlesButton.setImage(circleSelected, for: .normal)
            doublesButton.setImage(circleUnselected, for: .normal)
        case 1:
            singlesButton.setImage(circleUnselected, for: .normal)
            doublesButton.setImage(circleSelected, for: .normal)
        default:
            break
        }
    }

    // MARK: - Actions
    @IBAction func selectorButtonTapped(_ sender: UIButton) {
        let title = sender.title(for: .normal)
        
        switch title {
        case "Singles":
            matchType = 0
            singlesButton.setImage(circleSelected, for: .normal)
            doublesButton.setImage(circleUnselected, for: .normal)
        case "Doubles":
            matchType = 1
            singlesButton.setImage(circleUnselected, for: .normal)
            doublesButton.setImage(circleSelected, for: .normal)
        default: break
        }
        
        delegate?.sendMatchType(matchType: matchType)
                
        dismiss(animated: true, completion: nil)

    }
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
