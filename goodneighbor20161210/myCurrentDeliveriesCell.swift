//
//  myCurrentDeliveriesCell.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/9/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//

import UIKit

class myCurrentDeliveriesCell: UITableViewCell {
    
    
    //@IBOutlet var redQuestionMark: UIImageView!
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var nameLabel: UILabel! //product name
    @IBOutlet var phoneImage: UIImageView!
    @IBOutlet var chatImage: UIImageView!
    @IBOutlet var coinImage: UIImageView!
    @IBOutlet var deliverToLabel: UILabel! //ie front desk
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var deliveringTo: UILabel! //This is person name
    @IBOutlet var payTypeImage: UIImageView!
    @IBOutlet var purchaseCompleteButton: UIButton!
    @IBOutlet var blueQuestionMarkButton: customButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
