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
    
    let tableHeaderArray = ["My Current Deliveries","My Current Requests","Community Requests"]
    
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
 
    
    @IBOutlet weak var table: UITableView!
    /*
     func returnMyDistance(myLocation: CLLocation, userLatitude:CLLocationDegrees,userLongitude: CLLocationDegrees) -> Int {
     
     let userLocation = CLLocation(latitude: userLatitude, longitude: userLongitude)
     
     let distanceInMeters = myLocation.distance(from: userLocation)
     
     return Int(distanceInMeters)
     }
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loggedInUserId = FIRAuth.auth()?.currentUser?.uid
            
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
                print(distanceMilesFloat)
                print(userLocation)
                
                if distanceMilesFloat < myRadius! {
                    
                    let requestDict = snapshot as! NSMutableDictionary
                    let distanceMilesFloatString = String(format: "%.2f", distanceMilesFloat)
                    requestDict["distanceFromUser"] = distanceMilesFloatString
                    
                    //General shopping list requests, those that are not already accepted and not sent by you
                    
                    
                    
                    if(snapID != self.loggedInUserId && snapAccepted != true ){
                        self.shoppingListCurrentRequests.append(requestDict)
                      
                        //self.table.insertRows(at: [IndexPath(row: 0, section: 2)], with: UITableViewRowAnimation.automatic)
                    }
                    
                    //My request
                    if(snapID == self.loggedInUserId && snapCompleted != true ){
                        self.myCurrentRequests.append(requestDict)
                     
                        //self.table.insertRows(at: [IndexPath(row: 0, section: 1)], with: UITableViewRowAnimation.automatic)
                    }
                    
                    //My Deliveries
                    if(accepterID == self.loggedInUserId && snapCompleted != true ){
                        self.myCurrentDeliveries.append(requestDict)
                     
                        //  self.table.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.automatic)
                    }
                    self.sectionData = [0:self.myCurrentDeliveries,1:self.myCurrentRequests,2:self.shoppingListCurrentRequests]
                    
                      //  self.table.insertRows(at: [IndexPath(row: 0, section: rowToUpdate)], with: UITableViewRowAnimation.automatic)
                    
                    self.table.reloadData()
                    
                }
            }
        }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionData.count
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            self.selectedRowIndex = indexPath.row
            self.performSegue(withIdentifier: "generalToDeliveryDetail", sender: nil)
        }
        
        if indexPath.section == 2 {
            
            self.selectedRowIndex = indexPath.row
            self.performSegue(withIdentifier: "generalToDetail", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //
        
        
        
        if segue.identifier == "generalToDeliveryDetail" {
            
            let newViewController = segue.destination as! viewDetailDeliveryView
            newViewController.myCurrentDeliveries = self.myCurrentDeliveries
            newViewController.selectedRowIndex = selectedRowIndex
            
        }
        
        
        if segue.identifier == "generalToDetail" {
            
            let secondViewController = segue.destination as! viewDetailGeneralShoppingList
            secondViewController.shoppingListCurrentRequests = shoppingListCurrentRequests
            secondViewController.selectedRowIndex = selectedRowIndex
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return(self.sectionData[section]?.count)!
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 { // if is my current deliveries
            
            let cell:myCurrentDeliveriesCell = tableView.dequeueReusableCell(withIdentifier: "myDeliveriesCell", for: indexPath) as! myCurrentDeliveriesCell
            
            cell.deliverToLabel.text = self.sectionData[indexPath.section]![indexPath.row]?["deliverTo"] as? String
            cell.distanceLabel.text = String("Lives \(self.sectionData[indexPath.section]![indexPath.row]?["distanceFromUser"] as! String) mi away from you")
            cell.nameLabel.text = self.sectionData[indexPath.section]![indexPath.row]?["itemName"] as? String
            cell.deliveringTo.text = String("Delivering to \(self.sectionData[indexPath.section]![indexPath.row]?["requesterName"] as! String)")
            
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
            
            cell.cancelCompleteButton.tag = indexPath.row
            
            if isAccepted == false {
                
                cell.deliveringToLabel.text = "Not yet accepted"
                //cell.requestedTimeLabel.text = String("Requested at \(self.sectionData[indexPath.section]![indexPath.row]?["requestedTime"] as! String)")
                
                cell.cancelCompleteButton.addTarget(self, action: #selector(self.didTapCancelButton(_:)), for: .touchUpInside)
                
                cell.chatImage.image = UIImage(named: "grayTextBubble.png")
                cell.phoneImage.image = UIImage(named: "grayTelephone.png")
                cell.cancelCompleteButton.setTitle("Cancel Request", for: [])
                cell.cancelCompleteButton.contentHorizontalAlignment = .left
                cell.cancelCompleteButton.setTitleColor(UIColor.red, for: [])
                
                //cell.profilePic.layer.cornerRadius = 27.5
                //cell.profilePic.layer.masksToBounds = true
                //cell.profilePic.contentMode = .scaleAspectFit
                //cell.profilePic.layer.borderWidth = 2.0
                // cell.profilePic.layer.borderColor = UIColor(red: 16/255, green: 126/255, blue: 207/255, alpha: 1).cgColor
                
                if tokenCountHelp == 1 {
                    cell.coinImage.image = UIImage(named: "blackWhite1Coin")
                }
                if tokenCountHelp == 2 {
                    cell.coinImage.image = UIImage(named: "blackWhite2Coin")
                }
                
            } else {
                
                DispatchQueue.main.async{
                    if let image = self.sectionData[indexPath.section]![indexPath.row]?["accepterProfilePicRef"] as? String {
                        let url = URL(string: image)
                        cell.profilePic!.sd_setImage(with: url, placeholderImage: UIImage(named:"saveImage2.png")!)
                    }}
                //here
                cell.profilePic.layer.cornerRadius = 27.5
                cell.profilePic.layer.masksToBounds = true
                cell.profilePic.contentMode = .scaleAspectFit
                cell.profilePic.layer.borderWidth = 2.0
                cell.profilePic.layer.borderColor = UIColor(red: 16/255, green: 126/255, blue: 207/255, alpha: 1).cgColor
                
                print(sectionData)
                cell.cancelCompleteButton.addTarget(self, action: #selector(self.didTapCompleteButton(_:)), for: .touchUpInside)
                
                //let me = self.sectionData[indexPath.section]![indexPath.row]?["distanceFromUser"] as? String
                
                
                // cell.distanceLabel.text = "ok"
                //String("Lives \(self.sectionData[indexPath.section]![indexPath.row]?["distanceFromUser"] as? String) away from you")
                
                cell.chatImage.image = UIImage(named: "greenTextBubble.png")
                cell.phoneImage.image = UIImage(named: "greenTelephone.png")
                cell.cancelCompleteButton.setTitle("Mark Request as Complete", for: [])
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
            
            cell.deliverToLabel.text = self.sectionData[indexPath.section]![indexPath.row]?["deliverTo"] as? String
            cell.distanceLabel.text = self.sectionData[indexPath.section]![indexPath.row]?["latitude"] as? String
            cell.nameLabel.text = self.sectionData[indexPath.section]![indexPath.row]?["itemName"] as? String
            
            cell.distanceLabel.text = String("Lives \(self.sectionData[indexPath.section]![indexPath.row]?["distanceFromUser"] as! String) mi away from you")
            
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
        // Dispose of any resources that can be recreated.
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
    
    
    func didTapCancelButton(_ sender: UIButton)  {
        
        if sender.titleLabel?.text != "Request has been deleted" {
        
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
            
            sender.setTitle("This request is complete!", for: [])
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
