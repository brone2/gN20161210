//
//  referralIncentiveExplained.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 2/9/17.
//  Copyright © 2017 Neil Bronfin. All rights reserved.
//

import UIKit
import MessageUI
import MessageUI.MFMailComposeViewController
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class referralIncentiveExplained: UIViewController, MFMessageComposeViewControllerDelegate {
    
    var databaseRef:FIRDatabaseReference!
    @IBOutlet var greyView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.databaseRef = FIRDatabase.database().reference()
        
        self.greyView.layer.cornerRadius = 5
        self.greyView.layer.masksToBounds = true

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func didTapDismiss(_ sender: customButton) {
        
        self.sendReferralText()
        
    }
    
    
    @IBAction func didTapBack(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "promoBackToToken", sender: nil)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    func sendReferralText() {
        
        if userReferralCode == "Not yet entered" {
            
            let randomNum:UInt32 = arc4random_uniform(1000)
            let someString:String = String(randomNum)
            
            let referralCode = loggedInUserName + someString
            userReferralCode = referralCode
            
        self.databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("referralCode").setValue(userReferralCode!)
            
            
        }
        
        let textMessage = "Download Goodneighbor Delivery and enter the referral code \(userReferralCode!) to get a free token!  https://itunes.apple.com/us/app/goodneighbor-delivery/id1186085872?mt=8"
        
        let requesterCell = ""
        
        self.purchaseActualText(textMessage: textMessage, requesterCell: requesterCell)
        
    }
    
    func purchaseActualText(textMessage: String, requesterCell: String) {
        
        if (MFMessageComposeViewController.canSendText()) {
            
            let controller = MFMessageComposeViewController();
            controller.body = textMessage;
            controller.recipients = [requesterCell]
            controller.messageComposeDelegate = self;
            self.present(controller, animated: true, completion: nil)
            
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }

    
}

