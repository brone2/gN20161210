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

class postRunView: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet var runLocationTextField: UITextField!
    @IBOutlet var hourTextfield: UITextField!
    @IBOutlet var minuteTextfield: UITextField!
    @IBOutlet var PMButtonText: UIButton!
    @IBOutlet var notesField: UITextView!
    
    @IBOutlet var toolbarBottomConstraint: NSLayoutConstraint!
    @IBOutlet var completeToolBar: UIToolbar!
    @IBOutlet var doneToolBarButton: UIBarButtonItem!
    var toolbarBottomConstraintInitialValue:CGFloat?
    
    var databaseRef = FIRDatabase.database().reference()
    var storageRef = FIRStorage.storage().reference()
    var timeRun: String?
    var myBuildingMates = [String]()

    @IBOutlet var grayView: UIView!
    var descriptionText: String?
    
    override func viewDidAppear(_ animated: Bool) {
        
    self.databaseRef.child("users").observe(.childAdded) { (snapshot: FIRDataSnapshot) in
    
    let userID = snapshot.key
    
    let snapshot = snapshot.value as! NSDictionary
    
    if let userBuilding = snapshot["buildingName"] as? String {
    
    if userBuilding == myBuilding &&  userID != globalLoggedInUserId &&  myBuilding != "N/A" {
    
    if snapshot["notifID"] != nil {
    
    let userNotifID = snapshot["notifID"] as? String
    self.myBuildingMates.append(userNotifID!)
    print(self.myBuildingMates)
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
        self.toolbarBottomConstraintInitialValue = toolbarBottomConstraint.constant
        self.completeToolBar.isHidden = true
    
        self.descriptionText = "I will be going to Trader Joe's around 12:30 and should be back by 2. Will meet you in the lobby of dardick dorm for pickup."
        
        notesField.text = self.descriptionText
        notesField.textColor = UIColor.lightGray
        notesField.layer.borderWidth = 1
        notesField.layer.borderColor = UIColor.black.cgColor
        
    }

    
    @IBAction func didTapPostRun(_ sender: Any) {
        
        if self.hourTextfield.text! == "" || self.runLocationTextField.text! == "" || self.notesField.text! == "I will be going to Trader Joe's around 12:30 and should be back by 2. Will meet you in the lobby of dardick dorm for pickup." {
            
            if self.runLocationTextField.text! == "I will be going to Trader Joe's around 12:30 and should be back by 2. Will meet you in the lobby of dardick dorm for pickup." {
                self.makeAlert(title: "Missing information", message: "Please provide a value for \"Detailed Information\"")
            } else if self.hourTextfield.text! == "" {
                self.makeAlert(title: "Missing information", message: "Please enter what time you are making the run")
            } else if self.hourTextfield.text! == "" {
                self.makeAlert(title: "Missing information", message: "Please enter where you are going to make a run")
            }
            
        } else {
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
        
        let buildingNamePath = "/runs/\(key)/buildingName"
        let buildingNamePathValue = myBuilding!
        //let buildingNamePathValue = "hello"
        
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
        
        let runnerCellPath = "/runs/\(key)/runnerCell"
        let runnerCellValue = myCellNumber as String
        
        let runnerNotifPath = "/runs/\(key)/runnerNotif"
        let runnerNotifValue = myNotif
        
        let profilePicReferencePath = "/runs/\(key)/profilePicReference"
        let profilePicReferenceValue = myProfilePicRef
        
        let childUpdatesRun:Dictionary<String, Any> = [timeRunPath: timeRunValue, runToPath: runToValue,descriptionPath: descriptionLabelValue, buildingNamePath: buildingNamePathValue,latitudePath: latitudeValue, longitudePath: longitudeValue,runnerNamePath: runnerNameValue,isCompletePath: isCompleteValue, runKeyPath: keyValue, runnerUIDPath: runnerUIDValue,runnerCellPath: runnerCellValue, profilePicReferencePath: profilePicReferenceValue, runnerNotifPath: runnerNotifValue,requestCountPath: requestCountValue]
        
        
        self.databaseRef.updateChildValues(childUpdatesRun)
            
        OneSignal.postNotification(["contents": ["en": "\(userFullName!) posted a run!"], "include_player_ids": [neilNotif],"ios_sound": "nil"])
            
            for mateID in 0..<self.myBuildingMates.count {
                print(mateID)
                print("EEEEEE")
                print(self.myBuildingMates[mateID])
                
                /*let deadlineTime = DispatchTime.now() + .seconds(1)
                 
                 DispatchQueue.main.asyncAfter(deadline: deadlineTime) {*/
                
                print("\(self.myBuildingMates[mateID])!")
                OneSignal.postNotification(["contents": ["en": "\(myName!) is going on a run to \(self.runLocationTextField.text!)!"], "include_player_ids": [self.myBuildingMates[mateID]],"ios_sound": "nil"])
                
                
            }

        
        self.makeAlert(title: "Run Posted", message: "Thank you for posting this run! When you are finished with your run, please tap \"Run Complete\" and this run will no longer be available for request")
        
    }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
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

}
