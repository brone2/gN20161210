//
//  initialViewController.swift
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
import FBSDKLoginKit
import CoreLocation
import OneSignal
import FBSDKLoginKit

var myLocation: CLLocation?
var myRadius: Float?
var autoLoginHelp: Int = 0

var isSmallScreen = false
var isVerySmallScreen = false
var isLargeScreen = false

var userFullName: String?
var userReferralCode: String?
var referralRedeemed:Bool = false
var neilNotif: String = "hello"
var myNotif: String = "yo"
var myName: String?

var myBuilding:String?

class initialViewController: UIViewController {
    
    var loggedInUserData: AnyObject?
    var databaseRef:FIRDatabaseReference!
    var url: String?
    var proPicURL: String?
    var proPic = 0
    var time = 0
    var timer = Timer()
    var loggedInUserId: String?
    var isPromotion = false
    
    override var prefersStatusBarHidden: Bool {
        return true
    } 

    override func viewDidLoad() {
        super.viewDidLoad()

//try! FIRAuth.auth()?.signOut()
  
       userReferralCode = "Not yet entered"
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        let screenHeight = screenSize.height
        
        if screenHeight < 490.0     {
            
            isVerySmallScreen = true
            
        }
        
        if screenHeight < 570.0 && screenHeight > 500 {
            
            isSmallScreen = true
            
        }
        
        if screenHeight > 700 {
            
            isLargeScreen = true
            
        }

        self.databaseRef = FIRDatabase.database().reference()

        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(initialViewController.startTimer), userInfo: nil, repeats: true)
    }
    
    func startTimer() {
        time += 1
        if time == 2 {
            //timer.invalidate()
            self.checkUser()
        }
        
        if time == 5 {
            print("gotto5")
            timer.invalidate()
            self.performSegue(withIdentifier: "goToFbookLogin", sender: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func checkUser()  {
        
            FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
                
                
                if autoLoginHelp == 0 {
                
                if user != nil {
                    
                        self.timer.invalidate()
                    
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    
                        self.loggedInUserId = FIRAuth.auth()?.currentUser?.uid
                    
                    
                        globalLoggedInUserId = FIRAuth.auth()?.currentUser?.uid
                        
                        //get user name
                        self.databaseRef.child("users").child(self.loggedInUserId!).observeSingleEvent(of: .value) { (snapshot:FIRDataSnapshot) in
                            
                            self.loggedInUserData = snapshot.value as? NSDictionary
                            
                        //If account is registered but for some reason not completed
                        //IF PROBLEM HAPPENS AGAIN UNCOMMENT BELOW
                            if self.loggedInUserData == nil {
                                try! FIRAuth.auth()?.signOut()
                                self.performSegue(withIdentifier: "goToFbookLogin", sender: nil)
                            }
                            
                            else {
                            
                            myBuilding = self.loggedInUserData?["buildingName"] as? String
                            
                            loggedInUserName = self.loggedInUserData?["name"] as! String
                                
                            //Save pushNotification ID if needed
                            OneSignal.idsAvailable({(_ userId, _ pushToken) in
                                print("UserId:\(userId)")
                                
                                if self.loggedInUserData?["notifID"] as? String != nil  {
                                    myNotif = userId!
                                    
                                    if myNotif != self.loggedInUserData?["notifID"] as!  String{
                                        self.databaseRef.child("users").child(self.loggedInUserId!).child("notifID").setValue(myNotif)
                                    }
                                } else {
                                print(self.loggedInUserId!)
                                let myNotifID = userId
                                self.databaseRef.child("users").child(self.loggedInUserId!).child("notifID").setValue(myNotifID!)
                                    myNotif = myNotifID!
                                    
                                }
                            })
                            
                            if self.loggedInUserData?["referralCode"] as?  String != nil {
                               let referOptional = self.loggedInUserData?["referralCode"] as! String
                                userReferralCode = referOptional
                            }
                            if let _ = self.loggedInUserData?["fullName"] as? String {
                                
                                userFullName = self.loggedInUserData?["fullName"] as? String
                                
                            } else {
                                
                                userFullName = loggedInUserName
                                
                            }
                            
                            if let _ = self.loggedInUserData?["referralRedeemed"] as? Bool {
                                
                                referralRedeemed = true
                                
                            }
                            
                            myProfilePicRef = self.loggedInUserData?["profilePicReference"] as! String
                            myCellNumber = self.loggedInUserData?["cellPhoneNumber"] as! String
                            currentTokenCount = self.loggedInUserData?["tokenCount"] as! Int
                            myName = self.loggedInUserData?["name"] as! String
                            
                            if let myLatitude = self.loggedInUserData?["latitude"] as? CLLocationDegrees{
                                if let myLongitude = self.loggedInUserData?["longitude"] as? CLLocationDegrees{
                                    myLocation = CLLocation(latitude: myLatitude, longitude: myLongitude)
                                }
                            }
                            
                            myRadius  = self.loggedInUserData?["deliveryRadius"] as? Float
                            FIRAnalytics.logEvent(withName: "openApp", parameters: nil)
                            
                            //if facebook update facebook profile pic in case necessary
                                if let myFullName = userFullName {
                                    
                                if myFullName != myName{
                                    if let image = myProfilePicRef {
                                        
                                        let data = try? Data(contentsOf: URL(string: image)!)
                                        
                                        if data != nil{
                                            
                                        } else { //have a profile picture problem
                                            self.performSegue(withIdentifier: "goToChangePic", sender: nil)
                                    }
                                
                                }
                                }
                                }
                                
                            //Store me push notification info
                            self.databaseRef.child("users").child("ZGioV7tbbRT9oEYhQbOKRtRTXbl2").observeSingleEvent(of: .value, with: { snapshot in
                                    let snapshot = snapshot.value as? NSDictionary
                                    if let tempNeilNotif = snapshot?["notifID"] as? String{
                                        neilNotif = tempNeilNotif
                                    }
                            print(neilNotif)
                                
                            })
                            
                            self.databaseRef.child("promoteShare").observeSingleEvent(of: .value) { (snapshot:FIRDataSnapshot) in
                                
                                let snapshot = snapshot.value as? NSDictionary
                                
                                self.isPromotion = snapshot?["isTrue"] as! Bool
                                
                                if self.isPromotion && isVerySmallScreen == false  {
                                    
                                   self.performSegue(withIdentifier: "goToPromoPage", sender: nil)
                                    //self.performSegue(withIdentifier: "chatView", sender: nil)
                                  
                                    
                                } else {
                                
                                //For now set default page to request page
                                let homeViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "shoppingList")
                                    
                                //let homeViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "requestItem")
                                
                                self.present(homeViewController, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                } else {
                    
                self.performSegue(withIdentifier: "goToFbookLogin", sender: nil)
                }
                }
            })
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
