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

class shoppingList: UIViewController, UITableViewDelegate,UITableViewDataSource, MFMessageComposeViewControllerDelegate, CLLocationManagerDelegate  {
    
    var tableHeaderArray = ["My Current Deliveries","My Current Requests","Community Requests"]
    
    @IBOutlet var oCoverUpText: UIImageView!
    @IBOutlet var coverUpBlueView: UIView!
    
    
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
    var requestPopUp:NSDictionary?
    
    var selectedRowIndex:Int?
    var rowHeight:CGFloat = 100
    
    var requesterTokenCount:Int?
    var accepterTokenCount: Int?
    var requesterRecieveCount:Int?
    var accepterDeliveryCount: Int?
    var purchasePrice: String?
    
    var locationManager = CLLocationManager()
    var userLocation: CLLocation?
    var userLatitude: CLLocationDegrees = 0.00000
    var userLongitude: CLLocationDegrees = 0.00000
    var isTest = false
    
    var questionMarkMessageRequest: String?
    var questionMarkMessageDelivery: String?
    var questionMarkMessageRequestTitle: String?
    var questionMarkMessageDeliveryTitle: String?
    
   @IBOutlet var questionMarkImage: UIButton!
    
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
                    //This is essentially backwards updating to prevent issue on .childAdded
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
                        let distanceMilesFloatString = String(format: "%.1f", distanceMilesFloat) //manually adding calculated distance from user
                        //isAccepted updated to take off this request immediately, isComplete is not so people can see isComplete message
                        requestDict["isAccepted"] = snapshot["isAccepted"] as? Bool
                        requestDict["distanceFromUser"] = distanceMilesFloatString
                        
                    self.sectionData[sectionIndex]?[valIndex] = requestDict
                    
