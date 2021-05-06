//
//  SetTiebreakAtViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 28.11.20.
//

import UIKit

protocol SetTiebreakAtViewControllerDelegate {
    func sendTiebreakAtData(tiebreakAt: Int)
}

class SetTiebreakAtViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Variables
    var maxGames: Int = 0
    var tiebreakAt: Int = 0
    var selectedCell: SelectorTableViewCell?
    var selectableTiebreakAt: [String] =
    [
        "0 all",
        "1 all",
        "2 all",
        "3 all",
        "4 all",
        "5 all",
        "6 all",
        "7 all",
        "8 all",
        "9 all",
        "10 all"
    ]
    let circleUnselected = UIImage(systemName: "circle")
    let circleSelected = UIImage(systemName: "dot.circle")
    var delegate: SetTiebreakAtViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var setTiebreakAtView: UIView!
    @IBOutlet weak var setTiebreakAtTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setTiebreakAtView.layer.cornerRadius = 10
        setTiebreakAtView.layer.masksToBounds = true
        
        setTiebreakAtTableView.delegate = self
        setTiebreakAtTableView.dataSource = self
        setTiebreakAtTableView.rowHeight = 44
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return maxGames+1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = setTiebreakAtTableView.dequeueReusableCell(withIdentifier: "selectorCell", for: indexPath) as! SelectorTableViewCell
        
        let row = indexPath.row
        
        cell.titleLabel.text = selectableTiebreakAt[row]
        
        if tiebreakAt == row {
            cell.stateImage.image = circleSelected
            selectedCell = cell
        } else {
            cell.stateImage.image = circleUnselected
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setTiebreakAtTableView.deselectRow(at: indexPath, animated: true)
        let newCell = setTiebreakAtTableView.dequeueReusableCell(withIdentifier: "selectorCell", for: indexPath) as! SelectorTableViewCell
        selectedCell?.imageView?.image = circleUnselected
        newCell.stateImage.image = circleSelected
        
        delegate?.sendTiebreakAtData(tiebreakAt: indexPath.row)
        dismiss(animated: true, completion: nil)
    }

}
