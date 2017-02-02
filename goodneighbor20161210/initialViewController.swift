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

class initialViewController: UIViewController {
    
    var loggedInUserData: AnyObject?
    var databaseRef:FIRDatabaseReference!
    var url: String?
    var proPicURL: String?
    var proPic = 0
    var time = 0
    var timer = Timer()
    var loggedInUserId: String?
    
    override var prefersStatusBarHidden: Bool {
        return true
    } 

    override func viewDidLoad() {
        super.viewDidLoad()
        
try! FIRAuth.auth()?.signOut()
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenHeight = screenSize.height
        
        print(screenHeight)
        
        if screenHeight < 490.0{
            
            isVerySmallScreen = true
            
        }
        
        if screenHeight < 570.0 && screenHeight > 500{
            
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
    
    func checkUser(){
        
   //try! FIRAuth.auth()?.signOut()
        
            FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
                
                if autoLoginHelp == 0 {
                
                if let currentUser = user {
                    
                        print("timer invalidated")
                        self.timer.invalidate()
                    
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    
                        self.loggedInUserId = FIRAuth.auth()?.currentUser?.uid
                        
                        //get user name
                        self.databaseRef.child("users").child(self.loggedInUserId!).observeSingleEvent(of: .value) { (snapshot:FIRDataSnapshot) in
                            
                            self.loggedInUserData = snapshot.value as? NSDictionary
                            
                            loggedInUserName = self.loggedInUserData?["name"] as! String
                            myProfilePicRef = self.loggedInUserData?["profilePicReference"] as! String
                            myCellNumber = self.loggedInUserData?["cellPhoneNumber"] as! String
                            currentTokenCount = self.loggedInUserData?["tokenCount"] as! Int
                            
                            if let myLatitude = self.loggedInUserData?["latitude"] as? CLLocationDegrees{
                                if let myLongitude = self.loggedInUserData?["longitude"] as? CLLocationDegrees{
                                    myLocation = CLLocation(latitude: myLatitude, longitude: myLongitude)
                                }
                            }
                            
                            myRadius  = self.loggedInUserData?["deliveryRadius"] as? Float
                            
                            
                            let homeViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "shoppingList")
                            print("should have been sent")
                            self.present(homeViewController, animated: true, completion: nil)
                        }
                } else {
                self.performSegue(withIdentifier: "goToFbookLogin", sender: nil)
                }
                }
            })
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
