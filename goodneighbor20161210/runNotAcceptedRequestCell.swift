//
//  runNotAcceptedRequestCell.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 6/13/17.
//  Copyright © 2017 Neil Bronfin. All rights reserved.
//

import UIKit

class runNotAcceptedRequestCell: UITableViewCell {
    
    
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var willPayLabel: UILabel!
    @IBOutlet var coinImage: UIImageView!
    @IBOutlet var payTypeImage: UIImageView!
    @IBOutlet var chatImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
