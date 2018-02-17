//
//  locationViewController.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/8/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import FirebaseDatabase
import FirebaseAuth
import Firebase

class locationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    var locationManager = CLLocationManager()
    var userLocation: CLLocation?
    var loggedInUser:String!
    var databaseRef: FIRDatabaseReference!
    var userCity = "N/A"
    var userState = "N/A"

    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(globalLoggedInUserId)
        self.databaseRef = FIRDatabase.database().reference()
        
        self.loggedInUser = FIRAuth.auth()?.currentUser?.uid

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(6), execute: {
            
            let alert = UIAlertController(title: "Delivery Location Set", message: "Thank you! Your delivery location is set to your current location. You can change this later in the Me tab", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                
                self.performSegue(withIdentifier: "mapToHomeChoice", sender: nil)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
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
            myLocation = CLLocation(latitude: latitude!, longitude: longitude!
            )
            
            let region = MKCoordinateRegion(center: location, span: span)
            
            self.map.setRegion(region, animated: true)
             DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            let childUpdates = ["/users/\(self.loggedInUser!)/longitude":longitude!, "/users/\(self.loggedInUser!)/latitude":latitude!] as [String : Any]
            
            //Update
            self.databaseRef.updateChildValues(childUpdates)
            
            })
            
            //Find State
                
                CLGeocoder().reverseGeocodeLocation(myLocation!) {(placemarks,error) in
                    
                    if error != nil{
                        
                    }//if error != nil{
                    else
                    {
                        if let placemark = placemarks?[0] {
                      
                            if placemark.subAdministrativeArea != nil {
                                self.userCity = placemark.subAdministrativeArea! + " "
                            }
                            
                            if placemark.postalCode != nil {
                                self.userState = placemark.administrativeArea! + " "
                            }
                            
                        }
                        
                        let childUpdates = ["/users/\(self.loggedInUser!)/city":self.userCity, "/users/\(self.loggedInUser!)/state":self.userState] as [String : Any]
                        self.databaseRef.updateChildValues(childUpdates)
                        self.locationManager.stopUpdatingLocation()
                        
                        //Save user properties
                        FIRAnalytics.setUserPropertyString(self.userCity, forName: "City")
                        FIRAnalytics.setUserPropertyString(self.userState, forName: "State")
                        
                    }
            
                }
        
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
