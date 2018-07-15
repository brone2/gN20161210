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

class postRunView: UIViewController, UITextViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
//20 people to a dorm to be dorm only
    
    @IBOutlet var picker: UIPickerView!
    
    
    @IBOutlet var runLocationTextField: UITextField!
    @IBOutlet var hourTextfield: UITextField!
    @IBOutlet var minuteTextfield: UITextField!
    @IBOutlet var PMButtonText: UIButton!
    @IBOutlet var notesField: UITextView!
    
    var firstTouchTime:Bool = true
    
    var locationManager = CLLocationManager()
    var userLocation: CLLocation?
    var userLatitude: CLLocationDegrees = 0.10000
    var userLongitude: CLLocationDegrees = 0.10000
    var tokensOffered = 2
    
    var isDormOnly = false
    
    var saveKey: String?
    
    var countriesArray: [String] = ["1","2","3","4","5","6","7","8","9","10","11","12"]
    var stateNumbersArray: [String] =  ["00","15","30","45"]
    var stateArray: [String] =  ["AM","PM"]
    
    @IBOutlet var oneTokenImage: UIImageView!
    @IBOutlet var twoTokenImage: UIImageView!
    
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
    
        /*
    if userBuilding == myBuilding &&  userID != globalLoggedInUserId &&  myBuilding != "N/A" {
    
      if snapshot["notifID"] != nil {
    
            let userNotifID = snapshot["notifID"] as? String
            self.myBuildingMates.append(userNotifID!)
        
            //  if (self.myBuildingMates.count) > 20 {
         if (self.myBuildingMates.count) > 20 {
         
                self.isDormOnly = true
        }
    
        }
    }
         */
        
        
        let userLongitude = snapshot["longitude"] as? CLLocationDegrees
        let userLatitude = snapshot["latitude"] as? CLLocationDegrees
        let userLocation = CLLocation(latitude: userLatitude!, longitude: userLongitude!)
        let distanceInMeters = myLocation!.distance(from: userLocation)
        let distanceMiles = distanceInMeters/1609.344897
        let distanceMilesFloat = Float(distanceMiles)
        
        if distanceMilesFloat < 1.00 && userID != globalLoggedInUserId { //
            
            if snapshot["notifID"] != nil {

                let userNotifID = snapshot["notifID"] as? String
                self.pplNearMe.append(userNotifID!)
                
         }
            
            // Populate same building name AND within one mile
            if userBuilding == myBuilding &&  userID != globalLoggedInUserId &&  myBuilding != "N/A" {
                
                if snapshot["notifID"] != nil {
                    
                    let userNotifID = snapshot["notifID"] as? String
                    self.myBuildingMates.append(userNotifID!)
                    
                    //  if (self.myBuildingMates.count) > 20 {
                    if (self.myBuildingMates.count) > 20 {
                        
                        self.isDormOnly = true
                        
                    }
                    
                }
            }
            
       } //if distanceMilesFloat < 1.00 && userID != globalLoggedInUserId {
    }
  }
}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //Picker stuff
        self.picker.isHidden = true
        
        //pickerConstraint
        
        if (!isLargeScreen && !isX) {
            
            for constraint in picker.constraints {
                if constraint.identifier == "pickerHeightConstraint" {
                    constraint.constant = 160
                }
                
            }
            
            
        }
        
        
        
        
        
        let tapTerm:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapTextView(_:)))
        let tapTerm2:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapTextView(_:)))
        hourTextfield.addGestureRecognizer(tapTerm)
        minuteTextfield.addGestureRecognizer(tapTerm2)
        
        
        picker.delegate = self
        picker.dataSource = self
        
        picker.selectRow(2, inComponent: 0, animated: true)
        picker.selectRow(2, inComponent: 1, animated: true)
        picker.selectRow(1, inComponent: 2, animated: true)
        
        
        //end picker stuff
        
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
        
        let oneTokenImageTap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapOneToken(_:)))
        oneTokenImage.addGestureRecognizer(oneTokenImageTap)
        
        let twoTokenImageTap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapTwoToken(_:)))
        twoTokenImage.addGestureRecognizer(twoTokenImageTap)
        
        notesField.text = self.descriptionText
        notesField.textColor = UIColor.lightGray
        notesField.layer.borderWidth = 1
        notesField.layer.borderColor = UIColor.black.cgColor
        
    }

    
    @IBAction func didTapPostRun(_ sender: Any) {
        if myCellNumber == "zzzz"{
            // Moved this to a later function to have it post automatically and then update phone# later
        }
        
        else
        {
            
            if self.notesField.text! == "I will be going to Trader Joe's around 12:30 and should be back by 2. Will meet you in the lobby of dardick dorm for pickup." {
                
                self.notesField.text = "Let me know if you need anything!"
                
            }
            
        if self.hourTextfield.text! == "" || self.runLocationTextField.text! == ""
        {
            
            self.makeAlertNoDismiss(title: "Missing information", message: "Please fill in all fields")
           
            /*if self.runLocationTextField.text! == "I will be going to Trader Joe's around 12:30 and should be back by 2. Will meet you in the lobby of dardick dorm for pickup." {
                self.makeAlertNoDismiss(title: "Missing information", message: "Please provide a value for \"Detailed Information\"")
                self.dismiss(animated: true, completion: nil)
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
        self.picker.isHidden = true
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
            
            let alertPurchaseLocation = UIAlertController(title: "Reset Home Location?", message: "You are posting this run from a new location. Would you like to reset your home location to your current location?", preferredStyle: UIAlertControllerStyle.alert)
            
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
        self.saveKey = key
        
        let timeRunPath = "/runs/\(key)/timeRun"
        let timeRunValue = self.timeRun
        
        let runToPath = "/runs/\(key)/runTo"
        let runToValue = self.runLocationTextField.text! as String
        
        let descriptionPath = "/runs/\(key)/notesField"
        let descriptionLabelValue = self.notesField.text! as String
        
        let tokenPath = "/runs/\(key)/tokensOffered"
        let tokensLabelValue = self.tokensOffered
        print(self.tokensOffered)
        
        let longitudePath = "/runs/\(key)/runnerLongitude"
        //let longitudeValue = self.requesterLongitude! as CLLocationDegrees
        let longitudeValue = (myLocation?.coordinate.longitude)! as CLLocationDegrees
        
        //hacky way to get post run users with less than 5 ppl in building to have request seen by everyone
        /*
        print((self.myBuildingMates.count))
        if (self.myBuildingMates.count) < 20 {
            self.buildingNamePath = "/runs/\(key)/buildingName"
            self.buildingNamePathValue = "NA"
        } else {
            
            self.buildingNamePath = "/runs/\(key)/buildingName"
            self.buildingNamePathValue = myBuilding!
            
        }
        */
        
        
        
        self.buildingNamePath = "/runs/\(key)/buildingName"
        self.buildingNamePathValue = myBuilding!
        
        let dormLockPath = "/runs/\(key)/isDormOnly"
        let dormLockValue = self.isDormOnly
        
        
        
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
        
        let childUpdatesRun:Dictionary<String, Any> = [timeRunPath: timeRunValue, runToPath: runToValue,descriptionPath: descriptionLabelValue, self.buildingNamePath!: self.buildingNamePathValue!,latitudePath: latitudeValue, longitudePath: longitudeValue,runnerNamePath: runnerNameValue,isCompletePath: isCompleteValue, runKeyPath: keyValue, runnerUIDPath: runnerUIDValue,runnerCellPath: runnerCellValue, profilePicReferencePath: profilePicReferenceValue, runnerNotifPath: runnerNotifValue,requestCountPath: requestCountValue,tokenPath: tokensLabelValue,dormLockPath: dormLockValue
        ]
            
        
        print(childUpdatesRun)
        self.databaseRef.updateChildValues(childUpdatesRun)
        
// Notification
        
        if let nameToSend = userFullName {
            
            OneSignal.postNotification(["contents": ["en": "\(nameToSend) posted a run!"], "include_player_ids": [neilNotif],"ios_sound": "nil", "data": ["type": "run"]])
            
        }
        
         if self.myBuildingMates.count > 20 {
            
             for mateID in 0..<self.myBuildingMates.count {
            
            OneSignal.postNotification(["contents": ["en": "\(myName!) is going on a run to \(self.runLocationTextField.text!)!"], "include_player_ids": [self.myBuildingMates[mateID]],"ios_sound": "nil", "data": ["type": "run"]])
            
            }
        
         } else {
        
        
        for mateID in 0..<self.pplNearMe.count {
            
            OneSignal.postNotification(["contents": ["en": "\(myName!) is going on a run to \(self.runLocationTextField.text!)!"], "include_player_ids": [self.pplNearMe[mateID]],"ios_sound": "nil", "data": ["type": "run"]])
            
            }
        }
        
        //Add phone number and update the run with phone number if not yet given
        if myCellNumber == "0"{
            
          self.cellPhoneUpdate()
            
        } else {
        
          self.makeAlert(title: "Run Posted", message: "Thank you for posting this run! When you are finished with your run, please tap \"Run Complete\" and this run will no longer be available for request")
            
        }
    }
    
    
    func didTapOneToken(_ sender: UITapGestureRecognizer) {
        
        // $1 and $2 offer
        
        if self.tokensOffered == 2 {
            self.oneTokenImage.image = UIImage(named: "1DollBlue.png")
            self.twoTokenImage.image = UIImage(named: "2DollGray.png")
            self.tokensOffered = 1
        }
        
    }
    
    func didTapTwoToken(_ sender: UITapGestureRecognizer) {
        
        // $1 and $2 offer
        
        if self.tokensOffered == 1 {
            self.twoTokenImage.image = UIImage(named: "2DollBlue.png")
            self.oneTokenImage.image = UIImage(named: "1DollGray.png")
            self.tokensOffered = 2
        }
    
    
    }
    
    
    func cellPhoneUpdate() {
        
        
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
            self.databaseRef.child("runs").child(self.saveKey!).child("runnerCell").setValue(self.enteredPhoneNumber)
            
            myCellNumber = self.enteredPhoneNumber
            
             self.makeAlert(title: "Run Posted", message: "Thank you for posting this run! When you are finished with your run, please tap \"Run Complete\" and this run will no longer be available for request")
            
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
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return countriesArray.count
        } else if component == 1 {
            return stateNumbersArray.count
        } else {
            return stateArray.count
        }
    }
    
    //MARK:- UIPickerViewDelegates methods
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0 {
            return countriesArray[row]
        } else if component == 1 {
            return stateNumbersArray[row]
        } else {
            return stateArray[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let countrySelected = countriesArray[pickerView.selectedRow(inComponent: 0)]
        let stateNumberSelected = stateNumbersArray[pickerView.selectedRow(inComponent: 1)]
        let stateelected = stateArray[pickerView.selectedRow(inComponent: 2)]
        hourTextfield.text = "\(countrySelected)"
        minuteTextfield.text = "\(stateNumberSelected)"
        self.PMButtonText.setTitle("\(stateelected)", for: [])
        
    }
    

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.picker.isHidden = true
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
          self.picker.isHidden = true
    }
    
    @objc func tapTextView(_ sender:UITapGestureRecognizer) {
        self.picker.isHidden = false
        hideKeyboard()
        if firstTouchTime {
                self.hourTextfield.text = "3"
                self.minuteTextfield.text = "30"
            
        }
        
        self.firstTouchTime = false
        
    }
    
    

}
