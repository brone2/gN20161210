//
//  mePastCompletedCell.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/11/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//

import UIKit

class mePastCompletedCell: UITableViewCell {

    @IBOutlet var coinImage: UIImageView!
    @IBOutlet var personNameLabel: UILabel!
    @IBOutlet var requestedTimeLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var complaintButton: UIButton!
    @IBOutlet var profilePic: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
