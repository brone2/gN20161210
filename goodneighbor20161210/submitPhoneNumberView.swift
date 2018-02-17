//
//  submitPhoneNumberView.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/10/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import MessageUI
import MessageUI.MFMailComposeViewController

class submitPhoneNumberView: UIViewController, UITextFieldDelegate, MFMessageComposeViewControllerDelegate {
    
    var phoneNumber1:String?
    var phoneNumber2:String?
    var selectSubmit = 0
    var databaseRef = FIRDatabase.database().reference()
    var isRequest: Bool = true
    var isRun: Bool = false
    var runPhone:Bool = false
    
    @IBOutlet var greyView: UIView!
    
    
    var textMessage:String?
    var phoneNumber:String?
    
    var saveKey: String?

    @IBOutlet var directionsLabel: UILabel!
    @IBOutlet var phoneText1: UITextField!

    override func viewDidAppear(_ animated: Bool) {
        self.selectSubmit = 0
    }

    
    @IBAction func didTapSubmit(_ sender: Any) {
        
         self.phoneNumber1 = String(self.phoneText1.text!)
        
        let alertController = UIAlertController(
            title: "Verify Phone Number",
            message: "Is \(self.phoneNumber1!) your phone number?",
            preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(
        title: "No", style: UIAlertActionStyle.default) {
            (action) -> Void in
           
        }
        
        let yesAction = UIAlertAction(
        title: "Yes", style: UIAlertActionStyle.default) {
            (action) -> Void in
           
            myCellNumber = self.phoneNumber1!
            
            myCellNumber = myCellNumber.replacingOccurrences(of: "(", with: "")
            myCellNumber = myCellNumber.replacingOccurrences(of: "-", with: "")
            myCellNumber = myCellNumber.replacingOccurrences(of: ")", with: "")
            
    
         
            //If is a request
            
            if self.isRequest {
                
                self.databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("cellPhoneNumber").setValue(myCellNumber)
                self.databaseRef.child("request").child(self.saveKey!).child("requesterCell").setValue(myCellNumber)
                
                let alertDeliveryComplete = UIAlertController(title: "Request posted!", message: "Your delivery request has been posted to the neighberhood shopping List! Please be alert for a neighbor reaching out to deliver this item", preferredStyle: UIAlertControllerStyle.alert)
                
                alertDeliveryComplete.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    
                    self.performSegue(withIdentifier: "phoneToGeneralRefreshSegue", sender: nil)
                    
                    
                }))
                self.present(alertDeliveryComplete, animated: true, completion: nil)
                
            } else { // if is delivery and need to enter phone number
                
                self.databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("cellPhoneNumber").setValue(myCellNumber)
                
                self.databaseRef.child("request").child(self.saveKey!).child("accepterCell").setValue(myCellNumber)
                
                let alertPhoneNumberDelivery = UIAlertController(title: "Phone number saved", message: "Thank you for accepting this request and have a great day!", preferredStyle: UIAlertControllerStyle.alert)
                
                
                alertPhoneNumberDelivery.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    
                   // self.sendText()
                    if self.isRun {
                         self.performSegue(withIdentifier: "phoneToRun", sender: nil)
                    } else {
                        self.performSegue(withIdentifier: "phoneToGeneralRefreshSegue", sender: nil)
                    }
                    
                }))
                self.present(alertPhoneNumberDelivery, animated: true, completion: nil)
                
            }
            }
        
        
        alertController.addAction(cancelAction)
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)

        }
        
    
    //selectSubmit keeps track of it is the first or second entering of phone number
        /*if self.selectSubmit == 0 {
        
        if (self.phoneText1.text != nil)        {
            
        self.phoneNumber1 = String(self.phoneText1.text!)
            
        }
            self.selectSubmit = 1
            
            self.phoneText1.text = ""
            
            self.directionsLabel.text = "Please verify phone number"
            
            return
            
    }
        
        if self.selectSubmit == 1 {
            
            if (phoneText1.text != nil)
            {
                self.phoneNumber2 = String("\(phoneText1.text!)")
            }
            
            if self.phoneNumber1 != self.phoneNumber2 {
                
                let alert = UIAlertController(title: "Invalid phone number", message: "You have entered two different phone numbers, \(self.phoneNumber1!) and \(self.phoneNumber2!). Please try again", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    
                    self.selectSubmit = 0
                    
                    self.phoneText1.text = ""
                    self.directionsLabel.text = "Please enter phone number"
                    
                    return
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
            
            myCellNumber = self.phoneNumber2
                
            myCellNumber = myCellNumber.replacingOccurrences(of: "(", with: "")
            myCellNumber = myCellNumber.replacingOccurrences(of: "-", with: "")
            myCellNumber = myCellNumber.replacingOccurrences(of: ")", with: "")

//Save phone number and segue to Shopping List
    
        //If is a request
                
         if self.isRequest {
            
                self.databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("cellPhoneNumber").setValue(myCellNumber)
                self.databaseRef.child("request").child(self.saveKey!).child("requesterCell").setValue(myCellNumber)
                
                    let alertDeliveryComplete = UIAlertController(title: "Request posted!", message: "Your delivery request has been posted to the neighberhood shopping List! Please be alert for a neighbor reaching out to deliver this item", preferredStyle: UIAlertControllerStyle.alert)
                
                    alertDeliveryComplete.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    
                        self.performSegue(withIdentifier: "phoneToGeneralRefreshSegue", sender: nil)
                        
                    
                }))
                    self.present(alertDeliveryComplete, animated: true, completion: nil)
                
         } else { // if is delivery and need to enter phone number
            
            self.databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("cellPhoneNumber").setValue(myCellNumber)
            
            self.databaseRef.child("request").child(self.saveKey!).child("accepterCell").setValue(myCellNumber)
            
            let alertPhoneNumberDelivery = UIAlertController(title: "Phone number saved", message: "Please be in contact with the recipient as you complete this delivery and thanks for being a goodneighbor :) ", preferredStyle: UIAlertControllerStyle.alert)
            
            
            alertPhoneNumberDelivery.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                
                self.sendText()
                
            }))
            self.present(alertPhoneNumberDelivery, animated: true, completion: nil)
        
            }
          }
        }*/
    
    func sendText() {
        
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController();
            controller.body = self.textMessage;
            controller.recipients = [self.phoneNumber!]
            controller.messageComposeDelegate = self;
            self.present(controller, animated: true, completion: nil)
        }
        
        
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: self.seger)
    }
    
    func seger (){
        self.performSegue(withIdentifier: "phoneToGeneralRefreshSegue", sender: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
