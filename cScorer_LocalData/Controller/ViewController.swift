//
//  ViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 13.11.20.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddMatchViewControllerDelegate {
    
    // MARK: - Variables
    var savedMatches: [Match] = []
    
    var editingEntries: Bool = false

    // MARK: - Outelts
    @IBOutlet weak var matchesTableView: UITableView!
    @IBOutlet weak var editMatchesButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        matchesTableView.delegate = self
        matchesTableView.dataSource = self
        
        let match = Match(_firstTeamFirstPlayer: "Dominik", _firstTeamFirstPlayerSurname: "Thiem", _firstTeamSecondPlayer: "", _firstTeamSecondPlayerSurname: "", _secondTeamFirstPlayer: "Roger", _secondTeamFirstPlayerSurname: "Federer", _secondTeamSecondPlayer: "", _secondTeamSecondPlayerSurname: "", _firstTeamFirstPlayerDetails: Player(), _firstTeamSecondPlayerDetails: Player(), _secondTeamFirstPlayerDetails: Player(), _secondTeamSecondPlayerDetails: Player(), _court: "CC", _syncedWithCloud: false)
        
        savedMatches.append(match)
        
    }

    // MARK: - Actions
    @IBAction func removeMatchButtonTapped(_ sender: UIButton) {
        
        if editingEntries == false {
            editingEntries = true
            editMatchesButton.tintColor = UIColor.red
            
        } else {
            editingEntries = false;
            editMatchesButton.tintColor = UIColor.white
        }
        
    }
    
    // MARK: - Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedMatches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = matchesTableView.dequeueReusableCell(withIdentifier: "matchSinglesPrototypeCell", for: indexPath) as! SinglesTableViewCell
        let row = indexPath.row
        let match = savedMatches[row]
        
        if match.syncedWithCloud == true {
            cell.syncedWithCloudImage.image = UIImage(systemName: "icloud")
        } else {
            cell.syncedWithCloudImage.image = UIImage(systemName: "icloud.slash")
        }
        
        if match.matchType.matchType == 0 {
            cell.matchDescriptionLabel.text = "\(match.firstTeamFirstPlayerSurname) \(match.firstTeamFirstPlayer.prefix(1)). vs \(match.secondTeamFirstPlayerSurname) \(match.secondTeamFirstPlayer.prefix(1))."
        } else {
            cell.matchDescriptionLabel.text = "\(match.firstTeamFirstPlayerSurname) \(match.firstTeamFirstPlayer.prefix(1)). u \(match.firstTeamSecondPlayerSurname) \(match.firstTeamSecondPlayer.prefix(1)). vs \(match.secondTeamFirstPlayerSurname) \(match.secondTeamFirstPlayer.prefix(1)). u \(match.secondTeamSecondPlayerSurname) \(match.secondTeamSecondPlayer.prefix(1))."
        }
        
        cell.matchCourtLabel.text = "Platz \(match.court)"
        
        let today = match.matchStatistics.matchStartedTimeStamp
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "dd.MM.yyyy HH:mm"
        
        cell.timestampMatchStartedLabel.text = formatter2.string(from: today as Date)
        
        cell.matchScoreLabel.text = "(\(match.matchStatistics.currentSets)), \(match.matchStatistics.currentGame)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingEntries == true {
            if editingStyle == .delete {
                let row = indexPath.row
                
                savedMatches.remove(at: row)
                
                matchesTableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "addMatchSegue":
            let destinationVC = segue.destination as! AddMatchViewController
            destinationVC.delegate = self
        default:
            break
        }
    }
    
    func sendMatch(match: Match) {
        savedMatches.append(match)
        matchesTableView.reloadData()
    }
    
}

