//
//  SelectCodeViolationViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 18.05.21.
//

import UIKit

protocol SelectCodeViolationViewControllerDelegate {
    func selctCodeViolation(player: String, violation: Int)
}

class SelectCodeViolationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Variables
    var delegate: SelectCodeViolationViewControllerDelegate?
    var selectedPlayer: String = ""
    var currentMatch: Match?
    var indexOfMatch: Int = 0
    
    var selectCodeViolationTableHeading: String = "Code Violation"
    var selectableCodeViolations: [String] =
    [
        "Unreasonable Delays",
        "Audible obscenity",
        "Visible obscenity",
        "Ball abuse",
        "Racket abuse",
        "Verbal abuse",
        "Physical abuse",
        "Coaching",
        "Unsportsmanlike conduct"
    ]
    var selectableCodeViolationAbbreviations: [String] =
    [
        "Del",
        "AOb",
        "VOb",
        "BA",
        "RA",
        "VA",
        "PhA",
        "CC",
        "UnC"
    ]
    
    // MARK: - Outlets
    @IBOutlet weak var selectCodeViolationView: UIView!
    @IBOutlet weak var selectCodeViolationHeadingLabel: UILabel!
    @IBOutlet weak var selectCodeViolationTableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        selectCodeViolationTableView.delegate = self
        selectCodeViolationTableView.dataSource = self
        
        initLayout()
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
    func initLayout() {
        selectCodeViolationView.layer.masksToBounds = true
        selectCodeViolationView.layer.cornerRadius = 10
        
        selectCodeViolationTableView.dataSource = self
        selectCodeViolationTableView.delegate = self
        selectCodeViolationTableView.rowHeight = 60
        
        switch selectedPlayer{
        case "firstTeamFirstPlayer":
            selectCodeViolationHeadingLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)"
        case "firstTeamSecondPlayer":
            selectCodeViolationHeadingLabel.text = "\(currentMatch!.firstTeamSecondPlayer.prefix(1)). \(currentMatch!.firstTeamSecondPlayerSurname)"
        case "secondTeamFirstPlayer":
            selectCodeViolationHeadingLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)"
        case "secondTeamSecondPlayer":
            selectCodeViolationHeadingLabel.text = "\(currentMatch!.secondTeamSecondPlayer.prefix(1)). \(currentMatch!.secondTeamSecondPlayerSurname)"
        default:
            break
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return selectCodeViolationTableHeading
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        view.backgroundColor = UIColor.init(red: 35/255, green: 110/255, blue: 103/255, alpha: 1)
        
        let label = UILabel()
        label.text = selectCodeViolationTableHeading
        label.font = UIFont(name: "System", size: 18)
        label.frame = CGRect(x: 20, y: 0, width: 200, height: 35)
        label.textColor = UIColor.white

        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectableCodeViolations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = selectCodeViolationTableView.dequeueReusableCell(withIdentifier: "selectorCell", for: indexPath) as! SelectorTableViewCell
        
        let row = indexPath.row
        
        cell.titleLabel.text = "\(selectableCodeViolationAbbreviations[row]) - \(selectableCodeViolations[row])"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectCodeViolationTableView.deselectRow(at: indexPath, animated: true)
        
        dismiss(animated: false, completion: nil)
        
        delegate?.selctCodeViolation(player: selectedPlayer, violation: indexPath.row)
    }
}
