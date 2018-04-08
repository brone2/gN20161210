//
//  postRunView.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 6/14/17.
//  Copyright © 2017 Neil Bronfin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import CoreLocation
import OneSignal

class postRunView: UIViewController, UITextViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var runLocationTextField: UITextField!
    @IBOutlet var hourTextfield: UITextField!
    @IBOutlet var minuteTextfield: UITextField!
    @IBOutlet var PMButtonText: UIButton!
    @IBOutlet var notesField: UITextView!
    
    var locationManager = CLLocationManager()
    var userLocation: CLLocation?
    var userLatitude: CLLocationDegrees = 0.10000
    var userLongitude: CLLocationDegrees = 0.10000
    
    var enteredPhoneNumber:String?
    
    @IBOutlet var toolbarBottomConstraint: NSLayoutConstraint!
    @IBOutlet var completeToolBar: UIToolbar!
    @IBOutlet var doneToolBarButton: UIBarButtonItem!
    var toolbarBottomConstraintInitialValue:CGFloat?
    
    var databaseRef = FIRDatabase.database().reference()
    var storageRef = FIRStorage.storage().reference()
    var timeRun: String?
    var myBuildingMates = [String]()
    var pplNearMe = [String]()
    var buildingNamePath:String?
    var buildingNamePathValue:String?
    
    //Move up cause of damn ipad
    @IBOutlet var backButton: customButton!
    @IBOutlet var postButton: customButton!
    
    @IBOutlet var grayView: UIView!
    var descriptionText: String?
    
    override func viewDidAppear(_ animated: Bool) {
        
        if isVerySmallScreen {
            
            
            self.backButton.frame = CGRect(x: 14, y: 354, width: 125, height: 33)
            self.postButton.frame = CGRect(x: 167, y: 354, width: 125, height: 33)
            
        }
        
    self.myBuildingMates = []
    self.pplNearMe = []
        
    self.databaseRef.child("users").observe(.childAdded) { (snapshot: FIRDataSnapshot) in
    
    let userID = snapshot.key
    
    let snapshot = snapshot.value as! NSDictionary
    
    if let userBuilding = snapshot["buildingName"] as? String {
    
   if userBuilding == myBuilding &&  userID != globalLoggedInUserId &&  myBuilding != "N/A" {
    
    if snapshot["notifID"] != nil {
    
    let userNotifID = snapshot["notifID"] as? String
    self.myBuildingMates.append(userNotifID!)
    
    }
    }
        
        
        let userLongitude = snapshot["longitude"] as? CLLocationDegrees
        let userLatitude = snapshot["latitude"] as? CLLocationDegrees
        let userLocation = CLLocation(latitude: userLatitude!, longitude: userLongitude!)
        let distanceInMeters = myLocation!.distance(from: userLocation)
        let distanceMiles = distanceInMeters/1609.344897
        let distanceMilesFloat = Float(distanceMiles)
        
        if distanceMilesFloat < 1.00 && userID != globalLoggedInUserId {
            
            if snapshot["notifID"] != nil {

                let userNotifID = snapshot["notifID"] as? String
                self.pplNearMe.append(userNotifID!)
                
            }
            
        }
        
        }
    }
}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.runLocationTextField.autocorrectionType = .no
        self.notesField.autocorrectionType = .no
        
        self.grayView.layer.cornerRadius = 5
        self.grayView.layer.masksToBounds = true
        
        enableKeyboardHideOnTap()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        
        self.toolbarBottomConstraintInitialValue = toolbarBottomConstraint.constant
        self.completeToolBar.isHidden = true
    
        self.descriptionText = "I will be going to Trader Joe's around 12:30 and should be back by 2. Will meet you in the lobby of dardick dorm for pickup."
        
        notesField.text = self.descriptionText
        notesField.textColor = UIColor.lightGray
        notesField.layer.borderWidth = 1
        notesField.layer.borderColor = UIColor.black.cgColor
        
    }

    
    @IBAction func didTapPostRun(_ sender: Any) {
        if myCellNumber == "0"{
            
            var phoneNumberTextField: UITextField?
            
            let alertController = UIAlertController(
                title: "Please Add Phone Number",
                message: "Phone# are not publicly shown - it is only available when needed to pay through Venmo",
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
                self.databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("cellPhoneNumber").setValue(self.enteredPhoneNumber)
                
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
        
        else
        {
        if self.hourTextfield.text! == "" || self.runLocationTextField.text! == ""
         || self.notesField.text! == "I will be going to Trader Joe's around 12:30 and should be back by 2. Will meet you in the lobby of dardick dorm for pickup."
        {
            
            self.makeAlertNoDismiss(title: "Missing information", message: "Please fill in all fields")
           
            /*if self.runLocationTextField.text! == "I will be going to Trader Joe's around 12:30 and should be back by 2. Will meet you in the lobby of dardick dorm for pickup." {
                self.makeAlertNoDismiss(title: "Missing information", message: "Please provide a value for \"Detailed Information\"")
//                self.dismiss(animated: true, completion: nil)
            } else if self.hourTextfield.text! == "" {
                self.makeAlertNoDismiss(title: "Missing information", message: "Please enter what time you are making the run")
            } else if self.hourTextfield.text! == "" {
                self.makeAlertNoDismiss(title: "Missing information", message: "Please enter where you are going to make a run")
            }*/
            
        } else {
         //Here add function to check location
            self.locationCheck()
    }
    }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //
        
        if segue.identifier == "runEnterPhoneSegue" {
            
            let secondViewController = segue.destination as! submitPhoneNumberView
            secondViewController.runPhone =  true
        }
        
    }

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if(notesField.textColor == UIColor.lightGray){
            self.notesField.text = ""
            self.notesField.textColor = UIColor.black
        }
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(postRunView.keyBoardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postRunView.keyBoardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(postRunView.hideKeyboard))
        self.view.addGestureRecognizer(tap)
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // Workaround for the jumping text bug.
        textField.resignFirstResponder()
        textField.layoutIfNeeded()
        
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
    func hideKeyboard() {
        
        self.view.endEditing(true)
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func didTapDone(_ sender: Any) {
        
        hideKeyboard()
        
    }
    
    @IBAction func didTapPMButton(_ sender: UIButton) {
        
    if sender.titleLabel?.text == "PM" {
        
        self.PMButtonText.setTitle("AM", for: [])
        
    } else {
        
        self.PMButtonText.setTitle("PM", for: [])
        
    }
    }
    
    
    func makeAlert(title: String, message: String)  {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
          
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func makeAlertNoDismiss(title: String, message: String)  {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = self.locationManager.location?.coordinate{
            
            self.userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            self.userLatitude = (self.userLocation?.coordinate.latitude)!
            self.userLongitude = (self.userLocation?.coordinate.longitude)!
            print(self.userLatitude)
            
        }
    }
    
    
//Check if run is being posted from a location different from that registered to user
func locationCheck() {
        
        let requestLocation = CLLocation(latitude: self.userLatitude, longitude: self.userLongitude)
        let distanceInMeters = myLocation?.distance(from: requestLocation)
        let distanceInMetersFloat = Float(distanceInMeters!)
        print(distanceInMetersFloat)
    print(requestLocation)
        
  if distanceInMetersFloat > 7750 {
            
            let alertPurchaseLocation = UIAlertController(title: "Reset Dorm Location?", message: "You are posting this run from a new location. Would you like to reset your dorm location to your current location?", preferredStyle: UIAlertControllerStyle.alert)
            
            alertPurchaseLocation.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                
                self.uploadRun()
                
            }))
            
            alertPurchaseLocation.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                
                myLocation = CLLocation(latitude: self.userLatitude, longitude: self.userLongitude)
                
                let childUpdates = ["/users/\(globalLoggedInUserId!)/longitude":self.userLongitude, "/users/\(globalLoggedInUserId!)/latitude":self.userLatitude] as [String : Any]
                
                //Update
                self.databaseRef.updateChildValues(childUpdates)
                
                let alertLocationSet = UIAlertController(title: "Location Set", message: "Your location has been reset to your current location", preferredStyle: UIAlertControllerStyle.alert)
                
                alertLocationSet.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.uploadRun()
                }))
                
                self.present(alertLocationSet, animated: true, completion: nil)
                
            }))
            self.present(alertPurchaseLocation, animated: true, completion: nil)
            
        } else { //location is where expected
    
            self.uploadRun()
    
        }
        
    }
    
    
    func uploadRun()  {
        self.timeRun = self.hourTextfield.text! as String + ":" + self.minuteTextfield.text! as String + " " + self.PMButtonText.currentTitle!
        
        let key = self.databaseRef.child("runs").childByAutoId().key
        
        let timeRunPath = "/runs/\(key)/timeRun"
        let timeRunValue = self.timeRun
        
        let runToPath = "/runs/\(key)/runTo"
        let runToValue = self.runLocationTextField.text! as String
        
        let descriptionPath = "/runs/\(key)/notesField"
        let descriptionLabelValue = self.notesField.text! as String
        
        let longitudePath = "/runs/\(key)/runnerLongitude"
        //let longitudeValue = self.requesterLongitude! as CLLocationDegrees
        let longitudeValue = (myLocation?.coordinate.longitude)! as CLLocationDegrees
        
        //hacky way to get post run users with less than 5 ppl in building to have request seen by everyone
        print((self.myBuildingMates.count))
        if (self.myBuildingMates.count) < 40 {
            self.buildingNamePath = "/runs/\(key)/buildingName"
            self.buildingNamePathValue = "NA"
        } else {
            
            self.buildingNamePath = "/runs/\(key)/buildingName"
            self.buildingNamePathValue = myBuilding!
            
        }
        
        
        let latitudePath = "/runs/\(key)/runnerLatitude"
        //let latitudeValue = self.requesterLatitude! as CLLocationDegrees
        let latitudeValue = (myLocation?.coordinate.latitude)! as CLLocationDegrees
        
        let runnerNamePath = "/runs/\(key)/runnerName"
        let runnerNameValue = loggedInUserName!
        
        let requestCountPath = "/runs/\(key)/requestCount"
        let requestCountValue = 0
        
        let isCompletePath = "/runs/\(key)/isComplete"
        let isCompleteValue = false
        
        let runKeyPath = "/runs/\(key)/runKey"
        let keyValue = key as String
        
        let runnerUIDPath = "/runs/\(key)/runnerUID"
        let runnerUIDValue = globalLoggedInUserId
        print(globalLoggedInUserId)
        
        let runnerCellPath = "/runs/\(key)/runnerCell"
        let runnerCellValue = myCellNumber as String
        
        let runnerNotifPath = "/runs/\(key)/runnerNotif"
        let runnerNotifValue = myNotif
        
        let profilePicReferencePath = "/runs/\(key)/profilePicReference"
        let profilePicReferenceValue = myProfilePicRef
        
        let childUpdatesRun:Dictionary<String, Any> = [timeRunPath: timeRunValue, runToPath: runToValue,descriptionPath: descriptionLabelValue, self.buildingNamePath!: self.buildingNamePathValue!,latitudePath: latitudeValue, longitudePath: longitudeValue,runnerNamePath: runnerNameValue,isCompletePath: isCompleteValue, runKeyPath: keyValue, runnerUIDPath: runnerUIDValue,runnerCellPath: runnerCellValue, profilePicReferencePath: profilePicReferenceValue, runnerNotifPath: runnerNotifValue,requestCountPath: requestCountValue]
        
        
        self.databaseRef.updateChildValues(childUpdatesRun)
        
        
        if let nameToSend = userFullName {
            
            OneSignal.postNotification(["contents": ["en": "\(nameToSend) posted a run!"], "include_player_ids": [neilNotif],"ios_sound": "nil", "data": ["type": "run"]])
            
        }
        
         if self.myBuildingMates.count > 9 {
            
             for mateID in 0..<self.pplNearMe.count {
            
            OneSignal.postNotification(["contents": ["en": "\(myName!) is going on a run to \(self.runLocationTextField.text!)!"], "include_player_ids": [self.myBuildingMates[mateID]],"ios_sound": "nil", "data": ["type": "run"]])
            
            }
        
         } else {
        
        
        for mateID in 0..<self.pplNearMe.count {
            
            OneSignal.postNotification(["contents": ["en": "\(myName!) is going on a run to \(self.runLocationTextField.text!)!"], "include_player_ids": [self.pplNearMe[mateID]],"ios_sound": "nil", "data": ["type": "run"]])
            
            }
        }
        
        
        self.makeAlert(title: "Run Posted", message: "Thank you for posting this run! When you are finished with your run, please tap \"Run Complete\" and this run will no longer be available for request")
    }
    
    
    
    
    

}
