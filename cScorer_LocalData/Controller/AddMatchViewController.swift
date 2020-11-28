//
//  AddMatchViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 13.11.20.
//

import UIKit

class AddMatchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SelectMatchTypeViewControllerDelegate, SetPlayerNameViewControllerDelegate, SetCourtViewControllerDelegate, EditMatchRuleViewControllerDelegate, TournamentInfoViewControllerDelegate {
    
    // MARK: - Variables
    var selectedPlayer: String = ""
    var selectedPlayerName: String = ""
    var selectedPlayerSurname: String = ""
    
    var match: Match = Match(_firstTeamFirstPlayer: "Spieler", _firstTeamFirstPlayerSurname: "1", _firstTeamSecondPlayer: "Spieler", _firstTeamSecondPlayerSurname: "1.1", _secondTeamFirstPlayer: "Spieler", _secondTeamFirstPlayerSurname: "2", _secondTeamSecondPlayer: "Spieler", _secondTeamSecondPlayerSurname: "2.2", _firstTeamFirstPlayerDetails: "", _firstTeamSecondPlayerDetails: "", _secondTeamFirstPlayerDetails: "", _secondTeamSecondPlayerDetails: "", _matchService: 0, _court: "-")
    
    let sectionHeaders: [String] =
    [
        "Spieler", "Match Einstellungen", "Match"
    ]
    let itemTitles: [[String]] =
    [
        ["Match Typ","Spieler 1","Spieler 1 Details","Spieler 1.1","Spieler 1.1 Details","Spieler 2","Spieler 2 Details","Spieler 2.1","Spieler 2.1 Details"],
        ["Court","Matchregel","Turnierinfos"],
        ["Start"]
    ]
    var itemSubtitles: [[String]] =
    [
    ]
    var selectableTemplates: [String] =
    [
        "Standard Match - 3 Sätze",
        "Standard Match - 1 Satz",
        "3 Sätze, Match TieBreak, NoAd",
        "4 Games Pro Satz",
        "8 Games Pro Satz",
        "10 Games Pro Satz",
        "4 Games 1 Satz",
        "4 Games 3 Satz",
        "TieBreak",
        "Match Tiebreak",
        "Benutzerdefiniert"
    ]
    
    // MARK: - Outlets
    @IBOutlet weak var matchDataTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        matchDataTableView.delegate = self
        matchDataTableView.dataSource = self
        
