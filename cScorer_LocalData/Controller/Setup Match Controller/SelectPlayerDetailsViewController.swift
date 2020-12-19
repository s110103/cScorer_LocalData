//
//  SelectPlayerDetailsViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 29.11.20.
//

import UIKit
import ProgressHUD

protocol SelectPlayerDetailsViewControllerDelegate {
    func sendPlayerDetailsData(selectedPlayer: Player, playerType: String)
}

class SelectPlayerDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddPlayerViewControlerDelegate {
    
    // MARK: - Variables
    var savedPlayers: [Player] = []
    var editPlayer: Bool = false
    var indexOfPlayer: Int = 0
    var editingEntries: Bool = false
    var selectedPlayer: Player = Player()
    var playerType: String = ""
    var delegate: SelectPlayerDetailsViewControllerDelegate?
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Players.plist")
    
    // MARK: - Outlets
    @IBOutlet weak var searchPlayerTextField: UITextField!
    @IBOutlet weak var playersTableView: UITableView!
    @IBOutlet weak var editPlayersButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        searchPlayerTextField.layer.borderWidth = 1
        searchPlayerTextField.layer.cornerRadius = 5
        searchPlayerTextField.layer.borderColor = UIColor(ciColor: .white).cgColor
        searchPlayerTextField.attributedPlaceholder = NSAttributedString(string: "Suche", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        loadPlayers()
        
        playersTableView.delegate = self
        playersTableView.dataSource = self
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func searchPlayerButtonTapped(_ sender: UIButton) {
    }
    @IBAction func editButtonTapped(_ sender: UIButton) {
        if editingEntries == false {
            editingEntries = true
            editPlayersButton.tintColor = UIColor.red
            
        } else {
            editingEntries = false;
            editPlayersButton.tintColor = UIColor.white
        }
    }
    @IBAction func addPlayerButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "addPlayerSegue", sender: self)
    }
    
    // MARK: - Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedPlayers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playersTableView.dequeueReusableCell(withIdentifier: "playerSelectorCell", for: indexPath)
        
        let row = indexPath.row
        
        cell.textLabel?.text = "\(savedPlayers[row].firstName) \(savedPlayers[row].surName)"
        cell.detailTextLabel?.text = "\(savedPlayers[row].country)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playersTableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        
        delegate?.sendPlayerDetailsData(selectedPlayer: savedPlayers[row], playerType: playerType)
        
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let buttonDelete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, IndexPath) in
            if self.editingEntries == true {
                let i = indexPath.row
                    
                self.savedPlayers.remove(at: i)
                self.savePlayers()
                self.playersTableView.reloadData()
                
                if self.savedPlayers.count == 0 {
                    self.editingEntries = false
                    self.editPlayersButton.tintColor = UIColor.white
                }
            }
        }
        
        let buttonEdit = UITableViewRowAction(style: .default, title: "Edit") { (action, IndexPath) in
            self.editPlayer = true
            self.indexOfPlayer = indexPath.row
            self.performSegue(withIdentifier: "addPlayerSegue", sender: self)
        }
        
        buttonEdit.backgroundColor = UIColor.orange
        
        return [buttonDelete, buttonEdit]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "addPlayerSegue":
            let destinationVC = segue.destination as! AddPlayerViewController
            
            if editPlayer == true {
                destinationVC.editPlayer = true
                destinationVC.currentPlayer = savedPlayers[indexOfPlayer]
                destinationVC.indexOfPlayer = indexOfPlayer
            }
            
            destinationVC.delegate = self
        default:
            break
        }
    }
    
    func sendAddPlayerData(newPlayer: Player, editPlayer: Bool, indexOfPlayer: Int) {
        if editPlayer == true {
            savedPlayers.remove(at: indexOfPlayer)
            savedPlayers.insert(newPlayer, at: indexOfPlayer)
            self.editPlayer = false
            self.indexOfPlayer = 0
        } else {
            savedPlayers.append(newPlayer)
        }
        savePlayers()
        playersTableView.reloadData()
    }
    
    /*
            Store Matches
     */
    
    func savePlayers() {
        
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(savedPlayers)
            try data.write(to: dataFilePath!)
        } catch {
            ProgressHUD.showFailed()
        }
    }
    
    func loadPlayers() {
        
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            
            do {
                savedPlayers = try decoder.decode([Player].self, from: data)
            } catch {
                ProgressHUD.showFailed()
            }
        }
    }
}
