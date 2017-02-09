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

class couponMaintenanceView: UIViewController {

    @IBOutlet var codeTextField: UITextField!
    
    @IBOutlet var uidLabel: UILabel!
    
    let databaseRef = FIRDatabase.database().reference()
    
    var couponText: String?
    var timeThreshold: Int?
    let threeHours: Int = 10800000
    
    override func viewDidAppear(_ animated: Bool) {
        let nowTime = (UInt64(NSDate().timeIntervalSince1970 * 1000.0))
        print(nowTime)
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
            
        } else if self.couponText == "dailyMaintenance" {
            
            self.databaseRef.child("request").observe(.childAdded) { (snapshot:FIRDataSnapshot) in
                
                let snapshot = snapshot.value as? NSDictionary
                
                let isComplete = snapshot?["isComplete"] as! Bool
                
                let timeStamp = snapshot?["timeStamp"] as! Int
                
                let nowTime = (UInt64(NSDate().timeIntervalSince1970 * 1000.0))
                
                let nowInt = Int(nowTime)
                
                let timeDif = nowInt - timeStamp
                
                if isComplete == false && timeDif > self.threeHours {
                    
                    let key = snapshot?["requestKey"] as? String
                    
                    let deletePath = "request/\(key!)"
                    let childUpdates = [deletePath:NSNull()]
                    self.databaseRef.updateChildValues(childUpdates)
                    
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
            
        else {
            let alert = UIAlertController(title: "Code not Recognized", message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                
            }))
            self.present(alert, animated: true, completion: nil)

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
   
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
   

}


