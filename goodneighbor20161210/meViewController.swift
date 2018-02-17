//
//  meViewController.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/9/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import MapKit
import CoreLocation

var globalLoggedInUserId: String!

class meViewController: UIViewController {
    
    var databaseRef = FIRDatabase.database().reference()
    var loggedInUserId:String?
    var enteredPhoneNumber:String?
    var deliveryCount = 0
    var recieveCount = 0
    var usersInMyRadius = 0
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var userInMyRadiusLabel: UILabel!
    
    @IBOutlet var topImag: UIImageView!
    @IBOutlet var couponRedemptionBackground: UIView!
    @IBOutlet var logOutButton: UIButton!
    @IBOutlet var termsOfServiceButton: UIButton!
    @IBOutlet var changePhoneNumberButton: UIButton!
    @IBOutlet var changeDeliveryRadiusButton: UIButton!
    @IBOutlet var viewPastDeliveriesButton: UIButton!
    @IBOutlet var viewPastRequestButton: UIButton!
    @IBOutlet var resetHomeLocationButton: UIButton!
    @IBOutlet var couponRedemptionButton: UIButton!
    @IBOutlet var profilePicImage: UIImageView!
    @IBOutlet var topWhiteBackgroundView: UIView!
    
    var leadingConstraint: NSLayoutConstraint?
    var leadingConstraintValue:CGFloat?
    
    var activeBuildingMates = [String]()
    
    var myPastRecieve = [NSDictionary?]()
    var myPastDeliveries = [NSDictionary?]()
    
    var relevantPastInfo = [NSDictionary?]()
    var navBarTitle:String?
    
    @IBAction func didTapLogOut(_ sender: Any) {
       // try! FIRAuth.auth()?.signOut()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isX {
            let pinTop = NSLayoutConstraint(item: self.titleLabel, attribute: .top, relatedBy: .equal,
                                            toItem: view, attribute: .top, multiplier: 4.0, constant: 38)
            
            
            
            NSLayoutConstraint.activate([pinTop])
        }
        
        self.profilePicImage.layer.cornerRadius = 40
        self.profilePicImage.layer.masksToBounds = true
        self.profilePicImage.contentMode = .scaleAspectFit
        self.profilePicImage.layer.borderWidth = 2.0
        self.profilePicImage.layer.borderColor = UIColor(red: 16/255, green: 126/255, blue: 207/255, alpha: 1).cgColor
    
