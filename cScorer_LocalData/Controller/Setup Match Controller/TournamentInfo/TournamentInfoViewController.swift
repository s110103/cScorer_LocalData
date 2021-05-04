//
//  TournamentInfoViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 26.11.20.
//

import UIKit

protocol TournamentInfoViewControllerDelegate {
    func sendTournamendInfoData(tournamentInfo: TournamentData)
}

class TournamentInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EditDistinctTournamendDataViewControllerDelegate {
    
    // MARK: - Variables
    var selectedItem: String = ""
    var distinctTournamentData: String = ""
    var tournamentInfo: TournamentData = TournamentData()
    var sectionHeaders: [String] =
    [
        "Tournament info"
    ]
    
    var itemTitles: [[String]] =
    [
        ["Tournament name",
        "Tournament venue",
        "Tournament level",
        "Tournament category"]
    ]
    var itemSubtitles: [[String]] = [[]]
    var delegate: TournamentInfoViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var tournamentInfoTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tournamentInfoTableView.delegate = self
        tournamentInfoTableView.dataSource = self
        
        initSubtitles()
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionHeaders.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeaders[section]
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemTitles[section].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tournamentInfoTableView.dequeueReusableCell(withIdentifier: "tournamentInfoCell", for: indexPath)
        
        let section = indexPath.section
        let row = indexPath.row
        
        cell.textLabel?.text = itemTitles[section][row]
        cell.detailTextLabel?.text = itemSubtitles[section][row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tournamentInfoTableView.deselectRow(at: indexPath, animated: true)
        
        let section = indexPath.section
        let row = indexPath.row
        let title = itemTitles[section][row]
        let subTitle = itemSubtitles[section][row]
        
        selectedItem = title
        distinctTournamentData = subTitle
        performSegue(withIdentifier: "editDistinctTournamentDataSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editDistinctTournamentDataSegue" {
            let destinationVC = segue.destination as! EditDistinctTournamentDataViewController
            
            destinationVC.selectedItem = selectedItem
            destinationVC.distinctTournamentData = distinctTournamentData
            
            destinationVC.delegate = self
        }
    }
    
    func sendDistinctTournamendDate(_dataType: String, _distinctTournamentData: String) {

        switch _dataType {
        case "Tournament name":
            tournamentInfo.tournamentName = _distinctTournamentData
        case "Tournament venue":
            tournamentInfo.tournamentPlace = _distinctTournamentData
        case "Tournament level":
            tournamentInfo.tournamentStage = _distinctTournamentData
        case "Tournament category":
            tournamentInfo.tournamentCategory = _distinctTournamentData
        default:
            break
        }
        
        initSubtitles()
        tournamentInfoTableView.reloadData()
    }
    
    func initSubtitles() {
        itemSubtitles.removeAll()
        
        var infoInput: [String] = []
        
        infoInput.append(tournamentInfo.tournamentName)
        infoInput.append(tournamentInfo.tournamentPlace)
        infoInput.append(tournamentInfo.tournamentStage)
        infoInput.append(tournamentInfo.tournamentCategory)
        
        itemSubtitles.append(infoInput)
    }

}
