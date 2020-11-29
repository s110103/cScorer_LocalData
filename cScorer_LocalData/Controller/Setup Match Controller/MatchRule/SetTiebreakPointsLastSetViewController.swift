//
//  SetTiebreakPointsLastSetViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 28.11.20.
//

import UIKit

protocol SetTiebreakPointsLastSetViewControllerDelegate {
    func sendTiebreakPointsLastSetData(tiebreakPointsLastSet: Int)
}

class SetTiebreakPointsLastSetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Variables
    var tiebreakPointsLastSet: Int = 0
    var selectedCell: SelectorTableViewCell?
    var selectablePoints: [String] =
    [
        "0 Punkte",
        "1 Punkte",
        "2 Punkte",
        "3 Punkte",
        "4 Punkte",
        "5 Punkte",
        "6 Punkte",
        "7 Punkte",
        "8 Punkte",
        "9 Punkte",
        "10 Punkte"
    ]
    let circleUnselected = UIImage(systemName: "circle")
    let circleSelected = UIImage(systemName: "dot.circle")
    var delegate: SetTiebreakPointsLastSetViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var setTiebreakPointsLastSetView: UIView!
    @IBOutlet weak var setTiebreakPointsLastSetTableView: UITableView!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setTiebreakPointsLastSetView.layer.cornerRadius = 10
        setTiebreakPointsLastSetView.layer.masksToBounds = true
        
        setTiebreakPointsLastSetTableView.delegate = self
        setTiebreakPointsLastSetTableView.dataSource = self
        setTiebreakPointsLastSetTableView.rowHeight = 44
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectablePoints.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = setTiebreakPointsLastSetTableView.dequeueReusableCell(withIdentifier: "selectorCell", for: indexPath) as! SelectorTableViewCell
        
        let row = indexPath.row
        
        cell.titleLabel.text = selectablePoints[row]
        
        if tiebreakPointsLastSet == row {
            cell.stateImage.image = circleSelected
            selectedCell = cell
        } else {
            cell.stateImage.image = circleUnselected
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setTiebreakPointsLastSetTableView.deselectRow(at: indexPath, animated: true)
        let newCell = setTiebreakPointsLastSetTableView.dequeueReusableCell(withIdentifier: "selectorCell", for: indexPath) as! SelectorTableViewCell
        selectedCell?.imageView?.image = circleUnselected
        newCell.stateImage.image = circleSelected
        
        delegate?.sendTiebreakPointsLastSetData(tiebreakPointsLastSet: indexPath.row)
        dismiss(animated: true, completion: nil)
    }

}
