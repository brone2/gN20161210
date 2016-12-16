//
//  viewDetailDeliveryView.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/11/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class viewDetailDeliveryView: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var productImage: UIImageView!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var productNameLabel: UILabel!
    @IBOutlet var profilePicImage: UIImageView!
    @IBOutlet var requestByLabel: UILabel!
    
    var currentUserName:String!
    var loggedInUserId:String!
    var acceptedTime = NSDate()
    var databaseRef = FIRDatabase.database().reference()
    
    var myCurrentDeliveries = [NSDictionary?]()
    var selectedRowIndex:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loggedInUserId = FIRAuth.auth()?.currentUser?.uid
        self.requestByLabel.text = String("Requested by \(self.myCurrentDeliveries[self.selectedRowIndex]?["requesterName"] as! String)")
        self.productNameLabel.text = String("Item name: \(self.myCurrentDeliveries[self.selectedRowIndex]?["itemName"] as! String)")
        // self.distanceLabel.text = String("Located \(self.shoppingListCurrentRequests[self.selectedRowIndex]?["latitude"] as! String) away from you")
        self.distanceLabel.text = String("Located \(self.myCurrentDeliveries[self.selectedRowIndex]?["distanceFromUser"] as! String) mi away from you")
        self.descriptionTextView.text = self.myCurrentDeliveries[self.selectedRowIndex]?["description"] as! String
        
        
        if let image = self.myCurrentDeliveries[self.selectedRowIndex]?["profilePicReference"] as? String {
            
            let data = try? Data(contentsOf: URL(string: image)!)
            
            self.profilePicImage.image = UIImage(data: data!)
            
        }
        
        self.profilePicImage.layer.cornerRadius = 40
        self.profilePicImage.layer.masksToBounds = true
        self.profilePicImage.contentMode = .scaleAspectFit
        self.profilePicImage.layer.borderWidth = 2.0
        self.profilePicImage.layer.borderColor = UIColor(red: 16/255, green: 126/255, blue: 207/255, alpha: 1).cgColor
        
        if let image = self.myCurrentDeliveries[self.selectedRowIndex]?["image_request"] as? String {
            
            let data = try? Data(contentsOf: URL(string: image)!)
            
            self.productImage.image = UIImage(data: data!)
            
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
