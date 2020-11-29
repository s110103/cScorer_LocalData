//
//  SelectAdvantageSetViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 28.11.20.
//

import UIKit

protocol SelectAdvantageSetViewControllerDelegate {
    func sendAdvantageSetData(advantageSet: Int)
}

class SelectAdvantageSetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Variables
    var selectedSetting: Int = 0
    var selectedCell: SelectorTableViewCell?
    var selectableAdvantageSetSettings: [String] =
    [
        "-",
        "Letzter Satz Vorteil Satz",
        "Jeder Satz Vorteil Satz"
    ]
    let circleUnselected = UIImage(systemName: "circle")
    let circleSelected = UIImage(systemName: "dot.circle")
    var delegate: SelectAdvantageSetViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var advantageSetView: UIView!
    @IBOutlet weak var advantageSetTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        advantageSetView.layer.cornerRadius = 10
        advantageSetView.layer.masksToBounds = true
        
        advantageSetTableView.delegate = self
        advantageSetTableView.dataSource = self
        advantageSetTableView.rowHeight = 44
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectableAdvantageSetSettings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = advantageSetTableView.dequeueReusableCell(withIdentifier: "selectorCell", for: indexPath) as! SelectorTableViewCell
        
        let row = indexPath.row
        
        cell.titleLabel.text = selectableAdvantageSetSettings[row]
        
        if selectedSetting == row {
            cell.stateImage.image = circleSelected
            selectedCell = cell
        } else {
            cell.stateImage.image = circleUnselected
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        advantageSetTableView.deselectRow(at: indexPath, animated: true)
        let newCell = advantageSetTableView.dequeueReusableCell(withIdentifier: "selectorCell", for: indexPath) as! SelectorTableViewCell
        selectedCell?.imageView?.image = circleUnselected
        newCell.stateImage.image = circleSelected
        
        delegate?.sendAdvantageSetData(advantageSet: indexPath.row)
        dismiss(animated: true, completion: nil)
    }

}
