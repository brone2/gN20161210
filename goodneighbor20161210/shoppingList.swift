//
//  shoppingList.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/8/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import SDWebImage
import MessageUI
import MessageUI.MFMailComposeViewController
import MapKit
import CoreLocation

var myProfilePicRef:String!
var myCellNumber:String!
var loggedInUserName:String!
var currentTokenCount: Int!

class shoppingList: UIViewController, UITableViewDelegate,UITableViewDataSource, MFMessageComposeViewControllerDelegate  {
    
    var tableHeaderArray = ["My Current Deliveries","My Current Requests","Community Requests"]
    
    let storageRef = FIRStorage.storage().reference()
    let databaseRef = FIRDatabase.database().reference()
    var loggedInUserId:String!
    var currentUserName:String!
    var loggedInUserData: AnyObject?
    var acceptorUserData: AnyObject?
    
    var myCurrentDeliveries = [NSDictionary?]()
    var myCurrentRequests = [NSDictionary?]()
    var shoppingListCurrentRequests = [NSDictionary?]()
    var sectionData = [Int:[NSDictionary?]]()
    
    var selectedRowIndex:Int?
    
    var requesterTokenCount:Int?
    var accepterTokenCount: Int?
    var requesterRecieveCount:Int?
    var accepterDeliveryCount: Int?
    
    var chatUser = 0
    
    @IBOutlet weak var table: UITableView!
    
    func childBeDeleted() {
        
        self.databaseRef.child("request").observe(.childRemoved) { (snapshot: FIRDataSnapshot) in
            
            let key = snapshot.key
         
            for sectionIndex in 0..<self.sectionData.count{
                
                for valIndex in (0..<((self.sectionData[sectionIndex]?.count)! as Int)).reversed() {
                    
                    let testKey = self.sectionData[sectionIndex]?[valIndex]?["requestKey"] as! String
                    
                    if testKey == key {
                     
                    self.sectionData[sectionIndex]?.remove(at: valIndex)
    
                    //Updating the community deliveries array for sake of real time update
                    //ISSUE IS HERE BECAUSE NEED TO HAVE GENERAL SECTION DATA UPDATED
                        if sectionIndex == 2 {
                    self.shoppingListCurrentRequests = self.sectionData[sectionIndex] as! [NSDictionary]
                        } else if sectionIndex == 1{
                    self.myCurrentRequests = self.sectionData[sectionIndex] as! [NSDictionary]
                        }
                        
                    self.table.reloadData()
                        
                    }
                }
            }
        }
    }
    
