//
//  couponMaintenanceView.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/29/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import OneSignal


class couponMaintenanceView: UIViewController {

    @IBOutlet var codeTextField: UITextField!
    @IBOutlet var uidLabel: UILabel!
    
    let databaseRef = FIRDatabase.database().reference()
    
    @IBOutlet var grayView: UIView!
    var couponText: String?
    var timeThreshold: Int?
    let threeHours: Int = 10800000
    var isVerified:Bool = false
    var isAlreadyUsed:Bool = false
    var myTokens:Int?
    var referralUid:String?
    var buildingUsersCount = 0
    var referralNotif:String?
    var plusOneReferral:Int?
    
    var myBuildingMates = [String]()
    var notifMates = [String]()
    
    var mitMates = [String]()
    var mitNotifID: String?
    
    override func viewDidAppear(_ animated: Bool) {
        let nowTime = (UInt64(NSDate().timeIntervalSince1970 * 1000.0))
        
       
    
        self.databaseRef.child("users").observe(.childAdded) { (snapshot3: FIRDataSnapshot) in
            
            let snapshot3 = snapshot3.value as! NSDictionary
            
            if let userName = snapshot3["name"] {
                
                if let city = snapshot3["city"] as? String {
                    
                    if city == "Los Angeles " {
                        print(userName)
                        
                        if let userNotifID = snapshot3["notifID"] as? String  {
                        
                      /*  self.notifMates.append(userNotifID)
                        print(self.notifMates)
                        print((self.notifMates.count))*/
                        }
                        
                        /*
                         if let notifID = snapshot3["notifID"] as? String {
                         let thisNotif = snapshot3["notifID"] as! String
                         OneSignal.postNotification(["headings" : ["en": "Get paid for being a Goodneighbor!"],
                         "contents" : ["en": "Update your app and begin earning $1-$2 per delivery!"],
                         "include_player_ids": [thisNotif],
                         "ios_sound": "nil"])*/
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
        
        
        
            self.myBuildingMates = ["d29acf14-ce6c-4d58-b1b8-2c28ac464e22"]
            
            //myBuildingMates - Store people to send to that are in your building and have an ID and are not you
            self.databaseRef.child("users").observe(.childAdded) { (snapshot: FIRDataSnapshot) in
                
                //Go ahead and save the fullName here
                
                let userID = snapshot.key
                
                let snapshot = snapshot.value as! NSDictionary
            print(userID)
            
             let userRecieve = snapshot["recieveCount"] as! Int
             let userDeliver = snapshot["deliveryCount"] as! Int
                
                if let userBuilding = snapshot["buildingName"] as? String {
                
                if let userState = snapshot["state"] as? String {
                 
                 if userBuilding != "N/A" &&  (userState == "CA " || userState == "IL " || userState == "OH " || userState == "NY ") && (userRecieve != 0 || userDeliver != 0)  {
                 
                 if snapshot["notifID"] != nil {
                 
                 let userNotifID = snapshot["notifID"] as? String
                 self.myBuildingMates.append(userNotifID!)
                 print(self.myBuildingMates)
                 print(self.myBuildingMates.count)
                 
            }
            }
            }
            }
            }
        
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.grayView.layer.cornerRadius = 3
        self.grayView.layer.masksToBounds = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapEnter(_ sender: UIButton) {
        
        let notificationType = UIApplication.shared.currentUserNotificationSettings!.types
        if notificationType.rawValue == 0 {
            
            
            self.notifAlert(title: "Please turn on notifications", message: "Please turn on notifications in order to redeem a coupon code")
            
        } else {
        
        
        
        self.buildingUsersCount = 0
        
        self.couponText = codeTextField.text
        // Count number of users in building
        if ((self.couponText)?.contains("#"))! {
            
            let textArray = (self.couponText)?.components(separatedBy: "#")
            let buildingName: String = String(textArray![1])!
           
            print(buildingName)
            self.databaseRef.child("users").observe(.childAdded) { (snapshot3: FIRDataSnapshot) in
                
                let snapshot3 = snapshot3.value as! NSDictionary
                
                if let userBuilding = snapshot3["buildingName"] as? String {
                    print(userBuilding)
                    if userBuilding == buildingName {
                        
                        self.buildingUsersCount += 1
                        self.uidLabel.text = String(self.buildingUsersCount)
                        
                    }
                    
                }
            }
            
            
        }
            
        if ((self.couponText)?.contains("#"))! {
            
            let textArray = (self.couponText)?.components(separatedBy: "#")
            let buildingName: String = String(textArray![1])!
            
            print(buildingName)
            self.databaseRef.child("users").observe(.childAdded) { (snapshot3: FIRDataSnapshot) in
                
                let snapshot3 = snapshot3.value as! NSDictionary
                
                if let userBuilding = snapshot3["buildingName"] as? String {
                    print(userBuilding)
                    if userBuilding == buildingName {
                        
                        self.buildingUsersCount += 1
                        self.uidLabel.text = String(self.buildingUsersCount)
                        
                    }
                    
                }
            }
            
            
        }
            
           else  if ((self.couponText)?.contains("&"))! { // find the name from notif id
                
                let textArray = (self.couponText)?.components(separatedBy: "&")
                let buildingName: String = String(textArray![1])!
                
                print(buildingName)
                self.databaseRef.child("users").observe(.childAdded) { (snapshot3: FIRDataSnapshot) in
                    
                    let snapshot3 = snapshot3.value as! NSDictionary
                    
                    if let userBuilding = snapshot3["notifID"] as? String {
                       
                        if userBuilding == buildingName {
                            
                            print(snapshot3["name"] as? String)
                            self.uidLabel.text = snapshot3["name"] as? String
                            
                        }
                        
                    }
                }
                
                
            }
            
            //Get referral count
        
        else if self.couponText == "referral" {
            
            
            self.databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).observeSingleEvent(of: .value, with: { snapshot7 in
                
                let snapshot = snapshot7.value as? NSDictionary
                let tempRef = snapshot?["referralCount"] as! Int
                self.uidLabel.text = String(tempRef)
            })
            
        }
            
            
            

        else if self.couponText == "justCompleted" {
           
            self.databaseRef.child("request").observe(.childAdded) { (snapshot:FIRDataSnapshot) in
                
                let snapshot = snapshot.value as? NSDictionary
                
                let isComplete = snapshot?["isComplete"] as! Bool
                
                if isComplete == true {
                    
                    let key = snapshot?["requestKey"] as? String
                    
                    let deletePath = "request/\(key!)"
                    let childUpdates = [deletePath:NSNull()]
                    self.databaseRef.updateChildValues(childUpdates)
                    
                }
            }
        } else if self.couponText == "uid" {
            
            self.uidLabel.text = FIRAuth.auth()?.currentUser?.uid
            
        }
        else if self.couponText == "sendNotif" {
            
            for mateID in 0..<self.notifMates.count {
                
                print(self.notifMates.count)
                print(mateID)
                print("\(self.notifMates[mateID])!")
                var ThisNotif = "\(self.notifMates[mateID])"
                print(ThisNotif)
                OneSignal.postNotification(["headings" : ["en": "Start getting paid to be a Goodneighbor!"],
                                            "contents" : ["en": "Update your app and get $1-$2 per delivery!"],
                                            "include_player_ids": [ThisNotif],
                                            "ios_sound": "nil"])
                
            }
            
        
        
        }
        
        else if self.couponText == "dailyMaintenance" {
            
            self.databaseRef.child("request").observe(.childAdded) { (snapshot:FIRDataSnapshot) in
                
                let snapshot = snapshot.value as? NSDictionary
                
                let isComplete = snapshot?["isComplete"] as! Bool
                
                let isAccepted = snapshot?["isAccepted"] as! Bool
                
                if let timeStamp = snapshot?["requestedTimeStamp"] as? Int {
                
                let nowTime = (UInt64(NSDate().timeIntervalSince1970 * 1000.0))
                
                let nowInt = Int(nowTime)
                
                let timeDif = nowInt - timeStamp
                
                if isAccepted == false && isComplete == false && timeDif > self.threeHours {
                    
                    let key = snapshot?["requestKey"] as? String
                    
                    let deletePath = "request/\(key!)"
                    let childUpdates = [deletePath:NSNull()]
                    self.databaseRef.updateChildValues(childUpdates)
                    
                }
            }
            }
            
        }
            
            
     // Send notif to MIT people
            
        else if self.couponText == "mit" {
            
            
            self.databaseRef.child("users").observe(.childAdded) { (snapshot6: FIRDataSnapshot) in
                
                let snapshot6 = snapshot6.value as! NSDictionary
                
                if let userName = snapshot6["name"] {
                    
                    if let city = snapshot6["buildingName"] as? String {
                        
                        if city == "Masseh Hall" {
                          
                            
                            if let userNotifID = snapshot6["notifID"] as? String  {
                                
                                // Have a filter for letters in name to get around 30 people
                                //(self.couponText)?.contains("#"))!
                                
                            if snapshot6["deliveryCount"] as! Int == 0 {
                            
                                //sept. 23 filtering these out not to send, 33 do not fit criteria
                                if ((snapshot6["name"] as! String).contains("Al")) || ((snapshot6["name"] as! String).contains("z")) || ((snapshot6["name"] as! String).contains("e"))
                               
                                {
                                
                            } else {
                                
                                    //SENDING MIT NOTIF
                                
                         
                                
                        //here are the notif id we are sending to!!!!
                                    if ((snapshot6["name"] as! String).contains("u"))  || ((snapshot6["name"] as! String).contains("i")) {
                                self.mitNotifID = snapshot6["notifID"] as! String
                                    
                                    print("this is an id!")
                                    print(self.mitNotifID!)
                                    self.mitMates.append(userNotifID)
                                    print((self.mitMates.count))
                                    
                                    
                        //Send the notif!
                      /*  OneSignal.postNotification(["headings" : ["en": "Post a Run Today and Earn 5 free Tokens!"],
                                                        "contents" : ["en": "Post your first run today and become 5 tokens closer to recieving a free gift card :)"],
                                                        "include_player_ids": [self.mitNotifID!],
                                         "ios_sound": "nil"])*/
 
 }
                               
                                }
                                }
                            }
                            
                            
                        }
                    }
            
                    }

            }}
            
        else if self.couponText == "beenCompleted" {
            
            //7 days 606503000 ticks http://www.currenttimestamp.com/
            //ISSUE
            //set the time for how long the threshold is
            self.timeThreshold = 606503000
         
            self.databaseRef.child("requestComplete").observe(.childAdded) { (snapshot:FIRDataSnapshot) in
                
                let snapshot = snapshot.value as? NSDictionary
                
                let timeStamp = snapshot?["timeStamp"] as! Int
                
                let nowTime = (UInt64(NSDate().timeIntervalSince1970 * 1000.0))
                
                let nowInt = Int(nowTime)
                
                let timeDif = nowInt - timeStamp
                
                if timeDif > self.timeThreshold! {
                    
                    let key = snapshot?["requestKey"] as? String
                    
                    let deletePath = "requestComplete/\(key!)"
                    let childUpdates = [deletePath:NSNull()]
                    self.databaseRef.updateChildValues(childUpdates)
                    
                }
            }
        }
            
        else {  //Code to allow for referral functionality
            
            let referralCode = self.couponText
            
            self.databaseRef.child("users").observeSingleEvent(of: .value) { (snapshot:FIRDataSnapshot) in
                
                let snapshot = snapshot.value as? NSDictionary
                
                for userDict in snapshot! {
                    
                   let userInfo = userDict.value as? NSDictionary
                
                   if let userReferralCode = userInfo?["referralCode"] as? String {
                    
                        if userReferralCode == referralCode {
                            
                            self.isVerified = true
                            self.referralUid = userDict.key as? String
                            
                            //Check user has not already used referral coupon
                            if referralRedeemed {
                                self.isAlreadyUsed = true
                            } else {
                                self.isAlreadyUsed = false
                            }
                        }
                   }
            }
                
        if self.isVerified == true && self.isAlreadyUsed == false { //Successful entry
            
                referralRedeemed = true
            
            
            //HERE UPDATE THAT PERSONS REFERRAL COUNT
      
                    
            //Give token to the user who referred
            self.databaseRef.child("users").child(self.referralUid!).observeSingleEvent(of: .value, with: { snapshot in
                        
                        let snapshot = snapshot.value as? NSDictionary
                        if let tempToken = snapshot?["tokenCount"] as? Int {
                            
                            let plusOneToken = tempToken + 1
                            self.databaseRef.child("users").child(self.referralUid!).child("tokenCount").setValue(plusOneToken)
                            
                            if let _ = snapshot?["notifID"] as? String {
                                
                                self.referralNotif = snapshot?["notifID"] as? String
                                
                              /*  OneSignal.postNotification(["headings" : ["en": "Thank you for your referral!"],
                                                            "contents" : ["en": "1 token has been added to your account.You have made \(referralCount) referrals."],
                                                            "include_player_ids": [self.referralNotif!],
                                                            "ios_sound": "nil"])
                                 
                                 */
                                
                            }
                        }
                
                if let tempReferralCount = snapshot?["referralCount"] as? Int {
                    
                    self.plusOneReferral = tempReferralCount + 1
                    self.databaseRef.child("users").child(self.referralUid!).child("referralCount").setValue(self.plusOneReferral!)
                    FIRAnalytics.logEvent(withName: "didMakeReferral", parameters: nil)
                    OneSignal.postNotification(["headings" : ["en": "Thank you for your referral!"],
                                                "contents" : ["en": "1 token has been added to your account.You have made \(self.plusOneReferral!) referrals."],
                                                "include_player_ids": [self.referralNotif!],
                                                "ios_sound": "nil"])
                }
                
                
                
                     })
                    
                //Update current user token count
                    self.databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).observeSingleEvent(of: .value, with: { snapshot in
                        
                        let snapshot = snapshot.value as? NSDictionary
                        if let tempToken = snapshot?["tokenCount"] as? Int {
                            
                        self.myTokens = tempToken
                        self.myTokens! += 1
                        self.databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("tokenCount").setValue(self.myTokens!)
                        self.databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("referralRedeemed").setValue(true)
                            
                        self.makeAlert(title: "Thank you!", message: "Thank you for your referral! You have been awarded a free token and now have \(self.myTokens!) tokens in your account")
                        
                        }
                        
                    })
                    
                } else if self.isAlreadyUsed == true {
                    
                    self.makeAlert(title: "Already referred", message: "This account has been credited a token for being referred. There are many other potential Goodneighbors out there for you to refer to recieve a free token!")
                    
                } else if self.couponText == "logout 1" {
                    
                    try! FIRAuth.auth()?.signOut()
                    self.performSegue(withIdentifier: "couponToLogIn", sender: nil)
                    
                } else {

                    
                    self.makeAlert(title: "Name not found", message: "We are unable to find this referral code. Please double check the correct code is entered (it is case sensitive).")
                    
                }
            }

        }
        
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
    
    func makeAlert(title: String, message: String)  {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            //do nothing
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func notifAlert(title: String, message: String)  {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
   
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
   

}


