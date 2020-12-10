//
//  SetAmountOfGamesViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 28.11.20.
//

import UIKit

protocol SetAmountOfGamesViewControllerDelegate {
    func sendAmountOfGamesData(amountOfGames: Int)
}

class SetAmountOfGamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Variables
    var selectedAmount: Int = 0
    var selectedCell: SelectorTableViewCell?
    var selectableGames: [String] =
    [
        "0 Games",
        "1 Game",
        "2 Games",
        "3 Games",
        "4 Games",
        "5 Games",
        "6 Games",
        "7 Games",
        "8 Games",
        "9 Games",
        "10 Games"
    ]
    let circleUnselected = UIImage(systemName: "circle")
    let circleSelected = UIImage(systemName: "dot.circle")
    var delegate: SetAmountOfGamesViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var setGamesView: UIView!
    @IBOutlet weak var setGamesTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setGamesView.layer.cornerRadius = 10
        setGamesView.layer.masksToBounds = true
        
        setGamesTableView.delegate = self
        setGamesTableView.dataSource = self
        setGamesTableView.rowHeight = 44
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectableGames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = setGamesTableView.dequeueReusableCell(withIdentifier: "selectorCell", for: indexPath) as! SelectorTableViewCell
        
        let row = indexPath.row
        
        cell.titleLabel.text = selectableGames[row]
        
        if selectedAmount == row {
            cell.stateImage.image = circleSelected
            selectedCell = cell
        } else {
            cell.stateImage.image = circleUnselected
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setGamesTableView.deselectRow(at: indexPath, animated: true)
        let newCell = setGamesTableView.dequeueReusableCell(withIdentifier: "selectorCell", for: indexPath) as! SelectorTableViewCell
        selectedCell?.imageView?.image = circleUnselected
        newCell.stateImage.image = circleSelected
        
        delegate?.sendAmountOfGamesData(amountOfGames: indexPath.row)
        dismiss(animated: true, completion: nil)
    }

}
