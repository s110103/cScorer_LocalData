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

class EditMatchRuleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TemplateMatchRuleViewControllerDelegate, SetAmountOfSetsViewControllerDelegate, SetAmountOfGamesViewControllerDelegate, SelectAdvantageSetViewControllerDelegate, SetTrueFalseViewControllerDelegate, SetTiebreakAtViewControllerDelegate, SetTiebreakPointsViewControllerDelegate, SetMatchTiebreakPointsViewControllerDelegate, SetTiebreakPointsLastSetViewControllerDelegate, SetBallChangeViewControllerDelegate {
    
    // MARK: - Variables
    var delegate: EditMatchRuleViewControllerDelegate?

    var selectedItem: String = ""
    var template: String = ""
    var matchType: MatchType = MatchType()
    var comparisonMatchType: MatchType = MatchType()
    var sectionHeaders: [String] = ["Matchrule", "Advantage Set", "TieBreak"]
    var matchRuleTitles: [[String]] =
    [
        ["Template", "Sets", "Games", "2 Games difference", "NoAd", "Heat Rule", "Ballchange"],
        ["Advantage Set"],
        ["TieBreak at", "Points in Set", "Points in last set", "Points in Match TieBreak", "Final Set Match TieBreak"]
    ]
    
    
    var matchRuleSubTitles: [[String]] =
    [
        [""]
    ]
    var selectableTemplates: [String] =
    [
        "Standard match - 3 Sets",
        "Standard match - 1 Set",
        "3 Sets, Match TieBreak, NoAd",
        "4 Games per Set",
        "8 Games per Set",
        "10 Games per Set",
        "4 Games 1 Set",
        "TieBreak",
        "Match Tiebreak",
        "Userdefined"
    ]
    var selectableSets: [String] =
    [
        "0 Sets",
        "1 Sets",
        "3 Sets",
        "5 Sets"
    ]
    var selectableGames: [String] =
    [
        "0 Games",
        "1 Game",
        "2 Games",
        "3 Games",
        "4 Games",
        "5 Games",
        "6 Games",
        "7 Games",
        "8 Games",
        "9 Games",
        "10 Games"
    ]
    var selectableAdvantageSetSettings: [String] =
    [
        "-",
        "Final Set Advantage Set",
        "Every Set Advantage Set"
    ]
    var selectableTiebreakAt: [String] =
    [
        "0 all",
        "1 all",
        "2 all",
        "3 all",
        "4 all",
        "5 all",
        "6 all",
        "7 all",
        "8 all",
        "9 all",
        "10 all"
    ]
    var selectablePoints: [String] =
    [
        "0 Points",
        "1 Points",
        "2 Points",
        "3 Points",
        "4 Points",
        "5 Points",
        "6 Points",
        "7 Points",
        "8 Points",
        "9 Points",
        "10 Points"
    ]
    var selectableBallChanges: [String] =
    [
        "No Ballchange",
        "7/9",
        "9/11",
        "11/13",
        "3. Satz"
    ]
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.sendMatchRuleData(matchType: matchType)
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
        
        var firstSection: [String] = [template, "\(selectableSets[matchType.totalSets])", "\(selectableGames[matchType.gamesInSet])"]
        
        if matchType.twoGameDifference == true {
            firstSection.append("Yes")
        } else {
            firstSection.append("No")
        }
        
        if matchType.noAd == true {
            firstSection.append("Yes")
        } else {
            firstSection.append("No")
        }
        
        if matchType.heatRule == true {
            firstSection.append("Yes")
        } else {
            firstSection.append("No")
        }
        
        firstSection.append(selectableBallChanges[matchType.ballChange])
        
        let secondSection: [String] = [selectableAdvantageSetSettings[matchType.advantageSet]]
                
        var thirdSection: [String] = ["\(selectableTiebreakAt[matchType.tiebreakAt])", "\(selectablePoints[matchType.tiebreakPoints])", "\(selectablePoints[matchType.lastSetTiebreakPoints])", "\(selectablePoints[matchType.matchTiebreakPoints])"]
        
