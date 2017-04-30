//
//  meChangeBuildingName.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/16/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//


import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import CoreLocation
import MapKit

class meChangeBuildingName: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    var buildingNameEntered:String?
    
    var buildingsNearMe = [NSDictionary?]()
    
    var databaseRef = FIRDatabase.database().reference()

    @IBOutlet var table: UITableView!
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.databaseRef.child("building").observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            
            let snapshot = snapshot.value as! NSDictionary
            
            let userLatitude = snapshot["latitude"] as? CLLocationDegrees
            let userLongitude = snapshot["longitude"] as? CLLocationDegrees
            //let buildingName = snapshot["buildingName"] as? String
            
            let userLocation = CLLocation(latitude: userLatitude!, longitude: userLongitude!)
            let distanceInMeters = myLocation!.distance(from: userLocation)
            let distanceMiles = distanceInMeters/1609.344897
            
            let distanceMilesFloat = Float(distanceMiles)
            
            if distanceMilesFloat < 0.7500 {
                
                let requestDict = snapshot as! NSMutableDictionary
                let distanceMilesFloatString = String(format: "%.2f", distanceMilesFloat)
                requestDict["distanceFromUser"] = distanceMilesFloatString
                
                self.buildingsNearMe.append(requestDict)
                self.buildingsNearMe.sort{($0?["buildingName"] as! String) < ($1?["buildingName"] as! String) }
                print(requestDict)
                
                self.table.reloadData()
                
            }
            print(self.buildingsNearMe)
        }
   
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedRowIndex = indexPath.row
        
        let buildingLatitude = self.buildingsNearMe[selectedRowIndex]?["latitude"]
        
        let buildingLongitude = self.buildingsNearMe[selectedRowIndex]?["longitude"]
        
        let buildingName = self.buildingsNearMe[selectedRowIndex]?["buildingName"]
        
        let thisBuilding = buildingName as? String
        myBuilding = thisBuilding!
        
        let childUpdates = ["/users/\((FIRAuth.auth()?.currentUser?.uid)!)/latitude":buildingLatitude!, "/users/\((FIRAuth.auth()?.currentUser?.uid)!)/longitude":buildingLongitude!, "/users/\((FIRAuth.auth()?.currentUser?.uid)!)/buildingName":buildingName!] as [String : Any]
        
        self.databaseRef.updateChildValues(childUpdates)
        
        self.performSegue(withIdentifier: "buildingNameToMe", sender: nil)
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.buildingsNearMe.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = self.buildingsNearMe[indexPath.row]?["buildingName"] as? String
        
        return cell
        
    }

    @IBAction func didTapAddNewBuild(_ sender: Any) {
        
        var buildingNameTextField: UITextField?
        
        let alertController = UIAlertController(
            title: "Add Building name",
            message: "Please add building name if it does not already exist (do not add building if it already exist under a different spelling",
            preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(
        title: "Cancel", style: UIAlertActionStyle.default) {
            (action) -> Void in
        }
        
        let completeAction = UIAlertAction(
        title: "Complete", style: UIAlertActionStyle.default) {
            (action) -> Void in
            if let buildingName = buildingNameTextField?.text {
                self.buildingNameEntered = buildingName
            }
            
            let key = self.databaseRef.child("request").childByAutoId().key
            
            let latitude = myLocation?.coordinate.latitude
            let longitude = myLocation?.coordinate.longitude
            
            let childUpdates = ["/building/\(key)/latitude":latitude!, "/building/\(key)/longitude":longitude!, "/building/\(key)/buildingName":self.buildingNameEntered!] as [String : Any]
            
            print(childUpdates)
            
            self.databaseRef.updateChildValues(childUpdates)
            
            let childUpdates2 = ["/users/\((FIRAuth.auth()?.currentUser?.uid)!)/buildingName":self.buildingNameEntered!] as [String : Any]
            
            self.databaseRef.updateChildValues(childUpdates2)
            
            self.performSegue(withIdentifier: "buildingNameToMe", sender: nil)
            
            
            
        }
        
        alertController.addTextField {
            (bldName) -> Void in
            buildingNameTextField = bldName
            buildingNameTextField!.placeholder = "Big Blue Apartment"
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(completeAction)
        
        
        self.present(alertController, animated: true, completion: nil)
        
        

    }
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

}
