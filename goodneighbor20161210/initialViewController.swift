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

var myLocation: CLLocation?
var myRadius: Float?
var autoLoginHelp: Int = 0

var isSmallScreen = false
var isVerySmallScreen = false
var isLargeScreen = false

var userFullName: String?
var userReferralCode: String?
var referralRedeemed:Bool = false

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
        if time == 3 {
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
                    
                        print("timer invalidated")
                        self.timer.invalidate()
                    
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    
                        self.loggedInUserId = FIRAuth.auth()?.currentUser?.uid
                        
                        //get user name
                        self.databaseRef.child("users").child(self.loggedInUserId!).observeSingleEvent(of: .value) { (snapshot:FIRDataSnapshot) in
                            
                            self.loggedInUserData = snapshot.value as? NSDictionary
                            
                            myBuilding = self.loggedInUserData?["buildingName"] as? String
                            
                            loggedInUserName = self.loggedInUserData?["name"] as! String
                            
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
                            
                            if let myLatitude = self.loggedInUserData?["latitude"] as? CLLocationDegrees{
                                if let myLongitude = self.loggedInUserData?["longitude"] as? CLLocationDegrees{
                                    myLocation = CLLocation(latitude: myLatitude, longitude: myLongitude)
                                }
                            }
                            
                            myRadius  = self.loggedInUserData?["deliveryRadius"] as? Float
                            FIRAnalytics.logEvent(withName: "openApp", parameters: nil)
                            
                            self.databaseRef.child("promoteShare").observeSingleEvent(of: .value) { (snapshot:FIRDataSnapshot) in
                                
                                let snapshot = snapshot.value as? NSDictionary
                                
                                self.isPromotion = snapshot?["isTrue"] as! Bool
                                
                                if self.isPromotion && isVerySmallScreen == false  {
                                    
                                    self.performSegue(withIdentifier: "goToPromoPage", sender: nil)
                                    
                                } else {
                                
                                //For now set default page to request page
                                let homeViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "shoppingList")
                                    
                                //let homeViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "requestItem")
                                
                                self.present(homeViewController, animated: true, completion: nil)
                                    
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
