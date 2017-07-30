//
//  meChangeRadius.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/17/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import CoreLocation

class meChangeRadius: UIViewController {

    @IBOutlet var slider: UISlider!
    @IBOutlet var distanceLabel: UILabel!
    
    @IBOutlet var grayView: UIView!
    @IBOutlet var feetLabel: UILabel!
    var loggedInUserId:String!
    var loggedInUserData: AnyObject?
    
    var databaseRef = FIRDatabase.database().reference()
    var deliveryRadius:Float = 0.5000
    
    var activityIndicator = UIActivityIndicatorView()
    
    @IBAction func didTapSave(_ sender: Any) {
        
        self.deliveryRadius += 0.00043
    
        self.databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("deliveryRadius").setValue(self.deliveryRadius)
        
        myRadius = self.deliveryRadius
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func didMoveThisSlider(_ sender: UISlider) {
        
        self.deliveryRadius = Float(sender.value)
        let stringDeliveryRadius = String(format: "%.2f", self.deliveryRadius)
        let feetDeliveryRadius = self.deliveryRadius * 5280.03932029
        let feetStringDeliveryRadius = String(format: "%.0f", feetDeliveryRadius)
        
        distanceLabel.text = "\(stringDeliveryRadius)"
        print(feetStringDeliveryRadius)
        feetLabel.text = "(\(feetStringDeliveryRadius) ft)"
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.grayView.layer.cornerRadius = 3
        self.grayView.layer.masksToBounds = true

        slider.minimumValue = 0.010000
        slider.maximumValue = 1.0000
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

}
