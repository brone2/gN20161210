//
//  myTokensView.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/8/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import OneSignal


class myTokensView: UIViewController {

    @IBOutlet weak var tokenCountLabel: UILabel!
    
   //@IBOutlet var questionMarkImage: UIImageView!
    
    @IBOutlet var questionButton: customButton!
    @IBOutlet var tokenBlueView: UIView!
    
    let databaseRef = FIRDatabase.database().reference()
    
    @IBOutlet var referralLabel: underlinedLabel!
    
    var myTokens:String?
    var myTokenInt: Int?
    var referralCount: Int?
    
    @IBOutlet var titleLabel: UILabel!
    var enteredEmail: String?
    
    var starbucksAmount: Int?
    var tokenLimit: Int?
    var redemptionActive = false
    
    @IBOutlet var redemptionLabel: underlinedLabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isX {
            let pinTop = NSLayoutConstraint(item: self.titleLabel, attribute: .top, relatedBy: .equal,
                                            toItem: view, attribute: .top, multiplier: 4.0, constant: 38)
            
            
            
            NSLayoutConstraint.activate([pinTop])
        }
        
       
       
        
        self.tokenBlueView.layer.cornerRadius = 4
        
        //Get redemption info
        self.databaseRef.child("redemptionAward").observeSingleEvent(of: .value) { (snapshot2:FIRDataSnapshot) in
            let snapshot2 = snapshot2.value as! NSDictionary
            if let isActive = snapshot2["isActive"] as? Bool {
                self.redemptionActive = true
            }
            if let starbucksRedeem = snapshot2["starbucksRedeem"] as? Int {
                self.starbucksAmount = starbucksRedeem
            }
            
            if let tokenRedeem = snapshot2["tokenRedeem"] as? Int {
                self.tokenLimit = tokenRedeem
            }
           
           
            
            
            self.databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).observeSingleEvent(of: .value, with: { snapshot7 in
                
                let snapshot = snapshot7.value as? NSDictionary
                if let tempRef = snapshot?["referralCount"] as? Int {
                    self.referralCount = tempRef
                    let refText = String((self.tokenLimit!) - (self.referralCount!))
                    self.referralLabel.text = "Refer \(refText) friends to earn $\(self.starbucksAmount!) to Starbucks!"
                //hide unless 5 referrals
                if self.referralCount! >= self.tokenLimit! {
                    self.redemptionLabel.isHidden = false
                    self.redemptionLabel.text = "Select here to redeem $\(self.starbucksAmount!) to starbucks!"
                } else {
                    self.redemptionLabel.isHidden = true
                }
            }
            })
            
            
           
        }

        
        //Get token Count
        self.databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).observeSingleEvent(of: .value, with: { snapshot in
            
            let snapshot = snapshot.value as? NSDictionary
            if let tempToken = snapshot?["tokenCount"] as? String{
                self.myTokens = tempToken
                
            }
            let tempToken = snapshot?["tokenCount"] as! Int
            self.myTokenInt = tempToken
            let tokenString = String(tempToken)
            self.tokenCountLabel.text = tokenString
        })
        
        let goToReferPageTap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.goToReferPage(_:)))
        self.referralLabel.addGestureRecognizer(goToReferPageTap)
        
        let goToRedeem:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.redeemPromo(_:)))
        self.redemptionLabel.addGestureRecognizer(goToRedeem)
        
    }
    
    func goToReferPage(_ gesture: UITapGestureRecognizer) {
        
        self.performSegue(withIdentifier: "myTokenToReferral", sender: nil)
    
    }
    
    func redeemPromo(_ gesture: UITapGestureRecognizer) {
       
        if Int(self.myTokenInt!) >= self.tokenLimit! {
           
            var phoneNumberTextField: UITextField?
            
            let alertController = UIAlertController(
                title: "Congratulations!",
                message: "Please enter your email address to recieve your $\(self.starbucksAmount!) starbucks gift card",
                preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(
            title: "Cancel", style: UIAlertActionStyle.default) {
                (action) -> Void in
            }
            
            let completeAction = UIAlertAction(
            title: "Complete", style: UIAlertActionStyle.default) {
                (action) -> Void in
                
                if let phoneNumber = phoneNumberTextField?.text {
                    
                    let key = self.databaseRef.child("redeemPrize").childByAutoId().key
                    
                    self.enteredEmail = phoneNumber
                  
                OneSignal.postNotification(["contents": ["en": "THERE IS A REDEMPTION!!!!!"], "include_player_ids": [neilNotif],"ios_sound": "nil", "data": ["type": "request"]])
                
                let userUIDPath = "/redeemPrize/\(key)/uid"
                let userUIDValue = globalLoggedInUserId!
                
                let userEmailPath = "/redeemPrize/\(key)/userEmail"
                let userEmailValue =  self.enteredEmail as! String
                
                let isPaidPath = "/redeemPrize/\(key)/isPaid"
                let isPaidValue = false
                    
               
                let childUpdatesRedeem = [userUIDPath:userUIDValue,userEmailPath:userEmailValue,isPaidPath:isPaidValue] as [String : Any]
                
                    self.databaseRef.updateChildValues(childUpdatesRedeem)
                    
                    self.makeAlert(title: "Thanks!", message: "Your gift card will be sent within 24 hours! After you recieve the gift card \(self.tokenLimit!) tokens will be deducted from your account")
                    
                    
                }
                
            }
            
            alertController.addTextField {
                (txtUsername) -> Void in
                txtUsername.keyboardType = .default
                phoneNumberTextField = txtUsername
                phoneNumberTextField!.placeholder = "jMadison@washu.edu"
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(completeAction)
            
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            let alertNotEnough = UIAlertController(title: "Insufficient amount of tokens", message: "Continuing acquiring tokens by making deliveries and referring friends!", preferredStyle: UIAlertControllerStyle.alert)
            
            alertNotEnough.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                return
            }))
            self.present(alertNotEnough, animated: true, completion: nil)
        }
        
       

        
    }
    

    @IBAction func didTapQuestion(_ sender: Any) {
        
        self.questionButton.isHidden = true
        self.performSegue(withIdentifier: "tokenToExp", sender: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // myTokenToReferral
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    
        self.redemptionLabel.isHidden = true
        
        if isVerySmallScreen {
            
            self.referralLabel.isHidden = true
            
        }
        
        
        
        
        self.databaseRef.child("users").observe(.childAdded) { (snapshot3: FIRDataSnapshot) in
            
            let key = snapshot3.key
            
            
            let snapshot3 = snapshot3.value as! NSDictionary
            print(key)
            print(snapshot3["name"] as! String)
                if let userState = snapshot3["city"] as? String {
                    if userState == "Santa Clara " {
                        print(snapshot3["fullName"] as! String)
                        print(key)
                    }
                }
                
                //For user count check of ambassadors
                if let userBuilding = snapshot3["notifID"] as? String{
                 if userBuilding == "c550e596-c3de-47b6-a3fb-6dd2c83d3ac8" {
                 print(snapshot3["name"] as? String)
                    print(snapshot3["fullName"] as? String)
                 }
                    if userBuilding == "9cc6d454-21ca-4a29-b606-54239942acbf" {
                        print(snapshot3["name"] as? String)
                        print(snapshot3["fullName"] as? String)
                    }
                 }
                
            }
        }

    func makeAlert(title: String, message: String)  {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            //do nothing
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    }
    


