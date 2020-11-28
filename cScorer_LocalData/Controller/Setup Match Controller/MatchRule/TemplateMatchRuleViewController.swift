//
//  TemplateMatchRuleViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 28.11.20.
//

import UIKit

protocol TemplateMatchRuleViewControllerDelegate {
    func sendTemplateMatchRuleData(selectedTemplate: Int)
}

class TemplateMatchRuleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Variables
    var selectedTemplate: Int = 0
    var selectedCell: SelectorTableViewCell?
    var selectableTemplates: [String] =
    [
        "Standard Match - 3 Sätze",
        "Standard Match - 1 Satz",
        "3 Sätze, Match TieBreak, NoAd",
        "4 Games Pro Satz",
        "8 Games Pro Satz",
        "10 Games Pro Satz",
        "4 Games 1 Satz",
        "4 Games 3 Satz",
        "TieBreak",
        "Match Tiebreak",
        "Benutzerdefiniert"
    ]
    let circleUnselected = UIImage(systemName: "circle")
    let circleSelected = UIImage(systemName: "dot.circle")
    var delegate: TemplateMatchRuleViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var templateView: UIView!
    @IBOutlet weak var templateTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        templateView.layer.cornerRadius = 10
        templateView.layer.masksToBounds = true
        
        templateTableView.delegate = self
        templateTableView.dataSource = self
        templateTableView.rowHeight = 44
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        selectableTemplates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = templateTableView.dequeueReusableCell(withIdentifier: "selectorCell", for: indexPath) as! SelectorTableViewCell
        
        let row = indexPath.row
        
        cell.titleLabel.text = selectableTemplates[row]
        
        if selectedTemplate == row {
            cell.stateImage.image = circleSelected
            selectedCell = cell
        } else {
            cell.stateImage.image = circleUnselected
        }
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        delegate?.sendTemplateMatchRuleData(selectedTemplate: indexPath.row)
        
        if selectedCell != nil {
            selectedCell?.stateImage.image = circleUnselected
        }
        let cell = templateTableView.dequeueReusableCell(withIdentifier: "selectorCell", for: indexPath) as! SelectorTableViewCell
        cell.stateImage.image = circleSelected
        
                
        templateTableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true, completion: nil)
    }

}
