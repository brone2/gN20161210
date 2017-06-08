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
    
    var couponText: String?
    var timeThreshold: Int?
    let threeHours: Int = 10800000
    var isVerified:Bool = false
    var isAlreadyUsed:Bool = false
    var myTokens:Int?
    var referralUid:String?
    
    var myBuildingMates = [String]()
    
    
    override func viewDidAppear(_ animated: Bool) {
        let nowTime = (UInt64(NSDate().timeIntervalSince1970 * 1000.0))
        print(nowTime)
        
        
        
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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapEnter(_ sender: UIButton) {
        
        self.couponText = codeTextField.text
        
        if self.couponText == "justCompleted" {
           
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
         
            //OneSignal.postNotification(["contents": ["en": "Best of luck studying for finals! Remember to use Goodneighbor to request deliveries from friends :)"]: ["23c8722c-2211-43a2-98a1-01c9c0c8def8"]])
           
             //OneSignal.postNotification(["contents": ["en": "It appears you have not registered your dorm! Register your dorm to see what your friends are requesting :)"], "include_player_ids": ["538471d8-733e-4a4a-bbb0-43be97d265ca"]])
            
            /*for mateID in 0..<self.myBuildingMates.count {
                print(mateID)
                print("EEEEEE")
                print(self.myBuildingMates[mateID])
                
                /*let deadlineTime = DispatchTime.now() + .seconds(1)
                 
                 DispatchQueue.main.asyncAfter(deadline: deadlineTime) {*/
                
                 OneSignal.postNotification(["contents": ["en": "Best of luck studying for finals! Remember to use Goodneighbor to request deliveries from friends :)"], "include_player_ids": [self.myBuildingMates[mateID]],"ios_sound": "nil"])
                
            }*/
            
           
            
            //"538471d8-733e-4a4a-bbb0-43be97d265ca" Toli
            
            
            //Victor
             //  OneSignal.postNotification(["contents": ["en": "A girl to cancel dinner plans and then give no suggestion on rescheduling!!! "], "include_player_ids": ["a757c9f4-14db-45e9-886a-e0d26dd38f68"]])
        //Cherner
             //OneSignal.postNotification(["contents": ["en": "Victor has requested a hairy nutsack to be dipped into his mouth"], "include_player_ids": ["a4789cf0-a0aa-4aa8-a7fc-76a756da177e"]])
        //The king neil"58ffaf31-7506-4cf5-b874-ebce01981ba4"
            
        //OneSignal.postNotification(["contents": ["en": "Harry has requested a Bottle of Butterbeer"], "include_player_ids": ["58ffaf31-7506-4cf5-b874-ebce01981ba4"]])
        
        //Morning Mom "6ec6cb06-0501-4509-974a-fc6a940dc8a3"
            //OneSignal.postNotification(["contents": ["en": "I hope you have a great week mom! I Love you!"], "include_player_ids": ["6ec6cb06-0501-4509-974a-fc6a940dc8a3"]])
        
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
                //Give token to the user who referred
                    
                     self.databaseRef.child("users").child(self.referralUid!).observeSingleEvent(of: .value, with: { snapshot in
                        
                        let snapshot = snapshot.value as? NSDictionary
                        if let tempToken = snapshot?["tokenCount"] as? Int {
                            
                            let plusOneToken = tempToken + 1
                            self.databaseRef.child("users").child(self.referralUid!).child("tokenCount").setValue(plusOneToken)
                            
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
   
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
   

}


