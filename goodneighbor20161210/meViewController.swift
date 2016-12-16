//
//  meViewController.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/9/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase


class meViewController: UIViewController {
    
    var databaseRef = FIRDatabase.database().reference()
    var loggedInUserId:String?
    var enteredPhoneNumber:String?
    var deliveryCount = 0
    var recieveCount = 0
    
    @IBOutlet var viewPastDeliveriesButton: UIButton!
    @IBOutlet var viewPastRequestButton: UIButton!
    
    var myPastRecieve = [NSDictionary?]()
    var myPastDeliveries = [NSDictionary?]()
    
    var relevantPastInfo = [NSDictionary?]()
    var navBarTitle:String?
    
    @IBAction func didTapLogOut(_ sender: Any) {
        try! FIRAuth.auth()?.signOut()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
       self.loggedInUserId = FIRAuth.auth()?.currentUser?.uid
        
       viewPastDeliveriesButton.contentHorizontalAlignment = .left
       viewPastRequestButton.contentHorizontalAlignment = .left
        
        self.databaseRef.child("users").child(self.loggedInUserId!).observeSingleEvent(of: .value) { (snapshot:FIRDataSnapshot) in
            
            let snapshot = snapshot.value as? NSDictionary
            let tempDelivery = snapshot?["deliveryCount"] as? Int
            self.deliveryCount = Int(tempDelivery!)
            let tempRecieve = snapshot?["recieveCount"] as? Int
            self.recieveCount = Int(tempRecieve!)
            
            self.viewPastRequestButton.setTitle("View past request (\(self.recieveCount))", for: [])
            self.viewPastDeliveriesButton.setTitle("View past deliveries (\(self.deliveryCount))", for: [])
        }
        
        
        self.databaseRef.child("request").observe(.childAdded) { (snapshot2: FIRDataSnapshot) in
            
            let snapshot2 = snapshot2.value as! NSDictionary
            let snapRecieveId = snapshot2["requesterUID"] as? String
            let snapDeliverId = snapshot2["accepterUID"] as? String
            let snapComplete = snapshot2["isComplete"] as? Bool
            
            //Past Recieved
            if(snapRecieveId == self.loggedInUserId && snapComplete == true){
                self.myPastRecieve.append(snapshot2)
            }
            
            //Past Delivered
            if(snapDeliverId == self.loggedInUserId && snapComplete == true){
                self.myPastDeliveries.append(snapshot2)
            }
        }

    }

    
    
    @IBAction func didTapPastRequests(_ sender: UIButton) {
        
        self.relevantPastInfo = self.myPastRecieve
        self.navBarTitle = "Completed Requests"
        
        self.performSegue(withIdentifier: "goToPast", sender: nil)
        
    }
    @IBAction func didTapPastDeliveries(_ sender: UIButton) {
        
        print(self.myPastDeliveries)
        
        self.relevantPastInfo = self.myPastDeliveries
        self.navBarTitle = "Completed Deliveries"
        
        self.performSegue(withIdentifier: "goToPast", sender: nil)
        
          }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //
        
        if segue.identifier == "goToPast" {
            
            let secondViewController = segue.destination as! pastActivityCompleted
            secondViewController.relevantPastInfo = self.relevantPastInfo
            secondViewController.navBarTitle = self.navBarTitle
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    @IBAction func didTapPhoneButton(_ sender: UIButton) {
        
        var phoneNumberTextField: UITextField?
        
        let alertController = UIAlertController(
            title: "Add Phone Number",
            message: "Current cell: \(myCellNumber!)",
            preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(
        title: "Cancel", style: UIAlertActionStyle.default) {
            (action) -> Void in
        }
        
        let completeAction = UIAlertAction(
        title: "Complete", style: UIAlertActionStyle.default) {
            (action) -> Void in
            if let phoneNumber = phoneNumberTextField?.text {
                self.enteredPhoneNumber = phoneNumber
            }
            
            self.databaseRef.child("users").child(self.loggedInUserId!).child("cellPhoneNumber").setValue(self.enteredPhoneNumber)
            
        }
        
        alertController.addTextField {
            (txtUsername) -> Void in
            phoneNumberTextField = txtUsername
            phoneNumberTextField!.placeholder = "ex: 4135691234"
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(completeAction)
        
        
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func didTapChangeDeliveryRadius(_ sender: Any) {
        
        var radiusNumberTextField: UITextField?
        
        let alertController = UIAlertController(
            title: "Enter New Delivery Radius",
            message: "Please enter a whole number for number of miles you wish your delivery radius to be",
            preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(
        title: "Cancel", style: UIAlertActionStyle.default) {
            (action) -> Void in
        }
        
        let completeAction = UIAlertAction(
        title: "Complete", style: UIAlertActionStyle.default) {
            (action) -> Void in
            if let deliveryRadius = radiusNumberTextField?.text {
                if Int(deliveryRadius) != nil{
                    print("trrrr")
                let deliveryRadiusFloat1 = Float(Int(deliveryRadius)!)
                let deliveryRadiusFloat2 = deliveryRadiusFloat1 + 0.00002
            self.databaseRef.child("users").child(self.loggedInUserId!).child("deliveryRadius").setValue(deliveryRadiusFloat2)
            
                } else{
                
                print("Yolo:")
                let alertControllerError = UIAlertController(
                    title: "Please enter valid number",
                    message: "",
                    preferredStyle: UIAlertControllerStyle.alert)
                
                let errorAction = UIAlertAction(
                title: "Ok", style: UIAlertActionStyle.default) {
                    (action) -> Void in
                }
                alertControllerError.addAction(errorAction)
                self.present(alertControllerError, animated: true, completion: nil)
                
            }
            }
            
            
        }
        
        alertController.addTextField {
            (txtUsername) -> Void in
            radiusNumberTextField = txtUsername
            radiusNumberTextField!.placeholder = "ex: 2"
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(completeAction)
        
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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


