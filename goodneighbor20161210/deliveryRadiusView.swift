//
//  deliveryRadiusView.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/11/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import CoreLocation
import OneSignal

class deliveryRadiusView: UIViewController {

    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var slider: UISlider!
    @IBOutlet var feetLabel: UILabel!
    @IBOutlet var grayView: UIView!
    
    var loggedInUserId:String!
    var loggedInUserData: AnyObject?
    
    var databaseRef = FIRDatabase.database().reference()
    var deliveryRadius:Float = 0.499789
    
    var activityIndicator = UIActivityIndicatorView()
    
    @IBAction func didTapContinue(_ sender: Any) {
        
        OneSignal.postNotification(["contents": ["en": "\(userFullName!) has made an account!"], "include_player_ids": [neilNotif],"ios_sound": "nil"])
        

        self.deliveryRadius += 0.00043
        
        print(self.deliveryRadius)
        
    self.databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("deliveryRadius").setValue(self.deliveryRadius)
        
        self.loggedInUserId = FIRAuth.auth()?.currentUser?.uid
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
        
        
        //get user name
        self.databaseRef.child("users").child(self.loggedInUserId!).observeSingleEvent(of: .value) { (snapshot:FIRDataSnapshot) in
            
            self.loggedInUserData = snapshot.value as? NSDictionary
            
            loggedInUserName = self.loggedInUserData?["name"] as! String
            myName = self.loggedInUserData?["name"] as! String
            myProfilePicRef = self.loggedInUserData?["profilePicReference"] as! String
            myCellNumber = self.loggedInUserData?["cellPhoneNumber"] as! String
            currentTokenCount = self.loggedInUserData?["tokenCount"] as! Int
            globalLoggedInUserId = FIRAuth.auth()?.currentUser?.uid
            
            if let myLatitude = self.loggedInUserData?["latitude"] as? CLLocationDegrees{
                if let myLongitude = self.loggedInUserData?["longitude"] as? CLLocationDegrees{
                    myLocation = CLLocation(latitude: myLatitude, longitude: myLongitude)
                }
            }
            
            myRadius  = self.loggedInUserData?["deliveryRadius"] as? Float
        
            self.activityIndicator.stopAnimating()
            
            if isVerySmallScreen == true || isSmallScreen == true || isX == true {
                self.performSegue(withIdentifier: "radToRun", sender: nil)
            } else {
                
            self.performSegue(withIdentifier: "goToExpIntro", sender: nil)
                
            }
        }
        })
    }
    
    @IBAction func didMoveSlider(_ sender: UISlider) {
        
        self.deliveryRadius = Float(sender.value)
        let stringDeliveryRadius = String(format: "%.2f", self.deliveryRadius)
        let feetDeliveryRadius = self.deliveryRadius * 5280.03932029
        let feetStringDeliveryRadius = String(format: "%.0f", feetDeliveryRadius)
        
        distanceLabel.text = "\(stringDeliveryRadius)"
        print(self.deliveryRadius)
        feetLabel.text = "(\(feetStringDeliveryRadius) ft)"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.grayView.layer.cornerRadius = 3
        self.grayView.layer.masksToBounds = true

        slider.minimumValue = 0.010000
        slider.maximumValue = 1.0000
        self.deliveryRadius = 0.499789
        
        //Save pushNotification ID
        OneSignal.idsAvailable({(_ userId, _ pushToken) in
            print("UserId:\(userId)")
                print((FIRAuth.auth()?.currentUser?.uid)!)
                let myNotifID = userId
                self.databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("notifID").setValue(myNotifID!)
                myNotif = myNotifID!
        })
        
       //Send push notif to me!!!
        self.databaseRef.child("users").child("ZGioV7tbbRT9oEYhQbOKRtRTXbl2").observeSingleEvent(of: .value, with: { snapshot in
            
            let snapshot = snapshot.value as? NSDictionary
            
            if let tempNeilNotif = snapshot?["notifID"] as? String{
                neilNotif = tempNeilNotif  
            }
            
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
