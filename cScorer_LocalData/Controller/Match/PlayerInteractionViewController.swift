//
//  PlayerInteractionViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 18.05.21.
//

import UIKit

protocol PlayerInteractionViewControllerDelegate {
    func openCodeViolation(player: String)
    func openTimeViolation(player: String)
}

class PlayerInteractionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Variables
    var delegate: PlayerInteractionViewControllerDelegate?
    var currentMatch: Match?
    var indexOfMatch: Int = 0
    var targetPlayer: String = ""
    
    var playerInteractionHeadings: [String] =
    [
        "Code Violation",
        "Time Violation",
        "Player Timeouts",
        "Retirement"
    ]
    
    var playerCodeViolationHeadings: [String] =
    [
        "Code Violation"
    ]
    var playerTimeViolationHeadings: [String] =
    [
        "Time Violation"
    ]
    var playerTimeoutHeadings: [String] =
    [
        "Medical Timeout",
        "Toilet Break",
        "Change of Attire"
    ]
    var playerRetirementHeadings: [String] =
    [
        "Retirement"
    ]
    
    // MARK: - Outlets
    @IBOutlet weak var playerInteractionView: UIView!
    @IBOutlet weak var playerInteractionHeadingView: UIView!
    @IBOutlet weak var playerInteractionHeadingLabel: UILabel!
    @IBOutlet weak var playerInteractionTableView: UITableView!
    @IBOutlet weak var playerInteractionCloseButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        playerInteractionTableView.delegate = self
        playerInteractionTableView.dataSource = self
        
        initLayout()
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
    func initLayout() {
        playerInteractionView.layer.masksToBounds = true
        playerInteractionView.layer.cornerRadius = 10
        
        playerInteractionTableView.dataSource = self
        playerInteractionTableView.delegate = self
        playerInteractionTableView.rowHeight = 60
        
        switch targetPlayer{
        case "firstTeamFirstPlayer":
            playerInteractionHeadingLabel.text = "\(currentMatch!.firstTeamFirstPlayer.prefix(1)). \(currentMatch!.firstTeamFirstPlayerSurname)"
        case "firstTeamSecondPlayer":
            playerInteractionHeadingLabel.text = "\(currentMatch!.firstTeamSecondPlayer.prefix(1)). \(currentMatch!.firstTeamSecondPlayerSurname)"
        case "secondTeamFirstPlayer":
            playerInteractionHeadingLabel.text = "\(currentMatch!.secondTeamFirstPlayer.prefix(1)). \(currentMatch!.secondTeamFirstPlayerSurname)"
        case "secondTeamSecondPlayer":
            playerInteractionHeadingLabel.text = "\(currentMatch!.secondTeamSecondPlayer.prefix(1)). \(currentMatch!.secondTeamSecondPlayerSurname)"
        default:
            break
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return playerInteractionHeadings.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return playerInteractionHeadings[section]
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        view.backgroundColor = UIColor.init(red: 35/255, green: 110/255, blue: 103/255, alpha: 1)
        
        let label = UILabel()
        label.text = playerInteractionHeadings[section]
        label.font = UIFont(name: "System", size: 18)
        label.frame = CGRect(x: 20, y: 0, width: 200, height: 35)
        label.textColor = UIColor.white

        view.addSubview(label)
        
        return view
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return playerCodeViolationHeadings.count
        case 1:
            return playerTimeViolationHeadings.count
        case 2:
            return playerTimeoutHeadings.count
        case 3:
            return playerRetirementHeadings.count
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = playerInteractionTableView.dequeueReusableCell(withIdentifier: "selectorCell", for: indexPath) as! SelectorTableViewCell
        
        let row = indexPath.row
        let section = indexPath.section
        
        switch section {
        case 0:
            cell.titleLabel.text = playerCodeViolationHeadings[row]
        case 1:
            cell.titleLabel.text = playerTimeViolationHeadings[row]
        case 2:
            cell.titleLabel.text = playerTimeoutHeadings[row]
        case 3:
            cell.titleLabel.text = playerRetirementHeadings[row]
        default:
            cell.titleLabel.text = "NA"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playerInteractionTableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        let section = indexPath.section
        
        dismiss(animated: true, completion: nil)
        
        switch section {
        case 0:
            delegate?.openCodeViolation(player: targetPlayer)
        case 1:
            delegate?.openTimeViolation(player: targetPlayer)
        case 2:
            // Timeout
            switch row {
            case 0:
                // Medical
                break
            case 1:
                // Toilett
                break
            case 2:
                // Change of Attire
                break
            default:
                break
            }
            break
        case 3:
            // Retirement
            break
        default:
            break
        }
    }

}
