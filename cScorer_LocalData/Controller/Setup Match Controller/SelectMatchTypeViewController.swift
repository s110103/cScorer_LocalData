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
    
    // MARK: - Outlets
    @IBOutlet weak var singlesButton: UIButton!
    @IBOutlet weak var doublesButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
        
        switch matchType {
        case 0:
            singlesButton.imageView?.image = UIImage(systemName: "dot.circle")
            doublesButton.imageView?.image = UIImage(systemName: "circle")
        case 1:
            singlesButton.imageView?.image = UIImage(systemName: "circle")
            doublesButton.imageView?.image = UIImage(systemName: "dot.circle")
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onDidReceiveData(_:)), name: .didReceiveData, object: nil)
    }
    
    @objc func onDidReceiveData(_ notification:Notification) {
        if let data = notification.userInfo as? [String: Int]
            {
                for (name, score) in data
                {
                    print("\(name) scored \(score) points!")
                }
            }
    }

    // MARK: - Actions
    @IBAction func selectorButtonTapped(_ sender: UIButton) {
        let title = sender.title(for: .normal)
        
        switch title {
        case "Einzel":
            matchType = 0
            singlesButton.imageView?.image = UIImage(systemName: "dot.circle")
            doublesButton.imageView?.image = UIImage(systemName: "circle")
        case "Doppel":
            matchType = 1
            singlesButton.imageView?.image = UIImage(systemName: "circle")
            doublesButton.imageView?.image = UIImage(systemName: "dot.circle")
        default: break
        }
        
        delegate?.sendMatchType(matchType: matchType)
        
        dismiss(animated: true, completion: nil)

    }
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
