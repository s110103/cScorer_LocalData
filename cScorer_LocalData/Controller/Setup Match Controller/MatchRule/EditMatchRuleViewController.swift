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

class EditMatchRuleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Variables
    var template: String = "Standard Match - 3 Sätze"
    var matchType: MatchType = MatchType()
    var sectionHeaders: [String] = ["Matchregel", "Vorteil Satz", "Tie Break"]
    var matchRuleTitles: [[String]] =
    [
        ["Vorlage", "Sätze im Match", "Games im Satz", "2 Games Unterschied", "NoAd", "Heat Rule"],
        ["Vorteil Satz"],
        ["TieBreak bei", "Punkte im Satz", "Punkte im letzten Satz", "Letzter Satz Match Tiebreak"]
    ]
    var matchRuleSubTitles: [[String]] =
    [
        [""]
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
        print(sectionHeaders.count)
        return sectionHeaders.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(matchRuleTitles[section].count)
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
            firstSection.append("Korrekt")
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
        
        var thirdSection: [String] = [template, "\(matchType.tiebreakPoints) Punkte", "\(matchType.lastSetTiebreakPoints) Punkte"]
        
        if matchType.matchTiebreak == true {
            thirdSection.append("Letzter Satz Match Tiebreak")
        } else {
            thirdSection.append("-")
        }
        
        matchRuleSubTitles.append(firstSection)
        matchRuleSubTitles.append(secondSection)
        matchRuleSubTitles.append(thirdSection)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
