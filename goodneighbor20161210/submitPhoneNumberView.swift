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


class submitPhoneNumberView: UIViewController, UITextFieldDelegate {
    
    var phoneNumber1:String?
    var phoneNumber2:String?
    var selectSubmit = 0
    var databaseRef = FIRDatabase.database().reference()
    
    var saveKey: String?

    @IBOutlet var directionsLabel: UILabel!
    @IBOutlet var phoneText1: UITextField!

    override func viewDidAppear(_ animated: Bool) {
        self.selectSubmit = 0
    }

    
    @IBAction func didTapSubmit(_ sender: Any) {
        
        
        if self.selectSubmit == 0 {
        
        if (self.phoneText1.text != nil)        {
        self.phoneNumber1 = String(self.phoneText1.text!)
        }
            self.selectSubmit = 1
            
            self.phoneText1.text = ""
            
            self.directionsLabel.text = "Please re-enter phone number"
            
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
                
                
            self.databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("cellPhoneNumber").setValue(myCellNumber)
                
            self.databaseRef.child("request").child(self.saveKey!).child("requesterCell").setValue(myCellNumber)
                
                let alertDeliveryComplete = UIAlertController(title: "Request posted!", message: "Your delivery request has been posted to the neighberhood shopping List! Please be alert for a neighbor reaching out to deliver this item", preferredStyle: UIAlertControllerStyle.alert)
                
                alertDeliveryComplete.addAction(UIAlertAction(title: "ok", style: .default, handler: { (action) in
                    
                    self.performSegue(withIdentifier: "phoneToGeneralRefreshSegue", sender: nil)
                    
                }))
                self.present(alertDeliveryComplete, animated: true, completion: nil)
                
            }
            
        }

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}
