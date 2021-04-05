//
//  StopMatchViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 05.04.21.
//

import UIKit

protocol StopMatchViewControllerDelegate {
    func interruptMatch(interruption: Int)
    func suspendMatch(suspension: Int)
}

class StopMatchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Variables
    var delegate: StopMatchViewControllerDelegate?
    let circleUnselected = UIImage(systemName: "circle")
    let circleSelected = UIImage(systemName: "dot.circle")
    var stopMatchSections: [String] =
    [
        "Match Suspension",
        "Match Interruption"
    ]
    var matchSuspensions: [String] =
    [
        "Rain",
        "Darkness",
        "Heat",
        "Switch Device",
        "Other"
    ]
    var matchInterruptions: [String] =
    [
        "Power Down",
        "Lights Out",
        "Other"
    ]
    
    // MARK: - Outlets
    @IBOutlet weak var stopMatchView: UIView!
    @IBOutlet weak var stopMatchTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        stopMatchView.layer.masksToBounds = true
        stopMatchView.layer.cornerRadius = 10
        
        stopMatchTableView.dataSource = self
        stopMatchTableView.delegate = self
        stopMatchTableView.rowHeight = 44
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return stopMatchSections.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return stopMatchSections[section]
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        view.backgroundColor = UIColor.init(red: 35/255, green: 110/255, blue: 103/255, alpha: 1)
        
        let label = UILabel()
        label.text = stopMatchSections[section]
        label.font = UIFont(name: "System", size: 18)
        label.frame = CGRect(x: 20, y: 0, width: 200, height: 35)
        label.textColor = UIColor.white

        view.addSubview(label)
        
        return view
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return matchSuspensions.count
        } else if section == 1 {
            return matchInterruptions.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = stopMatchTableView.dequeueReusableCell(withIdentifier: "selectorCell", for: indexPath) as! SelectorTableViewCell
        
        let row = indexPath.row
        let section = indexPath.section
        
        if section == 0 {
            cell.titleLabel.text = matchSuspensions[row]
            
            cell.stateImage.image = circleUnselected
        } else if section == 1 {
            cell.titleLabel.text = matchInterruptions[row]
            
            cell.stateImage.image = circleUnselected
        } else {
            cell.titleLabel.text = "NA"
            
            cell.stateImage.image = circleUnselected
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        stopMatchTableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        let section = indexPath.section
        
        if section == 0 {
            delegate?.suspendMatch(suspension: row)
        } else {
            delegate?.interruptMatch(interruption: row)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}
