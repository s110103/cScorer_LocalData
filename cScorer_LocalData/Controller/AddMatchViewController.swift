//
//  AddMatchViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 13.11.20.
//

import UIKit

protocol AddMatchViewControllerDelegate {
    func sendMatch(match: Match)
}

class AddMatchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SelectMatchTypeViewControllerDelegate, SetPlayerNameViewControllerDelegate, SetCourtViewControllerDelegate, EditMatchRuleViewControllerDelegate, TournamentInfoViewControllerDelegate, SelectPlayerDetailsViewControllerDelegate {
    
    // MARK: - Variables
    var delegate: AddMatchViewControllerDelegate?
    var selectedPlayer: String = ""
    var selectedPlayerName: String = ""
    var selectedPlayerSurname: String = ""
        
    var match: Match = Match()
    
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
        "TieBreak",
        "Match Tiebreak",
        "Benutzerdefiniert"
    ]
    
    var percentageDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition!
    
    // MARK: - Outlets
    @IBOutlet weak var matchDataTableView: UITableView!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        matchDataTableView.delegate = self
        matchDataTableView.dataSource = self
        
        initSubtitles()
        addGesture()
    }
    
    //MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func addMatchButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        delegate?.sendMatch(match: match)
    }
    @IBAction func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        
        let percent = max(panGesture.translation(in: view).x, 0) / view.frame.width
        
        switch panGesture.state {
        case .began:
            navigationController?.delegate = self
            navigationController?.popViewController(animated: true)
        case .changed:
            percentageDrivenInteractiveTransition.update(percent)
        case .ended:
            let velocity = panGesture.velocity(in: view).x
            
            if percent > 0.5 || velocity > 1000 {
                percentageDrivenInteractiveTransition.finish()
            } else {
                percentageDrivenInteractiveTransition.cancel()
            }
        case .cancelled, .failed:
            percentageDrivenInteractiveTransition.cancel()
        default:
            break
        }
        
    }
    
    //MARK: - Functions
    func addGesture() {
        guard (navigationController?.viewControllers.count)! > 1 else {
            return
        }
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(AddMatchViewController.handlePanGesture(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    
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
            if match.matchType.matchType == 0 {
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
            if match.matchType.matchType == 0 {
                
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
        
        let section = indexPath.section
        var row = indexPath.row
        
        if section == 0 {
            if match.matchType.matchType == 0 {
                if row > 2 {
                    row += 2
                }
            }
        }
        
        
        let title = itemTitles[section][row]
                
                        
        switch title {
        case "Match Typ":
            performSegue(withIdentifier: "selectMatchTypeSegue", sender: self)
        case "Spieler 1":
            selectedPlayer = "1"
            selectedPlayerName = match.firstTeamFirstPlayer
            selectedPlayerSurname = match.firstTeamFirstPlayerSurname
            performSegue(withIdentifier: "setPlayerNameSegue", sender: self)
        case "Spieler 1 Details":
            selectedPlayer = "1"
            selectedPlayerName = match.firstTeamFirstPlayer
            selectedPlayerSurname = match.firstTeamFirstPlayerSurname
            performSegue(withIdentifier: "selectPlayerSegue", sender: self)
        case "Spieler 1.1":
            selectedPlayer = "1.1"
            selectedPlayerName = match.firstTeamSecondPlayer
            selectedPlayerSurname = match.firstTeamSecondPlayerSurname
            performSegue(withIdentifier: "setPlayerNameSegue", sender: self)
        case "Spieler 1.1 Details":
            selectedPlayer = "1.1"
            selectedPlayerName = match.firstTeamSecondPlayer
            selectedPlayerSurname = match.firstTeamSecondPlayerSurname
            performSegue(withIdentifier: "selectPlayerSegue", sender: self)
        case "Spieler 2":
            selectedPlayer = "2"
            selectedPlayerName = match.secondTeamFirstPlayer
            selectedPlayerSurname = match.secondTeamFirstPlayerSurname
            performSegue(withIdentifier: "setPlayerNameSegue", sender: self)
        case "Spieler 2 Details":
            selectedPlayer = "2"
            selectedPlayerName = match.secondTeamFirstPlayer
            selectedPlayerSurname = match.secondTeamFirstPlayerSurname
            performSegue(withIdentifier: "selectPlayerSegue", sender: self)
        case "Spieler 2.1":
            selectedPlayer = "2.1"
            selectedPlayerName = match.secondTeamSecondPlayer
            selectedPlayerSurname = match.secondTeamSecondPlayerSurname
            performSegue(withIdentifier: "setPlayerNameSegue", sender: self)
        case "Spieler 2.1 Details":
            selectedPlayer = "2.1"
            selectedPlayerName = match.secondTeamSecondPlayer
            selectedPlayerSurname = match.secondTeamSecondPlayerSurname
            performSegue(withIdentifier: "selectPlayerSegue", sender: self)
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
            
            destinationVC.matchType = match.matchType.matchType
            
            destinationVC.delegate = self
        case "setPlayerNameSegue":
            let destinationVC = segue.destination as! SetPlayerNameViewController
            
            destinationVC.selectedPlayer = selectedPlayer
                        
            if selectedPlayerName == "Spieler" && (selectedPlayerSurname == "1" || selectedPlayerSurname == "1.1" || selectedPlayerSurname == "2" || selectedPlayerSurname == "2.1") {
                
                destinationVC.selectedPlayerName = ""
                destinationVC.selectedPlayerSurname = ""
            } else {
                destinationVC.selectedPlayerName = selectedPlayerName
                destinationVC.selectedPlayerSurname = selectedPlayerSurname
            }
            
            destinationVC.delegate = self
        case "selectPlayerSegue":
            let destinationVC = segue.destination as! SelectPlayerDetailsViewController
            
            destinationVC.playerType = selectedPlayer
            
            destinationVC.delegate = self
        case "editMatchRuleSegue":
            let destinationVC = segue.destination as! EditMatchRuleViewController
            
            destinationVC.matchType = match.matchType
            
            destinationVC.delegate = self
        case "editTournamentInfoSegue":
            let destinationVC = segue.destination as! TournamentInfoViewController
            
            destinationVC.tournamentInfo = match.tournamendData
            
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
        
        if match.matchType.matchType == 0 {
            firstSection.append("Einzel")
        } else {
            firstSection.append("Doppel")
        }
        
        if match.firstTeamFirstPlayer == "" && match.firstTeamFirstPlayerSurname == "" {
            firstSection.append("Spieler 1")
            firstSection.append("Spieler 1")
        } else {
            firstSection.append("\(match.firstTeamFirstPlayer) \(match.firstTeamFirstPlayerSurname)")
            firstSection.append("\(match.firstTeamFirstPlayer) \(match.firstTeamFirstPlayerSurname)")
        }
        
        if match.firstTeamSecondPlayer == "" && match.firstTeamSecondPlayerSurname == "" {
            firstSection.append("Spieler 1.1")
            firstSection.append("Spieler 1.1")
        } else {
            firstSection.append("\(match.firstTeamSecondPlayer) \(match.firstTeamSecondPlayerSurname)")
            firstSection.append("\(match.firstTeamSecondPlayer) \(match.firstTeamSecondPlayerSurname)")
        }
        
        if match.secondTeamFirstPlayer == "" && match.secondTeamFirstPlayerSurname == "" {
            firstSection.append("Spieler 2")
            firstSection.append("Spieler 2")
        } else {
            firstSection.append("\(match.secondTeamFirstPlayer) \(match.secondTeamFirstPlayerSurname)")
            firstSection.append("\(match.secondTeamFirstPlayer) \(match.secondTeamFirstPlayerSurname)")
        }
        
        if match.secondTeamSecondPlayer == "" && match.secondTeamSecondPlayerSurname == "" {
            firstSection.append("Spieler 2.1")
            firstSection.append("Spieler 2.1")
        } else {
            firstSection.append("\(match.secondTeamSecondPlayer) \(match.secondTeamSecondPlayerSurname)")
            firstSection.append("\(match.secondTeamSecondPlayer) \(match.secondTeamSecondPlayerSurname)")
        }
        
        var secondSection: [String] = []
        
        secondSection.append(match.court)
        secondSection.append(selectableTemplates[match.matchType.template])
        secondSection.append("Daten zum Turnier")
        
        let thirdSection: [String] = [""]
        
        let subtitles: [[String]] = [firstSection, secondSection, thirdSection]
        
        itemSubtitles.removeAll()
        itemSubtitles = subtitles
    }
    
    func sendMatchType(matchType: Int) {
        match.matchType.matchType = matchType
        
        switch matchType {
        case 0:
            match.matchType.template = 0
        case 1:
            match.matchType.template = 2
        default:
            break
        }
        
        initSubtitles()
        
        matchDataTableView.reloadData()
    }
    
    func sendPlayerNameData(selectedPlayer: String, selectedPlayerName: String, selectedPlayerSurname: String) {
        
        switch selectedPlayer {
        case "1":
            match.firstTeamFirstPlayer = selectedPlayerName
            match.firstTeamFirstPlayerSurname = selectedPlayerSurname
            itemSubtitles[0][1] = "\(selectedPlayerName) \(selectedPlayerSurname)"
        case "1.1":
            if match.matchType.matchType == 0 {
                match.firstTeamSecondPlayer = selectedPlayerName
                match.firstTeamSecondPlayerSurname = selectedPlayerSurname
            } else {
                match.firstTeamSecondPlayer = selectedPlayerName
                match.firstTeamSecondPlayerSurname = selectedPlayerSurname
                itemSubtitles[0][3] = "\(selectedPlayerName) \(selectedPlayerSurname)"
            }
        case "2":
            if match.matchType.matchType == 0 {
                match.secondTeamFirstPlayer = selectedPlayerName
                match.secondTeamFirstPlayerSurname = selectedPlayerSurname
                itemSubtitles[0][3] = "\(selectedPlayerName) \(selectedPlayerSurname)"
            } else {
                match.secondTeamFirstPlayer = selectedPlayerName
                match.secondTeamFirstPlayerSurname = selectedPlayerSurname
                itemSubtitles[0][5] = "\(selectedPlayerName) \(selectedPlayerSurname)"
            }
        case "2.1":
            if match.matchType.matchType == 0 {
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
        
        initSubtitles()
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
    
    func sendPlayerDetailsData(selectedPlayer: Player, playerType: String) {
        switch playerType {
        case "1":
            match.firstTeamFirstPlayerDetails = selectedPlayer
            match.firstTeamFirstPlayer = selectedPlayer.firstName
            match.firstTeamFirstPlayerSurname = selectedPlayer.surName
        case "1.1":
            match.firstTeamSecondPlayerDetails = selectedPlayer
            match.firstTeamSecondPlayer = selectedPlayer.firstName
            match.firstTeamSecondPlayerSurname = selectedPlayer.surName
        case "2":
            match.secondTeamFirstPlayerDetails = selectedPlayer
            match.secondTeamFirstPlayer = selectedPlayer.firstName
            match.secondTeamFirstPlayerSurname = selectedPlayer.surName
        case "2.1":
            match.secondTeamSecondPlayerDetails = selectedPlayer
            match.secondTeamSecondPlayer = selectedPlayer.firstName
            match.secondTeamSecondPlayerSurname = selectedPlayer.surName
        default:
            break
        }
        
        initSubtitles()
        matchDataTableView.reloadData()
    }
}

extension AddMatchViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideAnimatedTransitioning()
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        navigationController.delegate = nil
        
        if panGestureRecognizer.state == .began {
            percentageDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
            percentageDrivenInteractiveTransition.completionCurve = .easeOut
        } else {
            percentageDrivenInteractiveTransition = nil
        }
        
        return percentageDrivenInteractiveTransition
    }
}