        initSubtitles()
    }
    
    //MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func addMatchButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Functions
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        view.backgroundColor = UIColor.init(red: 35/255, green: 110/255, blue: 103/255, alpha: 1)
        
        let label = UILabel()
        label.text = sectionHeaders[section]
        label.font = UIFont(name: "System", size: 18)
        label.frame = CGRect(x: 20, y: 0, width: 200, height: 35)
        label.textColor = UIColor.white

        view.addSubview(label)
        
        return view
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeaders[section]
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionHeaders.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if match.matchType?.matchType == 0 {
                return itemTitles[section].count-4
            } else {
                return itemTitles[section].count
            }
        } else {
            return itemTitles[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = matchDataTableView.dequeueReusableCell(withIdentifier: "matchDataCell", for: indexPath)
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0 {
            if match.matchType?.matchType == 0 {
                
                switch row {
                case 0...2:
                    cell.textLabel?.text = itemTitles[section][row]
                    cell.detailTextLabel?.text = itemSubtitles[section][row]
                case 3:
                    cell.textLabel?.text = itemTitles[section][5]
                    cell.detailTextLabel?.text = itemSubtitles[section][5]
                case 4:
                    cell.textLabel?.text = itemTitles[section][6]
                    cell.detailTextLabel?.text = itemSubtitles[section][6]
                default:
                    break
                }
                
            } else {
                cell.textLabel?.text = itemTitles[section][row]
                cell.detailTextLabel?.text = itemSubtitles[section][row]
            }
        } else {
            cell.textLabel?.text = itemTitles[section][row]
            cell.detailTextLabel?.text = itemSubtitles[section][row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let title = itemTitles[indexPath.section][indexPath.row]
                
        switch title {
        case "Match Typ":
            performSegue(withIdentifier: "selectMatchTypeSegue", sender: self)
        case "Spieler 1":
            selectedPlayer = "1"
            selectedPlayerName = match.firstTeamFirstPlayer
            selectedPlayerSurname = match.firstTeamFirstPlayerSurname
            performSegue(withIdentifier: "setPlayerNameSegue", sender: self)
        case "Spieler 1.1":
            selectedPlayer = "1.1"
            selectedPlayerName = match.firstTeamSecondPlayer
            selectedPlayerSurname = match.firstTeamSecondPlayerSurname
            performSegue(withIdentifier: "setPlayerNameSegue", sender: self)
        case "Spieler 2":
            selectedPlayer = "2"
            selectedPlayerName = match.secondTeamFirstPlayer
            selectedPlayerSurname = match.secondTeamFirstPlayerSurname
            performSegue(withIdentifier: "setPlayerNameSegue", sender: self)
        case "Spieler 2.1":
            selectedPlayer = "2.1"
            selectedPlayerName = match.secondTeamSecondPlayer
            selectedPlayerSurname = match.secondTeamSecondPlayerSurname
            performSegue(withIdentifier: "setPlayerNameSegue", sender: self)
        case "Matchregel":
            performSegue(withIdentifier: "editMatchRuleSegue", sender: self)
        case "Turnierinfos":
            performSegue(withIdentifier: "editTournamentInfoSegue", sender: self)
        case "Court":
            performSegue(withIdentifier: "setCourtSegue", sender: self)
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "selectMatchTypeSegue":
            let destinationVC = segue.destination as! SelectMatchTypeViewController
            
            destinationVC.matchType = match.matchType!.matchType
            
            destinationVC.delegate = self
        case "setPlayerNameSegue":
            let destinationVC = segue.destination as! SetPlayerNameViewController
            
            destinationVC.selectedPlayer = selectedPlayer
            
            if selectedPlayerName == "Spieler" && (selectedPlayerSurname == "1" || selectedPlayerSurname == "1.1" || selectedPlayerSurname == "2" || selectedPlayerSurname == "2.2") {
                
                destinationVC.selectedPlayerName = ""
                destinationVC.selectedPlayerSurname = ""
            } else {
                destinationVC.selectedPlayerName = selectedPlayerName
                destinationVC.selectedPlayerSurname = selectedPlayerSurname
            }
            
            destinationVC.delegate = self
        case "editMatchRuleSegue":
            let destinationVC = segue.destination as! EditMatchRuleViewController
            
            destinationVC.matchType = match.matchType!
            
            destinationVC.delegate = self
        case "editTournamentInfoSegue":
            let destinationVC = segue.destination as! TournamentInfoViewController
            
            destinationVC.tournamentInfo = match.tournamendData!
            
            destinationVC.delegate = self
        case "setCourtSegue":
            let destinationVC = segue.destination as! SetCourtViewController
            
            destinationVC.court = match.court
            
            destinationVC.delegate = self
        default:
            break
        }
    }
    
    func initSubtitles() {
        var firstSection: [String] = []
        
        if match.matchType?.matchType == 0 {
            firstSection.append("Einzel")
        } else {
            firstSection.append("Einzel")
        }
        firstSection.append("\(match.firstTeamFirstPlayer) \(match.firstTeamFirstPlayerSurname)")
        firstSection.append("\(match.firstTeamFirstPlayer) \(match.firstTeamFirstPlayerSurname)")
        
        firstSection.append("\(match.firstTeamSecondPlayer) \(match.firstTeamSecondPlayerSurname)")
        firstSection.append("\(match.firstTeamSecondPlayer) \(match.firstTeamSecondPlayerSurname)")
        
        firstSection.append("\(match.secondTeamFirstPlayer) \(match.secondTeamFirstPlayerSurname)")
        firstSection.append("\(match.secondTeamFirstPlayer) \(match.secondTeamFirstPlayerSurname)")
        
        firstSection.append("\(match.secondTeamSecondPlayer) \(match.secondTeamSecondPlayerSurname)")
        firstSection.append("\(match.secondTeamSecondPlayer) \(match.secondTeamSecondPlayerSurname)")
        
        var secondSection: [String] = []
        
        secondSection.append(match.court)
        secondSection.append(selectableTemplates[match.matchType!.matchType])
        secondSection.append("Daten zum Turnier")
        
        let thirdSection: [String] = [""]
        
        let subtitles: [[String]] = [firstSection, secondSection, thirdSection]
        
        itemSubtitles.removeAll()
        itemSubtitles = subtitles
    }
    
    func sendMatchType(matchType: Int) {
        match.matchType?.matchType = matchType
        
        switch matchType {
        case 0:
            itemSubtitles[0][0] = "Einzel"
        case 1:
            itemSubtitles[0][0] = "Doppel"
        default:
            break
        }
        
        matchDataTableView.reloadData()
    }
    
    func sendPlayerNameData(selectedPlayer: String, selectedPlayerName: String, selectedPlayerSurname: String) {
        
        switch selectedPlayer {
        case "1":
            match.firstTeamFirstPlayer = selectedPlayerName
            match.firstTeamFirstPlayerSurname = selectedPlayerSurname
            itemSubtitles[0][1] = "\(selectedPlayerName) \(selectedPlayerSurname)"
        case "1.1":
            if match.matchType?.matchType == 0 {
                match.firstTeamSecondPlayer = selectedPlayerName
                match.firstTeamSecondPlayerSurname = selectedPlayerSurname
            } else {
                match.firstTeamSecondPlayer = selectedPlayerName
                match.firstTeamSecondPlayerSurname = selectedPlayerSurname
                itemSubtitles[0][3] = "\(selectedPlayerName) \(selectedPlayerSurname)"
            }
        case "2":
            if match.matchType?.matchType == 0 {
                match.secondTeamFirstPlayer = selectedPlayerName
                match.secondTeamFirstPlayerSurname = selectedPlayerSurname
                itemSubtitles[0][3] = "\(selectedPlayerName) \(selectedPlayerSurname)"
            } else {
                match.secondTeamFirstPlayer = selectedPlayerName
                match.secondTeamFirstPlayerSurname = selectedPlayerSurname
                itemSubtitles[0][5] = "\(selectedPlayerName) \(selectedPlayerSurname)"
            }
        case "2.1":
            if match.matchType?.matchType == 0 {
                match.secondTeamSecondPlayer = selectedPlayerName
                match.secondTeamSecondPlayerSurname = selectedPlayerSurname
            } else {
                match.secondTeamSecondPlayer = selectedPlayerName
                match.secondTeamSecondPlayerSurname = selectedPlayerSurname
                itemSubtitles[0][7] = "\(selectedPlayerName) \(selectedPlayerSurname)"
            }
        default:
            break
        }
        
        matchDataTableView.reloadData()
    }
    
    func sendCourtData(court: String) {
        match.court = court
        itemSubtitles[1][0] = court
        
        matchDataTableView.reloadData()
    }
    
    func sendMatchRuleData(matchType: MatchType) {
        match.matchType = matchType
        itemSubtitles[1][1] = selectableTemplates[matchType.template]
        matchDataTableView.reloadData()
    }
    
    func sendTournamendInfoData(tournamentInfo: TournamentData) {
        match.tournamendData = tournamentInfo
    }
}
