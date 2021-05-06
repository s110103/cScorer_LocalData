//
//  SetBallChangeViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 29.11.20.
//

import UIKit

protocol SetBallChangeViewControllerDelegate {
    func sendBallChangeData(selectedBallChange: Int)
}

class SetBallChangeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Varibles
    var selectedBallChange: Int = 0
    var selectedCell: SelectorTableViewCell?
    var selectableBallChanges: [String] =
    [
        "No Ballchange",
        "7/9",
        "9/11",
        "11/13",
        "3. Satz"
    ]
    
    let circleUnselected = UIImage(systemName: "circle")
    let circleSelected = UIImage(systemName: "dot.circle")
    
    var delegate: SetBallChangeViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var setBallChangeTableView: UITableView!
    @IBOutlet weak var setBallChangeView: UIView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setBallChangeView.layer.cornerRadius = 10
        setBallChangeView.layer.masksToBounds = true
        
        setBallChangeTableView.delegate = self
        setBallChangeTableView.dataSource = self
        setBallChangeTableView.rowHeight = 44
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectableBallChanges.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = setBallChangeTableView.dequeueReusableCell(withIdentifier: "selectorCell", for: indexPath) as! SelectorTableViewCell
        
        let row = indexPath.row
        
        cell.titleLabel.text = selectableBallChanges[row]
        
        if selectedBallChange == row {
            cell.stateImage.image = circleSelected
            selectedCell = cell
        } else {
            cell.stateImage.image = circleUnselected
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setBallChangeTableView.deselectRow(at: indexPath, animated: true)
        let newCell = setBallChangeTableView.dequeueReusableCell(withIdentifier: "selectorCell", for: indexPath) as! SelectorTableViewCell
        selectedCell?.imageView?.image = circleUnselected
        newCell.stateImage.image = circleSelected
        
        delegate?.sendBallChangeData(selectedBallChange: indexPath.row)
        dismiss(animated: true, completion: nil)
    }

}
