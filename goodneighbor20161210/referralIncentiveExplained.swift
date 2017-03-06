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

class referralIncentiveExplained: UIViewController, MFMessageComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func didTapDismiss(_ sender: customButton) {
        
        self.sendReferralText()
        
    }
    
    
    @IBAction func didTapBack(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    func sendReferralText() {
        
        let textMessage = "Download Goodneighbor Delivery and enter the referral code REFERRALCODE to get a free token!  https://itunes.apple.com/us/app/goodneighbor-delivery/id1186085872?mt=8"
        
        let requesterCell = "0"
        
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

