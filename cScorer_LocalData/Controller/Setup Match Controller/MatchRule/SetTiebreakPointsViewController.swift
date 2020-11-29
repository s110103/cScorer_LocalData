//
//  SetTiebreakPointsViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 28.11.20.
//

import UIKit

protocol SetTiebreakPointsViewControllerDelegate {
    func sendTiebreakPointsData(tiebreakPoints: Int)
}

class SetTiebreakPointsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Variables
    var tiebreakPoints: Int = 0
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
    var delegate: SetTiebreakPointsViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var setTiebreakPointsView: UIView!
    @IBOutlet weak var setTiebreakPointsTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setTiebreakPointsView.layer.cornerRadius = 10
        setTiebreakPointsView.layer.masksToBounds = true
        
        setTiebreakPointsTableView.delegate = self
        setTiebreakPointsTableView.dataSource = self
        setTiebreakPointsTableView.rowHeight = 44
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
        let cell = setTiebreakPointsTableView.dequeueReusableCell(withIdentifier: "selectorCell", for: indexPath) as! SelectorTableViewCell
        
        let row = indexPath.row
        
        cell.titleLabel.text = selectablePoints[row]
        
        if tiebreakPoints == row {
            cell.stateImage.image = circleSelected
            selectedCell = cell
        } else {
            cell.stateImage.image = circleUnselected
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setTiebreakPointsTableView.deselectRow(at: indexPath, animated: true)
        let newCell = setTiebreakPointsTableView.dequeueReusableCell(withIdentifier: "selectorCell", for: indexPath) as! SelectorTableViewCell
        selectedCell?.imageView?.image = circleUnselected
        newCell.stateImage.image = circleSelected
        
        delegate?.sendTiebreakPointsData(tiebreakPoints: indexPath.row)
        dismiss(animated: true, completion: nil)
    }

}
