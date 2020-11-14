//
//  AddMatchViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 13.11.20.
//

import UIKit

class AddMatchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SelectMatchTypeViewControllerDelegate {
    
    // MARK: - Variables
    var matchType = 0
    
    let sectionHeaders: [String] =
    [
        "Spieler", "Match Einstellungen", "Match"
    ]
    let itemTitles: [[String]] =
    [
        ["Match Typ","Spieler 1","Spieler 1 Details","Spieler 2","Spieler 2 Details"],
        ["Platz","Aufschläger","Aufschläger","Aufschläger"],
        ["Start"]
    ]
    let itemSubtitles: [[String]] =
    [
        ["Einzel","Spieler 1","Spieler 1","Spieler 2","Spieler 2"],
        ["CC","Spieler 1","Standard Match - 3 Sätze","Daten zum Turnier"],
        [""]
    ]
        
    
    // MARK: - Outlets
    @IBOutlet weak var matchDataTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        matchDataTableView.delegate = self
        matchDataTableView.dataSource = self
        
        
    }
    
    //MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        let scores = ["Bob": 5, "Alice": 3, "Arthur": 42]
        
        NotificationCenter.default.post(Notification(name: .didReceiveData, object: self, userInfo: scores))
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
        return itemTitles[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = matchDataTableView.dequeueReusableCell(withIdentifier: "matchDataCell", for: indexPath)
        let section = indexPath.section
        let row = indexPath.row
        
        cell.textLabel?.text = itemTitles[section][row]
        cell.detailTextLabel?.text = itemSubtitles[section][row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let title = itemTitles[indexPath.section][indexPath.row]
                
        switch title {
        case "Match Typ":
            let scores = ["Bob": 5, "Alice": 3, "Arthur": 42]
            
            NotificationCenter.default.post(Notification(name: .didReceiveData, object: self, userInfo: scores))
            
            performSegue(withIdentifier: "selectMatchTypeSegue", sender: self)
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectMatchTypeSegue" {
            print("Segue prepare")
            let destinationVC = segue.destination as! SelectMatchTypeViewController
            
            destinationVC.delegate = self
        }
    }
    
    func sendMatchType(matchType: Int) {
        self.matchType = matchType
        print("sendMatchType \(matchType)")
    }
}
