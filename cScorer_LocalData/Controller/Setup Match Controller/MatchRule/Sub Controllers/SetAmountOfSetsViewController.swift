//
//  SetAmountOfSetsViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 28.11.20.
//

import UIKit

protocol SetAmountOfSetsViewControllerDelegate {
    func sendAmountOfSetsData(amountOfSets: Int)
}

class SetAmountOfSetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Variables
    var selectedAmount: Int = 0
    var selectedCell: SelectorTableViewCell?
    var selectableSets: [String] =
    [
        "0 Sätze",
        "1 Satz",
        "3 Sätze",
        "5 Sätze"
    ]
    let circleUnselected = UIImage(systemName: "circle")
    let circleSelected = UIImage(systemName: "dot.circle")
    var delegate: SetAmountOfSetsViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var setSetsView: UIView!
    @IBOutlet weak var setSetsTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setSetsView.layer.cornerRadius = 10
        setSetsView.layer.masksToBounds = true
        
        setSetsTableView.delegate = self
        setSetsTableView.dataSource = self
        setSetsTableView.rowHeight = 44
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectableSets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = setSetsTableView.dequeueReusableCell(withIdentifier: "selectorCell", for: indexPath) as! SelectorTableViewCell
        
        let row = indexPath.row
        
        cell.titleLabel.text = selectableSets[row]
        
        if selectedAmount == row {
            cell.stateImage.image = circleSelected
            selectedCell = cell
        } else {
            cell.stateImage.image = circleUnselected
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setSetsTableView.deselectRow(at: indexPath, animated: true)
        let newCell = setSetsTableView.dequeueReusableCell(withIdentifier: "selectorCell", for: indexPath) as! SelectorTableViewCell
        selectedCell?.imageView?.image = circleUnselected
        newCell.stateImage.image = circleSelected
        
        delegate?.sendAmountOfSetsData(amountOfSets: indexPath.row)
        dismiss(animated: true, completion: nil)
    }

}
