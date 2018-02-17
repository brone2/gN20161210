 //
//  requestItem.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/8/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import CoreLocation
import OneSignal



class requestItem: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate, UITextViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    
    var databaseRef = FIRDatabase.database().reference()
    var storageRef = FIRStorage.storage().reference()
    var tokensOffered = 1
    var loggedInUser:String!
    var requesterName:String?
    var loggedInUserData:NSDictionary?
    var requesterLatitude:CLLocationDegrees?
    var requesterLongitude:CLLocationDegrees?
    var requesterBuildingName:String?
    var requesterTokenCount:Int?
    var isAccepted = false
    var imageData:Data?
    var requestedTime = NSDate()
    var date:String?
    var profilePicReference:String!
    var saveKeyPath: String?
    var saveKey: String?
    var downloadUrlAbsoluteString: String?
    var paymentType = "Venmo"
    var requestPrice = "$0.00"
    var myBuildingMates = [String]()
    var alertText:String?
    var whoSeesText: String?
    
    var visibleTo = "NA"
    
    var locationManager = CLLocationManager()
    var userLocation: CLLocation?
    var userLatitude: CLLocationDegrees = 0.10000
    var userLongitude: CLLocationDegrees = 0.10000
    
    var isRun = false
    var selectedRun:NSDictionary?
    var descriptionText: String?
    var runkey: String?
    
    @IBOutlet var itemRequestLabel: UILabel!
    
    @IBOutlet var questionButton: customButton!
    //@IBOutlet var questionToTap: UIImageView!
    @IBOutlet var requestButton: customButton!
    @IBOutlet var oneTokenLabel: UILabel!
    @IBOutlet var twoTokenLabel: UILabel!
    
    @IBOutlet var completeToolBar: UIToolbar!
    @IBOutlet var doneToolBarButton: UIBarButtonItem!
    @IBOutlet var toolbarBottomConstraint: NSLayoutConstraint!
    var toolbarBottomConstraintInitialValue:CGFloat?
    
    var runnerNotifID: String?
 
    @IBOutlet weak var twoTokenImage: UIImageView!
    @IBOutlet weak var oneTokenImage: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var priceLabel: UITextField!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet var venmoImage: UIImageView!
    @IBOutlet var cashImage: UIImageView!
    
    
    @IBOutlet var detailInfoLabel: UILabel!
    @IBOutlet var tokensOfferedLabel: UILabel!
    @IBOutlet var deliverToLabel: UILabel!
    @IBOutlet var maxPayLabel: UILabel!
    @IBOutlet var itemNameLabel: UILabel!
    @IBOutlet var runTextLabel: UILabel!
    
    @IBOutlet var titleLabel: UILabel!
    var requestRun = "request"
    
    @IBOutlet var addPictureButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if isX {
            let pinTop = NSLayoutConstraint(item: self.titleLabel, attribute: .top, relatedBy: .equal,
                                            toItem: view, attribute: .top, multiplier: 4.0, constant: 38)

            NSLayoutConstraint.activate([pinTop])
        }
        
        let randomNum:UInt32 = arc4random_uniform(100000)
        let someString:String = String(randomNum)
        
        self.image.isHidden = true
        
        //Run Request
        
        if self.isRun {
            itemNameLabel.text = "Item from \(self.selectedRun?["runTo"] as! String)"
            self.descriptionText = "Provide \(self.selectedRun?["runnerName"] as! String) detailed information about your request for their run to  \(self.selectedRun?["runTo"] as! String)"
            self.runkey = self.selectedRun?["runKey"] as! String
            self.runnerNotifID = self.selectedRun?["runnerNotif"] as! String
            self.whoSeesText = "Request will only be visible to \(self.selectedRun?["runnerName"] as! String)"
        } else {
            self.descriptionText = "Ex: Please pick up a six pack of diet coke, but regular coke is fine if there's no diet. I live in Lisner Dorm. Call me with any questions."
            self.whoSeesText = "Visible to neighbors in \(myBuilding!)"
            
        }
        
        self.runTextLabel.text = (self.whoSeesText as! String)
        
        let selectWhoSees:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.selectWhoSees(_:)))
        self.runTextLabel.addGestureRecognizer(selectWhoSees)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
    
    //Turn off the three text options when inputting text, perhaps makes it look better
        self.nameLabel.autocorrectionType = .no
        self.descriptionTextView.autocorrectionType = .no
        
        self.completeToolBar.isHidden = true
        
        self.cashImage.layer.cornerRadius = 2.0
        self.cashImage.layer.masksToBounds = true
        
    //For ipad small hide token info
        if isVerySmallScreen {
            
            let smallFont:CGFloat = 16.0
            self.oneTokenImage.isHidden = true
            self.twoTokenImage.isHidden = true
            //self.oneTokenLabel.isHidden = true
            //self.twoTokenLabel.isHidden = true
            self.tokensOfferedLabel.isHidden = true
            self.addPictureButton.isHidden = true
            self.runTextLabel.isHidden = true
            self.detailInfoLabel.font = UIFont.systemFont(ofSize: smallFont)
            self.tokensOfferedLabel.font = UIFont.systemFont(ofSize: smallFont)
            self.tokensOfferedLabel.text = "Tokens Offered"
            self.deliverToLabel.font = UIFont.systemFont(ofSize: smallFont)
            self.maxPayLabel.font = UIFont.systemFont(ofSize: smallFont)
            self.itemNameLabel.font = UIFont.systemFont(ofSize: smallFont)
            
            self.requestButton.frame = CGRect(x: view.frame.width/2 - self.requestButton.frame.width/2, y: 400, width: 132, height: 30)
           
            
        } else if isSmallScreen {
            
            self.image.isHidden = true
            let smallFont:CGFloat = 16.0
            self.detailInfoLabel.font = UIFont.systemFont(ofSize: smallFont)
            self.tokensOfferedLabel.font = UIFont.systemFont(ofSize: smallFont)
            self.tokensOfferedLabel.text = "Tokens Offered"
            self.deliverToLabel.font = UIFont.systemFont(ofSize: smallFont)
            self.maxPayLabel.font = UIFont.systemFont(ofSize: smallFont)
            self.itemNameLabel.font = UIFont.systemFont(ofSize: smallFont)
           // self.oneTokenLabel.font = UIFont.systemFont(ofSize: smallFont)
          //  self.twoTokenLabel.font = UIFont.systemFont(ofSize: smallFont)
            
            self.requestButton.frame = CGRect(x: view.frame.width/2 - self.requestButton.frame.width/2, y: 490, width: 132, height: 30)
            self.image.isHidden = true
            self.addPictureButton.isHidden = true
            self.runTextLabel.isHidden = true
            
            
        } else if isX {
            
            self.requestButton.frame = CGRect(x: view.frame.width/2 - self.requestButton.frame.width/2, y: 625+44, width: 132, height: 30)
            self.image.frame = CGRect(x: view.frame.width/2 - 60, y: 485+25, width: 120, height: 120)
            self.addPictureButton.frame = CGRect(x: view.frame.width/2 - self.addPictureButton.frame.width/2, y: 525+35, width: 195, height: 30)
            self.runTextLabel.frame = CGRect(x: 0, y: 645 + 70, width: view.frame.width, height: 30)
            
            
        }
        
        
        else if isLargeScreen {
            
            /*let bottomConstraint = self.image.bottomAnchor.constraint(equalTo: self.requestButton.topAnchor, constant: -55)
            NSLayoutConstraint.activate([bottomConstraint])*/
            
            self.requestButton.frame = CGRect(x: view.frame.width/2 - self.requestButton.frame.width/2, y: 625, width: 132, height: 30)
            self.image.frame = CGRect(x: view.frame.width/2 - 60, y: 485, width: 120, height: 120)
            self.addPictureButton.frame = CGRect(x: view.frame.width/2 - self.addPictureButton.frame.width/2, y: 525, width: 195, height: 30)
            self.runTextLabel.frame = CGRect(x: 0, y: 645 + 20, width: view.frame.width, height: 30)
            
        }  else {
            
            let delta:CGFloat = 10.0
            self.requestButton.frame = CGRect(x: view.frame.width/2 - self.requestButton.frame.width/2, y: 552 + delta, width: 132, height: 30)
            self.image.frame = CGRect(x: view.frame.width/2 - self.image.frame.width/2, y: 465 + delta/2, width: 72, height: 72)
            self.addPictureButton.frame = CGRect(x: view.frame.width/2 - self.addPictureButton.frame.width/2, y: 484 + delta/2, width: 195, height: 30)
              self.runTextLabel.frame = CGRect(x:0 , y: 582 + 30, width: view.frame.width, height: 30)
            
        }
        
        self.nameLabel.delegate = self
        self.priceLabel.delegate = self
        
        self.loggedInUser = FIRAuth.auth()?.currentUser?.uid

        descriptionTextView.text = self.descriptionText
        descriptionTextView.textColor = UIColor.lightGray
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        
        self.locationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        
        //retrieve user info
        self.databaseRef.child("users").child(self.loggedInUser!).observeSingleEvent(of: .value) { (snapshot:FIRDataSnapshot) in
            
            self.loggedInUserData = snapshot.value as? NSDictionary
            
            self.requesterName = self.loggedInUserData?["name"] as? String
            
            loggedInUserName = self.requesterName
            
            self.profilePicReference = self.loggedInUserData?["profilePicReference"] as? String
            
            self.requesterLongitude = self.loggedInUserData?["longitude"] as! CLLocationDegrees?
            
            self.requesterLatitude = self.loggedInUserData?["latitude"] as! CLLocationDegrees?
            
            self.requesterBuildingName = self.loggedInUserData?["buildingName"] as? String
        }
        
        //Get date and time information
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm MMM dd"
        let result = formatter.string(from: requestedTime as Date)
        self.date = result
        
        //imageGestureRecognizers
        //oneToken
        let oneTokenImageTap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapOneToken(_:)))
        oneTokenImage.addGestureRecognizer(oneTokenImageTap)
        
        let twoTokenImageTap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapTwoToken(_:)))
        twoTokenImage.addGestureRecognizer(twoTokenImageTap)
        
        let venmoImageTap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapVenmoImage(_:)))
        venmoImage.addGestureRecognizer(venmoImageTap)
        
        let cashImageTap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapCashImage(_:)))
        cashImage.addGestureRecognizer(cashImageTap)
        
        let imageTap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImageIcon(_:)))
        image.addGestureRecognizer(imageTap)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if(descriptionTextView.textColor == UIColor.lightGray){
            self.descriptionTextView.text = ""
            self.descriptionTextView.textColor = UIColor.black
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    /* Having the jumping text issues when top textfield pressed
        if self.priceLabel.text == "" {
            self.priceLabel.text = "$"
            self.priceLabel.textColor = UIColor.black
        }
 */
    }
    
 
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // Workaround for the jumping text bug.
        //NEED TO MAKE TEXTFIELDS DELEGATES
        textField.resignFirstResponder()
        textField.layoutIfNeeded()
        
    }
    
    @IBAction func didTapRequest(_ sender: Any) {
        
        let notificationType = UIApplication.shared.currentUserNotificationSettings!.types
        if notificationType.rawValue == 0 {
            
            
            self.notifAlert(title: "Please turn on notifications", message: "Please turn on notifications in order to redeem a coupon code")
            
        } else {
        
    OneSignal.postNotification(["contents": ["en": "\(loggedInUserName!) posted a request!"], "include_player_ids": [neilNotif],"ios_sound": "nil", "data": ["type": "request"]])

        
    self.databaseRef.child("users").child(self.loggedInUser!).observeSingleEvent(of: .value) { (snapshot:FIRDataSnapshot) in
        
        currentTokenCount = self.loggedInUserData?["tokenCount"] as? Int
        
        if self.itemNameLabel.text == "" || self.priceLabel.text == "" || self.priceLabel.text == "" || self.priceLabel.text == "$"
            /*
            || self.descriptionTextView.text! == "Ex: Please pick up a six pack of diet coke, but regular coke is fine if there's no diet. I live in Lisner Dorm. Call me with any questions."*/
        
        {
            let alertNotEnough = UIAlertController(title: "Missing Information", message: "Please fill out all fields", preferredStyle: UIAlertControllerStyle.alert)
            
            alertNotEnough.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                return
            }))
            self.present(alertNotEnough, animated: true, completion: nil)
        }
        
        if self.tokensOffered > currentTokenCount {
            
            let alertNotEnough = UIAlertController(title: "Make some deliveries!", message: "Unfortunately, you do not have enough tokens for this request. Solve this problem by helping your neighbors with some deliveries!", preferredStyle: UIAlertControllerStyle.alert)
            
            alertNotEnough.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                
            }))
            self.present(alertNotEnough, animated: true, completion: nil)
        } else {
            
        let alert = UIAlertController(title: "Post Request", message: "I agree to pay a maximum of \(self.priceLabel.text!) for \(self.nameLabel.text!). Once this item has been accepted for delivery it cannot be cancelled", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
                
        }))
        
       alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
        
            //self.cashPopUp()
        self.locationCheck()
        
        }))
        self.present(alert, animated: true, completion: nil)
        }
    }
    }
    }
    
    func locationCheck() {
        
        let requestLocation = CLLocation(latitude: self.userLatitude, longitude: self.userLongitude)
        let distanceInMeters = myLocation?.distance(from: requestLocation)
        let distanceInMetersFloat = Float(distanceInMeters!)
        print(distanceInMetersFloat)
        print(requestLocation)
        
        if myLocation?.coordinate.latitude == 0.000000 {
            
            self.makeAlert(title: "Missing Delivery Location", message: "Please go to settings and allow Location services. Once you have done this, you may set your delivery location in the Me tab")
            
        } else if self.userLatitude == 0.10000 {
            self.cashPopUp()
        } else if distanceInMetersFloat > 750 {
            
            let alertPurchaseLocation = UIAlertController(title: "Reset Delivery Location?", message: "You appear to be requesting this item from a new location. Would you like to reset your delivery location to your current Location?", preferredStyle: UIAlertControllerStyle.alert)
            
            alertPurchaseLocation.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                self.cashPopUp()
            }))
            
            alertPurchaseLocation.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                
                myLocation = CLLocation(latitude: self.userLatitude, longitude: self.userLongitude)
                
                let childUpdates = ["/users/\(self.loggedInUser!)/longitude":self.userLongitude, "/users/\(self.loggedInUser!)/latitude":self.userLatitude] as [String : Any]
                
                //Update
                self.databaseRef.updateChildValues(childUpdates)
                
                let alertLocationSet = UIAlertController(title: "Delivery Location Set", message: "Your delivery location has been reset to your current location", preferredStyle: UIAlertControllerStyle.alert)
                
                alertLocationSet.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.cashPopUp()
                }))
                
                self.present(alertLocationSet, animated: true, completion: nil)
                
            }))
            self.present(alertPurchaseLocation, animated: true, completion: nil)
            
        } else { //is requesting near delivery location
            self.cashPopUp()
        }
        
    }
    
    func cashPopUp() {
        
        self.requestPrice = self.priceLabel.text! as String
        
        //Event Request made
        FIRAnalytics.logEvent(withName: "didMakeRequest", parameters: nil)
        
        //Event Request has picture
        if self.imageData != nil{
            FIRAnalytics.logEvent(withName: "didAddPictureToRequest", parameters: nil)
        }
        
        if self.paymentType == "Venmo" {
            
        //Event Venmo Request made
            
            FIRAnalytics.logEvent(withName: "didMakeVenmoRequest", parameters: nil)
            self.prepareUploadRequest()
            
        } else if self.paymentType == "Cash" {
            
        FIRAnalytics.logEvent(withName: "didMakeCashRequest", parameters: nil)
            
            if (self.requestPrice).contains(".") {
                
                let requestPriceCash1 = self.requestPrice
                
                let requestPriceCash = requestPriceCash1.replacingOccurrences(of: "$", with: "")
                print(requestPriceCash)
                
                let priceStringArray = requestPriceCash.components(separatedBy: ".")
                
                if priceStringArray[1].characters.count > 0 {
                    
                    let centsAsInt: Int = Int(priceStringArray[1])!
                    print(priceStringArray[0])
                    if centsAsInt > 0 {
                        
                        var dollarsAsInt: Int = Int(priceStringArray[0])!
                        dollarsAsInt += 1
                        let dollarsAsString = String(dollarsAsInt)
                        let requestDollarsString = "$" + dollarsAsString + ".00"
                        self.requestPrice = requestDollarsString
                        
                    }
                }
            }

        let cashAlert = UIAlertController(title: "Cash Payment Notice", message: "If you would like to pay cash, you must round up to the nearest dollar, change is not allowed. Thus, your max price will be \(self.requestPrice)", preferredStyle: UIAlertControllerStyle.alert)
            
        cashAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            //do nothing
        }))
        
        cashAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.prepareUploadRequest()
        }))
        
        
         self.present(cashAlert, animated: true, completion: nil)
        
    }
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //
        
        if segue.identifier == "goToPhone" {
            
            let secondViewController = segue.destination as! submitPhoneNumberView
            secondViewController.saveKey =  self.saveKey
        }
        
    }

    func didTapOneToken(_ sender: UITapGestureRecognizer) {
        
        if self.tokensOffered == 2 {
            self.oneTokenImage.image = UIImage(named: "1DollBlue.png")
            self.twoTokenImage.image = UIImage(named: "2DollGray.png")
            self.tokensOffered = 1
        }
}
    
    func didTapTwoToken(_ sender: UITapGestureRecognizer) {
        
        if self.tokensOffered == 1 {
            self.twoTokenImage.image = UIImage(named: "2DollBlue.png")
            self.oneTokenImage.image = UIImage(named: "1DollGray.png")
            self.tokensOffered = 2
        }
}
    
    func didTapVenmoImage(_ sender: UITapGestureRecognizer) {
        
        if self.paymentType == "Cash" {
            self.venmoImage.image = UIImage(named: "venmo-icon.png")
            self.cashImage.image = UIImage(named: "grey_cash.png")
            self.paymentType = "Venmo"
            print(self.paymentType)
        }
    }
    
    func didTapCashImage(_ sender: UITapGestureRecognizer) {
        
        if self.paymentType == "Venmo" {
            self.venmoImage.image = UIImage(named: "venmo-icon_grey.png")
            self.cashImage.image = UIImage(named: "Cash_icon.png")
            self.paymentType = "Cash"
            print(self.paymentType)
        }
    }
    
    @IBAction func didTapAddPicture(_ sender: UIButton) {
      
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePickerController.allowsEditing = true
       
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    func didTapImageIcon(_ sender:UITapGestureRecognizer){
        /*let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil) */
    }
    
    @IBAction func didTapDeliverTo(_ sender: UIButton) {
        
        let myActionSheet = UIAlertController(title:"Delivery Location",message:"Please select where you would like item delivered",preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let aptLobby = UIAlertAction(title: "Will meet in my dorm", style: UIAlertActionStyle.default) { (action) in
            sender.setTitle("Will meet in my dorm", for: [])
        }
        
        let myFloor = UIAlertAction(title: "Will pick up", style: UIAlertActionStyle.default) { (action) in
            sender.setTitle("Will pick up", for: [])
        }
        
        let myDoor = UIAlertAction(title: "My door", style: UIAlertActionStyle.default) { (action) in
            sender.setTitle("My door", for: [])
        }
        
        
        let otherChoice = UIAlertAction(title: "Other", style: UIAlertActionStyle.default) { (action) in
            
            var enterLocationTextField: UITextField?
            
            let alertController = UIAlertController(
                title: "Enter Delivery Location",
                message: "",
                preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(
            title: "Cancel", style: UIAlertActionStyle.default) {
                (action) -> Void in
            }
            
            let completeAction = UIAlertAction(
            title: "Enter", style: UIAlertActionStyle.default) {
                (action) -> Void in
                
                if let deliveryLocation = enterLocationTextField?.text {
                    sender.setTitle(deliveryLocation, for: [])
                }
                
            }
            
            alertController.addTextField {
                (txtUsername) -> Void in
                enterLocationTextField = txtUsername
                enterLocationTextField!.placeholder = "ex: Outside Olin Library"
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(completeAction)
            
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        
        myActionSheet.addAction(myDoor)
        myActionSheet.addAction(myFloor)
        myActionSheet.addAction(aptLobby)
        myActionSheet.addAction(otherChoice)
        
        self.present(myActionSheet, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage?
        self.image.isHidden = false
        self.addPictureButton.isHidden = true
        self.image.image = image
        self.imageData = UIImageJPEGRepresentation(image!, 0.2)
        self.dismiss(animated: true, completion: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func prepareUploadRequest() {
        
        //Begin request upload
        //Save Request to firebase
        //Save Picture
        
        let key = self.databaseRef.child("request").childByAutoId().key
        
        _ = self.storageRef.child("request/\(self.loggedInUser)/media/\(key)")
        
        let metadata = FIRStorageMetadata()
        //Choose png of jpeg or whatever
        metadata.contentType = "image/png"
        
        if self.imageData != nil{
        
        let profilePicStorageRef = self.storageRef.child("productImages/\(key)/image_request")
          
        _ = profilePicStorageRef.put(self.imageData!, metadata: metadata,  completion: { (metadata, error) in
            
            if error != nil{
                
            }else{
                
                let downloadUrl = metadata!.downloadURL()
                self.downloadUrlAbsoluteString = downloadUrl!.absoluteString
                self.finalizeUploadRequest(key: key)
            }
        })
        } else {
            if !isRun {
                    self.finalizeUploadRequest(key: key)
            } else {
                    self.finalizeUploadRequest(key: key)
            }
        }
    }
    
    //Make this a seperate function because of multi threading issue with saving the image to firebase
    func finalizeUploadRequest(key: String) {
    
        //Save text
        

        let paymentTypePath = "/\(key)/paymentType"
        //Will need to change this
        let paymentTypeValue = self.paymentType as String
        
        var priceString = self.requestPrice
        
         if priceString.contains(".") {
         
         let priceStringArray = priceString.components(separatedBy: ".")
         
         if priceStringArray[1].characters.count == 1 {
            
         priceString += "0"
         self.requestPrice = priceString
         
        }
         
         } else  { //if no values after decimal
         
         priceString += ".00"
         self.requestPrice = priceString
         
         }
        
        //"/\(self.requestRun)"+
        let pricePath = "/\(key)/price"
        let priceLabelValue = self.requestPrice
        //let priceLabelValue = self.priceLabel.text! as String
        
        let tokenPath = "/\(key)/tokensOffered"
        let tokensLabelValue = self.tokensOffered
        
        let purchaePricePath = "/\(key)/purchasePrice"
        let purchaePriceValue = "NA"
        
        let requesterNotifPath = "/\(key)/requesterNotifID"
        let requesterNotif = myNotif
        
        let descriptionPath = "/\(key)/description"
        let descriptionLabelValue = self.descriptionTextView.text! as String
        
        let requesterNamePath = "/\(key)/requesterName"
        let requesterNameValue = self.requesterName! as String
        
        let itemNamePath = "/\(key)/itemName"
        let itemNameValue = self.nameLabel.text! as String
        
        let requestedTimePath = "/\(key)/requestedTime"
        let requestedTimeValue = self.date
        
        let longitudePath = "/\(key)/longitude"
        //let longitudeValue = self.requesterLongitude! as CLLocationDegrees
        let longitudeValue = (myLocation?.coordinate.longitude)! as CLLocationDegrees
        
        let buildingNamePath = "/\(key)/buildingName"
        let buildingNamePathValue = self.requesterBuildingName! as String
        print(buildingNamePathValue)
        //let buildingNamePathValue = "hello"
        
        let latitudePath = "/\(key)/latitude"
        //let latitudeValue = self.requesterLatitude! as CLLocationDegrees
        let latitudeValue = (myLocation?.coordinate.latitude)! as CLLocationDegrees
        
        let requesterUIDPath = "/\(key)/requesterUID"
        let requesterUIDValue = self.loggedInUser as String
        
        let requesterCellPath = "/\(key)/requesterCell"
        let requesterCellValue = myCellNumber as String
        
        let profilePicReferencePath = "/\(key)/profilePicReference"
        let profilePicReferenceValue = self.profilePicReference
        
        let accepterNotifIdPath = "/\(key)/accepterNotifId"
        let accepterNotifIdValue = "NA"
        
        let accepterNamePath = "/\(key)/accepterName"
        let accepterUIDPath = "/\(key)/accepterUID"
        let accepterProfilePicRefPath = "/\(key)/accepterProfilePicRef"
        let runKeyPath = "/\(key)/runKey"
        let runToPath = "/\(key)/runTo"
        let accepterCellPath = "/\(key)/accepterCell"
        
        let visibleToPath = "/\(key)/visibleTo"
        let visibleToValue = self.visibleTo as String
        
        let isAcceptedPath = "/\(key)/isAccepted"
        let isAcceptedValue = self.isAccepted as Bool
        
        let deliverToPath = "/\(key)/deliverTo"
        let deliverToValue = self.locationButton.currentTitle! as String
        
        let isCompletePath = "/\(key)/isComplete"
        let isCompleteValue = false
        
        let isNewMessageRequesterPath = "/\(key)/isNewMessageRequester"
        let isNewMessageReqesterValue = false
        
        let isNewMessageAccepterPath = "/\(key)/isNewMessageAccepter"
        let isNewMessageAccepterValue = false
        
        let isRunPath = "/\(key)/isRun"
        let isRunValue = true
        
        let requestedTimeStamp = "/\(key)/requestedTimeStamp"
        
        //Set key value for later reference
        let requestKeyPath = "/\(key)/requestKey"
        let keyValue = key as String
        
        let completedPopUpUsedPath = "/\(key)/completedPopUpUsed"
        let completedPopUpUsedValue = false
        
        self.saveKeyPath = requestKeyPath
        self.saveKey = keyValue
        
    
    //Send out push notifications
      //  DispatchQueue.main.async {
      DispatchQueue.global().async {
        
        if self.isRun {
            
            OneSignal.postNotification(["contents": ["en": "\(requesterNameValue) has posted a request to your run!"], "include_player_ids": [self.runnerNotifID!],"ios_sound": "nil", "data": ["type": "run"]])
            
        } else {
            for mateID in 0..<self.myBuildingMates.count {
            print(mateID)
            print("EEEEEE")
            print(self.myBuildingMates[mateID])
            
            /*let deadlineTime = DispatchTime.now() + .seconds(1)
                
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {*/
            
                print("\(self.myBuildingMates[mateID])!")
                OneSignal.postNotification(["contents": ["en": "\(requesterNameValue) has requested \(itemNameValue)!"], "include_player_ids": [self.myBuildingMates[mateID]],"ios_sound": "nil", "data": ["type": "request"]])
            
                
            }
        }
       }
     //   }
        
        
        if self.isRun {
            print(self.requestRun)
            
            let childUpdates:Dictionary<String, Any> = ["/\(self.requestRun)\(requestedTimeStamp)": [".sv": "timestamp"],"/\(self.requestRun)\(profilePicReferencePath)": profilePicReferenceValue!, "/\(self.requestRun)\(requesterCellPath)": requesterCellValue,"/\(self.requestRun)\(pricePath)": priceLabelValue, "/\(self.requestRun)\(buildingNamePath)": buildingNamePathValue, "/\(self.requestRun)\(itemNamePath)": itemNameValue,"/\(self.requestRun)\(tokenPath)": tokensLabelValue,"/\(self.requestRun)\(descriptionPath)":descriptionLabelValue,"/\(self.requestRun)\(requesterNamePath)":requesterNameValue,"/\(self.requestRun)\(deliverToPath)":deliverToValue,"/\(self.requestRun)\(longitudePath)":longitudeValue,"/\(self.requestRun)\(latitudePath)":latitudeValue,"/\(self.requestRun)\(requestedTimePath)":requestedTimeValue!,"/\(self.requestRun)\(requesterUIDPath)":requesterUIDValue,"/\(self.requestRun)\(isAcceptedPath)":isAcceptedValue,"/\(self.requestRun)\(isCompletePath)":isCompleteValue,"/\(self.requestRun)\(requestKeyPath)":keyValue, "/\(self.requestRun)\(paymentTypePath)":paymentTypeValue, "/\(self.requestRun)\(purchaePricePath)":purchaePriceValue, "/\(self.requestRun)\(completedPopUpUsedPath)":completedPopUpUsedValue, "/\(self.requestRun)\(requesterNotifPath)": requesterNotif, "/\(self.requestRun)\(accepterNotifIdPath)":self.selectedRun!["runnerNotif"] as! String, "/\(self.requestRun)\(isNewMessageRequesterPath)": isNewMessageReqesterValue, "/\(self.requestRun)\(isNewMessageAccepterPath)": isNewMessageAccepterValue, "/\(self.requestRun)\(accepterNamePath)":self.selectedRun!["runnerName"] as! String, "/\(self.requestRun)\(accepterUIDPath)": self.selectedRun!["runnerUID"] as! String, "/\(self.requestRun)\(accepterProfilePicRefPath)": self.selectedRun!["profilePicReference"] as! String, "/\(self.requestRun)\(runKeyPath)": self.selectedRun!["runKey"] as! String,"/\(self.requestRun)\(runToPath)":self.selectedRun!["runTo"] as! String,"/\(self.requestRun)\(isRunPath)":isRunValue, "/\(self.requestRun)\(accepterCellPath)": self.selectedRun!["runnerCell"] as! String]
            
            self.databaseRef.updateChildValues(childUpdates)
            
            let requestCount = self.selectedRun!["requestCount"] as! Int
            let newRequestCount = requestCount + 1
            let newRequestCountPath = "runs/\(self.selectedRun!["runKey"] as! String)/requestCount"
            
            let childUpdates2:Dictionary<String, Any> = [newRequestCountPath:newRequestCount]
            
            self.databaseRef.updateChildValues(childUpdates2)
            
            self.requestReset()
            
        } else {
            
        
        if self.imageData != nil{
            
            let downloadUrlAbsoluteStringPath = "/request/\(runKeyPath)/productImage"
            let downloadUrlAbsoluteStringValue = self.downloadUrlAbsoluteString
            
            let childUpdates:Dictionary<String, Any> = ["/\(self.requestRun)\(requestedTimeStamp)": [".sv": "timestamp"],"/\(self.requestRun)\(profilePicReferencePath)": profilePicReferenceValue!,downloadUrlAbsoluteStringPath:downloadUrlAbsoluteStringValue!, "/\(self.requestRun)\(requesterCellPath)": requesterCellValue,"/\(self.requestRun)\(pricePath)": priceLabelValue, "/\(self.requestRun)\(buildingNamePath)": buildingNamePathValue, "/\(self.requestRun)\(itemNamePath)": itemNameValue,"/\(self.requestRun)\(tokenPath)": tokensLabelValue,"/\(self.requestRun)\(descriptionPath)":descriptionLabelValue,"/\(self.requestRun)\(requesterNamePath)":requesterNameValue,"/\(self.requestRun)\(deliverToPath)":deliverToValue,"/\(self.requestRun)\(longitudePath)":longitudeValue,"/\(self.requestRun)\(latitudePath)":latitudeValue,"/\(self.requestRun)\(requestedTimePath)":requestedTimeValue!,"/\(self.requestRun)\(requesterUIDPath)":requesterUIDValue,"/\(self.requestRun)\(isAcceptedPath)":isAcceptedValue,"/\(self.requestRun)\(isCompletePath)":isCompleteValue,"/\(self.requestRun)\(requestKeyPath)":keyValue, "/\(self.requestRun)\(paymentTypePath)":paymentTypeValue, "/\(self.requestRun)\(purchaePricePath)":purchaePriceValue, "/\(self.requestRun)\(completedPopUpUsedPath)":completedPopUpUsedValue, "/\(self.requestRun)\(requesterNotifPath)": requesterNotif, "/\(self.requestRun)\(accepterNotifIdPath)":accepterNotifIdValue, "/\(self.requestRun)\(isNewMessageRequesterPath)": isNewMessageReqesterValue, "/\(self.requestRun)\(isNewMessageAccepterPath)": isNewMessageAccepterValue, "/\(self.requestRun)\(visibleToPath)": visibleToValue]
            
        self.databaseRef.updateChildValues(childUpdates)
            
        if myCellNumber == "0"{
            
                 //self.performSegue(withIdentifier: "goToPhone", sender: nil)
                 self.requestReset()
            
            } else {
            
        self.requestReset()
            
            }
        }
            
        else
            
        {
           let childUpdates:Dictionary<String, Any> = ["/\(self.requestRun)\(requestedTimeStamp)": [".sv": "timestamp"],"/\(self.requestRun)\(profilePicReferencePath)": profilePicReferenceValue!, "/\(self.requestRun)\(requesterCellPath)": requesterCellValue,"/\(self.requestRun)\(pricePath)": priceLabelValue, "/\(self.requestRun)\(buildingNamePath)": buildingNamePathValue, "/\(self.requestRun)\(itemNamePath)": itemNameValue,"/\(self.requestRun)\(tokenPath)": tokensLabelValue,"/\(self.requestRun)\(descriptionPath)":descriptionLabelValue,"/\(self.requestRun)\(requesterNamePath)":requesterNameValue,"/\(self.requestRun)\(deliverToPath)":deliverToValue,"/\(self.requestRun)\(longitudePath)":longitudeValue,"/\(self.requestRun)\(latitudePath)":latitudeValue,"/\(self.requestRun)\(requestedTimePath)":requestedTimeValue!,"/\(self.requestRun)\(requesterUIDPath)":requesterUIDValue,"/\(self.requestRun)\(isAcceptedPath)":isAcceptedValue,"/\(self.requestRun)\(isCompletePath)":isCompleteValue,"/\(self.requestRun)\(requestKeyPath)":keyValue, "/\(self.requestRun)\(paymentTypePath)":paymentTypeValue, "/\(self.requestRun)\(purchaePricePath)":purchaePriceValue, "/\(self.requestRun)\(completedPopUpUsedPath)":completedPopUpUsedValue, "/\(self.requestRun)\(requesterNotifPath)": requesterNotif, "/\(self.requestRun)\(accepterNotifIdPath)":accepterNotifIdValue, "/\(self.requestRun)\(isNewMessageRequesterPath)": isNewMessageReqesterValue, "/\(self.requestRun)\(isNewMessageAccepterPath)": isNewMessageAccepterValue, "/\(self.requestRun)\(visibleToPath)": visibleToValue]

            
            self.databaseRef.updateChildValues(childUpdates)
            
            if myCellNumber == "0"{
              //  self.performSegue(withIdentifier: "goToPhone", sender: nil)
                 self.requestReset()
            } else {
                self.requestReset()
            }
            
        }
    }
        
    }
    
    func requestReset(){
        
        //Clear all textfields and reset image
        self.nameLabel.text = ""
        self.priceLabel.text = ""
        self.descriptionTextView.text = ""
        self.image.image = UIImage(named: "saveImage2.png")
        
        
        if isRun {
            self.alertText = "Your request has been made to this run! You will recieve a notification when it is accepted."
        } else {
            self.alertText = "Your request has been posted! Please be alert for a neighbor reaching out to deliver this item"
        }
        let alertDeliveryComplete = UIAlertController(title: "Request posted!", message: self.alertText!, preferredStyle: UIAlertControllerStyle.alert)
        
        alertDeliveryComplete.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            self.segueToShoppingList()
            
        }))
        self.present(alertDeliveryComplete, animated: true, completion: nil)
    }
    
    func segueToShoppingList() {
        performSegue(withIdentifier: "requestToShoppingList", sender: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /*@IBAction func didTapQuestion(_ sender: Any) {
        self.performSegue(withIdentifier: "requestToExplanation", sender: nil)
    }*/
 func textFieldShouldReturn(_ textField: UITextField) -> Bool{
    self.view.endEditing(true)
    return false
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func enableKeyboardHideOnTap () {
        
        NotificationCenter.default.addObserver(self, selector: #selector(requestItem.keyBoardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(requestItem.keyBoardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(requestItem.hideKeyboard))
        self.view.addGestureRecognizer(tap)

    }
    

    
    func keyBoardWillShow(_ notification: NSNotification){

        let info = (notification as NSNotification).userInfo!

        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

       let duration = (notification as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double

        UIView.animate(withDuration: duration) {

            self.toolbarBottomConstraint.constant = keyboardFrame.size.height
            self.completeToolBar.isHidden = false
            self.view.layoutIfNeeded()

}
        
}
    
    func keyBoardWillHide(_ notification: NSNotification){
 
        let duration = (notification as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double

        UIView.animate(withDuration: duration) {

            self.toolbarBottomConstraint.constant = self.toolbarBottomConstraintInitialValue!
            self.completeToolBar.isHidden = true
            self.view.layoutIfNeeded()
        }
    }
    
     override func viewDidAppear(_ animated: Bool) {
        enableKeyboardHideOnTap()
        self.toolbarBottomConstraintInitialValue = toolbarBottomConstraint.constant
        globalLoggedInUserId = FIRAuth.auth()?.currentUser?.uid
        self.myBuildingMates = []
        
        //myBuildingMates - Store people to send to that are in your building and have an ID and are not you
        self.databaseRef.child("users").observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            
            //Go ahead and save the fullName here
            
            let userID = snapshot.key
            
            let snapshot = snapshot.value as! NSDictionary
          
        // This is for building 
            if let userBuilding = snapshot["buildingName"] as? String {
                
              /*  if userBuilding == myBuilding &&  userID != self.loggedInUser &&  myBuilding != "N/A" {
                    
                    if snapshot["notifID"] != nil {
                        
                        let userNotifID = snapshot["notifID"] as? String
                        self.myBuildingMates.append(userNotifID!)
                        print(self.myBuildingMates)
                        
                    }
                }*/
                
                let userLongitude = snapshot["longitude"] as? CLLocationDegrees
                let userLatitude = snapshot["latitude"] as? CLLocationDegrees
                let userLocation = CLLocation(latitude: userLatitude!, longitude: userLongitude!)
                let distanceInMeters = myLocation!.distance(from: userLocation)
                let distanceMiles = distanceInMeters/1609.344897
                let distanceMilesFloat = Float(distanceMiles)
                
                if distanceMilesFloat < 1.00 && userID != self.loggedInUser {
                    
                    if snapshot["notifID"] != nil {
                        
                        let userNotifID = snapshot["notifID"] as? String
                        self.myBuildingMates.append(userNotifID!)
                        print(self.myBuildingMates)
                        
                    }
                    
                }
                
                let deadlineTime = DispatchTime.now() + .seconds(1)
                 
                 DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                
                if !(self.isRun) && ((self.myBuildingMates.count < 5) || myBuilding == "N/A") {
                    
                    self.runTextLabel.text = "Visible to neighbors within \(String(format: "%.2f", myRadius!)) mi"
                    self.visibleTo = "NA"
                
                }
                }
            }
            /*
            let userLatitude = snapshot["latitude"] as? CLLocationDegrees
            let userLongitude = snapshot["longitude"] as? CLLocationDegrees
            
            let userLocation = CLLocation(latitude: userLatitude!, longitude: userLongitude!)
            let distanceInMeters = myLocation!.distance(from: userLocation)
            let distanceMiles = distanceInMeters/1609.344897
            let distanceMilesFloat = Float(distanceMiles)
            
            if distanceMilesFloat < 0.20 && userID != self.loggedInUser {
                
                if snapshot["notifID"] != nil {
                    
                    let userNotifID = snapshot["notifID"] as? String
                    self.myBuildingMates.append(userNotifID!)
                    print(self.myBuildingMates)
                    
                }
                
            }*/
            
 
        }
    }

    @IBAction func didTapDone(_ sender: UIBarButtonItem) {
        
        hideKeyboard()
        
    }
    
    func hideKeyboard() {
        
        self.view.endEditing(true)
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    func checkLocationOnRequest()  {
        //check if location there at matches home
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = self.locationManager.location?.coordinate{
            
            self.userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            self.userLatitude = (self.userLocation?.coordinate.latitude)!
            self.userLongitude = (self.userLocation?.coordinate.longitude)!
            
        }
    }
    
 /*   func goToExplanation(_ gesture: UITapGestureRecognizer) {
        self.questionToTap.isHidden = true
        self.performSegue(withIdentifier: "requestToExplanation", sender: nil)
    }*/
    
    
    @IBAction func didToGoToExp(_ sender: Any) {
        
        self.questionButton.isHidden = true
        self.performSegue(withIdentifier: "requestToExplanation", sender: nil)
        
    }
    
    func makeAlert(title: String, message: String)  {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            //do nothing
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func didTapCoverBack(_ sender: UIButton) {
        
        if isRun{
            self.performSegue(withIdentifier: "requestToRuns", sender: nil)
        } else {
            self.performSegue(withIdentifier: "requestToShoppingList", sender: nil)
        }
        
    }
    
    /*
    @IBAction func didTapLargeBack(_ sender: UIButton) {
        if isRun{
            self.performSegue(withIdentifier: "requestToRuns", sender: nil)
        } else {
            self.performSegue(withIdentifier: "requestToShoppingList", sender: nil)
        }

        
    }*/
    @IBAction func didTapBack(_ sender: UIButton) {
        
        if isRun{
            self.performSegue(withIdentifier: "requestToRuns", sender: nil)
        } else {
            self.performSegue(withIdentifier: "requestToShoppingList", sender: nil)
        }
    }
    
    func selectWhoSees(_ gesture: UITapGestureRecognizer) {
      
        if !isRun {
        if myBuilding != "N/A" {
        
        let myActionSheet = UIAlertController(title:"Request Visibility",message:"Select who you would like to see your request",preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let deliveryRadiusView = UIAlertAction(title: "Neighbors within \(String(format: "%.2f", myRadius!)) mi", style: UIAlertActionStyle.default) { (action) in
           //save choice to request
            self.runTextLabel.text = "Visible to neighbors within \(String(format: "%.2f", myRadius!)) mi"
            self.visibleTo = "NA"
        }
        
        let myAptView = UIAlertAction(title: "Only neighbors in \(myBuilding!)", style: UIAlertActionStyle.default) { (action) in
           //save choice to request
            self.runTextLabel.text = "Visible to neighbors in \(myBuilding!)"
            self.visibleTo = myBuilding!
        }

        myActionSheet.addAction(deliveryRadiusView)
        myActionSheet.addAction(myAptView)
        
        self.present(myActionSheet, animated: true, completion: nil)
        }
        }
    }
    
    func notifAlert(title: String, message: String)  {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
}

