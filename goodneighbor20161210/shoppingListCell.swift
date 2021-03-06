//
//  shoppingListCell.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/9/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//

import UIKit

class shoppingListCell: UITableViewCell {

    @IBOutlet var payTypeImage: UIImageView!
    @IBOutlet var coinImage: UIImageView!
    @IBOutlet var deliverToLabel: UILabel! //ie front desk
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var willingToPayLabel: UILabel!
    
    @IBOutlet var chatBubble: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
