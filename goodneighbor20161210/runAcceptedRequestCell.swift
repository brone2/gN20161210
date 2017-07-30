//
//  runAcceptedRequestCell.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 6/13/17.
//  Copyright © 2017 Neil Bronfin. All rights reserved.
//

import UIKit

class runAcceptedRequestCell: UITableViewCell {

    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var coinImage: UIImageView!
    @IBOutlet var payTypeImage: UIImageView!
    @IBOutlet var chatImage: UIImageView!
    @IBOutlet var purchaseCompleteButton: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
