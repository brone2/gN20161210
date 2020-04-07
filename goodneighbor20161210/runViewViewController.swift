//
//  runViewViewController.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 6/12/17.
//  Copyright © 2017 Neil Bronfin. All rights reserved.
//

import UIKit
import OneSignal
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import SDWebImage
import CoreLocation
//sISSUE CANT POST MORE THAN ONE REQUEST TO A RUN BECASUE IT SAVES TO THE SAME KEY I THINK!
class runViewViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet var table: UITableView!
    
    var myRuns = [NSDictionary?]()
    var communityRuns = [NSDictionary?]()
    var myAcceptedRequest = [NSDictionary?]()
    var myPendingRequest = [NSDictionary?]()
    var sectionData = [Int:[NSDictionary?]]()
    var selectedRowIndex:Int?
    var purchasePrice: String?
    
    var otherUserId: String?
    var otherUserName: String?
    var otherUserNotifId: String?
    var requestKey: String?
    
    var locationManager = CLLocationManager()
    var userLocation: CLLocation?
    var userLatitude: CLLocationDegrees = 0.00000
    var userLongitude: CLLocationDegrees = 0.00000
    
    var pendingRequestCount = 0
    var incompleteRequestCount = 0
    
    
    var databaseRef = FIRDatabase.database().reference()
    var storageRef = FIRStorage.storage().reference()
    
    var rowHeight:CGFloat = 100
    
    var tableHeaderArray = ["l","MY CURRENT RUNS","ACCEPTED REQUESTS","PENDING REQUESTS","COMMUNITY RUNS"]
    
    func childBeDeleted() {
        
        self.databaseRef.child("request").observe(.childRemoved) { (snapshot: FIRDataSnapshot) in
            
            let key = snapshot.key
            
            for sectionIndex in 2...3{
                
                for valIndex in (0..<((self.sectionData[sectionIndex]?.count)! as Int)).reversed() {
                    
                    let testKey = self.sectionData[sectionIndex]?[valIndex]?["requestKey"] as! String
                    
                    if testKey == key {
                        
                        self.sectionData[sectionIndex]?.remove(at: valIndex)
                        
                        //Updating the community deliveries array for sake of real time update
                        //ISSUE IS HERE BECAUSE NEED TO HAVE GENERAL SECTION DATA UPDATED
                        //This is essentially backwards updating to prevent issue on .childAdded
                        if sectionIndex == 4 {
                            self.communityRuns = self.sectionData[sectionIndex] as! [NSDictionary]
                        } else if sectionIndex == 3{
                            self.myPendingRequest = self.sectionData[sectionIndex] as! [NSDictionary]
                            self.pendingRequestCount = self.myPendingRequest.count
                        } else if sectionIndex == 2{
                            self.myAcceptedRequest = self.sectionData[sectionIndex] as! [NSDictionary]
                        } else if sectionIndex == 1{
                            self.myRuns = self.sectionData[sectionIndex] as! [NSDictionary]
                        }
                        self.table.reloadData()
                        
                    }
                }
            }
        }
    }

    func childBeChanged(){
        
        self.databaseRef.child("request").observe(.childChanged) { (snapshot: FIRDataSnapshot) in
            print("CHANGEEEE")
            let key = snapshot.key
            let snapshot = snapshot.value as! NSDictionary
            //Only is updating the pending and accepted request
            for sectionIndex in 2...3{
                
                for valIndex in 0..<((self.sectionData[sectionIndex]?.count)! as Int) {
                   
                 //   print(self.sectionData[1]?[0]?["requestKey"])
                    let testKey = self.sectionData[sectionIndex]?[valIndex]?["requestKey"] as! String
                    
                    if testKey == key {
                        
                        //Update incomplete request count if delivery complete
                        let completeCheck = self.sectionData[sectionIndex]?[valIndex]?["isComplete"] as! Bool
                        if completeCheck {
                            self.incompleteRequestCount -= 1
                        }
                        
                        //distance must be manually solved because not stored in firebase
                        if let userLatitude = snapshot["latitude"] as? CLLocationDegrees {
                        let userLongitude = snapshot["longitude"] as? CLLocationDegrees
                        
                        
                        let userLocation = CLLocation(latitude: userLatitude, longitude: userLongitude!)
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
                        if sectionIndex == 4 {
                            self.communityRuns = self.sectionData[sectionIndex] as! [NSDictionary]
                        } else if sectionIndex == 3{
                            self.myPendingRequest = self.sectionData[sectionIndex] as! [NSDictionary]
                        } else if sectionIndex == 2{
                            self.myAcceptedRequest = self.sectionData[sectionIndex] as! [NSDictionary]
                        } else if sectionIndex == 1{
                            self.myRuns = self.sectionData[sectionIndex] as! [NSDictionary]
                        }
                        self.table.reloadData()
                        
                    }
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isX {
            
            for constraint in self.view.constraints {
                if constraint.identifier == "titleTopConstraint" {
                    constraint.constant = 35
                }
                
            }
            
        }
        
        self.table.layer.cornerRadius = 10
        
        self.table.layer.masksToBounds = true
    
    //Pull run data

        self.databaseRef.child("runs").observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            
            let snapshot = snapshot.value as! NSDictionary
            
            let runnerUID = snapshot["runnerUID"] as? String
            
            let runCompleted = snapshot["isComplete"] as? Bool
            let isDormOnly = snapshot["isDormOnly"] as? Bool
            
            let runnerBuilding = snapshot["buildingName"] as? String
            let runnerLongitude = snapshot["runnerLongitude"] as? CLLocationDegrees
            let runnerLatitude = snapshot["runnerLatitude"] as? CLLocationDegrees
            let userLocation = CLLocation(latitude: runnerLatitude!, longitude: runnerLongitude!)
            let distanceInMeters = myLocation!.distance(from: userLocation)
            let distanceMiles = distanceInMeters/1609.344897
            let distanceMilesFloat = Float(distanceMiles)
            
            //Filter out all request outside geolocation
            //if distanceMilesFloat < myRadius! {
            
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            self.locationManager.startUpdatingLocation()
            
            let runDict = snapshot as! NSMutableDictionary
            let distanceMilesFloatString = String(format: "%.1f", distanceMilesFloat)
            runDict["distanceFromUser"] = distanceMilesFloatString
            
            //Store my runs
            if(runnerUID == globalLoggedInUserId && runCompleted != true){
                self.myRuns.append(runDict)
            }
            
            //General runs, those that are not already complete and not sent by you
            // HERE ADDED CHANGE so ONLY CAN SEE building nAMES
            
            
            if distanceMilesFloat < myRadius! {
                
                //Filter out dorm only requests
                if(runnerUID != globalLoggedInUserId && runCompleted != true) && (isDormOnly == false || (isDormOnly == true && runnerBuilding == myBuilding))  {
                
             //   if(runnerUID != globalLoggedInUserId && runCompleted != true) && (runnerBuilding == "NA" || (runnerBuilding != "NA" && runnerBuilding == myBuilding)) {
                    
                    self.communityRuns.append(runDict)
                    //print(self.communityRuns)
                    self.communityRuns.sort{ Double($0?["distanceFromUser"] as! String)! < Double($1?["distanceFromUser"] as! String)! }
                    
                    //}
                    
                
            }
            
            }
            
            self.sectionData = [1:self.myRuns,2:self.myAcceptedRequest, 3: self.myPendingRequest, 4: self.communityRuns]
            self.table.reloadData()
            
            }
        
    //Pull request data
        self.databaseRef.child("request").observe(.childAdded) { (snapshot2: FIRDataSnapshot) in
            
            
            let snapshot2 = snapshot2.value as! NSDictionary
            let accepterUID = snapshot2["accepterUID"] as? String
            let snapAccepted = snapshot2["isAccepted"] as? Bool
            let snapCompleted = snapshot2["isComplete"] as? Bool
            let accepterID = snapshot2["accepterUID"] as? String //idk why this is here but wtvr just left it
            let isRun = snapshot2["isRun"] as? Bool
            
            if let requesterLongitude = snapshot2["longitude"] as? CLLocationDegrees {
            let requesterLatitude = snapshot2["latitude"] as? CLLocationDegrees
            
            let userLocation = CLLocation(latitude: requesterLatitude!, longitude: requesterLongitude)
            let distanceInMeters = myLocation!.distance(from: userLocation)
            let distanceMiles = distanceInMeters/1609.344897
            let distanceMilesFloat = Float(distanceMiles)
            
            //Filter out all request outside geolocation
            //if distanceMilesFloat < myRadius! {
            
            let runDict = snapshot2 as! NSMutableDictionary
            let distanceMilesFloatString = String(format: "%.1f", distanceMilesFloat)
            runDict["distanceFromUser"] = distanceMilesFloatString
           
        //Store my Pending Request Data
            if isRun != nil {
            if(accepterUID == globalLoggedInUserId && snapAccepted != true ){
                self.myPendingRequest.append(runDict)
                self.pendingRequestCount = self.myPendingRequest.count
               // print(self.pendingRequestCount)
            }
        //Store my Accepted Request Data
            if(accepterUID == globalLoggedInUserId && snapAccepted == true && snapCompleted != true){
                
                self.myAcceptedRequest.append(runDict)
                self.incompleteRequestCount = self.myAcceptedRequest.count
               // print(self.incompleteRequestCount)
                
            }
            }
            
            self.sectionData = [1:self.myRuns,2:self.myAcceptedRequest, 3: self.myPendingRequest, 4: self.communityRuns]
            self.table.reloadData()
            }
        }
         
        self.childBeChanged()
        self.childBeDeleted()
     
        }
    
    
    
    //Populate Table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let payTypeVenmoTap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapVenmoImage(_:)))
        
        let payTypeCashTap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapCashImage(_:)))
        
        let oneTokenTap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapOneCoin(_:)))
        
        let twoTokenTap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapTwoCoin(_:)))
        
        let oneTokenTapMyRequest: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapOneCoinMyRequest(_:)))
        
        let twoTokenTapMyRequest: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapTwoCoinMyRequest(_:)))
        
        let chatImageTapPending:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.chatImageTapPending(_:)))
        
        let chatImageTapAccepted:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.chatImageTapAccepted(_:)))
        
        if indexPath.section == 0 {

        let cell:newRunCell = tableView.dequeueReusableCell(withIdentifier: "newRunCell", for: indexPath) as! newRunCell
            
            cell.appIcon2.layer.cornerRadius = 3.0
            cell.appIcon2.layer.masksToBounds = true
            cell.appIcon2.contentMode = .scaleAspectFit
            //cell.pic.layer.borderWidth = 1.0
            cell.appIcon2.layer.borderColor = UIColor(red: 255/255, green: 230/255, blue: 63/255, alpha: 1).cgColor
            
            return cell
        
            
        } else if indexPath.section == 1 { //is my current Runs
            
            let cell:myCurrentRuns = tableView.dequeueReusableCell(withIdentifier: "myCurrentRuns", for: indexPath) as! myCurrentRuns
            
            let requestCount = self.sectionData[indexPath.section]![indexPath.row]?["requestCount"] as? Int
            
            cell.runnerNameLabel.text = String("Requests: \(self.incompleteRequestCount) incomplete, \(self.pendingRequestCount) pending ")
            
            cell.runLabel.text = self.sectionData[indexPath.section]![indexPath.row]?["runTo"] as? String
            
            //HERE trying to load in background
            
            
            if let image = self.sectionData[indexPath.section]![indexPath.row]?["profilePicReference"] as? String {
                
                let url = URL(string: image)
                
                cell.profilePic!.sd_setImage(with: url, placeholderImage: UIImage(named:"saveImage2.png")!)
                
                
            }
            
            cell.profilePic.layer.cornerRadius = 27.5
            cell.profilePic.layer.masksToBounds = true
            cell.profilePic.contentMode = .scaleAspectFit
            cell.profilePic.layer.borderWidth = 2.0
            cell.profilePic.layer.borderColor = UIColor(red: 16/255, green: 126/255, blue: 207/255, alpha: 1).cgColor
            
            
            cell.endRunButton.contentHorizontalAlignment = .left
            cell.endRunButton.tag = indexPath.row
            
            
            
            return cell

            
        }
        
        else if indexPath.section == 2 { //is accepted request
            
            let cell:runAcceptedRequestCell = tableView.dequeueReusableCell(withIdentifier: "runAcceptedRequestCell", for: indexPath) as! runAcceptedRequestCell
            
            let buildingCheck = self.sectionData[indexPath.section]![indexPath.row]?["buildingName"] as? String
            
            if buildingCheck != "N/A" && buildingCheck != "NA" {
                
                cell.distanceLabel.text = String("\(self.sectionData[indexPath.section]![indexPath.row]?["requesterName"] as! String) - \(buildingCheck!) (\(self.sectionData[indexPath.section]![indexPath.row]?["distanceFromUser"] as! String) mi)")
                
            } else {
                
                cell.distanceLabel.text = String("\(self.sectionData[indexPath.section]![indexPath.row]?["requesterName"] as! String) lives \(self.sectionData[indexPath.section]![indexPath.row]?["distanceFromUser"] as! String) mi from you")
                
            }
            
            cell.nameLabel.text = self.sectionData[indexPath.section]![indexPath.row]?["itemName"] as? String
            
            //High Offer
            //cell.itemLabel.text = "Will pay \(self.sectionData[indexPath.section]![indexPath.row]?["price"] as! String) +$\(self.sectionData[indexPath.section]![indexPath.row]?["tokensOffered"] as! Int + 1) fee"
            
            //Low Offer
            cell.itemLabel.text = "Will pay \(self.sectionData[indexPath.section]![indexPath.row]?["price"] as! String) +$\(self.sectionData[indexPath.section]![indexPath.row]?["tokensOffered"] as! Int + 0) fee"
            
            let payType:String = (self.sectionData[indexPath.section]![indexPath.row]?["paymentType"] as? String)!
            
            cell.payTypeImage.tag = indexPath.row
            cell.chatImage.tag = indexPath.row
            let chatImageTap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.chatImageTapAccepted(_:)))
            cell.chatImage.addGestureRecognizer(chatImageTap)
            
            if payType == "Venmo" {
                cell.payTypeImage.image = UIImage(named: "venmo-icon.png")
                cell.payTypeImage.addGestureRecognizer(payTypeVenmoTap)
            } else if payType == "Cash" {
                cell.payTypeImage.image = UIImage(named: "Cash_icon.png")
                cell.payTypeImage.layer.cornerRadius = 2.0
                cell.payTypeImage.layer.masksToBounds = true
                cell.payTypeImage.addGestureRecognizer(payTypeCashTap)
            }

            let tokenCountHelp:Int = (self.sectionData[indexPath.section]![indexPath.row]?["tokensOffered"] as? Int)!
            
            cell.coinImage.tag = indexPath.row
            
            if tokenCountHelp == 1 {
                
                //High Offer
                // cell.coinImage.image = UIImage(named: "2DollBlue.png")
                
                //Low Offer
                cell.coinImage.image = UIImage(named: "1DollBlue.png")
                
                cell.coinImage.addGestureRecognizer(oneTokenTap)
            }
            if tokenCountHelp == 2 {
                //High Offer
                //cell.coinImage.image = UIImage(named: "3DollBlue.png")
                
                //Low Offer
                 cell.coinImage.image = UIImage(named: "2DollBlue.png")
                
                cell.coinImage.addGestureRecognizer(twoTokenTap)
            }
            
            
                if let image = self.sectionData[indexPath.section]![indexPath.row]?["profilePicReference"] as? String {
                    
                    let url = URL(string: image)
                    
                        cell.profilePic!.sd_setImage(with: url, placeholderImage: UIImage(named:"saveImage2.png")!)
                    
                }
            
            cell.profilePic.layer.cornerRadius = 27.5
            cell.profilePic.layer.masksToBounds = true
            cell.profilePic.contentMode = .scaleAspectFit
            cell.profilePic.layer.borderWidth = 2.0
            cell.profilePic.layer.borderColor = UIColor(red: 16/255, green: 126/255, blue: 207/255, alpha: 1).cgColor
            
            if let accepterUIDNotif = (self.sectionData[indexPath.section]![indexPath.row]?["accepterNotifId"] as? String) {
                
                if let isNewMessage:Bool = (self.sectionData[indexPath.section]![indexPath.row]?["isNewMessageAccepter"] as? Bool)! {
                    // print(isNewMessage)
                    if isNewMessage {
                        cell.chatImage.image = UIImage(named: "fillBlueChat1.png")
                    } else {
                        cell.chatImage.image = UIImage(named: "fillBlueChat.png")
                    }
                    
                }
                
            }
            
            
            
            cell.purchaseCompleteButton.contentHorizontalAlignment = .left
            
            cell.purchaseCompleteButton.tag = indexPath.row
            
            let isComplete: Bool = self.sectionData[indexPath.section]![indexPath.row]?["isComplete"] as! Bool
            
            let purchasePriceString: String = (self.sectionData[indexPath.section]![indexPath.row]?["purchasePrice"] as? String)!
            
            cell.purchaseCompleteButton.tag = indexPath.row
            
            if purchasePriceString == "NA" {
                
                cell.purchaseCompleteButton.setTitle("Purchase Complete", for: [])
                
                //High Offer
                //cell.itemLabel.text = "Will pay \(self.sectionData[indexPath.section]![indexPath.row]?["price"] as! String) +$\(self.sectionData[indexPath.section]![indexPath.row]?["tokensOffered"] as! Int + 1) fee"
                
                //Low Offer
                cell.itemLabel.text = "Will pay \(self.sectionData[indexPath.section]![indexPath.row]?["price"] as! String) +$\(self.sectionData[indexPath.section]![indexPath.row]?["tokensOffered"] as! Int + 0) fee"
                
            } else {
            
            if !isComplete { //is not complete
                
                cell.purchaseCompleteButton.setTitle("Awaiting Confirmation", for: [])
                cell.itemLabel.text = "Purchased for \(self.sectionData[indexPath.section]![indexPath.row]?["purchasePrice"] as! String)"
                
            } else {  //is complete
                
                cell.purchaseCompleteButton.setTitle("Delivery Complete!", for: [])
                cell.itemLabel.text = "Purchased for \(self.sectionData[indexPath.section]![indexPath.row]?["purchasePrice"] as! String)"
              
                }
            }
            
            return cell

        
        }
        
        else if indexPath.section == 3 { // if is pending request
            
            let cell:runNotAcceptedRequestCell = tableView.dequeueReusableCell(withIdentifier: "runNotAcceptedRequestCell", for: indexPath) as! runNotAcceptedRequestCell
            
            cell.chatImage.tag = indexPath.row
            let chatImageTap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.chatImageTapPending(_:)))
            cell.chatImage.addGestureRecognizer(chatImageTap)
            
            let buildingCheck = self.sectionData[indexPath.section]![indexPath.row]?["buildingName"] as? String
            
            if buildingCheck != "N/A" && buildingCheck != "NA" {
                
                cell.distanceLabel.text = String("\(self.sectionData[indexPath.section]![indexPath.row]?["requesterName"] as! String) - \(buildingCheck!) (\(self.sectionData[indexPath.section]![indexPath.row]?["distanceFromUser"] as! String) mi)")
                
            } else {
                
                cell.distanceLabel.text = String("\(self.sectionData[indexPath.section]![indexPath.row]?["requesterName"] as! String) lives \(self.sectionData[indexPath.section]![indexPath.row]?["distanceFromUser"] as! String) mi from you")
                
            }
            
            cell.nameLabel.text = self.sectionData[indexPath.section]![indexPath.row]?["itemName"] as? String
            
            cell.itemLabel.text = self.sectionData[indexPath.section]![indexPath.row]?["deliverTo"] as? String
            
            //cell.willPayLabel.text = "Will pay \(self.sectionData[indexPath.section]![indexPath.row]?["price"] as! String) +$\(self.sectionData[indexPath.section]![indexPath.row]?["tokensOffered"] as! Int) fee"
            cell.willPayLabel.text = "Tap to Accept!"
            cell.willPayLabel.textColor = UIColor(red: 127/255, green: 127/255, blue: 127/255, alpha: 1)
            
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
            
            let tokenCountHelp:Int = (self.sectionData[indexPath.section]![indexPath.row]?["tokensOffered"] as? Int)!
            
            cell.coinImage.tag = indexPath.row
            
            if tokenCountHelp == 1 {
                
                // High Offer
                //cell.coinImage.image = UIImage(named: "2DollBlue.png")
                
                // Low Offer
                cell.coinImage.image = UIImage(named: "1DollBlue.png")
                cell.coinImage.addGestureRecognizer(oneTokenTap)
            }
            if tokenCountHelp == 2 {
                
                // High Offer
                //cell.coinImage.image = UIImage(named: "3DollBlue.png")
                
                // Low Offer
                cell.coinImage.image = UIImage(named: "2DollBlue.png")
                
                
                cell.coinImage.addGestureRecognizer(twoTokenTap)
            }
            
    
                if let image = self.sectionData[indexPath.section]![indexPath.row]?["profilePicReference"] as? String {
                    
                    let url = URL(string: image)
                    
                    cell.profilePic!.sd_setImage(with: url, placeholderImage: UIImage(named:"saveImage2.png")!)
                    
                }
            
            cell.profilePic.layer.cornerRadius = 27.5
            cell.profilePic.layer.masksToBounds = true
            cell.profilePic.contentMode = .scaleAspectFit
            cell.profilePic.layer.borderWidth = 2.0
            cell.profilePic.layer.borderColor = UIColor(red: 16/255, green: 126/255, blue: 207/255, alpha: 1).cgColor
            
            if let accepterUIDNotif = (self.sectionData[indexPath.section]![indexPath.row]?["accepterNotifId"] as? String) {
                
                if let isNewMessage:Bool = (self.sectionData[indexPath.section]![indexPath.row]?["isNewMessageAccepter"] as? Bool)! {
                  // print(isNewMessage)
                    if isNewMessage {
                        cell.chatImage.image = UIImage(named: "fillBlueChat1.png")
                    } else {
                        cell.chatImage.image = UIImage(named: "fillBlueChat.png")
                    }
                    
                }
                
            }
            
            
            
            return cell
        }
        
        else if indexPath.section == 4 { // if is community runs
            
            let cell:currentRunsCell = tableView.dequeueReusableCell(withIdentifier: "currentRunsCell", for: indexPath) as! currentRunsCell
            
            let buildingCheck = self.sectionData[indexPath.section]![indexPath.row]?["buildingName"] as? String
            let tokensOffered = self.sectionData[indexPath.section]![indexPath.row]?["tokensOffered"] as? Int
            print(tokensOffered)
            let requestCount = self.sectionData[indexPath.section]![indexPath.row]?["requestCount"] as? Int
            
            if buildingCheck != "N/A" && buildingCheck != "NA" {
                
                cell.runnerNameLabel.text = String("\(self.sectionData[indexPath.section]![indexPath.row]?["runnerName"] as! String) - \(buildingCheck!) (\(self.sectionData[indexPath.section]![indexPath.row]?["distanceFromUser"] as! String) mi)")
                
            } else {
                
                cell.runnerNameLabel.text = String("\(self.sectionData[indexPath.section]![indexPath.row]?["runnerName"] as! String) lives \(self.sectionData[indexPath.section]![indexPath.row]?["distanceFromUser"] as! String) mi from you")
                
            }
            
            cell.runnerLocationLabel.text = String("Run will end at \(self.sectionData[indexPath.section]![indexPath.row]?["timeRun"] as! String)")
            
            cell.runLabel.text = "\(self.sectionData[indexPath.section]![indexPath.row]?["runTo"] as! String) - $\(tokensOffered!) fee"
            
            if  (self.sectionData[indexPath.section]![indexPath.row]?["isEvent"]) != nil {
        
                cell.runLabel.text = "\(self.sectionData[indexPath.section]![indexPath.row]?["runTo"] as! String) - $0 fee"
                
            } else {
                
                cell.runLabel.text = "\(self.sectionData[indexPath.section]![indexPath.row]?["runTo"] as! String) - $\(tokensOffered!) fee"
                
            }
           //Taking out the number of requests to the run to say tap to make a request
           // cell.requestCountLabel.text = "\(requestCount!) requests to this run" HERE
             cell.requestCountLabel.text = "Tap to request an item from \(self.sectionData[indexPath.section]![indexPath.row]?["runTo"] as! String)!"
         
        
            if let image = self.sectionData[indexPath.section]![indexPath.row]?["profilePicReference"] as? String {
                
                let url = URL(string: image)
                
                cell.profilePic!.sd_setImage(with: url, placeholderImage: UIImage(named:"saveImage2.png")!)
                
            }
            
            
        
        cell.profilePic.layer.cornerRadius = 27.5
        cell.profilePic.layer.masksToBounds = true
        cell.profilePic.contentMode = .scaleAspectFit
        cell.profilePic.layer.borderWidth = 2.0
        cell.profilePic.layer.borderColor = UIColor(red: 16/255, green: 126/255, blue: 207/255, alpha: 1).cgColor
        
        
        
            return cell
        
        } else {
              let cell:newRunCell = tableView.dequeueReusableCell(withIdentifier: "newRunCell", for: indexPath) as! newRunCell
            
            return cell
        }
    
    }
    
    @IBAction func didTapPurchaseComplete(_ sender: UIButton) {
        
        
        let index = sender.tag
        
        /*if let requesterNotifIDTemp = self.sectionData[0]![index]?["requesterNotifID"] as? String {
            self.requesterNotifID = requesterNotifIDTemp
        }*/
        
        if sender.titleLabel?.text == "Purchase Complete" {
        
        let itemName = self.sectionData[2]?[index]?["itemName"] as! String
            
        let requesterName = self.sectionData[2]?[index]?["requesterName"] as! String
            
        let requesterNotifID = self.sectionData[2]?[index]?["requesterNotifID"] as! String
            
        let requesterUID = self.sectionData[2]?[index]?["requesterUID"] as! String
        
        let alertPurchaseComplete = UIAlertController(title: "Purchase Verification", message: "Have you purchased \(itemName)?", preferredStyle: UIAlertControllerStyle.alert)
        
        alertPurchaseComplete.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
            //do nothing
        }))
        
        alertPurchaseComplete.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            var phoneNumberTextField: UITextField?
            
            sender.setTitle("Awaiting Confirmation", for: [])
            
            phoneNumberTextField?.keyboardType = UIKeyboardType.numberPad
            
            let paymentType = self.sectionData[2]?[index]?["paymentType"] as! String
            
            self.locationManager.startUpdatingLocation()
            
            let itemName = self.sectionData[2]?[index]?["itemName"] as! String
            
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
            
                let requestKey = self.sectionData[2]?[index]?["requestKey"] as! String
                let purchasePricePath = "/request/\(requestKey)/purchasePrice"
                let purchaseLatitudePath = "/request/\(requestKey)/purchaseLatitude"
                let purchaseLongitudePath = "/request/\(requestKey)/purchaseLongitude"
                let purchaseTimeStampPath = "/request/\(requestKey)/purchaseTimeStamp"
              
                 let childUpdatePurchaseCompleteRequester:Dictionary<String, Any> = [purchasePricePath: self.purchasePrice!, purchaseLatitudePath:self.userLatitude,purchaseLongitudePath:self.userLongitude,purchaseTimeStampPath:[".sv": "timestamp"]]
                self.databaseRef.updateChildValues(childUpdatePurchaseCompleteRequester)
                
                //Issue arising in that when a new requested is added to community, the Awaiting complete button become purchas and bottom label reverts to "will pay". To solve this manually update
                
                let dictBeingUpdated = self.myAcceptedRequest[index] as! NSMutableDictionary //find dictionary you want to change
                dictBeingUpdated["purchasePrice"] = self.purchasePrice! as String
                self.myAcceptedRequest[index] = dictBeingUpdated //add updated dictionary to array of myCurrentDeliveries
                self.sectionData = [1:self.myRuns,2:self.myAcceptedRequest, 3: self.myPendingRequest, 4: self.communityRuns]
                self.table.reloadData()//Update all section data
                self.purchaseText(itemName: itemName, requesterName: requesterName, purchasePrice: self.purchasePrice!, isVenmo: true,notifID: requesterNotifID, requesterUID: requesterUID,requestKey:requestKey )
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

         } else {
            
            let requesterName = self.sectionData[2]?[index]?["requesterName"] as! String
            let tokensOffered = self.sectionData[2]?[index]?["tokensOffered"] as! Int
            
            makeAlert(title: "Awaiting Delivery Confirmation", message: "After you have delivered the item and received payment, \(requesterName) will mark this delivery as complete and you will be awarded \(tokensOffered) token!")
            
        }
        
    }
    
    func purchaseText(itemName: String, requesterName: String, purchasePrice: String, isVenmo: Bool, notifID: String, requesterUID: String, requestKey: String) {
        
        self.databaseRef.child("request").child(requestKey).child("isNewMessageRequester").setValue(true)
        
        if !isVenmo {
            
            let messageHeader = "\(loggedInUserName!) has purchased \(itemName) for \(purchasePrice)"
            let textMessage = "Please have \(purchasePrice) + the delivery fee ready when \(requesterName) arrives!"
            
            let itemRef = databaseRef.child("messages").childByAutoId()
            
            let text = "I have purchased \(itemName) for \(purchasePrice), please have \(purchasePrice) cash ready to pay when I arrive."
            
            let messageItem = [
                "senderId": globalLoggedInUserId,
                "senderName": loggedInUserName,
                "text": text,
                "otherUserId": requesterUID //is requesterCell = requestUID
            ]
            
            itemRef.setValue(messageItem)
            
            self.purchaseActualText(textMessage: textMessage, notifID: notifID, messageHeader: messageHeader )
            
        } else {
            
            let messageHeader = "\(loggedInUserName!) has purchased \(itemName) for \(purchasePrice)"
            let textMessage = "Please venmo \(loggedInUserName!) \(purchasePrice) + the delivery fee when they arrive!"
            
            let itemRef = databaseRef.child("messages").childByAutoId()
            
            let text = "I have purchased \(itemName) for \(purchasePrice), please be ready to venmo me \(purchasePrice) + the delivery fee when I arrive."
            
            let messageItem = [
                "senderId": globalLoggedInUserId,
                "senderName": loggedInUserName,
                "text": text,
                "otherUserId": requesterUID //is requesterCell = requestUID
            ]
            
            itemRef.setValue(messageItem)
            
            self.purchaseActualText(textMessage: textMessage, notifID: notifID, messageHeader: messageHeader)
            
        }
        
    }
    
    func purchaseActualText(textMessage: String, notifID: String, messageHeader: String) {
        
        /*if (MFMessageComposeViewController.canSendText()) {
         
         let controller = MFMessageComposeViewController();
         controller.body = textMessage;
         controller.recipients = [requesterCell]
         controller.messageComposeDelegate = self;
         self.present(controller, animated: true, completion: nil)
         
         }*/
        
        OneSignal.postNotification(["headings" : ["en": messageHeader],
                                    "contents" : ["en": textMessage],
                                    "include_player_ids": [notifID],
                                 //   "ios_sound": "nil",
                                    "data": ["type": "request"]])
        
    }

    
    /*func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let headers = tableHeaderArray[section]
        
        if section != 0 {
            let emptyCheck = self.sectionData[section]! as! [NSDictionary]
            
            if emptyCheck == [] {
                return nil
            }
          
            return headers
            
        } else {
            return nil
        }
        //return nil
    }*/
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! headerCell
        
        if section == 3 {
            
            let myCurrentRunCheck = self.sectionData[1]! as! [NSDictionary]
            
            if myCurrentRunCheck != [] {
                header.headerText.text = tableHeaderArray[section]
                return header
            }
        }
        
        if section != 0 {
            let emptyCheck = self.sectionData[section]! as! [NSDictionary]
            
            if emptyCheck == [] {
                return nil
            }
            
            header.headerText.text = tableHeaderArray[section]
            return header
            
        } else {
            return nil
        }
        //return nil

       // return header
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 3 {
            
            let myCurrentRunCheck = self.sectionData[1]! as! [NSDictionary]
            
            if myCurrentRunCheck != [] {
                return 15
            }
        }
        if section == 1 {
            return 0
        }
        if section != 0 {
            let emptyCheck = self.sectionData[section]! as! [NSDictionary]
            
            if emptyCheck == [] {

                return 0
            }
            
            return 15
            
        } else {
            return 0
        }

    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if section == 0{
            if (self.sectionData[1]?.count) != 0 {
                
                return 0
                
            } else {
                
            return 1
                
        }}
       
      
            return((self.sectionData[section]?.count)!)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
      
         if (self.sectionData[1]?.count) != 0 {
            return sectionData.count
        } else {
        return sectionData.count + 1
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            self.rowHeight = 62
            
        } else if indexPath.section == 1 {
            
            self.rowHeight = 80
            
        }  else if indexPath.section == 4 {
            
            self.rowHeight = 90
            
        } else {
            
            self.rowHeight = 110
            
        }
        
        return self.rowHeight
        
    }
    



    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    //Enter Run
        if indexPath.section == 0 {
            self.performSegue(withIdentifier: "goToPostRun", sender: nil)
        }
        
    //Is accepted request
        if indexPath.section == 1 {
            self.selectedRowIndex = indexPath.row
            self.performSegue(withIdentifier: "myRunsPopUp", sender: nil)
        }
    
    //Is accepted request
        if indexPath.section == 2 {
            self.selectedRowIndex = indexPath.row
            self.performSegue(withIdentifier: "acceptedRequestPopUp", sender: nil)
        }
    
    //Is pending request
        if indexPath.section == 3 {
            self.selectedRowIndex = indexPath.row
            self.performSegue(withIdentifier: "runToDetailAccept", sender: nil)
        }
      
    //General Runs
        if indexPath.section == 4 {
            self.selectedRowIndex = indexPath.row
            self.performSegue(withIdentifier: "goToViewRun", sender: nil)
        }
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //
        
    //Community run to detail
        if segue.identifier == "goToViewRun" {
            
            let newViewController = segue.destination as! runDetail
            newViewController.communityRuns = self.communityRuns
            newViewController.selectedRowIndex = selectedRowIndex
            
        }
        
        if segue.identifier == "myRunsPopUp" {
            
            let newViewController = segue.destination as! viewDetailDeliveryView
            newViewController.myRun = self.myRuns
            newViewController.selectedRowIndex = selectedRowIndex
            newViewController.isRun = true
            newViewController.isMyRun = true
        }
        
        if segue.identifier == "acceptedRequestPopUp" {
            
            let newViewController = segue.destination as! viewDetailDeliveryView
            newViewController.runRequest = self.myAcceptedRequest
            newViewController.selectedRowIndex = selectedRowIndex
            newViewController.isRun = true
        }
      
        if segue.identifier == "runToDetailAccept" {
            
            let newViewController = segue.destination as! viewDetailGeneralShoppingList
            newViewController.runRequest = self.myPendingRequest
            newViewController.selectedRowIndex = selectedRowIndex
            newViewController.isRun = true
        }
    
        if segue.identifier == "runToChat" {
            
            
            let navVc = segue.destination as! UINavigationController // 1
            let channelVc = navVc.viewControllers.first as! chatView //
            
            
            channelVc.otherUserId = self.otherUserId!
            channelVc.otherUserName = self.otherUserName!
            if self.otherUserNotifId != nil {
                channelVc.otherUserNotifId = self.otherUserNotifId!
            } else {
                channelVc.otherUserNotifId = "NA"
            }
            channelVc.requestKey = self.requestKey
        }
        
        if segue.identifier == "runNotifsSegue" {
            
            let secondViewController = segue.destination as! enableNotifsView
            
            if myLocation?.coordinate.latitude == 0.000000 {
                
                secondViewController.isLocation = true
                
            }
            
            
        }
        
        
    }
    
    func didTapVenmoImage(_ sender: UITapGestureRecognizer) {
        
        makeAlert(title: "Venmo Payment", message: "Payment will be complete through the use of Venmo")
        
    }
    
    func didTapCashImage(_ sender: UITapGestureRecognizer) {
        
        makeAlert(title: "Cash Payment", message: "Payment will be complete by cash. All cash payments must be strictly in dollar bills, and the deliverer should not be expected to have change. The amount paid will be rounded up to the next dollar")
        
    }
    
    //Alerts for clicking on coin images
    
    func didTapOneCoin(_ sender: UITapGestureRecognizer) {
        
        makeAlert(title: "One Dollar For Delivery", message: "For making this delivery, you will receive a one dollar delivery fee, as well as being fully compensated for the price of the purchase")
        
    }
    
    func didTapOneCoinMyRequest(_ sender: UITapGestureRecognizer) {
        
        makeAlert(title: "One Dollar For Delivery", message:  "When this delivery is complete, please venmo one dollar to the deliverer as a service fee, as well as compensating them for the price of the purchase")
        
    }
    
    func didTapTwoCoinMyRequest(_ sender: UITapGestureRecognizer) {
        
        makeAlert(title: "Two Dollars For Delivery", message: "When this delivery is complete, please venmo two dollars to the deliverer as a service fee, as well as compensating them for the price of the purchase")
        
    }
    
    func didTapTwoCoin(_ sender: UITapGestureRecognizer) {
        
        makeAlert(title: "Two Dollars For Delivery", message: "For making this delivery, you will receive two dollars, as well as being fully compensated for the price of the purchase")
        
    }

    func makeAlert(title: String, message: String)  {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            //do nothing
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = self.locationManager.location?.coordinate{
            
            self.userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            self.userLatitude = (self.userLocation?.coordinate.latitude)!
            self.userLongitude = (self.userLocation?.coordinate.longitude)!
            
        }
    }
    
    func chatImageTapPending(_ gesture: UITapGestureRecognizer)  {
        
        let imageTag = gesture.view!.tag
        
        self.otherUserId = self.sectionData[3]![imageTag]?["requesterUID"] as? String
        self.otherUserName = self.sectionData[3]![imageTag]?["requesterName"] as? String
        self.otherUserNotifId = self.sectionData[3]![imageTag]?["requesterNotifID"] as? String
        self.requestKey = self.sectionData[3]![imageTag]?["requestKey"] as? String
        self.databaseRef.child("request").child(self.requestKey!).child("isNewMessageAccepter").setValue(false)
        
        self.performSegue(withIdentifier: "runToChat", sender: nil)
        
        }
    
    func chatImageTapAccepted(_ gesture: UITapGestureRecognizer)  {
        
        let imageTag = gesture.view!.tag
        
        self.otherUserId = self.sectionData[2]![imageTag]?["requesterUID"] as? String
        self.otherUserName = self.sectionData[2]![imageTag]?["requesterName"] as? String
        self.otherUserNotifId = self.sectionData[2]![imageTag]?["requesterNotifID"] as? String
        self.requestKey = self.sectionData[2]![imageTag]?["requestKey"] as? String
        self.databaseRef.child("request").child(self.requestKey!).child("isNewMessageAccepter").setValue(false)
        
        self.performSegue(withIdentifier: "runToChat", sender: nil)
        
    }
    
    @IBAction func didTapEndRun(_ sender: UIButton) {
        
        let index = sender.tag
        
        let alertPurchaseComplete = UIAlertController(title: "Purchase Verification", message: "Have you completed this run?", preferredStyle: UIAlertControllerStyle.alert)
        
        alertPurchaseComplete.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
            
            
        }))
        
        alertPurchaseComplete.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.requestKey = self.sectionData[1]![index]?["runKey"] as? String
            self.databaseRef.child("runs").child(self.requestKey!).child("isComplete").setValue(true)
            
            sender.setTitle("Run is Complete", for: [])
            
            self.makeAlert(title: "Thank you!", message: "This run is complete! We hope you will continue to be a goodneighbor and make some more runs.")
    }))
    
    self.present(alertPurchaseComplete, animated: true, completion: nil)
}
    override func viewDidAppear(_ animated: Bool) {
        
         globalLoggedInUserId = FIRAuth.auth()?.currentUser?.uid
       
            //myBuildingMates - Store people to send to that are in your building and have an ID and are not you
        self.table.reloadData()
        
        
        let notificationType = UIApplication.shared.currentUserNotificationSettings!.types
        if notificationType.rawValue == 0 && (forceNotifCount < 1 || forceNotifCount > 3)
            
            
        {
            
            self.performSegue(withIdentifier: "runNotifsSegue", sender: nil)
        }
        
        if myLocation?.coordinate.latitude == 0.000000 && (forceNotifCount < 1 || forceNotifCount > 3) {
            
            self.performSegue(withIdentifier: "runNotifsSegue", sender: nil)
            
        }
        
        
        
        
        
        
    }
 

}
