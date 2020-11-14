//
//  ViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 13.11.20.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Variables
    var matchFirstPlayer: [String] = ["Thiem D."]
    var matchSecondPlayer: [String] = ["Federer R."]
    var matchCourt: [String] = ["CC"]
    var matchStarted: [String] = ["13.11.2020 18:20"]
    var matchScore: [String] = ["(0:0), 0:0"]
    var matchSyncedWithCloud: [Bool] = [false]
    
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
        return matchScore.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = matchesTableView.dequeueReusableCell(withIdentifier: "matchSinglesPrototypeCell", for: indexPath) as! SinglesTableViewCell
        let i = indexPath.row
        
        if matchSyncedWithCloud[i] == true {
            cell.syncedWithCloudImage.image = UIImage(systemName: "icloud")
        } else {
            cell.syncedWithCloudImage.image = UIImage(systemName: "icloud.slash")
        }
        
        cell.matchDescriptionLabel.text = "\(matchFirstPlayer[i]) vs \(matchSecondPlayer[i])"
        cell.matchCourtLabel.text = "Platz \(matchCourt[i])"
        cell.timestampMatchStartedLabel.text = "\(matchStarted[i])"
        cell.matchScoreLabel.text = "\(matchScore[i])"
        
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
                let i = indexPath.row
                
                matchSyncedWithCloud.remove(at: i)
                matchFirstPlayer.remove(at: i)
                matchSecondPlayer.remove(at: i)
                matchCourt.remove(at: i)
                matchStarted.remove(at: i)
                matchScore.remove(at: i)
                
                matchesTableView.reloadData()
            }
        }
    }
    
}

