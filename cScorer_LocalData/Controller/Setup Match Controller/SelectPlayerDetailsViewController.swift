//
//  SelectPlayerDetailsViewController.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 29.11.20.
//

import UIKit

class SelectPlayerDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Variables
    var savedPlayers: [Player] = [Player(_firstName: "Dominik", _surName: "Thiem", _abbreviation: "Dominik T.", _country: "Österreich", _tennisClub: "", _gender: 0)]
    var editingEntries: Bool = false
    
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
        searchPlayerTextField.attributedPlaceholder = NSAttributedString(string: "Suche", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
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
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingEntries == true {
            if editingStyle == .delete {
                let i = indexPath.row
                
                savedPlayers.remove(at: i)
                
                playersTableView.reloadData()
            }
        }
    }

}