    func childBeChanged(){
        
        self.databaseRef.child("request").observe(.childChanged) { (snapshot: FIRDataSnapshot) in
         
            let key = snapshot.key
            let snapshot = snapshot.value as! NSDictionary
           
            for sectionIndex in 0..<self.sectionData.count{
              
                for valIndex in 0..<((self.sectionData[sectionIndex]?.count)! as Int) {
                    
                    let testKey = self.sectionData[sectionIndex]?[valIndex]?["requestKey"] as! String
                    
                    if testKey == key {
                        
                        //distance must be manually solved because not stored in firebase
                        let userLatitude = snapshot["latitude"] as? CLLocationDegrees
                        let userLongitude = snapshot["longitude"] as? CLLocationDegrees
                        let userLocation = CLLocation(latitude: userLatitude!, longitude: userLongitude!)
                        let distanceInMeters = myLocation!.distance(from: userLocation)
                        let distanceMiles = distanceInMeters/1609.344897
                        let distanceMilesFloat = Float(distanceMiles)
                        let requestDict = snapshot as! NSMutableDictionary //request dict holds updated data
                        let distanceMilesFloatString = String(format: "%.2f", distanceMilesFloat) //manually adding calculated distance from user
                        //isAccepted updated to take off this request immediately, isComplete is not so people can see isComplete message
                        requestDict["isAccepted"] = snapshot["isAccepted"] as? Bool
                        requestDict["distanceFromUser"] = distanceMilesFloatString
                        print(requestDict)
                        
                    self.sectionData[sectionIndex]?[valIndex] = requestDict
                    self.table.reloadData()
                        
                    }
                }
            }
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sectionData = [0:self.myCurrentDeliveries,1:self.myCurrentRequests,2:self.shoppingListCurrentRequests]
        
        self.loggedInUserId = FIRAuth.auth()?.currentUser?.uid
        
        self.childBeChanged()
        
        self.childBeDeleted()
        
     self.databaseRef.child("request").observe(.childAdded) { (snapshot: FIRDataSnapshot) in
        
            let snapshot = snapshot.value as! NSDictionary
            
            let snapID = snapshot["requesterUID"] as? String
            let snapAccepted = snapshot["isAccepted"] as? Bool
            let snapCompleted = snapshot["isComplete"] as? Bool
            let accepterID = snapshot["accepterUID"] as? String
        
            let userLatitude = snapshot["latitude"] as? CLLocationDegrees
            let userLongitude = snapshot["longitude"] as? CLLocationDegrees
        
            let userLocation = CLLocation(latitude: userLatitude!, longitude: userLongitude!)
            let distanceInMeters = myLocation!.distance(from: userLocation)
            let distanceMiles = distanceInMeters/1609.344897
            let distanceMilesFloat = Float(distanceMiles)
            
            //Filter out all request outside geolocation
            if distanceMilesFloat < myRadius! {
                
                let requestDict = snapshot as! NSMutableDictionary
                let distanceMilesFloatString = String(format: "%.2f", distanceMilesFloat)
                requestDict["distanceFromUser"] = distanceMilesFloatString
                
                //General shopping list requests, those that are not already accepted and not sent by you
                if(snapID != self.loggedInUserId && snapAccepted != true ){
             
                    self.shoppingListCurrentRequests.append(requestDict)
                    
                    self.shoppingListCurrentRequests.sort{ Double($0?["distanceFromUser"] as! String)! < Double($1?["distanceFromUser"] as! String)! }
                  
                }
                
                //My request
                if(snapID == self.loggedInUserId && snapCompleted != true ){
                    self.myCurrentRequests.append(requestDict)
                }
                
                //My Deliveries
                if(accepterID == self.loggedInUserId && snapCompleted != true ){
                    self.myCurrentDeliveries.append(requestDict)
               
                }
                self.sectionData = [0:self.myCurrentDeliveries,1:self.myCurrentRequests,2:self.shoppingListCurrentRequests]
                
                self.table.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return sectionData.count
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (self.sectionData[0]?.count) == 0 && (self.sectionData[1]?.count) == 0 && (self.sectionData[2]?.count) == 0 {
            
            self.performSegue(withIdentifier: "listToRequest", sender: nil)
            
        } else {
            
            if indexPath.section == 0 {
                self.selectedRowIndex = indexPath.row
                self.performSegue(withIdentifier: "generalToDeliveryDetail", sender: nil)
            }
            
            //Check added on plane
            if indexPath.section == 1 {
                self.selectedRowIndex = indexPath.row
                self.performSegue(withIdentifier: "myRequestDetailSegue", sender: nil)
            }
            
            if indexPath.section == 2 {
                
                //Need to handle live update issue where another user accepts delivery but it remains on screen
                let isAccepted:Bool = self.sectionData[indexPath.section]![indexPath.row]?["isAccepted"] as! Bool
                
                if isAccepted == false {
                    
                    self.selectedRowIndex = indexPath.row
                    self.performSegue(withIdentifier: "generalToDetail", sender: nil)
                    
                } else {
                    
                    let alertCancel = UIAlertController(title: "Request already accepted", message: "A different goodneighbor has accepted this request. Please choose another!", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alertCancel.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        //nothing happens
                    }))
                    
                    self.present(alertCancel, animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //
        
        if segue.identifier == "generalToDeliveryDetail" {
            
            let newViewController = segue.destination as! viewDetailDeliveryView
            newViewController.myCurrentDeliveries = self.myCurrentDeliveries
            newViewController.selectedRowIndex = selectedRowIndex
            
        }
        
        if segue.identifier == "myRequestDetailSegue" {
            
            let newViewController = segue.destination as! myCurrentRequestPopUp
            newViewController.myCurrentRequests = self.myCurrentRequests
            newViewController.selectedRowIndex = selectedRowIndex
            
        }
        
        if segue.identifier == "generalToDetail" {
            
            let secondViewController = segue.destination as! viewDetailGeneralShoppingList
            secondViewController.shoppingListCurrentRequests = shoppingListCurrentRequests
            secondViewController.selectedRowIndex = selectedRowIndex
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section != 2 {
            
            return((self.sectionData[section]?.count))!
            
        } else {
            
            if (self.sectionData[0]?.count) == 0 && (self.sectionData[1]?.count) == 0 && (self.sectionData[2]?.count) == 0 {
                return 1
            } else {
                return((self.sectionData[section]?.count))!
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 { // if is my current deliveries
            
            let cell:myCurrentDeliveriesCell = tableView.dequeueReusableCell(withIdentifier: "myDeliveriesCell", for: indexPath) as! myCurrentDeliveriesCell
            
            let isCompleted:Bool = self.sectionData[indexPath.section]![indexPath.row]?["isComplete"] as! Bool
            
            cell.deliverToLabel.text = self.sectionData[indexPath.section]![indexPath.row]?["deliverTo"] as? String
            
            let buildingCheck = self.sectionData[indexPath.section]![indexPath.row]?["buildingName"] as? String
            
            if buildingCheck != "N/A" {
                
                cell.distanceLabel.text = String("Lives \(self.sectionData[indexPath.section]![indexPath.row]?["distanceFromUser"] as! String) mi away in \(buildingCheck!)")
                
            } else {
                
                cell.distanceLabel.text = String("Lives \(self.sectionData[indexPath.section]![indexPath.row]?["distanceFromUser"] as! String) mi away from you")
                
            }
            
            cell.nameLabel.text = self.sectionData[indexPath.section]![indexPath.row]?["itemName"] as? String
            
            if isCompleted == false {
                cell.deliveringTo.text = String("Delivering to \(self.sectionData[indexPath.section]![indexPath.row]?["requesterName"] as! String)")
            } else {
                 cell.deliveringTo.text = "This request is complete!"
            }
            
            
            let tokenCountHelp:Int = (self.sectionData[indexPath.section]![indexPath.row]?["tokensOffered"] as? Int)!
            
            if tokenCountHelp == 1 {
                cell.coinImage.image = UIImage(named: "1FullToken.png")
            }
            if tokenCountHelp == 2 {
                cell.coinImage.image = UIImage(named: "2FullToken.png")
            }
            
            cell.chatImage.tag = indexPath.row
            let chatImageTap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapChatImage(_:)))
            cell.chatImage.addGestureRecognizer(chatImageTap)
            
            cell.phoneImage.tag = indexPath.row
            let phoneImageTap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapPhoneImage(_:)))
            cell.phoneImage.addGestureRecognizer(phoneImageTap)
            
            DispatchQueue.main.async{
                if let image = self.sectionData[indexPath.section]![indexPath.row]?["profilePicReference"] as? String {
                    
                    let url = URL(string: image)
                    
                    cell.profilePic!.sd_setImage(with: url, placeholderImage: UIImage(named:"saveImage2.png")!)
                    
                }}
            
            cell.profilePic.layer.cornerRadius = 27.5
            cell.profilePic.layer.masksToBounds = true
            cell.profilePic.contentMode = .scaleAspectFit
            cell.profilePic.layer.borderWidth = 2.0
            cell.profilePic.layer.borderColor = UIColor(red: 16/255, green: 126/255, blue: 207/255, alpha: 1).cgColor
            
            return cell
            
        }
            
        else if indexPath.section == 1 { //if is my current request
            
            let cell:myCurrentRequestsCell = tableView.dequeueReusableCell(withIdentifier: "myRequestsCell", for: indexPath) as! myCurrentRequestsCell
            
            cell.nameLabel.text = self.sectionData[indexPath.section]![indexPath.row]?["itemName"] as? String
            cell.deliverToLabel.text = self.sectionData[indexPath.section]![indexPath.row]?["deliverTo"] as? String
            
            let tokenCountHelp:Int = (self.sectionData[indexPath.section]![indexPath.row]?["tokensOffered"] as? Int)!
            
            let isAccepted:Bool = self.sectionData[indexPath.section]![indexPath.row]?["isAccepted"] as! Bool
            
            let isCompleted:Bool = self.sectionData[indexPath.section]![indexPath.row]?["isComplete"] as! Bool
            
            cell.cancelCompleteButton.tag = indexPath.row
            
            if isAccepted == false {
                
                cell.deliveringToLabel.text = "Not yet accepted"
                
                cell.cancelCompleteButton.removeTarget(nil, action: nil, for: .allEvents)
                cell.cancelCompleteButton.addTarget(self, action: #selector(self.didTapCancelButton(_:)), for: .touchUpInside)
                
                cell.chatImage.image = UIImage(named: "grayTextBubble.png")
                cell.phoneImage.image = UIImage(named: "grayTelephone.png")
                cell.cancelCompleteButton.setTitle("Cancel Request", for: [])
                cell.cancelCompleteButton.contentHorizontalAlignment = .left
                cell.cancelCompleteButton.setTitleColor(UIColor.red, for: [])
                
                if tokenCountHelp == 1 {
                    cell.coinImage.image = UIImage(named: "blackWhite1Coin")
                }
                if tokenCountHelp == 2 {
                    cell.coinImage.image = UIImage(named: "blackWhite2Coin")
                }
                
            } else { //isAccepted == true
                
                DispatchQueue.main.async{
                    if let image = self.sectionData[indexPath.section]![indexPath.row]?["accepterProfilePicRef"] as? String {
                        let url = URL(string: image)
                        cell.profilePic!.sd_setImage(with: url, placeholderImage: UIImage(named:"saveImage2.png")!)
                    }}
            
                cell.profilePic.layer.cornerRadius = 27.5
                cell.profilePic.layer.masksToBounds = true
                cell.profilePic.contentMode = .scaleAspectFit
                cell.profilePic.layer.borderWidth = 2.0
                cell.profilePic.layer.borderColor = UIColor(red: 16/255, green: 126/255, blue: 207/255, alpha: 1).cgColor
                
                cell.cancelCompleteButton.removeTarget(nil, action: nil, for: .allEvents)
                cell.cancelCompleteButton.addTarget(self, action: #selector(self.didTapCompleteButton(_:)), for: .touchUpInside)
                
              
                if isCompleted == false {
                     cell.cancelCompleteButton.setTitle("Mark Request as Complete", for: [])
                } else {
                    cell.cancelCompleteButton.setTitle("This request is complete!", for: [])
                }
                
                cell.chatImage.image = UIImage(named: "greenTextBubble.png")
                cell.chatImage.tag = indexPath.row
                let chatImageTap2:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapChatImageRequest(_:)))
                cell.chatImage.addGestureRecognizer(chatImageTap2)
              
                cell.phoneImage.image = UIImage(named: "greenTelephone.png")
                cell.phoneImage.tag = indexPath.row
                let phoneImageTap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapPhoneImageRequest(_:)))
                cell.phoneImage.addGestureRecognizer(phoneImageTap)
               
                cell.cancelCompleteButton.contentHorizontalAlignment = .left
                cell.cancelCompleteButton.setTitleColor(UIColor(red:0.054902, green: 0.376471, blue:0.61568, alpha:1.0), for: [])
                
                cell.deliveringToLabel.text = String("Delivery from \(self.sectionData[indexPath.section]![indexPath.row]?["accepterName"] as! String)")
                
                if tokenCountHelp == 1 {
                    cell.coinImage.image = UIImage(named: "1FullToken.png")
                }
                if tokenCountHelp == 2 {
                    cell.coinImage.image = UIImage(named: "2FullToken.png")
                }
                
            }
            
            return cell
            
        } else { //if is community request
            
            let cell:shoppingListCell = tableView.dequeueReusableCell(withIdentifier: "shoppingListCell", for: indexPath) as! shoppingListCell
            
            print(self.sectionData)
            
            if (self.sectionData[indexPath.section]?.count) == 0 {
                cell.nameLabel.text = "No Current Request in your community"
                cell.distanceLabel.text = "Select the pencil below and add one!"
                cell.deliverToLabel.text = ""
                return cell
            }
            
            cell.deliverToLabel.text = self.sectionData[indexPath.section]![indexPath.row]?["deliverTo"] as? String
            cell.distanceLabel.text = self.sectionData[indexPath.section]![indexPath.row]?["latitude"] as? String
            cell.nameLabel.text = self.sectionData[indexPath.section]![indexPath.row]?["itemName"] as? String
            
            let buildingCheck = self.sectionData[indexPath.section]![indexPath.row]?["buildingName"] as? String
            
            if buildingCheck != "N/A" {
                
                cell.distanceLabel.text = String("Lives \(self.sectionData[indexPath.section]![indexPath.row]?["distanceFromUser"] as! String) mi away in \(buildingCheck!)")
                
            } else {
                
                cell.distanceLabel.text = String("Lives \(self.sectionData[indexPath.section]![indexPath.row]?["distanceFromUser"] as! String) mi away from you")
                
            }
            
            let tokenCountHelp:Int? = self.sectionData[indexPath.section]![indexPath.row]?["tokensOffered"] as? Int
            
            if tokenCountHelp == 1 {
                cell.coinImage.image = UIImage(named: "1FullToken.png")
            }
            if tokenCountHelp == 2 {
                cell.coinImage.image = UIImage(named: "2FullToken.png")
            }
            DispatchQueue.main.async{
                if let image = self.sectionData[indexPath.section]![indexPath.row]?["profilePicReference"] as? String {
                    
                    let url = URL(string: image)
                    cell.profilePic!.sd_setImage(with: url, placeholderImage: UIImage(named:"saveImage2.png")!)
                    
                }}
            cell.profilePic.layer.cornerRadius = 27.5
            cell.profilePic.layer.masksToBounds = true
            cell.profilePic.contentMode = .scaleAspectFit
            cell.profilePic.layer.borderWidth = 2.0
            cell.profilePic.layer.borderColor = UIColor(red: 16/255, green: 126/255, blue: 207/255, alpha: 1).cgColor
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return 75
        } else {
            return 105
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let headers = tableHeaderArray[section]
        
        let emptyCheck = self.sectionData[section]! as! [NSDictionary]
        
        if emptyCheck == [] && section != 2 {
            return nil
        }
        
        return headers
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.table.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func didTapChatImage(_ gesture: UITapGestureRecognizer)  {
        
        let imageTag = gesture.view!.tag
        
        let requesterCell = self.sectionData[0]![imageTag]?["requesterCell"] as? String
        let requesterName = self.sectionData[0]![imageTag]?["requesterName"] as? String
        
        let textMessage = "Hey \(requesterName!), "
        
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController();
            controller.body = textMessage;
            controller.recipients = [requesterCell!]
            controller.messageComposeDelegate = self;
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func didTapPhoneImage(_ gesture: UITapGestureRecognizer)  {
        
        let imageTag = gesture.view!.tag
        
        let requesterCell = self.sectionData[0]![imageTag]?["requesterCell"] as? String
        
        if let url = URL(string: "tel://\(requesterCell!)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }

    
    func didTapPhoneImageRequest(_ gesture: UITapGestureRecognizer)  {
        
        let imageTag = gesture.view!.tag
        
        let requesterCell = self.sectionData[1]![imageTag]?["requesterCell"] as? String
        
        if let url = URL(string: "tel://\(requesterCell!)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
    func didTapChatImageRequest(_ gesture: UITapGestureRecognizer)  {
        
        let imageTag = gesture.view!.tag
        
        
        let requesterCell = self.sectionData[1]![imageTag]?["accepterCell"] as? String
        let requesterName = self.sectionData[1]![imageTag]?["accepterName"] as? String
        
        let textMessage = "Hey \(requesterName!), "
        
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController();
            controller.body = textMessage;
            controller.recipients = [requesterCell!]
            controller.messageComposeDelegate = self;
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func didTapCancelButton(_ sender: UIButton)  {
        
        if sender.titleLabel?.text == "Cancel Request" {
            
            let alertCancel = UIAlertController(title: "Cancel Request", message: "Are you sure you want to cancel this request? ", preferredStyle: UIAlertControllerStyle.alert)
            
            alertCancel.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                //nothing happens
            }))
            
            alertCancel.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                
                sender.setTitle("Request has been deleted", for: [])
                
                let index = sender.tag
                let requestKey = self.sectionData[1]![index]?["requestKey"] as? String
                let requestPath = "request/\(requestKey!)"
                let childUpdates = [requestPath:NSNull()]
                self.databaseRef.updateChildValues(childUpdates)
                
            }))
         self.present(alertCancel, animated: true, completion: nil)
        }
    }
    
    func reloaData(){
        self.table.reloadData()
    }
    
    
    func didTapCompleteButton(_ sender: UIButton)  {
        
        let alertComplete = UIAlertController(title: "Request Completed", message: "If you have recieved the item, and compensated the deliverer for the price he/she paid in full, this delivery is complete!", preferredStyle: UIAlertControllerStyle.alert)
        
        alertComplete.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            //nothing happens
        }))
        
        alertComplete.addAction(UIAlertAction(title: "Complete", style: .default, handler: { (action) in
            print("Selected COMPLETE")
            sender.setTitle("This request is complete!", for: [])
            //sender.isEnabled = false
            print("Selected COMPLETE1")
            
            let index = sender.tag
            let accepterUIDToken = self.sectionData[1]![index]?["accepterUID"] as? String
            let requesterUIDToken = self.sectionData[1]![index]?["requesterUID"] as? String
            let tokensToTransfer = self.sectionData[1]![index]?["tokensOffered"] as? Int
            let requestKey = self.sectionData[1]![index]?["requestKey"] as? String
            
            self.databaseRef.child("users").child(accepterUIDToken!).observeSingleEvent(of: .value) { (snapshot:FIRDataSnapshot) in
                
                let snapshot = snapshot.value as? NSDictionary
                self.accepterTokenCount = snapshot?["tokenCount"] as? Int
                self.accepterDeliveryCount = snapshot?["deliveryCount"] as? Int
                
                self.databaseRef.child("users").child(requesterUIDToken!).observeSingleEvent(of: .value) { (snapshot2:FIRDataSnapshot) in
                    
                    let snapshot2 = snapshot2.value as? NSDictionary
                    self.requesterTokenCount = snapshot2?["tokenCount"] as? Int
                    self.requesterRecieveCount = snapshot2?["recieveCount"] as? Int
                    
                    self.accepterTokenCount! += tokensToTransfer!
                    self.requesterTokenCount! -= tokensToTransfer!
                    
                    self.requesterRecieveCount! += 1
                    self.accepterDeliveryCount! += 1
                    
                    self.databaseRef.child("users").child(accepterUIDToken!).child("tokenCount").setValue(self.accepterTokenCount!)
                    self.databaseRef.child("users").child(requesterUIDToken!).child("tokenCount").setValue(self.requesterTokenCount!)
                    self.databaseRef.child("users").child(accepterUIDToken!).child("deliveryCount").setValue(self.accepterDeliveryCount!)
                    self.databaseRef.child("users").child(requesterUIDToken!).child("recieveCount").setValue(self.requesterRecieveCount!)
                    
                    self.databaseRef.child("request").child(requestKey!).child("isComplete").setValue(true)
                    
                    //Next Step move the request to completedRequestNode
                    
                }
            }
            
        }))
        self.present(alertComplete, animated: true, completion: nil)
        
    }
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
