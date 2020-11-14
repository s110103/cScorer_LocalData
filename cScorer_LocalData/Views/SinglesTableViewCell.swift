//
//  SinglesTableViewCell.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 13.11.20.
//

import UIKit

class SinglesTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var syncedWithCloudImage: UIImageView!
    @IBOutlet weak var matchDescriptionLabel: UILabel!
    @IBOutlet weak var timestampMatchStartedLabel: UILabel!
    @IBOutlet weak var matchCourtLabel: UILabel!
    @IBOutlet weak var matchScoreLabel: UILabel!
    
    
    // MARK: - Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