                    //This is backwards from the .childAdded, but the purpose is to update the three dictionaries of SectionData, in the case a .childAdded event, the section data will pull from these three dictionaries which would not otherwise be updated 
                        if sectionIndex == 2 {
                            self.shoppingListCurrentRequests = self.sectionData[sectionIndex] as! [NSDictionary]
                        } else if sectionIndex == 1{
                            self.myCurrentRequests = self.sectionData[sectionIndex] as! [NSDictionary]
                        } else if sectionIndex == 0{
                            self.myCurrentDeliveries = self.sectionData[sectionIndex] as! [NSDictionary]
                        }
                    self.table.reloadData()
                        
                    }
                }
            }
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isSmallScreen || isVerySmallScreen {
            self.coverUpBlueView.frame = CGRect(x:99.7, y: 24.5, width: 11.1, height: 22)
            self.oCoverUpText.image = UIImage(named: "smallO2.png")
             self.oCoverUpText.frame = CGRect(x:99.9, y: 24.5, width: 10.5, height: 22)
        } else if isLargeScreen {
            self.coverUpBlueView.frame = CGRect(x:129.5, y: 20.5, width: 13.9, height: 30)
            self.oCoverUpText.image = UIImage(named: "smallOLarge1.png")
            self.oCoverUpText.frame = CGRect(x:129, y: 20.5, width: 14, height: 30)
        } else {
            self.oCoverUpText.frame = CGRect(x: 113, y: 26.5, width: 20.5, height: 19)
            self.coverUpBlueView.isHidden = true
        }
       
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        
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
            //if distanceMilesFloat < myRadius! {
                
                let requestDict = snapshot as! NSMutableDictionary
                let distanceMilesFloatString = String(format: "%.1f", distanceMilesFloat)
                requestDict["distanceFromUser"] = distanceMilesFloatString
                
                //General shopping list requests, those that are not already accepted and not sent by you
                if distanceMilesFloat < myRadius! {
                if(snapID != self.loggedInUserId && snapAccepted != true){
             
                    self.shoppingListCurrentRequests.append(requestDict)
                    self.shoppingListCurrentRequests.sort{ Double($0?["distanceFromUser"] as! String)! < Double($1?["distanceFromUser"] as! String)! }
                  
                }
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
        
        if segue.identifier == "listToCompletePopUp" {
            
            let secondViewController = segue.destination as! deliveryCompletePopUp
            secondViewController.requestPopUp = self.requestPopUp
            
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
        
    //Gesture Recognizers that apply to all sections
        let payTypeVenmoTap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapVenmoImage(_:)))
        
        let payTypeCashTap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapCashImage(_:)))
        
        let oneTokenTap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapOneCoin(_:)))
        
        let twoTokenTap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapTwoCoin(_:)))
        
        let oneTokenTapMyRequest: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapOneCoinMyRequest(_:)))
        
        let twoTokenTapMyRequest: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapTwoCoinMyRequest(_:)))
        
    //Table populated: First section is my Current Deliveries, Second is my Current Request, Third is community Request
        
        if indexPath.section == 0 { // if is my current deliveries
            
            let cell:myCurrentDeliveriesCell = tableView.dequeueReusableCell(withIdentifier: "myDeliveriesCell", for: indexPath) as! myCurrentDeliveriesCell
            
            cell.purchaseCompleteButton.contentHorizontalAlignment = .left

            let buildingCheck = self.sectionData[indexPath.section]![indexPath.row]?["buildingName"] as? String
            
            if buildingCheck != "N/A" {
                
                cell.distanceLabel.text = String("\(self.sectionData[indexPath.section]![indexPath.row]?["requesterName"] as! String) - \(buildingCheck!) (\(self.sectionData[indexPath.section]![indexPath.row]?["distanceFromUser"] as! String) mi)")
                
            } else {
                
                cell.distanceLabel.text = String("\(self.sectionData[indexPath.section]![indexPath.row]?["requesterName"] as! String) lives \(self.sectionData[indexPath.section]![indexPath.row]?["distanceFromUser"] as! String) mi from you")
                
            }
            
            cell.nameLabel.text = self.sectionData[indexPath.section]![indexPath.row]?["itemName"] as? String
            
            let payType:String = (self.sectionData[indexPath.section]![indexPath.row]?["paymentType"] as? String)!
            
            cell.payTypeImage.tag = indexPath.row
            
            if payType == "Venmo" {
                cell.payTypeImage.image = UIImage(named: "venmo-icon.png")
                cell.payTypeImage.addGestureRecognizer(payTypeVenmoTap)
            } else if payType == "Cash" {
                cell.payTypeImage.image = UIImage(named: "Cash_icon.png")
                cell.payTypeImage.layer.cornerRadius = 2.0
                cell.payTypeImage.layer.masksToBounds = true
                 cell.payTypeImage.addGestureRecognizer(payTypeCashTap)
            }
            
            let purchasePriceString: String = (self.sectionData[indexPath.section]![indexPath.row]?["purchasePrice"] as? String)!
            
            cell.purchaseCompleteButton.tag = indexPath.row
            
            cell.blueQuestionMarkButton.tag = indexPath.row
            
            if purchasePriceString == "NA" {
                
                cell.purchaseCompleteButton.setTitle("Purchase Complete", for: [])
                cell.deliverToLabel.text = "Will pay \(self.sectionData[indexPath.section]![indexPath.row]?["price"] as! String)"
               
            } else {
                
                let isComplete: Bool = self.sectionData[indexPath.section]![indexPath.row]?["isComplete"] as! Bool
                
                if !isComplete { //is not complete
                
                 cell.purchaseCompleteButton.setTitle("Awaiting Confirmation", for: [])
                 cell.deliverToLabel.text = "Purchased for \(self.sectionData[indexPath.section]![indexPath.row]?["purchasePrice"] as! String)"
                    
                } else {  //is complete WORKING HERE
                    
                    cell.purchaseCompleteButton.setTitle("Delivery Complete!", for: [])
                    cell.deliverToLabel.text = "Purchased for \(self.sectionData[indexPath.section]![indexPath.row]?["purchasePrice"] as! String)"
                    self.requestPopUp = self.sectionData[indexPath.section]![indexPath.row]
                    
                    if self.requestPopUp?["completedPopUpUsed"] != nil {
                        
                        let isPopUpComplete = self.requestPopUp?["completedPopUpUsed"] as! Bool
                        
                        if !isPopUpComplete {
                            
                            let tempDict = requestPopUp as! NSMutableDictionary //Mutable dict so I can change popup
                            tempDict["completedPopUpUsed"] = true
                            self.myCurrentDeliveries[indexPath.row] = tempDict
                            self.sectionData[indexPath.section]?[indexPath.row] = tempDict
                            
                            let requestKey = requestPopUp?["requestKey"] as! String
                            self.databaseRef.child("request").child(requestKey).child("completedPopUpUsed").setValue(true)
                            
                            self.performSegue(withIdentifier: "listToCompletePopUp", sender: nil)
                            
                        }
                        
                    
                    
                    }
                }
                
            }
            
            let tokenCountHelp:Int = (self.sectionData[indexPath.section]![indexPath.row]?["tokensOffered"] as? Int)!
            
            cell.coinImage.tag = indexPath.row
            
            if tokenCountHelp == 1 {
                cell.coinImage.image = UIImage(named: "1FullToken.png")
                cell.coinImage.addGestureRecognizer(oneTokenTap)
            }
            if tokenCountHelp == 2 {
                cell.coinImage.image = UIImage(named: "2FullToken.png")
                cell.coinImage.addGestureRecognizer(twoTokenTap)
            }
            
            if isVerySmallScreen {
                cell.chatImage.isHidden = true
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
            cell.profilePic.layer.borderColor = UIColor(red: 32/255, green: 90/255, blue: 130/255, alpha: 1).cgColor
            
            return cell
            
        }
            
        else if indexPath.section == 1 { //if is my current request
            
            let cell:myCurrentRequestsCell = tableView.dequeueReusableCell(withIdentifier: "myRequestsCell", for: indexPath) as! myCurrentRequestsCell
            
            cell.nameLabel.text = self.sectionData[indexPath.section]![indexPath.row]?["itemName"] as? String
            
            cell.blueQuestionMark.tag = indexPath.row
            
            let purchasePriceString: String = (self.sectionData[indexPath.section]![indexPath.row]?["purchasePrice"] as? String)!
            
            if purchasePriceString == "NA" {
            cell.deliverToLabel.text = self.sectionData[indexPath.section]![indexPath.row]?["deliverTo"] as? String
            } else {
            cell.deliverToLabel.text = "Purchased for \(self.sectionData[indexPath.section]![indexPath.row]?["purchasePrice"] as! String)"
           // cell.deliverToLabel.textColor = UIColor.red
            }
            
            let tokenCountHelp:Int = (self.sectionData[indexPath.section]![indexPath.row]?["tokensOffered"] as? Int)!
            
            let payType:String = (self.sectionData[indexPath.section]![indexPath.row]?["paymentType"] as? String)!
            
            if payType == "Venmo" {
                cell.payTypeImage.image = UIImage(named: "venmo-icon.png")
                cell.payTypeImage.addGestureRecognizer(payTypeVenmoTap)
            } else if payType == "Cash" {
                cell.payTypeImage.image = UIImage(named: "Cash_icon.png")
                cell.payTypeImage.layer.cornerRadius = 2.0
                cell.payTypeImage.layer.masksToBounds = true
                cell.payTypeImage.addGestureRecognizer(payTypeCashTap)
            }
            
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
                    cell.coinImage.addGestureRecognizer(oneTokenTapMyRequest)
                    
                }
                if tokenCountHelp == 2 {
                    cell.coinImage.image = UIImage(named: "blackWhite2Coin")
                    cell.coinImage.addGestureRecognizer(twoTokenTapMyRequest)
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
            
                if isVerySmallScreen {
                    cell.chatImage.isHidden = true
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
                
                //Delivery Line become pay instruction
                if purchasePriceString == "NA" {
                    
                cell.deliveringToLabel.text = String("Delivery from \(self.sectionData[indexPath.section]![indexPath.row]?["accepterName"] as! String)")
                    
                cell.cancelCompleteButton.setTitle("In Progress", for: [])
                
                    
                } else {
                    
                    if isCompleted == false {
                        
                        cell.cancelCompleteButton.setTitle("Mark as Complete", for: [])
                        
                    } else {
                        cell.cancelCompleteButton.setTitle("Request is complete!", for: [])
                        cell.cancelCompleteButton.isEnabled = false
                    }
                    
                    if payType == "Cash" {
                        cell.deliveringToLabel.text = "Please have \(self.sectionData[indexPath.section]![indexPath.row]?["purchasePrice"] as! String) cash for delivery"
                    } else { //is Venmo Payment
                            
                            cell.deliveringToLabel.text = "Copy Phone Number"
                            cell.deliveringToLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
                            cell.deliveringToLabel.textColor = UIColor(red: 14/255, green: 96/255, blue: 157/255, alpha: 1)
                        
                            cell.deliveringToLabel.tag = indexPath.row
                            let cellPhoneNumberTap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapCellPhoneCopy(_:)))
                            cell.deliveringToLabel.addGestureRecognizer(cellPhoneNumberTap)
                    }
                }
                
                cell.payTypeImage.tag = indexPath.row
                
                if tokenCountHelp == 1 {
                    cell.coinImage.image = UIImage(named: "1FullToken.png")
                    cell.coinImage.addGestureRecognizer(oneTokenTap)
                }
                if tokenCountHelp == 2 {
                    cell.coinImage.image = UIImage(named: "2FullToken.png")
                    cell.coinImage.addGestureRecognizer(twoTokenTap)
                }
            }
            
            return cell
            
        } else { //if is community request
            
            let cell:shoppingListCell = tableView.dequeueReusableCell(withIdentifier: "shoppingListCell", for: indexPath) as! shoppingListCell
            
            if (self.sectionData[indexPath.section]?.count) == 0 {
                
                if isSmallScreen{
                    cell.nameLabel.text = "No current requests"
                   cell.distanceLabel.text = "Click pencil below to add one!"
                } else if isVerySmallScreen {
                    cell.distanceLabel.isHidden = true
                    cell.nameLabel.text = "No current requests"
                } else {
                   cell.distanceLabel.text = "Select the pencil below and add one!"
                   cell.nameLabel.text = "No current requests in your community"
                }
                
                cell.deliverToLabel.text = ""
                cell.willingToPayLabel.isHidden = true
                cell.payTypeImage.isHidden = true
                
                return cell
            }
            
            print(sectionData)
            
            let payType:String = (self.sectionData[indexPath.section]![indexPath.row]?["paymentType"] as? String)!
            
            cell.payTypeImage.tag = indexPath.row
            
            if payType == "Venmo" {
                cell.payTypeImage.image = UIImage(named: "venmo-icon.png")
                cell.payTypeImage.addGestureRecognizer(payTypeVenmoTap)
            } else if payType == "Cash" {
                cell.payTypeImage.image = UIImage(named: "Cash_icon.png")
                cell.payTypeImage.layer.cornerRadius = 2.0
                cell.payTypeImage.layer.masksToBounds = true
                cell.payTypeImage.addGestureRecognizer(payTypeCashTap)
            }
            
            cell.deliverToLabel.text = self.sectionData[indexPath.section]![indexPath.row]?["deliverTo"] as? String
            cell.distanceLabel.text = self.sectionData[indexPath.section]![indexPath.row]?["latitude"] as? String
            cell.nameLabel.text = self.sectionData[indexPath.section]![indexPath.row]?["itemName"] as? String
            
           let payAmount = self.sectionData[indexPath.section]![indexPath.row]?["price"] as! String
            
           if payAmount.characters.count < 6 {
            
            let leadingConstraint = cell.payTypeImage.trailingAnchor.constraint(equalTo: cell.willingToPayLabel.trailingAnchor, constant: 14)
            NSLayoutConstraint.activate([leadingConstraint])
            
           } else {
            
            let leadingConstraint = cell.payTypeImage.trailingAnchor.constraint(equalTo: cell.willingToPayLabel.trailingAnchor, constant: 22)
            NSLayoutConstraint.activate([leadingConstraint])
            
            }
            
            cell.willingToPayLabel.text = "Willing to pay \(self.sectionData[indexPath.section]![indexPath.row]?["price"] as! String) via"
            
            let buildingCheck = self.sectionData[indexPath.section]![indexPath.row]?["buildingName"] as? String
            
            if buildingCheck != "N/A" {
                
                cell.distanceLabel.text = String("\(self.sectionData[indexPath.section]![indexPath.row]?["requesterName"] as! String) - \(buildingCheck!) (\(self.sectionData[indexPath.section]![indexPath.row]?["distanceFromUser"] as! String) mi)")
                
            } else {
                
                cell.distanceLabel.text = String("\(self.sectionData[indexPath.section]![indexPath.row]?["requesterName"] as! String) lives \(self.sectionData[indexPath.section]![indexPath.row]?["distanceFromUser"] as! String) mi from you")
                
            }
            
            let tokenCountHelp:Int? = self.sectionData[indexPath.section]![indexPath.row]?["tokensOffered"] as? Int
            
            cell.coinImage.tag = indexPath.row
            
            if tokenCountHelp == 1 {
                cell.coinImage.image = UIImage(named: "1FullToken.png")
                cell.coinImage.addGestureRecognizer(oneTokenTap)
            }
            if tokenCountHelp == 2 {
                cell.coinImage.image = UIImage(named: "2FullToken.png")
                cell.coinImage.addGestureRecognizer(twoTokenTap)
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
            
            cell.willingToPayLabel.isHidden = false
            cell.payTypeImage.isHidden = false
            
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (self.sectionData[0]?.count) == 0 && (self.sectionData[1]?.count) == 0 && (self.sectionData[2]?.count) == 0 {
    
            self.rowHeight = 75
           
        } else if indexPath.section == 2 {
            
            self.rowHeight = 102
            
        } else if indexPath.section == 0 || indexPath.section == 1  {
            
            self.rowHeight = 105
            
        }
        
    return self.rowHeight
      
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
        //self.databaseRef.child("promoteShare").child("isTrue").setValue(true)
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
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
    }

    
    func didTapPhoneImageRequest(_ gesture: UITapGestureRecognizer)  {
        
        let imageTag = gesture.view!.tag
        
        let requesterCell = self.sectionData[1]![imageTag]?["accepterCell"] as? String
        
        if let url = URL(string: "tel://\(requesterCell!)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
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
        
        if sender.titleLabel?.text == "In Progress" {
            
            let index = sender.tag
            let accepterName = self.sectionData[1]![index]?["accepterName"] as? String
            let itemName = self.sectionData[1]![index]?["itemName"] as? String
            
            makeAlert(title: "Delivery In Progress", message: "\(accepterName!) has not yet purchased \(itemName!). Feel free to reach out to \(accepterName!) by clicking on the green chat button")
            
        } else {
            
        self.locationManager.startUpdatingLocation()
        
        let index = sender.tag
        let purchasePrice = self.sectionData[1]![index]?["purchasePrice"] as? String
        let accepterName = self.sectionData[1]![index]?["accepterName"] as? String
        
        let alertPrice = UIAlertController(title: "Payment Verification", message: "Have you paid \(accepterName!) the price of the item up or equal to \(purchasePrice!)?", preferredStyle: UIAlertControllerStyle.alert)
        
        alertPrice.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
            //nothing happens
        }))
        
        alertPrice.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in

        let alertComplete = UIAlertController(title: "Request Completed", message: "If you have receive the item, and compensated the deliverer for the price he/she paid in full, this delivery is complete!", preferredStyle: UIAlertControllerStyle.alert)
        
        alertComplete.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            //nothing happens
        }))
        
        alertComplete.addAction(UIAlertAction(title: "Complete", style: .default, handler: { (action) in
            sender.setTitle("Request is complete!", for: [])
            
            let index = sender.tag
            let accepterUIDToken = self.sectionData[1]![index]?["accepterUID"] as? String
            let requesterUIDToken = self.sectionData[1]![index]?["requesterUID"] as? String
            let tokensToTransfer = self.sectionData[1]![index]?["tokensOffered"] as? Int
            let requestKey = self.sectionData[1]![index]?["requestKey"] as? String
            
            //Move the request to completedRequestNode
            let itemName = self.sectionData[1]![index]?["itemName"] as? String
            let requestedTime = self.sectionData[1]![index]?["requestedTime"] as? String
            let profilePicReference = self.sectionData[1]![index]?["profilePicReference"] as? String
            let accepterName = self.sectionData[1]![index]?["accepterName"] as? String
            let accepterProfilePicRef = self.sectionData[1]![index]?["accepterProfilePicRef"] as? String
            let requesterName = self.sectionData[1]![index]?["requesterName"] as? String
            let requesterUID = self.sectionData[1]![index]?["requesterUID"] as? String
            let requestedTimeStamp = self.sectionData[1]![index]?["requestedTimeStamp"] as? Int
            let price = self.sectionData[1]![index]?["price"] as? String
            let purchaseTimeStamp = self.sectionData[1]![index]?["purchaseTimeStamp"] as? Int
            
            let accepterNamePath = "/requestComplete/\(requestKey!)/accepterName"
            let accepterProfilePicRefPath = "/requestComplete/\(requestKey!)/accepterProfilePicRef"
            let accepterUIDPath = "/requestComplete/\(requestKey!)/accepterUID"
            let itemNamePath = "/requestComplete/\(requestKey!)/itemName"
            let pricePath = "/requestComplete/\(requestKey!)/price"
            let profilePicReferencePath = "/requestComplete/\(requestKey!)/profilePicReference"
            let requestedTimePath = "/requestComplete/\(requestKey!)/requestedTime"
            let requesterNamePath = "/requestComplete/\(requestKey!)/requesterName"
            let requesterUIDPath = "/requestComplete/\(requestKey!)/requesterUID"
            let requestedTimeStampPath = "/requestComplete/\(requestKey!)/requestTime"
            let tokensOfferedPath = "/requestComplete/\(requestKey!)/tokensOffered"
            let keyPath = "/requestComplete/\(requestKey!)/requestKey"
            let timeRequestToPurchaseMinutesPath  = "/requestComplete/\(requestKey!)/timeRequestToPurchaseMinutes"
            let isTestPath = "/requestComplete/\(requestKey!)/isTest"
            let distanceTraveledPath = "/requestComplete/\(requestKey!)/distanceTraveled"
            
            //Check difference between purchase and delivery
            let purchaseLongitude = self.sectionData[1]![index]?["purchaseLongitude"] as? CLLocationDegrees
            let purchaseLatitude = self.sectionData[1]![index]?["purchaseLatitude"] as? CLLocationDegrees
            let purchaseLocation = CLLocation(latitude: purchaseLatitude!, longitude: purchaseLongitude!)
            
            let acceptLocation = CLLocation(latitude: self.userLatitude, longitude: self.userLongitude)
            let distanceInMeters = purchaseLocation.distance(from: acceptLocation)
            let distanceInMetersFloat = Float(distanceInMeters)
            let distanceInMetersFloatString = String(format: "%.1f", distanceInMeters)
            
            
            if distanceInMetersFloat > 20 {
                
                self.isTest = true
                
            }
            
            let timeRequestToPurchase = purchaseTimeStamp! - requestedTimeStamp!
            let timeRequestToPurchaseMinutes = timeRequestToPurchase/60000
            
            if timeRequestToPurchase < 90000 {
                
                 self.isTest = true
                 print("timeRequestToPurchase")
            }
            
            self.locationManager.stopUpdatingLocation()
            
            //Event delivery is complete and "test" or not
            
            if self.isTest {
                FIRAnalytics.logEvent(withName: "deliveryCompleteTest", parameters: nil)
            } else {
                FIRAnalytics.logEvent(withName: "deliveryCompleteReal", parameters: nil)
            }
            
            
            let childUpdateMoveNode:Dictionary<String, Any> = [accepterNamePath:accepterName!,accepterProfilePicRefPath:accepterProfilePicRef!,accepterUIDPath:accepterUIDToken!,itemNamePath:itemName!,pricePath:price!,profilePicReferencePath:profilePicReference!,requestedTimeStampPath:requestedTimeStamp!,requesterNamePath:requesterName!,requesterUIDPath:requesterUID!,requestedTimePath:requestedTime!,tokensOfferedPath:tokensToTransfer!,keyPath:requestKey!,distanceTraveledPath:distanceInMetersFloatString,isTestPath:self.isTest, timeRequestToPurchaseMinutesPath:timeRequestToPurchaseMinutes]
            
            self.databaseRef.updateChildValues(childUpdateMoveNode)
            
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
                    
                                 //Save the updated token counts and delivery/recieved counts
                    let childUpdates = ["/users/\(accepterUIDToken!)/tokenCount":self.accepterTokenCount!,"/users/\(requesterUIDToken!)/tokenCount":self.requesterTokenCount!,"/users/\(accepterUIDToken!)/deliveryCount":self.accepterDeliveryCount!,"/users/\(requesterUIDToken!)/recieveCount":self.self.requesterRecieveCount!] as [String : Any]
                        
                    self.databaseRef.updateChildValues(childUpdates)
                        
                    self.databaseRef.child("request").child(requestKey!).child("isComplete").setValue(true)
                
                }
            }
            
        }))
        self.present(alertComplete, animated: true, completion: nil)
    
            }))
        self.present(alertPrice, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapPurchaseButton(_ sender: UIButton) {
       
        let index = sender.tag
        
        //Set values for purchaseText function
        
        let requesterCell = self.sectionData[0]![index]?["requesterCell"] as! String
        let requesterName = self.sectionData[0]![index]?["requesterName"] as! String
        let itemName = self.sectionData[0]![index]?["itemName"] as! String
        
        if sender.titleLabel?.text == "Purchase Complete" {
            
            self.locationManager.startUpdatingLocation()
            
            let itemName = self.sectionData[0]?[index]?["itemName"] as! String
            
            let alertPurchaseComplete = UIAlertController(title: "Purchase Verification", message: "Have you purchased \(itemName)?", preferredStyle: UIAlertControllerStyle.alert)
            
            alertPurchaseComplete.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                //do nothing
            }))
            
            alertPurchaseComplete.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                
                var phoneNumberTextField: UITextField?
                
                sender.setTitle("Awaiting Confirmation", for: [])
                
                phoneNumberTextField?.keyboardType = UIKeyboardType.numberPad
                
                let paymentType = self.sectionData[0]?[index]?["paymentType"] as! String
                
                let itemName = self.sectionData[0]?[index]?["itemName"] as! String
                
                let alertController = UIAlertController(
                    title: "Enter Price Paid",
                    message: "Please enter the price you paid for the \(itemName) ",
                    preferredStyle: UIAlertControllerStyle.alert)
                
                let completeAction = UIAlertAction(
                title: "Complete", style: UIAlertActionStyle.default) {
                    (action) -> Void in
                    if let phoneNumber = phoneNumberTextField?.text {
                        
                        self.purchasePrice = phoneNumber
         
                        if paymentType == "Cash" {
                            
                            if self.purchasePrice!.contains(".") {
                                
                                let requestPriceCash1 = self.purchasePrice!
                                
                                let requestPriceCash = requestPriceCash1.replacingOccurrences(of: "$", with: "")
                                
                                let priceStringArray = requestPriceCash.components(separatedBy: ".")
                                
                                if priceStringArray[1].characters.count > 0 {
                                    
                                let centsAsInt: Int = Int(priceStringArray[1])!
                                
                                if centsAsInt > 0 {
                                        
                                    var dollarsAsInt: Int = Int(priceStringArray[0])!
                                    dollarsAsInt += 1
                                    let dollarsAsString = String(dollarsAsInt)
                                    let requestDollarsString = "$" + dollarsAsString + ".00"
                                    self.purchasePrice = requestDollarsString
                                        
                                    }
                                }
                            }
                        }
                    }
                    
                let requestKey = self.sectionData[0]?[index]?["requestKey"] as! String
                let purchasePricePath = "/request/\(requestKey)/purchasePrice"
                let purchaseLatitudePath = "/request/\(requestKey)/purchaseLatitude"
                let purchaseLongitudePath = "/request/\(requestKey)/purchaseLongitude"
                let purchaseTimeStampPath = "/request/\(requestKey)/purchaseTimeStamp"
                    
                let childUpdatePurchaseComplete:Dictionary<String, Any> = [purchasePricePath: self.purchasePrice!, purchaseLatitudePath:self.userLatitude,purchaseLongitudePath:self.userLongitude,purchaseTimeStampPath:[".sv": "timestamp"]]
                    
                //Issue arising in that when a new requested is added to community, the Awaiting complete button become purchas and bottom label reverts to "will pay". To solve this manually update
                
                let dictBeingUpdated = self.myCurrentDeliveries[index] as! NSMutableDictionary //find dictionary you want to change
                dictBeingUpdated["purchasePrice"] = self.purchasePrice! as String
                self.myCurrentDeliveries[index] = dictBeingUpdated //add updated dictionary to array of myCurrentDeliveries
                self.sectionData = [0:self.myCurrentDeliveries,1:self.myCurrentRequests,2:self.shoppingListCurrentRequests]//Update all section data
                
                self.databaseRef.updateChildValues(childUpdatePurchaseComplete)
                    
                self.locationManager.stopUpdatingLocation()
                    
                 if paymentType == "Cash" {
                    
                    let cashAlert = UIAlertController(title: "Cash Payment Notice", message: "As this delivery will be paid in cash, the amount owed will be \(self.purchasePrice!)", preferredStyle: UIAlertControllerStyle.alert)
                    
                    cashAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.purchaseText(itemName: itemName, requesterCell: requesterCell, requesterName: requesterName, purchasePrice: self.purchasePrice!, isVenmo: false)
                    }))
                    
                    self.present(cashAlert, animated: true, completion: nil)
                    
                 } else {
                    
                    self.purchaseText(itemName: itemName, requesterCell: requesterCell, requesterName: requesterName, purchasePrice: self.purchasePrice!, isVenmo: true)
                 }
                }
                
                alertController.addTextField {
                    (txtUsername) -> Void in
                    txtUsername.keyboardType = .decimalPad
                    phoneNumberTextField = txtUsername
                    phoneNumberTextField!.text = "$"
                }
                
                alertController.addAction(completeAction)
                self.present(alertController, animated: true, completion: nil)
                
            }))
            
            self.present(alertPurchaseComplete, animated: true, completion: nil)
            
        } else if sender.titleLabel?.text == "Awaiting Confirmation"{
            
            let requesterName = self.sectionData[0]?[index]?["requesterName"] as! String
            let tokensOffered = self.sectionData[0]?[index]?["tokensOffered"] as! Int
            
            makeAlert(title: "Awaiting Delivery Confirmation", message: "After you have delivered the item and received payment, \(requesterName) will mark this delivery as complete and you will be awarded \(tokensOffered) token!")
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didTapCellPhoneCopy(_ gesture: UITapGestureRecognizer) {
        //heeeee
      let chatTag = gesture.view!.tag
        print(chatTag)
    
      let accepterCell = self.sectionData[1]![chatTag]?["accepterCell"] as! String
    
      let accepterName = self.sectionData[1]![chatTag]?["accepterName"] as! String
        
      UIPasteboard.general.string = accepterCell
        
        let cellCopiedAlert = UIAlertController(title: "Deliverer cell # copied", message: "\(accepterName)'s cell number is copied to your clipboard. Please paste this into venmo to pay them for the delivery ", preferredStyle: UIAlertControllerStyle.alert)
        
        cellCopiedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
        }))
        self.present(cellCopiedAlert, animated: true, completion: nil)
     
    }
    
    @IBAction func didTapMyDeliveryQuestion(_ sender: UIButton) {
        
        let index = sender.tag
        
        let purchasePriceString: String = (self.sectionData[0]![index]?["purchasePrice"] as? String)!
        print(index)
        
        let isComplete: Bool = self.sectionData[0]![index]?["isComplete"] as! Bool
        
        if !isComplete {
            if purchasePriceString == "NA" {
                
                self.questionMarkMessageDelivery = "Once you have purchased \(self.sectionData[0]![index]?["itemName"] as! String), please tap \"Purchase Complete\" and then enter the price you paid for it"
                
                self.questionMarkMessageDeliveryTitle = "Item not purchased"
                
            } else {
                
                self.questionMarkMessageDelivery = "The final step is to deliver \(self.sectionData[0]![index]?["itemName"] as! String) to \(self.sectionData[0]![index]?["requesterName"] as! String) and receive payment of \(self.sectionData[0]![index]?["purchasePrice"] as! String). Once the delivery is complete \(self.sectionData[0]![index]?["requesterName"] as! String) will select \"Mark as Complete\" and you will receive \(self.sectionData[0]![index]?["tokensOffered"] as! Int) token"
                
                self.questionMarkMessageDeliveryTitle = "Delivery in Progress"
            }
        } else {
            self.questionMarkMessageDelivery = "Request is Complete!"
            self.questionMarkMessageDeliveryTitle = "Request is Complete!"
            self.questionMarkImage.isEnabled = false
        }
        
        self.makeAlert(title: self.questionMarkMessageDeliveryTitle!, message: self.questionMarkMessageDelivery!)
        
    }
    

    @IBAction func didTapMyRequestQuestion(_ sender: UIButton) {
        
        let index = sender.tag
        
        let isAccepted:Bool = self.sectionData[1]![index]?["isAccepted"] as! Bool
        
        let isComplete: Bool = self.sectionData[1]![index]?["isComplete"] as! Bool
        
        if !isComplete {
            if isAccepted == false {
                
                self.questionMarkMessageRequest = "Your request of \( self.sectionData[1]![index]?["itemName"] as! String) is not yet accepted. When it is accepted, the Goodneighbor who accepted it will send you a text. If you no longer want \(self.sectionData[1]![index]?["itemName"] as! String), select \"Cancel Request\"."
                self.questionMarkMessageRequestTitle = "Awaiting a Goodneighbor"
                
            } else {
                
                let purchasePriceString: String = (self.sectionData[1]![index]?["purchasePrice"] as? String)!
                
                if purchasePriceString == "NA" {
                    self.questionMarkMessageRequest = "Your request of \(self.sectionData[1]![index]?["itemName"] as! String) has been accepted. When \(self.sectionData[1]![index]?["accepterName"] as! String) has purchased the item you will get a text message."
                    
                    self.questionMarkMessageRequestTitle = "Item not yet Purchased"
                    
                } else {
                    
                    self.questionMarkMessageRequest = " \(self.sectionData[1]![index]?["accepterName"] as! String)  has purchased \(self.sectionData[1]![index]?["itemName"] as! String) for \(self.sectionData[1]![index]?["purchasePrice"] as! String). Please be prepared to pay this amount when you meet. Once the delivery is complete please press \"Mark as Complete\" to finalize the transaction."
                    
                    self.questionMarkMessageRequestTitle = "Awaiting Delivery"
                }
            }
        } else {
            
            self.questionMarkMessageDelivery = "Request is Complete!"
            self.questionMarkMessageDeliveryTitle = "Request is Complete!"
            self.questionMarkImage.isEnabled = false
            
        }
        
        self.makeAlert(title: self.questionMarkMessageRequestTitle!, message: self.questionMarkMessageRequest!)
        
    }
    
    
    func didTapRequestQuestionMark(_ sender: UITapGestureRecognizer) {
        
        let index = sender.view!.tag
        
        let isAccepted:Bool = self.sectionData[1]![index]?["isAccepted"] as! Bool
        
        let isComplete: Bool = self.sectionData[1]![index]?["isComplete"] as! Bool
        
        if !isComplete {
        if isAccepted == false {
         
            self.questionMarkMessageRequest = "Your request of \( self.sectionData[1]![index]?["itemName"] as! String) is not yet accepted. When it is accepted, the Goodneighbor who accepted it will send you a text. If you no longer want \(self.sectionData[1]![index]?["itemName"] as! String) select \"Cancel Request\"."
            self.questionMarkMessageRequestTitle = "Awaiting a Goodneighbor"

        } else {
            
            let purchasePriceString: String = (self.sectionData[1]![index]?["purchasePrice"] as? String)!
            
                if purchasePriceString == "NA" {
                    self.questionMarkMessageRequest = "Your request of \(self.sectionData[1]![index]?["itemName"] as! String) has been accepted. When \(self.sectionData[1]![index]?["accepterName"] as! String) has purchased the item you will get a text message."
                    
                    self.questionMarkMessageRequestTitle = "Item not yet Purchased"
                    
                } else {
                    
                    self.questionMarkMessageRequest = " \(self.sectionData[1]![index]?["accepterName"] as! String)  has purchased \(self.sectionData[1]![index]?["itemName"] as! String) for \(self.sectionData[1]![index]?["purchasePrice"] as! String). Please be prepared to pay this amount when you meet. Once the delivery is complete please press \"Mark as Complete\" to finalize the transaction."
                    
                    self.questionMarkMessageRequestTitle = "Awaiting Delivery"
            }
         }
        } else {
            
            self.questionMarkMessageDelivery = "Request is Complete!"
            self.questionMarkMessageDeliveryTitle = "Request is Complete!"
            self.questionMarkImage.isEnabled = false
            
        }
        
        self.makeAlert(title: self.questionMarkMessageRequestTitle!, message: self.questionMarkMessageRequest!)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
//Alerts for clicking a venmo or cash icon
    func didTapVenmoImage(_ sender: UITapGestureRecognizer) {
        
        makeAlert(title: "Venmo Payment", message: "Payment will be complete through the use of Venmo")
        
    }
    
    func didTapCashImage(_ sender: UITapGestureRecognizer) {
        
        makeAlert(title: "Cash Payment", message: "Payment will be complete by cash. All cash payments must be strictly in dollar bills, and the deliverer should not be expected to have change. The amount paid will be rounded up to the next dollar")
        
    }

//Alerts for clicking on coin images
    
    func didTapOneCoin(_ sender: UITapGestureRecognizer) {
        
        makeAlert(title: "One Token For Delivery", message: "For making this delivery, you will receive one token, as well as being fully compensated for the price of the purchase")
        
    }
    
    func didTapOneCoinMyRequest(_ sender: UITapGestureRecognizer) {
        
        makeAlert(title: "One Token For Delivery", message: "When this delivery is complete, you will transfer one token to the deliverer, as well as compensating them for the price of the purchase")
        
    }
    
    func didTapTwoCoinMyRequest(_ sender: UITapGestureRecognizer) {
        
        makeAlert(title: "Two Tokens For Delivery", message: "When this delivery is complete, you will transfer two tokens to the deliverer, as well as compensating them for the price of the purchase")
        
    }
    
    func didTapTwoCoin(_ sender: UITapGestureRecognizer) {
        
        makeAlert(title: "Two Tokens For Delivery", message: "For making this delivery, you will receive two tokens, as well as being fully compensated for the price of the purchase")
        
    }
    
    func purchaseText(itemName: String, requesterCell: String, requesterName: String, purchasePrice: String, isVenmo: Bool) {
        
        if !isVenmo {
        
            let textMessage = "Hey \(requesterName), I have purchased \(itemName) for \(purchasePrice). Please have \(purchasePrice) cash ready to pay me when I arrive. Thanks!"
            
            self.purchaseActualText(textMessage: textMessage, requesterCell: requesterCell)
            
        } else {
            
            let textMessage = "Hey \(requesterName), I have purchased \(itemName) for \(purchasePrice). Please be ready to venmo me \(purchasePrice) when I arrive. You can copy my phone number by tapping on \"Copy Phone Number\" written in bold blue. Thanks!"
            
            self.purchaseActualText(textMessage: textMessage, requesterCell: requesterCell)
            
        }
        
    }
    
    func purchaseActualText(textMessage: String, requesterCell: String) {
    
    if (MFMessageComposeViewController.canSendText()) {
        
        let controller = MFMessageComposeViewController();
        controller.body = textMessage;
        controller.recipients = [requesterCell]
        controller.messageComposeDelegate = self;
        self.present(controller, animated: true, completion: nil)

        }
    }
    
     func makeAlert(title: String, message: String)  {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            //do nothing
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func didTapQuestionMark(_ sender: Any) {
        
        self.questionMarkImage.isHidden = true
        self.performSegue(withIdentifier: "listToExp", sender: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = self.locationManager.location?.coordinate{
            
            self.userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            self.userLatitude = (self.userLocation?.coordinate.latitude)!
            self.userLongitude = (self.userLocation?.coordinate.longitude)!
            
        }
    }
}