        if isSmallScreen || isVerySmallScreen {
            
            self.profilePicImage.isHidden = true
            self.leadingConstraintValue = -15.0
            
            self.leadingConstraint = self.topImag.bottomAnchor.constraint(equalTo: self.topWhiteBackgroundView.topAnchor, constant: self.leadingConstraintValue!)
            NSLayoutConstraint.activate([self.leadingConstraint!])
            
        } else {
            
            if let image = myProfilePicRef {
                
                let data = try? Data(contentsOf: URL(string: image)!)
                self.profilePicImage.image = UIImage(data: data!)
                
            }
            
            let imageTap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapMediaInTweet(_:)))
            
            self.profilePicImage.addGestureRecognizer(imageTap)
            
        }
   

       self.logOutButton.isHidden = true
        
        //For ipad small hide coupon redemption
        if isVerySmallScreen {
            
            self.couponRedemptionButton.isHidden = true
            self.couponRedemptionBackground.isHidden = true
            
        }
        
        
       self.loggedInUserId = FIRAuth.auth()?.currentUser?.uid
       globalLoggedInUserId = self.loggedInUserId
        
        self.termsOfServiceButton.contentHorizontalAlignment = .left
        self.changePhoneNumberButton.contentHorizontalAlignment = .left
        self.viewPastDeliveriesButton.contentHorizontalAlignment = .left
        self.changeDeliveryRadiusButton.contentHorizontalAlignment = .left
        self.resetHomeLocationButton.contentHorizontalAlignment = .left
        self.viewPastRequestButton.contentHorizontalAlignment = .left
        self.couponRedemptionButton.contentHorizontalAlignment = .left
        
        self.databaseRef.child("users").child(self.loggedInUserId!).observeSingleEvent(of: .value) { (snapshot:FIRDataSnapshot) in
            
            let snapshot = snapshot.value as? NSDictionary
            let tempDelivery = snapshot?["deliveryCount"] as? Int
            self.deliveryCount = Int(tempDelivery!)
            let tempRecieve = snapshot?["recieveCount"] as? Int
            self.recieveCount = Int(tempRecieve!)
            
            self.viewPastRequestButton.setTitle("View past requests (\(self.recieveCount))", for: .normal)
            self.viewPastDeliveriesButton.setTitle("View past deliveries (\(self.deliveryCount))", for: .normal)
        }
        
    //now pulling from completedRequest
        //self.databaseRef.child("request").observe(.childAdded) { (snapshot2: FIRDataSnapshot) in
          self.databaseRef.child("requestComplete").observe(.childAdded) { (snapshot2: FIRDataSnapshot) in
            
            let snapshot2 = snapshot2.value as! NSDictionary
            let snapRecieveId = snapshot2["requesterUID"] as? String
            let snapDeliverId = snapshot2["accepterUID"] as? String
           // let snapComplete = snapshot2["isComplete"] as? Bool
            
            //Past Recieved
            if(snapRecieveId == self.loggedInUserId){// && snapComplete == true){
                self.myPastRecieve.append(snapshot2)
            }
            
            //Past Delivered
            if(snapDeliverId == self.loggedInUserId){// && snapComplete == true){
                self.myPastDeliveries.append(snapshot2)
            }
        }
        
        self.databaseRef.child("users").observe(.childAdded) { (snapshot3: FIRDataSnapshot) in
 
            let snapshot3 = snapshot3.value as! NSDictionary
            
            if let userLatitude = snapshot3["latitude"] as? CLLocationDegrees {
            let userLongitude = snapshot3["longitude"] as? CLLocationDegrees
            
            let userLocation = CLLocation(latitude: userLatitude, longitude: userLongitude!)
            let distanceInMeters = myLocation!.distance(from: userLocation)
            let distanceMiles = distanceInMeters/1609.344897
            let distanceMilesFloat = Float(distanceMiles)
            
            if distanceMilesFloat < myRadius! {
                
                self.usersInMyRadius += 1
                
                self.userInMyRadiusLabel.text = "\(self.usersInMyRadius - 1) goodneighbors in your community!"
                
                }
                if let userState = snapshot3["state"] as? String {
                    if userState == "GA " {
                    }
                }
                
                //For user count check of ambassadors
               /* if let userBuilding = snapshot3["buildingName"] as? String{
                if userBuilding == "Wohlford" {
                    print(snapshot3["fullName"] as? String)
                }
            }*/
                
            }
        }
        
        /*self.databaseRef.child("request").observe(.childAdded) { (snapshot4: FIRDataSnapshot) in
            
            let snapshot4 = snapshot4.value as! NSDictionary
          
            
            if let userTime = snapshot4["purchaseTimeStamp"] as? Int {
               
                let requestBuilding = snapshot4["buildingName"] as? String
                //let userTimeInt = Int(userTime)
                
               if userTime > 191265775752 && (requestBuilding == "Hamilton Holmes" || requestBuilding == "Raoul Hall"  || requestBuilding == "Complex" || requestBuilding == "Longstreet means" )  {
               //if userTime>1490676932011 && (requestBuilding == "Fawcett") {
                //Adele
               //if userTime>1490676932011 && (requestBuilding == "Wohlford" || requestBuilding == "Boswell") {
                    
                    if  self.activeBuildingMates.contains(snapshot4["requesterName"] as! String)  {
                    } else {
                    self.activeBuildingMates.append(snapshot4["requesterName"] as! String)
                    }
                    if  self.activeBuildingMates.contains(snapshot4["accepterName"] as! String) {
                    } else {
                        self.activeBuildingMates.append(snapshot4["accepterName"] as! String)
                    }
                    
                }
            }
            print(self.activeBuildingMates)
            print(self.activeBuildingMates.count)
        }*/
        
    }

    @IBAction func didTapCouponRedemption(_ sender: UIButton) {
    }
    
    
    @IBAction func didTapPastRequests(_ sender: UIButton) {
        
        self.relevantPastInfo = self.myPastRecieve
        self.navBarTitle = "Completed Requests"
        
        self.performSegue(withIdentifier: "goToPast", sender: nil)
    }
    
    @IBAction func didTapPastDeliveries(_ sender: UIButton) {
        
        print(self.myPastDeliveries)
        
        self.relevantPastInfo = self.myPastDeliveries
        self.navBarTitle = "Completed Deliveries"
        
        self.performSegue(withIdentifier: "goToPast", sender: nil)
        
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //
        
        if segue.identifier == "goToPast" {
            
            let secondViewController = segue.destination as! pastActivityCompleted
            secondViewController.relevantPastInfo = self.relevantPastInfo
            secondViewController.navBarTitle = self.navBarTitle
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapPhoneButton(_ sender: UIButton) {
        
        var phoneNumberTextField: UITextField?
        
        let alertController = UIAlertController(
            title: "Add Phone Number",
            message: "Current cell: \(myCellNumber!)",
            preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(
        title: "Cancel", style: UIAlertActionStyle.default) {
            (action) -> Void in
        }
        
        let completeAction = UIAlertAction(
        title: "Complete", style: UIAlertActionStyle.default) {
            (action) -> Void in
            if let phoneNumber = phoneNumberTextField?.text {
                
                self.enteredPhoneNumber = phoneNumber
                if self.enteredPhoneNumber == "" {
                    self.enteredPhoneNumber = "0"
                }
            }
            self.databaseRef.child("users").child(self.loggedInUserId!).child("cellPhoneNumber").setValue(self.enteredPhoneNumber)
            
                myCellNumber = self.enteredPhoneNumber
            
        }
        
        alertController.addTextField {
            (txtUsername) -> Void in
            txtUsername.keyboardType = .decimalPad
            phoneNumberTextField = txtUsername
            phoneNumberTextField!.placeholder = "ex: 4135691234"
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(completeAction)
        
        
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func didTapChangeDeliveryRadius(_ sender: Any) {
       /*
        var radiusNumberTextField: UITextField?
        
        let alertController = UIAlertController(
            title: "Enter New Delivery Radius",
            message: "Please enter a whole number for number of miles you wish your delivery radius to be",
            preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(
        title: "Cancel", style: UIAlertActionStyle.default) {
            (action) -> Void in
        }
        
        let completeAction = UIAlertAction(
        title: "Complete", style: UIAlertActionStyle.default) {
            (action) -> Void in
            if let deliveryRadius = radiusNumberTextField?.text {
                if Int(deliveryRadius) != nil{
                    print("trrrr")
                let deliveryRadiusFloat1 = Float(Int(deliveryRadius)!)
                let deliveryRadiusFloat2 = deliveryRadiusFloat1 + 0.00002
            self.databaseRef.child("users").child(self.loggedInUserId!).child("deliveryRadius").setValue(deliveryRadiusFloat2)
            
                } else{
                
                print("Yolo:")
                let alertControllerError = UIAlertController(
                    title: "Please enter valid number",
                    message: "",
                    preferredStyle: UIAlertControllerStyle.alert)
                
                let errorAction = UIAlertAction(
                title: "Ok", style: UIAlertActionStyle.default) {
                    (action) -> Void in
                }
                alertControllerError.addAction(errorAction)
                self.present(alertControllerError, animated: true, completion: nil)
                
            }
            }
            
            
        }
        
        alertController.addTextField {
            (txtUsername) -> Void in
            radiusNumberTextField = txtUsername
            radiusNumberTextField!.placeholder = "ex: 2"
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(completeAction)
        
        
        self.present(alertController, animated: true, completion: nil)
        */
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


