//
//  viewDetailGeneralShoppingList.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/9/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import MessageUI
import MessageUI.MFMailComposeViewController

class viewDetailGeneralShoppingList: UIViewController, UITextViewDelegate, UITextFieldDelegate, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet var decriptionTextView: UITextView!
    @IBOutlet var requestedByLabel: UILabel!
    @IBOutlet var profilePicImage: UIImageView!
    @IBOutlet var productNameLabel: UILabel!
    @IBOutlet var productImage: UIImageView!
    @IBOutlet var distanceLabel: UILabel!
    
    @IBOutlet var flagButton: UIButton!
    
    var currentUserName:String!
    var loggedInUserId:String!
    var acceptedTime = NSDate()
    var databaseRef = FIRDatabase.database().reference()
    var shoppingListCurrentRequests = [NSDictionary?]()
    var selectedRowIndex:Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.flagButton.contentHorizontalAlignment = .left
        
        
        self.loggedInUserId = FIRAuth.auth()?.currentUser?.uid
        self.requestedByLabel.text = String("Requested by \(self.shoppingListCurrentRequests[self.selectedRowIndex]?["requesterName"] as! String)")
        self.productNameLabel.text = String("\(self.shoppingListCurrentRequests[self.selectedRowIndex]?["itemName"] as! String)")
 
        
        let buildingCheck = self.shoppingListCurrentRequests[self.selectedRowIndex]?["buildingName"] as? String
        
        if buildingCheck != "N/A" {
            
             self.distanceLabel.text = String("Located \(self.shoppingListCurrentRequests[self.selectedRowIndex]?["distanceFromUser"] as! String) mi away in \(buildingCheck!)")
            
        } else {

        self.distanceLabel.text = String("Located \(self.shoppingListCurrentRequests[self.selectedRowIndex]?["distanceFromUser"] as! String) mi away from you")
            
        }
        
        self.decriptionTextView.text = self.shoppingListCurrentRequests[self.selectedRowIndex]?["description"] as! String
        
        
        if let image = self.shoppingListCurrentRequests[self.selectedRowIndex]?["profilePicReference"] as? String {
            
            let data = try? Data(contentsOf: URL(string: image)!)
            
            self.profilePicImage.image = UIImage(data: data!)
            
        }
        
        self.profilePicImage.layer.cornerRadius = 40
        self.profilePicImage.layer.masksToBounds = true
        self.profilePicImage.contentMode = .scaleAspectFit
        self.profilePicImage.layer.borderWidth = 2.0
        self.profilePicImage.layer.borderColor = UIColor(red: 16/255, green: 126/255, blue: 207/255, alpha: 1).cgColor
        
        //if let image = self.shoppingListCurrentRequests[self.selectedRowIndex]?["image_request"] as? String {
        if let image = self.shoppingListCurrentRequests[self.selectedRowIndex]?["productImage"] as? String {
            
            let data = try? Data(contentsOf: URL(string: image)!)
            
            self.productImage.image = UIImage(data: data!)
            
        }

        let imageTap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapMediaInTweet(_:)))
        let imageTap2:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapMediaInTweet(_:)))
        
        self.profilePicImage.addGestureRecognizer(imageTap2)
        self.productImage.addGestureRecognizer(imageTap)
       
        
    }
    
    
    @IBAction func didTapFlagContent(_ sender: Any) {
        
        
        let alert = UIAlertController(title: "Flag user", message: "You have identified this user as either having an inappropriate account or posting inappropriate content. This request will be immediately removed from the neighberhood shopping list and the user's account will be put under review ", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            //nothing happens
        }))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
        self.databaseRef.child("request").child((self.shoppingListCurrentRequests[self.selectedRowIndex]?["requestKey"] as? String)!).child("isComplete").setValue(true)
            
        self.databaseRef.child("request").child((self.shoppingListCurrentRequests[self.selectedRowIndex]?["requestKey"] as? String)!).child("isAccepted").setValue(true)
            
        self.databaseRef.child("request").child((self.shoppingListCurrentRequests[self.selectedRowIndex]?["requestKey"] as? String)!).child("isFlagged").setValue(true)
            
            let alertFin = UIAlertController(title: "Thank you", message: "The request has been removed and this user's account is currently under review", preferredStyle: UIAlertControllerStyle.alert)
            
            alertFin.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: self.seger)
            }))
            self.present(alertFin, animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    

    @IBAction func didTapAccept(_ sender: Any) {
        
        let alert = UIAlertController(title: "Accept Delivery", message: "Please only accept this if you know you will be able to deliver this item within the next two hours. It will be the responsibility of the recievor to repay you upon delivery ", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            //nothing happens
        }))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
     /*
        self.databaseRef.child("request").child((self.shoppingListCurrentRequests[self.selectedRowIndex]?["requestKey"] as? String)!).child("isAccepted").setValue(true)
         
        self.databaseRef.child("request").child((self.shoppingListCurrentRequests[self.selectedRowIndex]?["requestKey"] as? String)!).child("accepterUID").setValue(self.loggedInUserId)
            
        self.databaseRef.child("request").child((self.shoppingListCurrentRequests[self.selectedRowIndex]?["requestKey"] as? String)!).child("accepterName").setValue(loggedInUserName)
            
        self.databaseRef.child("request").child((self.shoppingListCurrentRequests[self.selectedRowIndex]?["requestKey"] as? String)!).child("accepterProfilePicRef").setValue(myProfilePicRef)
   */
       
        let childUpdates = ["/request/\((self.shoppingListCurrentRequests[self.selectedRowIndex]?["requestKey"] as? String)!)/isAccepted":true,"/request/\((self.shoppingListCurrentRequests[self.selectedRowIndex]?["requestKey"] as? String)!)/accepterCell":myCellNumber as String,"/request/\((self.shoppingListCurrentRequests[self.selectedRowIndex]?["requestKey"] as? String)!)/accepterUID":self.loggedInUserId,"/request/\((self.shoppingListCurrentRequests[self.selectedRowIndex]?["requestKey"] as? String)!)/accepterName":loggedInUserName, "/request/\((self.shoppingListCurrentRequests[self.selectedRowIndex]?["requestKey"] as? String)!)/accepterProfilePicRef":myProfilePicRef] as [String : Any]
 
        self.databaseRef.updateChildValues(childUpdates)
 
            let requesterCell = self.shoppingListCurrentRequests[self.selectedRowIndex]?["requesterCell"] as? String
            let requesterName = self.shoppingListCurrentRequests[self.selectedRowIndex]?["requesterName"] as? String
            let itemName = self.shoppingListCurrentRequests[self.selectedRowIndex]?["itemName"] as? String
            let itemPrice = self.shoppingListCurrentRequests[self.selectedRowIndex]?["price"] as? String
            
            let textMessage = "Hey \(requesterName!), I should be able to deliver to you \(itemName!) if I can find it for a price equal to or less than \(itemPrice!). Please message me back confirming you will fully recompensate me the price of the item up to or equal than \(itemPrice!). Thanks, \(loggedInUserName!) "
           // print(textMessage)
            
            if (MFMessageComposeViewController.canSendText()) {
                let controller = MFMessageComposeViewController();
                controller.body = textMessage;
                controller.recipients = [requesterCell!]
                controller.messageComposeDelegate = self;
                self.present(controller, animated: true, completion: nil)
            }
            
        }))
        self.present(alert, animated: true, completion: nil)
       
        
        }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.performSegue(withIdentifier: "detailToGeneralRefreshSegue", sender: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: self.seger)
    }

    func seger (){
     self.performSegue(withIdentifier: "detailToGeneralRefreshSegue", sender: nil)
    }
    
    func didTapMediaInTweet(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        
        newImageView.frame = self.view.frame
        
        newImageView.backgroundColor = UIColor.black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissFullScreenImage))
        
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        
    }
    func dismissFullScreenImage(sender: UITapGestureRecognizer){
        sender.view?.removeFromSuperview()
    }
}
