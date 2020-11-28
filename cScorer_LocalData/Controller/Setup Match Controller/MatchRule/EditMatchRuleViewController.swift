//
//  EditMatchRuleViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 25.11.20.
//

import UIKit

protocol EditMatchRuleViewControllerDelegate {
    func sendMatchRuleData(matchType: MatchType)
}

class EditMatchRuleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TemplateMatchRuleViewControllerDelegate {
    
    // MARK: - Variables
    var selectedItem: String = ""
    var template: String = ""
    var matchType: MatchType = MatchType()
    var sectionHeaders: [String] = ["Matchregel", "Vorteil Satz", "TieBreak"]
    var matchRuleTitles: [[String]] =
    [
        ["Vorlage", "Sätze im Match", "Games im Satz", "2 Games Unterschied", "NoAd", "Heat Rule"],
        ["Vorteil Satz"],
        ["TieBreak bei", "Punkte im Satz", "Punkte im letzten Satz", "Punkte im Match TieBreak", "Letzter Satz Match TieBreak"]
    ]
    var matchRuleSubTitles: [[String]] =
    [
        [""]
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
    var delegate: EditMatchRuleViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var matchRuleTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initSubtitles()
        
        matchRuleTableView.delegate = self
        matchRuleTableView.dataSource = self
    }
    
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        delegate?.sendMatchRuleData(matchType: matchType)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
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
        return matchRuleTitles[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = matchRuleTableView.dequeueReusableCell(withIdentifier: "matchRuleCell", for: indexPath)
        
        let section = indexPath.section
        let row = indexPath.row
                
        cell.textLabel?.text = matchRuleTitles[section][row]
        cell.detailTextLabel?.text = matchRuleSubTitles[section][row]
        
        return cell
    }
    
    func initSubtitles() {
        matchRuleSubTitles.removeAll()
        template = selectableTemplates[matchType.template]
        
        var firstSection: [String] = [template, "\(matchType.totalSets) Sätze", "\(matchType.gamesInSet) Games"]
        
        if matchType.twoGameDifference == true {
            firstSection.append("Korrekt")
        } else {
            firstSection.append("Nein")
        }
        
        if matchType.noAd == true {
            firstSection.append("Korrekt")
        } else {
            firstSection.append("Nein")
        }
        
        if matchType.heatRule == true {
            firstSection.append("Ja")
        } else {
            firstSection.append("Nein")
        }
        
        var secondSection: [String] = []
        
        if matchType.advantageSet == 0 {
            secondSection = ["Nein"]
        } else if matchType.advantageSet == 1 {
            secondSection = ["Letzter Satz Vorteil Satz"]
        } else {
            secondSection = ["Jeder Satz Vorteil Satz"]
        }
        
        var thirdSection: [String] = ["\(matchType.tiebreakAt) All", "\(matchType.tiebreakPoints) Punkte", "\(matchType.lastSetTiebreakPoints) Punkte", "\(matchType.matchTiebreakPoints) Punkte"]
        
        if matchType.matchTiebreak == true {
            thirdSection.append("Ja")
        } else {
            thirdSection.append("Nein")
        }
        
        matchRuleSubTitles.append(firstSection)
        matchRuleSubTitles.append(secondSection)
        matchRuleSubTitles.append(thirdSection)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = indexPath.section
        let row = indexPath.row
        
        let title = matchRuleTitles[section][row]
        
        selectedItem = title
        
        switch title {
        case "Vorlage":
            performSegue(withIdentifier: "templateMatchRuleSegue", sender: self)
        case "Sätze im Match":
            performSegue(withIdentifier: "setAmountOfSetsSegue", sender: self)
        case "Games im Satz":
            performSegue(withIdentifier: "setAmountOfGamesSegue", sender: self)
        case "2 Games Unterschied":
            performSegue(withIdentifier: "setTrueFalseSegue", sender: self)
        case "NoAd":
            performSegue(withIdentifier: "setTrueFalseSegue", sender: self)
        case "Heat Rule":
            performSegue(withIdentifier: "setTrueFalseSegue", sender: self)
        case "Letzter Satz Match TieBreak":
            performSegue(withIdentifier: "setTrueFalseSegue", sender: self)
        case "Vorteil Satz":
            performSegue(withIdentifier: "selectAdvantageSetSegue", sender: self)
        case "TieBreak bei":
            performSegue(withIdentifier: "setTiebreakAtSegue", sender: self)
        case "Punkte im Satz":
            performSegue(withIdentifier: "setTiebreakPointsSegue", sender: self)
        case "Punkte im letzten Satz":
            performSegue(withIdentifier: "setTiebreakPointsLastSetSegue", sender: self)
        case "Punkte im Match TieBreak":
            performSegue(withIdentifier: "setMatchTiebreakPointsSegue", sender: self)
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "templateMatchRuleSegue":
            let destinationVC = segue.destination as! TemplateMatchRuleViewController
            
            destinationVC.selectedTemplate = matchType.template
            
            destinationVC.delegate = self
        default:
            break
        }
    }
    
    func sendTemplateMatchRuleData(selectedTemplate: Int) {
        matchType.template = selectedTemplate
        template = selectableTemplates[selectedTemplate]
        
        initSubtitles()
        matchRuleTableView.reloadData()
        
    }
    
}
