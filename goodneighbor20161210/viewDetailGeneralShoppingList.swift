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
        
    if myCellNumber == "0"{
        
        self.deliverAcceptedCompletion()
        
        let phoneAlert = UIAlertController(title: "Please Enter Phone Number", message: "Please enter your phone number so that \(self.shoppingListCurrentRequests[self.selectedRowIndex]?["requesterName"] as! String) may venmo you payment upon completion", preferredStyle: UIAlertControllerStyle.alert)
        
        phoneAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "viewGeneralToEnterPhone", sender: nil)
        }))
        self.present(phoneAlert, animated: true, completion: nil)

        
    } else {
        
        self.acceptDelivery()
        
    }
        
    }
    
    func acceptDelivery() {
        
        let alert = UIAlertController(title: "Accept Delivery", message: "Thank you for accepting this delivery! Please keep in touch with the requestor to ensure a smooth delivery process", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            //nothing happens
        }))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            /*let childUpdates = ["/request/\((self.shoppingListCurrentRequests[self.selectedRowIndex]?["requestKey"] as? String)!)/isAccepted":true,"/request/\((self.shoppingListCurrentRequests[self.selectedRowIndex]?["requestKey"] as? String)!)/accepterCell":myCellNumber as String,"/request/\((self.shoppingListCurrentRequests[self.selectedRowIndex]?["requestKey"] as? String)!)/accepterUID":self.loggedInUserId,"/request/\((self.shoppingListCurrentRequests[self.selectedRowIndex]?["requestKey"] as? String)!)/accepterName":loggedInUserName, "/request/\((self.shoppingListCurrentRequests[self.selectedRowIndex]?["requestKey"] as? String)!)/accepterProfilePicRef":myProfilePicRef] as [String : Any]
            
            self.databaseRef.updateChildValues(childUpdates)
            
            let requesterCell = self.shoppingListCurrentRequests[self.selectedRowIndex]?["requesterCell"] as? String
            let requesterName = self.shoppingListCurrentRequests[self.selectedRowIndex]?["requesterName"] as? String
            let itemName = self.shoppingListCurrentRequests[self.selectedRowIndex]?["itemName"] as? String
            let itemPrice = self.shoppingListCurrentRequests[self.selectedRowIndex]?["price"] as? String
            
            let textMessage = "Hey \(requesterName!), I am happy to deliver \(itemName!). Please message me back confirming you are committed to recompensate me a price up to \(itemPrice!), as well as a specific location of delivery. Thanks, \(loggedInUserName!) "
            // print(textMessage)
            
            if (MFMessageComposeViewController.canSendText()) {
                let controller = MFMessageComposeViewController();
                controller.body = textMessage;
                controller.recipients = [requesterCell!]
                controller.messageComposeDelegate = self;
                self.present(controller, animated: true, completion: nil)
            }*/
            
            self.deliverAcceptedCompletion()
            
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func deliverAcceptedCompletion() {
    
       let childUpdates = ["/request/\((self.shoppingListCurrentRequests[self.selectedRowIndex]?["requestKey"] as? String)!)/isAccepted":true,"/request/\((self.shoppingListCurrentRequests[self.selectedRowIndex]?["requestKey"] as? String)!)/accepterCell":myCellNumber as String,"/request/\((self.shoppingListCurrentRequests[self.selectedRowIndex]?["requestKey"] as? String)!)/accepterUID":FIRAuth.auth()?.currentUser?.uid,"/request/\((self.shoppingListCurrentRequests[self.selectedRowIndex]?["requestKey"] as? String)!)/accepterName":loggedInUserName, "/request/\((self.shoppingListCurrentRequests[self.selectedRowIndex]?["requestKey"] as? String)!)/accepterProfilePicRef":myProfilePicRef] as [String : Any]
         
         self.databaseRef.updateChildValues(childUpdates)
        
        if myCellNumber != "0" {
         
         let requesterCell = self.shoppingListCurrentRequests[self.selectedRowIndex]?["requesterCell"] as? String
         let requesterName = self.shoppingListCurrentRequests[self.selectedRowIndex]?["requesterName"] as? String
         let itemName = self.shoppingListCurrentRequests[self.selectedRowIndex]?["itemName"] as? String
         let itemPrice = self.shoppingListCurrentRequests[self.selectedRowIndex]?["price"] as? String
         
         let textMessage = "Hey \(requesterName!), I am happy to deliver \(itemName!). Please message me back confirming you are committed to recompensate me a price up to \(itemPrice!), as well as a specific location of delivery. Thanks, \(loggedInUserName!) "
         // print(textMessage)
         
         if (MFMessageComposeViewController.canSendText()) {
         let controller = MFMessageComposeViewController();
         controller.body = textMessage;
         controller.recipients = [requesterCell!]
         controller.messageComposeDelegate = self;
         self.present(controller, animated: true, completion: nil)
         }
    
        }
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "viewGeneralToEnterPhone" {
            
            let newViewController = segue.destination as! submitPhoneNumberView
            newViewController.isRequest = false
            newViewController.saveKey = (self.shoppingListCurrentRequests[self.selectedRowIndex]?["requestKey"] as? String)!
            newViewController.textMessage = "Hey \(self.shoppingListCurrentRequests[self.selectedRowIndex]?["requesterName"] as! String), I am happy to deliver \(self.shoppingListCurrentRequests[self.selectedRowIndex]?["itemName"] as! String). Please message me back confirming you are committed to recompensate me a price up to \(self.shoppingListCurrentRequests[self.selectedRowIndex]?["price"] as! String), as well as a specific location of delivery. Thanks, \(loggedInUserName!)"
            newViewController.phoneNumber = self.shoppingListCurrentRequests[self.selectedRowIndex]?["requesterCell"] as! String
            
            
        }
        
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
