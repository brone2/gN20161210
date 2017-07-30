//
//  currentRunsCell.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 6/13/17.
//  Copyright © 2017 Neil Bronfin. All rights reserved.
//

import UIKit

class currentRunsCell: UITableViewCell {
    
    
    @IBOutlet var runLabel: UILabel!
    @IBOutlet var runnerNameLabel: UILabel!
    @IBOutlet var runnerLocationLabel: UILabel!
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var requestCountLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
