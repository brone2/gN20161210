//
//  changeLocationViewController.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/12/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import FirebaseDatabase
import FirebaseAuth
import Firebase

class changeLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet var map: MKMapView!
    
    var locationManager = CLLocationManager()
    var userLocation: CLLocation?
    var loggedInUser:String!
    var databaseRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.databaseRef = FIRDatabase.database().reference()
        
        self.loggedInUser = FIRAuth.auth()?.currentUser?.uid
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(6), execute: {
            
            self.performSegue(withIdentifier: "replaceMapToBuilding", sender: nil)
            
        })
        

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = self.locationManager.location?.coordinate{
            
            self.userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            
            let latitude = self.userLocation?.coordinate.latitude
            let longitude = self.userLocation?.coordinate.longitude
            
            let latDelta: CLLocationDegrees = 0.001
            let lonDelta: CLLocationDegrees = 0.001
            //Zoom in level based on the deltas above
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            //Set location into new variable
            let location = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            
            let region = MKCoordinateRegion(center: location, span: span)
            
            self.map.setRegion(region, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
                let childUpdates = ["/users/\(self.loggedInUser!)/longitude":longitude!, "/users/\(self.loggedInUser!)/latitude":latitude!] as [String : Any]
                
                //Update
                self.databaseRef.updateChildValues(childUpdates)
                
                self.locationManager.stopUpdatingLocation()
                
            })
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
