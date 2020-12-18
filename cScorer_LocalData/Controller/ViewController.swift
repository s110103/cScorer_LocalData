//
//  ViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 13.11.20.
//

import UIKit
import ProgressHUD

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddMatchViewControllerDelegate, ChairUmpireOnCourtViewControllerDelegate, PlayersOnCourtViewControllerDelegate, StartMatchViewControllerDelegate {
    
    // MARK: - Variables
    var savedMatches: [Match] = []
    var selectedIndex: Int = 0
    var selectedMatch: Match = Match()
    
    var editingEntries: Bool = false
    var editDistinctMatch: Bool = false
    var backToChairUmpire: Bool = false
    var backToPlayers: Bool = false
    var backToStartMatch: Bool = false
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Matches.plist")

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
    @IBAction func addMatchButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "addMatchSegueAnimated", sender: self)
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
        
        selectedIndex = indexPath.row
        selectedMatch = savedMatches[selectedIndex]
        
        if selectedMatch.matchStatistics.chairUmpireOnCourt == false {
            performSegue(withIdentifier: "chairUmpireOnCourtSegueAnimated", sender: self)
        } else {
            if selectedMatch.matchStatistics.playersOnCourt == false {
                performSegue(withIdentifier: "playersOnCourtSegueAnimated", sender: self)
            } else {
                if selectedMatch.matchStatistics.matchInitiated == false {
                    performSegue(withIdentifier: "startMatchSegueAnimated", sender: self)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let buttonDelete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, IndexPath) in
            if self.editingEntries == true {
                let i = indexPath.row
                    
                self.savedMatches.remove(at: i)
                self.matchesTableView.reloadData()
                
                if self.savedMatches.count == 0 {
                    self.editingEntries = false
                    self.editMatchesButton.tintColor = UIColor.white
                }
            } else {
                ProgressHUD.show("Aktiviere Bearbeitungsmodus", icon: .failed, interaction: true)
            }
        }
        
        let buttonEdit = UITableViewRowAction(style: .default, title: "Edit") { (action, IndexPath) in
            self.editDistinctMatch = true
            self.selectedIndex = indexPath.row
            self.selectedMatch = self.savedMatches[self.selectedIndex]
            self.performSegue(withIdentifier: "addMatchSegueAnimated", sender: self)
        }
        
        buttonEdit.backgroundColor = UIColor.orange
        
        return [buttonDelete, buttonEdit]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "addMatchSegue":
            let destinationVC = segue.destination as! AddMatchViewController
            
            destinationVC.match = selectedMatch
            destinationVC.indexOfMatch = selectedIndex
            
            if editDistinctMatch == true {
                destinationVC.editingDistinctMatch = true
            } else {
                destinationVC.editingDistinctMatch = false
            }
            
            destinationVC.delegate = self
        case "addMatchSegueAnimated":
            let destinationVC = segue.destination as! AddMatchViewController
            
            destinationVC.match = selectedMatch
            destinationVC.indexOfMatch = selectedIndex
            
            if editDistinctMatch == true {
                destinationVC.editingDistinctMatch = true
            } else {
                destinationVC.editingDistinctMatch = false
            }
            
            destinationVC.delegate = self
        case "chairUmpireOnCourtSegue":
            let destinationVC = segue.destination as! ChairUmpireOnCourtViewController
            
            destinationVC.selectedIndex = selectedIndex
            destinationVC.currentMatch = selectedMatch
            
            destinationVC.delegate = self
        case "chairUmpireOnCourtSegueAnimated":
            let destinationVC = segue.destination as! ChairUmpireOnCourtViewController
            
            destinationVC.selectedIndex = selectedIndex
            destinationVC.currentMatch = selectedMatch
            
            destinationVC.delegate = self
        case "playersOnCourtSegue":
            let destinationVC = segue.destination as! PlayersOnCourtViewController
            
            destinationVC.selectedIndex = selectedIndex
            destinationVC.currentMatch = selectedMatch
            
            destinationVC.delegate = self
        case "playersOnCourtSegueAnimated":
            let destinationVC = segue.destination as! PlayersOnCourtViewController
            
            destinationVC.selectedIndex = selectedIndex
            destinationVC.currentMatch = selectedMatch
            
            destinationVC.delegate = self
        case "startMatchSegue":
            let destinationVC = segue.destination as! StartMatchViewController
            
            destinationVC.selectedIndex = selectedIndex
            destinationVC.currentMatch = selectedMatch
            
            destinationVC.delegate = self
        case "startMatchSegueAnimated":
            let destinationVC = segue.destination as! StartMatchViewController
            
            destinationVC.selectedIndex = selectedIndex
            destinationVC.currentMatch = selectedMatch
            
            destinationVC.delegate = self
        default:
            break
        }
    }
    
    func sendMatch(match: Match, editingDistinctMatch: Bool, indexOfMatch: Int) {
        if editingDistinctMatch == true {
            if match.backToChairUmpireViewController == true {
                performSegue(withIdentifier: "chairUmpireOnCourtSegue", sender: self)
                match.backToChairUmpireViewController = false
            }
            if match.backToPlayersViewController == true {
                performSegue(withIdentifier: "playersOnCourtSegue", sender: self)
                match.backToPlayersViewController = false
            }
            if match.backToStartMatchViewController == true {
                performSegue(withIdentifier: "startMatchSegue", sender: self)
                match.backToStartMatchViewController = false
            }
            
            savedMatches.remove(at: indexOfMatch)
            savedMatches.insert(match, at: indexOfMatch)
            editDistinctMatch = false
            matchesTableView.reloadData()
        } else {
            savedMatches.append(match)
            editDistinctMatch = false
            matchesTableView.reloadData()
        }
    }
    
    func sendSelectedMatchChairUmpire(currentMatch: Match, selectedIndex: Int) {
        selectedMatch = currentMatch
        self.selectedIndex = selectedIndex
        savedMatches.remove(at: selectedIndex)
        savedMatches.insert(currentMatch, at: selectedIndex)
        
        matchesTableView.reloadData()
        
        if selectedMatch.matchStatistics.playersOnCourt == false {
            performSegue(withIdentifier: "playersOnCourtSegue", sender: self)
        } else {
            if selectedMatch.matchStatistics.matchInitiated == false {
                performSegue(withIdentifier: "startMatchSegue", sender: self)
            } else {
                
            }
        }
    }
    
    func sendSelectedMatchPlayers(currentMatch: Match, selectedIndex: Int) {
        selectedMatch = currentMatch
        self.selectedIndex = selectedIndex
        savedMatches.remove(at: selectedIndex)
        savedMatches.insert(currentMatch, at: selectedIndex)
        matchesTableView.reloadData()
        
        if selectedMatch.matchStatistics.matchInitiated == false {
            performSegue(withIdentifier: "startMatchSegue", sender: self)
        } else {
            
        }
    }
    
    func sendStartMatchData(currentMatch: Match, selectedIndex: Int) {
        selectedMatch = currentMatch
        self.selectedIndex = selectedIndex
        savedMatches.remove(at: selectedIndex)
        savedMatches.insert(currentMatch, at: selectedIndex)
        matchesTableView.reloadData()
    }
    
    func sendEditMatchFromChairUmpire(currentMatch: Match, selectedIndex: Int) {
        currentMatch.backToChairUmpireViewController = true
        self.editDistinctMatch = true
        self.selectedIndex = selectedIndex
        self.selectedMatch = self.savedMatches[self.selectedIndex]
        self.performSegue(withIdentifier: "addMatchSegue", sender: self)
    }
    
    func sendEditMatchFromPlayers(currentMatch: Match, selectedIndex: Int) {
        currentMatch.backToPlayersViewController = true
        self.editDistinctMatch = true
        self.selectedIndex = selectedIndex
        self.selectedMatch = self.savedMatches[self.selectedIndex]
        self.performSegue(withIdentifier: "addMatchSegue", sender: self)
    }
    
    func sendEditMatchFromStartMatch(currentMatch: Match, selectedIndex: Int) {
        currentMatch.backToStartMatchViewController = true
        self.editDistinctMatch = true
        self.selectedIndex = selectedIndex
        self.selectedMatch = self.savedMatches[self.selectedIndex]
        self.performSegue(withIdentifier: "addMatchSegue", sender: self)
    }
    
    /*
            Store Matches
     */
}

