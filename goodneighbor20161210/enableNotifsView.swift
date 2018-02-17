//
//  enableNotifsView.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 7/25/17.
//  Copyright © 2017 Neil Bronfin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import CoreLocation

class enableNotifsView: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var greyView: UIView!
    var timer = Timer()
    @IBOutlet var enableLabel: UILabel!
    
    
    
    var locationManager = CLLocationManager()
    var userLocation: CLLocation?
    var userLatitude: CLLocationDegrees = 0.00000
    var userLongitude: CLLocationDegrees = 0.00000
    
    let databaseRef = FIRDatabase.database().reference()
    
    var isLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        
        self.greyView.layer.cornerRadius = 3
        self.greyView.layer.masksToBounds = true
        
        forceNotifCount = 2
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
    
        if isLocation {
            self.enableLabel.text = "Please enable location services to identify your Goodneighbor Community!"
        }
        
    if !isLocation {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(enableNotifsView.startTimer), userInfo: nil, repeats: true)
    } else {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(enableNotifsView.findLocation), userInfo: nil, repeats: true)
    }
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapEnable(_ sender: UIButton) {
        
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func startTimer() {
        
        let notificationType = UIApplication.shared.currentUserNotificationSettings!.types
        
        if notificationType.rawValue != 0 {
            timer.invalidate()
           self.dismiss(animated: true, completion: nil)
        }
    }
   
    func findLocation() {
        
        print(self.userLatitude)
        
        if self.userLatitude != 0.000000 {
            
            myLocation = CLLocation(latitude: self.userLatitude, longitude: self.userLongitude)
            timer.invalidate()
            let childUpdates = ["/users/\(globalLoggedInUserId!)/longitude":self.userLongitude, "/users/\(globalLoggedInUserId!)/latitude":self.userLatitude] as [String : Any]
            self.databaseRef.updateChildValues(childUpdates)
         self.dismiss(animated: true, completion: nil)
           
            
        }
        
        
        
}
    
    
    @IBAction func didTapNotNow(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = self.locationManager.location?.coordinate{
            
            self.userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            self.userLatitude = (self.userLocation?.coordinate.latitude)!
            self.userLongitude = (self.userLocation?.coordinate.longitude)!
            
        }
    }
}