        if matchType.matchTiebreak == true {
            thirdSection.append("Yes")
        } else {
            thirdSection.append("No")
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
        case "Template":
            performSegue(withIdentifier: "templateMatchRuleSegue", sender: self)
        case "Sets":
            performSegue(withIdentifier: "setAmountOfSetsSegue", sender: self)
        case "Games":
            performSegue(withIdentifier: "setAmountOfGamesSegue", sender: self)
        case "2 Games difference":
            performSegue(withIdentifier: "setTrueFalseSegue", sender: self)
        case "NoAd":
            performSegue(withIdentifier: "setTrueFalseSegue", sender: self)
        case "Heat Rule":
            performSegue(withIdentifier: "setTrueFalseSegue", sender: self)
        case "Ballchange":
            performSegue(withIdentifier: "setBallChangeSegue", sender: self)
        case "Final Set Match TieBreak":
            performSegue(withIdentifier: "setTrueFalseSegue", sender: self)
        case "Advantage Set":
            performSegue(withIdentifier: "selectAdvantageSetSegue", sender: self)
        case "TieBreak at":
            performSegue(withIdentifier: "setTiebreakAtSegue", sender: self)
        case "Points in Set":
            performSegue(withIdentifier: "setTiebreakPointsSegue", sender: self)
        case "Points in final Set":
            performSegue(withIdentifier: "setTiebreakPointsLastSetSegue", sender: self)
        case "Points in Match TieBreak":
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
        case "setAmountOfSetsSegue":
            let destinationVC = segue.destination as! SetAmountOfSetsViewController
            
            destinationVC.selectedAmount = matchType.totalSets
            
            destinationVC.delegate = self
        case "setAmountOfGamesSegue":
            let destinationVC = segue.destination as! SetAmountOfGamesViewController
            
            destinationVC.selectedAmount = matchType.gamesInSet
            
            destinationVC.delegate = self
        case "selectAdvantageSetSegue":
            let destinationVC = segue.destination as! SelectAdvantageSetViewController
            
            destinationVC.selectedSetting = matchType.advantageSet
            
            destinationVC.delegate = self
        case "setTiebreakAtSegue":
            let destinationVC = segue.destination as! SetTiebreakAtViewController
            
            destinationVC.maxGames = matchType.gamesInSet
            destinationVC.tiebreakAt = matchType.tiebreakAt
            
            destinationVC.delegate = self
        case "setTiebreakPointsSegue":
            let destinationVC = segue.destination as! SetTiebreakPointsViewController
            
            destinationVC.tiebreakPoints = matchType.tiebreakPoints
            
            destinationVC.delegate = self
        case "setTiebreakPointsLastSetSegue":
            let destinationVC = segue.destination as! SetTiebreakPointsLastSetViewController
            
            destinationVC.tiebreakPointsLastSet = matchType.lastSetTiebreakPoints
            
            destinationVC.delegate = self
        case "setMatchTiebreakPointsSegue":
            let destinationVC = segue.destination as! SetMatchTiebreakPointsViewController
            
            destinationVC.matchTiebreakPoints = matchType.matchTiebreakPoints
            
            destinationVC.delegate = self
        case "setBallChangeSegue":
            let destinationVC = segue.destination as! SetBallChangeViewController
            
            destinationVC.selectedBallChange = matchType.ballChange
            
            destinationVC.delegate = self
        case "setTrueFalseSegue":
            let destinationVC = segue.destination as! SetTrueFalseViewController
            
            destinationVC.currentHeading = selectedItem
            switch selectedItem {
            case "2 Games difference":
                destinationVC.selectedBool = matchType.twoGameDifference
            case "NoAd":
                destinationVC.selectedBool = matchType.noAd
            case "Heat Rule":
                destinationVC.selectedBool = matchType.heatRule
            case "Final Set Match TieBreak":
                destinationVC.selectedBool = matchType.matchTiebreak
            default:
                destinationVC.selectedBool = false
            }
            
            destinationVC.delegate = self
        default:
            break
        }
    }
    
    func sendTemplateMatchRuleData(selectedTemplate: Int) {
        matchType.template = selectedTemplate
        matchType.templateBackup = selectedTemplate
        template = selectableTemplates[selectedTemplate]
        
        switch matchType.template {
        case 0:
            matchType.totalSets = 2
            matchType.gamesInSet = 6
            matchType.twoGameDifference = true
            matchType.noAd = false
            matchType.heatRule = false
            matchType.ballChange = 0
            matchType.advantageSet = 0
            matchType.tiebreakAt = 6
            matchType.tiebreakPoints = 7
            matchType.lastSetTiebreakPoints = 7
            matchType.matchTiebreakPoints = 10
            matchType.matchTiebreak = false
        case 1:
            matchType.totalSets = 1
            matchType.gamesInSet = 6
            matchType.twoGameDifference = true
            matchType.noAd = false
            matchType.heatRule = false
            matchType.ballChange = 0
            matchType.advantageSet = 0
            matchType.tiebreakAt = 6
            matchType.tiebreakPoints = 7
            matchType.lastSetTiebreakPoints = 7
            matchType.matchTiebreakPoints = 10
            matchType.matchTiebreak = false
        case 2:
            matchType.totalSets = 2
            matchType.gamesInSet = 6
            matchType.twoGameDifference = true
            matchType.noAd = true
            matchType.heatRule = false
            matchType.ballChange = 0
            matchType.advantageSet = 0
            matchType.tiebreakAt = 6
            matchType.tiebreakPoints = 7
            matchType.lastSetTiebreakPoints = 7
            matchType.matchTiebreakPoints = 10
            matchType.matchTiebreak = true
        case 3:
            matchType.totalSets = 2
            matchType.gamesInSet = 4
            matchType.twoGameDifference = true
            matchType.noAd = false
            matchType.heatRule = false
            matchType.ballChange = 0
            matchType.advantageSet = 0
            matchType.tiebreakAt = 4
            matchType.tiebreakPoints = 7
            matchType.lastSetTiebreakPoints = 7
            matchType.matchTiebreakPoints = 10
            matchType.matchTiebreak = false
        case 4:
            matchType.totalSets = 2
            matchType.gamesInSet = 8
            matchType.twoGameDifference = true
            matchType.noAd = false
            matchType.heatRule = false
            matchType.ballChange = 0
            matchType.advantageSet = 0
            matchType.tiebreakAt = 8
            matchType.tiebreakPoints = 7
            matchType.lastSetTiebreakPoints = 7
            matchType.matchTiebreakPoints = 10
            matchType.matchTiebreak = false
        case 5:
            matchType.totalSets = 2
            matchType.gamesInSet = 10
            matchType.twoGameDifference = true
            matchType.noAd = false
            matchType.heatRule = false
            matchType.ballChange = 0
            matchType.advantageSet = 0
            matchType.tiebreakAt = 10
            matchType.tiebreakPoints = 7
            matchType.lastSetTiebreakPoints = 7
            matchType.matchTiebreakPoints = 10
            matchType.matchTiebreak = false
        case 6:
            matchType.totalSets = 1
            matchType.gamesInSet = 4
            matchType.twoGameDifference = true
            matchType.noAd = false
            matchType.heatRule = false
            matchType.ballChange = 0
            matchType.advantageSet = 0
            matchType.tiebreakAt = 4
            matchType.tiebreakPoints = 7
            matchType.lastSetTiebreakPoints = 7
            matchType.matchTiebreakPoints = 10
            matchType.matchTiebreak = false
        case 7:
            matchType.totalSets = 0
            matchType.gamesInSet = 0
            matchType.twoGameDifference = false
            matchType.noAd = false
            matchType.heatRule = false
            matchType.ballChange = 0
            matchType.advantageSet = 0
            matchType.tiebreakAt = 0
            matchType.tiebreakPoints = 7
            matchType.lastSetTiebreakPoints = 0
            matchType.matchTiebreakPoints = 0
            matchType.matchTiebreak = false
        case 8:
            matchType.totalSets = 0
            matchType.gamesInSet = 0
            matchType.twoGameDifference = false
            matchType.noAd = false
            matchType.heatRule = false
            matchType.ballChange = 0
            matchType.advantageSet = 0
            matchType.tiebreakAt = 0
            matchType.tiebreakPoints = 0
            matchType.lastSetTiebreakPoints = 0
            matchType.matchTiebreakPoints = 10
            matchType.matchTiebreak = false
        case 9:
            matchType.totalSets = 2
            matchType.gamesInSet = 6
            matchType.twoGameDifference = true
            matchType.noAd = false
            matchType.heatRule = false
            matchType.ballChange = 0
            matchType.advantageSet = 0
            matchType.tiebreakAt = 6
            matchType.tiebreakPoints = 7
            matchType.lastSetTiebreakPoints = 7
            matchType.matchTiebreakPoints = 10
            matchType.matchTiebreak = false
        default:
            break
        }
        
        initSubtitles()
        matchRuleTableView.reloadData()
        
    }
    
    func initComparison() {
        switch matchType.templateBackup {
        case 0:
            comparisonMatchType.totalSets = 2
            comparisonMatchType.gamesInSet = 6
            comparisonMatchType.twoGameDifference = true
            comparisonMatchType.noAd = false
            comparisonMatchType.heatRule = false
            comparisonMatchType.ballChange = 0
            comparisonMatchType.advantageSet = 0
            comparisonMatchType.tiebreakAt = 6
            comparisonMatchType.tiebreakPoints = 7
            comparisonMatchType.lastSetTiebreakPoints = 7
            comparisonMatchType.matchTiebreakPoints = 10
            comparisonMatchType.matchTiebreak = false
        case 1:
            comparisonMatchType.totalSets = 1
            comparisonMatchType.gamesInSet = 6
            comparisonMatchType.twoGameDifference = true
            comparisonMatchType.noAd = false
            comparisonMatchType.heatRule = false
            comparisonMatchType.ballChange = 0
            comparisonMatchType.advantageSet = 0
            comparisonMatchType.tiebreakAt = 6
            comparisonMatchType.tiebreakPoints = 7
            comparisonMatchType.lastSetTiebreakPoints = 7
            comparisonMatchType.matchTiebreakPoints = 10
            comparisonMatchType.matchTiebreak = false
        case 2:
            comparisonMatchType.totalSets = 2
            comparisonMatchType.gamesInSet = 6
            comparisonMatchType.twoGameDifference = true
            comparisonMatchType.noAd = true
            comparisonMatchType.heatRule = false
            comparisonMatchType.ballChange = 0
            comparisonMatchType.advantageSet = 0
            comparisonMatchType.tiebreakAt = 6
            comparisonMatchType.tiebreakPoints = 7
            comparisonMatchType.lastSetTiebreakPoints = 7
            comparisonMatchType.matchTiebreakPoints = 10
            comparisonMatchType.matchTiebreak = true
        case 3:
            comparisonMatchType.totalSets = 2
            comparisonMatchType.gamesInSet = 4
            comparisonMatchType.twoGameDifference = true
            comparisonMatchType.noAd = false
            comparisonMatchType.heatRule = false
            comparisonMatchType.ballChange = 0
            comparisonMatchType.advantageSet = 0
            comparisonMatchType.tiebreakAt = 4
            comparisonMatchType.tiebreakPoints = 7
            comparisonMatchType.lastSetTiebreakPoints = 7
            comparisonMatchType.matchTiebreakPoints = 10
            comparisonMatchType.matchTiebreak = false
        case 4:
            comparisonMatchType.totalSets = 2
            comparisonMatchType.gamesInSet = 8
            comparisonMatchType.twoGameDifference = true
            comparisonMatchType.noAd = false
            comparisonMatchType.heatRule = false
            comparisonMatchType.ballChange = 0
            comparisonMatchType.advantageSet = 0
            comparisonMatchType.tiebreakAt = 8
            comparisonMatchType.tiebreakPoints = 7
            comparisonMatchType.lastSetTiebreakPoints = 7
            comparisonMatchType.matchTiebreakPoints = 10
            comparisonMatchType.matchTiebreak = false
        case 5:
            comparisonMatchType.totalSets = 2
            comparisonMatchType.gamesInSet = 10
            comparisonMatchType.twoGameDifference = true
            comparisonMatchType.noAd = false
            comparisonMatchType.heatRule = false
            comparisonMatchType.ballChange = 0
            comparisonMatchType.advantageSet = 0
            comparisonMatchType.tiebreakAt = 10
            comparisonMatchType.tiebreakPoints = 7
            comparisonMatchType.lastSetTiebreakPoints = 7
            comparisonMatchType.matchTiebreakPoints = 10
            comparisonMatchType.matchTiebreak = false
        case 6:
            comparisonMatchType.totalSets = 1
            comparisonMatchType.gamesInSet = 4
            comparisonMatchType.twoGameDifference = true
            comparisonMatchType.noAd = false
            comparisonMatchType.heatRule = false
            comparisonMatchType.ballChange = 0
            comparisonMatchType.advantageSet = 0
            comparisonMatchType.tiebreakAt = 4
            comparisonMatchType.tiebreakPoints = 7
            comparisonMatchType.lastSetTiebreakPoints = 7
            comparisonMatchType.matchTiebreakPoints = 10
            comparisonMatchType.matchTiebreak = false
        case 7:
            comparisonMatchType.totalSets = 0
            comparisonMatchType.gamesInSet = 0
            comparisonMatchType.twoGameDifference = false
            comparisonMatchType.noAd = false
            comparisonMatchType.heatRule = false
            comparisonMatchType.ballChange = 0
            comparisonMatchType.advantageSet = 0
            comparisonMatchType.tiebreakAt = 0
            comparisonMatchType.tiebreakPoints = 7
            comparisonMatchType.lastSetTiebreakPoints = 0
            comparisonMatchType.matchTiebreakPoints = 0
            comparisonMatchType.matchTiebreak = false
        case 8:
            comparisonMatchType.totalSets = 0
            comparisonMatchType.gamesInSet = 0
            comparisonMatchType.twoGameDifference = false
            comparisonMatchType.noAd = false
            comparisonMatchType.heatRule = false
            comparisonMatchType.ballChange = 0
            comparisonMatchType.advantageSet = 0
            comparisonMatchType.tiebreakAt = 0
            comparisonMatchType.tiebreakPoints = 0
            comparisonMatchType.lastSetTiebreakPoints = 0
            comparisonMatchType.matchTiebreakPoints = 10
            comparisonMatchType.matchTiebreak = false
        case 9:
            comparisonMatchType.totalSets = 2
            comparisonMatchType.gamesInSet = 6
            comparisonMatchType.twoGameDifference = true
            comparisonMatchType.noAd = false
            comparisonMatchType.heatRule = false
            comparisonMatchType.ballChange = 0
            comparisonMatchType.advantageSet = 0
            comparisonMatchType.tiebreakAt = 6
            comparisonMatchType.tiebreakPoints = 7
            comparisonMatchType.lastSetTiebreakPoints = 7
            comparisonMatchType.matchTiebreakPoints = 10
            comparisonMatchType.matchTiebreak = false
        default:
            break
        }
    }
    
    func compareMatchTypes(firstMatchType: MatchType, secondMatchType: MatchType) -> Bool {
        if firstMatchType.matchType == secondMatchType.matchType {
            if firstMatchType.template == secondMatchType.template {
                if firstMatchType.totalSets == secondMatchType.totalSets {
                    if firstMatchType.gamesInSet == secondMatchType.gamesInSet {
                        if firstMatchType.twoGameDifference == secondMatchType.twoGameDifference {
                            if firstMatchType.noAd == secondMatchType.noAd {
                                if firstMatchType.heatRule == secondMatchType.heatRule {
                                    if firstMatchType.advantageSet == secondMatchType.advantageSet {
                                        if firstMatchType.tiebreakAt == secondMatchType.tiebreakAt {
                                            if firstMatchType.tiebreakPoints == secondMatchType.tiebreakPoints {
                                                if firstMatchType.lastSetTiebreakPoints == secondMatchType.lastSetTiebreakPoints {
                                                    if firstMatchType.matchTiebreakPoints == secondMatchType.matchTiebreakPoints {
                                                        if firstMatchType.matchTiebreak == secondMatchType.matchTiebreak {
                                                            return true
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return false
    }
    
    func sendAmountOfSetsData(amountOfSets: Int) {
        matchType.totalSets = amountOfSets
        
        initComparison()
        
        if matchType.totalSets != comparisonMatchType.totalSets {
            matchType.template = 9
        } else {
            if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false{
                let checkupTemplate = comparisonMatchType.template
                comparisonMatchType.template = 9
                
                if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false {
                    comparisonMatchType.template = checkupTemplate
                } else {
                    comparisonMatchType.template = checkupTemplate
                    matchType.template = matchType.templateBackup
                }
            }
        }
        
        initSubtitles()
        matchRuleTableView.reloadData()
    }
    
    func sendAmountOfGamesData(amountOfGames: Int) {
        matchType.gamesInSet = amountOfGames
        matchType.tiebreakAt = amountOfGames
        
        initComparison()
        
        if matchType.gamesInSet != comparisonMatchType.gamesInSet {
            matchType.template = 9
        } else {
            if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false{
                let checkupTemplate = comparisonMatchType.template
                comparisonMatchType.template = 9
                
                if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false {
                    comparisonMatchType.template = checkupTemplate
                } else {
                    comparisonMatchType.template = checkupTemplate
                    matchType.template = matchType.templateBackup
                }
            }
        }
                
        initSubtitles()
        matchRuleTableView.reloadData()
    }
    
    func sendAdvantageSetData(advantageSet: Int) {
        matchType.advantageSet = advantageSet
        
        initComparison()
        
        if matchType.advantageSet != comparisonMatchType.advantageSet {
            matchType.template = 9
        } else {
            if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false{
                let checkupTemplate = comparisonMatchType.template
                comparisonMatchType.template = 9
                
                if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false {
                    comparisonMatchType.template = checkupTemplate
                } else {
                    comparisonMatchType.template = checkupTemplate
                    matchType.template = matchType.templateBackup
                }
            }
        }
                
        initSubtitles()
        matchRuleTableView.reloadData()
    }
    
    func sendTiebreakAtData(tiebreakAt: Int) {
        matchType.tiebreakAt = tiebreakAt
        
        initComparison()
        
        if matchType.tiebreakAt != comparisonMatchType.tiebreakAt {
            matchType.template = 9
        } else {
            if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false{
                let checkupTemplate = comparisonMatchType.template
                comparisonMatchType.template = 9
                
                if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false {
                    comparisonMatchType.template = checkupTemplate
                } else {
                    comparisonMatchType.template = checkupTemplate
                    matchType.template = matchType.templateBackup
                }
            }
        }
                
        initSubtitles()
        matchRuleTableView.reloadData()
    }
    
    func sendTiebreakPointsData(tiebreakPoints: Int) {
        matchType.tiebreakPoints = tiebreakPoints
        
        initComparison()
        
        if matchType.tiebreakPoints != comparisonMatchType.tiebreakPoints {
            matchType.template = 9
        } else {
            if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false{
                let checkupTemplate = comparisonMatchType.template
                comparisonMatchType.template = 9
                
                if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false {
                    comparisonMatchType.template = checkupTemplate
                } else {
                    comparisonMatchType.template = checkupTemplate
                    matchType.template = matchType.templateBackup
                }
            }
        }
                
        initSubtitles()
        matchRuleTableView.reloadData()
    }
    
    func sendMatchTiebreakPointsData(matchTiebreakPoints: Int) {
        matchType.matchTiebreakPoints = matchTiebreakPoints
        
        initComparison()
        
        if matchType.matchTiebreakPoints != comparisonMatchType.matchTiebreakPoints {
            matchType.template = 9
        } else {
            if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false{
                let checkupTemplate = comparisonMatchType.template
                comparisonMatchType.template = 9
                
                if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false {
                    comparisonMatchType.template = checkupTemplate
                } else {
                    comparisonMatchType.template = checkupTemplate
                    matchType.template = matchType.templateBackup
                }
            }
        }
                
        initSubtitles()
        matchRuleTableView.reloadData()
    }
    
    func sendTiebreakPointsLastSetData(tiebreakPointsLastSet: Int) {
        matchType.lastSetTiebreakPoints = tiebreakPointsLastSet
        
        initComparison()
        
        if matchType.lastSetTiebreakPoints != comparisonMatchType.lastSetTiebreakPoints {
            matchType.template = 9
        } else {
            if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false{
                let checkupTemplate = comparisonMatchType.template
                comparisonMatchType.template = 9
                
                if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false {
                    comparisonMatchType.template = checkupTemplate
                } else {
                    comparisonMatchType.template = checkupTemplate
                    matchType.template = matchType.templateBackup
                }
            }
        }
                
        initSubtitles()
        matchRuleTableView.reloadData()
    }
    
    func sendBallChangeData(selectedBallChange: Int) {
        matchType.ballChange = selectedBallChange
        
        initComparison()
        
        if matchType.ballChange != comparisonMatchType.ballChange {
            matchType.template = 9
        } else {
            if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false{
                let checkupTemplate = comparisonMatchType.template
                comparisonMatchType.template = 9
                
                if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false {
                    comparisonMatchType.template = checkupTemplate
                } else {
                    comparisonMatchType.template = checkupTemplate
                    matchType.template = matchType.templateBackup
                }
            }
        }
                
        initSubtitles()
        matchRuleTableView.reloadData()
    }
    
    func sendTrueFalseData(selectedBool: Bool, currentHeading: String) {
        switch currentHeading {
        case "2 Games difference":
            matchType.twoGameDifference = selectedBool
            
            initComparison()
            
            if matchType.twoGameDifference != comparisonMatchType.twoGameDifference {
                matchType.template = 9
            } else {
                if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false{
                    let checkupTemplate = comparisonMatchType.template
                    comparisonMatchType.template = 9
                    
                    if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false {
                        comparisonMatchType.template = checkupTemplate
                    } else {
                        comparisonMatchType.template = checkupTemplate
                        matchType.template = matchType.templateBackup
                    }
                }
            }
        case "NoAd":
            matchType.noAd = selectedBool
            
            initComparison()
            
            if matchType.noAd != comparisonMatchType.noAd {
                matchType.template = 9
            } else {
                if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false{
                    let checkupTemplate = comparisonMatchType.template
                    comparisonMatchType.template = 9
                    
                    if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false {
                        comparisonMatchType.template = checkupTemplate
                    } else {
                        comparisonMatchType.template = checkupTemplate
                        matchType.template = matchType.templateBackup
                    }
                }
            }
        case "Heat Rule":
            matchType.heatRule = selectedBool
            
            initComparison()
            
            if matchType.heatRule != comparisonMatchType.heatRule {
                matchType.template = 9
            } else {
                if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false{
                    let checkupTemplate = comparisonMatchType.template
                    comparisonMatchType.template = 9
                    
                    if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false {
                        comparisonMatchType.template = checkupTemplate
                    } else {
                        comparisonMatchType.template = checkupTemplate
                        matchType.template = matchType.templateBackup
                    }
                }
            }
        case "Final Set Match TieBreak":
            matchType.matchTiebreak = selectedBool
            
            initComparison()
            
            if matchType.matchTiebreak != comparisonMatchType.matchTiebreak {
                matchType.template = 9
            } else {
                if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false{
                    let checkupTemplate = comparisonMatchType.template
                    comparisonMatchType.template = 9
                    
                    if compareMatchTypes(firstMatchType: matchType, secondMatchType: comparisonMatchType) == false {
                        comparisonMatchType.template = checkupTemplate
                    } else {
                        comparisonMatchType.template = checkupTemplate
                        matchType.template = matchType.templateBackup
                    }
                }
            }
        default:
            break
        }
                
        initSubtitles()
        matchRuleTableView.reloadData()
    }
    
}
