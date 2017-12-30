//
//  viewDetailDeliveryView.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/11/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class viewDetailDeliveryView: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var productImage: UIImageView!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var productNameLabel: UILabel!
    @IBOutlet var profilePicImage: UIImageView!
    @IBOutlet var requestByLabel: UILabel!
    @IBOutlet var deliveryLocation: UILabel!
    
    var isMyRun = false
    var myRun = [NSDictionary?]()
    
    var currentUserName:String!
    var loggedInUserId:String!
    var acceptedTime = NSDate()
    var databaseRef = FIRDatabase.database().reference()
    var myCurrentDeliveries = [NSDictionary?]()
    var selectedRowIndex:Int!
    
    var isRun = false
    var runRequest = [NSDictionary?]()
    
    @IBOutlet var grayView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.grayView.layer.cornerRadius = 5
        self.grayView.layer.masksToBounds = true
        
        self.productImage.layer.cornerRadius = 3
        self.productImage.layer.masksToBounds = true
        self.productImage.contentMode = .scaleAspectFill

        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.black.cgColor

        
        self.loggedInUserId = FIRAuth.auth()?.currentUser?.uid
        
        if isMyRun {
            
            self.requestByLabel.text = String("My run to \(self.myRun[self.selectedRowIndex]?["runTo"] as! String)")
            self.deliveryLocation.text = String("Run will end around \(self.myRun[self.selectedRowIndex]?["timeRun"] as! String)")
            self.productNameLabel.text = "Description"
            
            let requestCount = self.myRun[selectedRowIndex]?["requestCount"] as! Int

            self.distanceLabel.text = String("\(requestCount) requests to this run")
            
            self.descriptionTextView.text = self.myRun[self.selectedRowIndex]?["notesField"] as! String
            
            
            if let image = self.myRun[self.selectedRowIndex]?["profilePicReference"] as? String {
                
                let data = try? Data(contentsOf: URL(string: image)!)
                
                self.profilePicImage.image = UIImage(data: data!)
                
            }
            
            self.profilePicImage.layer.cornerRadius = 40
            self.profilePicImage.layer.masksToBounds = true
            self.profilePicImage.contentMode = .scaleAspectFit
            self.profilePicImage.layer.borderWidth = 2.0
            self.profilePicImage.layer.borderColor = UIColor(red: 16/255, green: 126/255, blue: 207/255, alpha: 1).cgColor
            
            if let image = self.myRun[self.selectedRowIndex]?["productImage"] as? String {
                
                let data = try? Data(contentsOf: URL(string: image)!)
                
                self.productImage.image = UIImage(data: data!)
                
            }
        } else {
        
        if !isRun {
            
        self.requestByLabel.text = String("Requested by \(self.myCurrentDeliveries[self.selectedRowIndex]?["requesterName"] as! String)")
        
        let deliverySpot = self.myCurrentDeliveries[self.selectedRowIndex]?["deliverTo"] as! String
            
            if deliverySpot == "My door" {
                
                self.deliveryLocation.text = String("Please deliver to \(self.myCurrentDeliveries[self.selectedRowIndex]?["deliverTo"] as! String)")
                
            } else {
                
                self.deliveryLocation.text = String("\(self.myCurrentDeliveries[self.selectedRowIndex]?["deliverTo"] as! String)") 
                
            }
            
        
            
            
        self.productNameLabel.text = String("\(self.myCurrentDeliveries[self.selectedRowIndex]?["itemName"] as! String)")
               
        let buildingCheck = self.self.myCurrentDeliveries[self.selectedRowIndex]?["buildingName"] as? String
        
        if buildingCheck != "N/A" {
            
            self.distanceLabel.text = String("Lives in \(buildingCheck!)")
            
        } else {
            
            self.distanceLabel.text = String("Located \(self.self.myCurrentDeliveries[self.selectedRowIndex]?["distanceFromUser"] as! String) mi away from you")
            
        }
        
        self.descriptionTextView.text = self.myCurrentDeliveries[self.selectedRowIndex]?["description"] as! String
        
        
        if let image = self.myCurrentDeliveries[self.selectedRowIndex]?["profilePicReference"] as? String {
            
            let data = try? Data(contentsOf: URL(string: image)!)
            
            self.profilePicImage.image = UIImage(data: data!)
            
        }
        
        self.profilePicImage.layer.cornerRadius = 40
        self.profilePicImage.layer.masksToBounds = true
        self.profilePicImage.contentMode = .scaleAspectFit
        self.profilePicImage.layer.borderWidth = 2.0
        self.profilePicImage.layer.borderColor = UIColor(red: 16/255, green: 126/255, blue: 207/255, alpha: 1).cgColor
        
        if let image = self.myCurrentDeliveries[self.selectedRowIndex]?["productImage"] as? String {
            
            let data = try? Data(contentsOf: URL(string: image)!)
            
            self.productImage.image = UIImage(data: data!)
            
        }
        } else {
           print(runRequest)
            self.requestByLabel.text = String("Requested by \(self.runRequest[self.selectedRowIndex]?["requesterName"] as! String)")
            self.deliveryLocation.text = String("Please deliver to \(self.runRequest[self.selectedRowIndex]?["deliverTo"] as! String)")
            self.productNameLabel.text = String("\(self.runRequest[self.selectedRowIndex]?["itemName"] as! String)")
            
            let buildingCheck = self.self.runRequest[self.selectedRowIndex]?["buildingName"] as? String
            
            if buildingCheck != "N/A" {
                
                self.distanceLabel.text = String("Lives in \(buildingCheck!)")
                
            } else {
                
                self.distanceLabel.text = String("Located \(self.self.runRequest[self.selectedRowIndex]?["distanceFromUser"] as! String) mi away from you")
                
            }
            
            self.descriptionTextView.text = self.runRequest[self.selectedRowIndex]?["description"] as! String
            
            
            if let image = self.runRequest[self.selectedRowIndex]?["profilePicReference"] as? String {
                
                let data = try? Data(contentsOf: URL(string: image)!)
                
                self.profilePicImage.image = UIImage(data: data!)
                
            }
            
            self.profilePicImage.layer.cornerRadius = 40
            self.profilePicImage.layer.masksToBounds = true
            self.profilePicImage.contentMode = .scaleAspectFit
            self.profilePicImage.layer.borderWidth = 2.0
            self.profilePicImage.layer.borderColor = UIColor(red: 16/255, green: 126/255, blue: 207/255, alpha: 1).cgColor
            
            if let image = self.runRequest[self.selectedRowIndex]?["productImage"] as? String {
                
                let data = try? Data(contentsOf: URL(string: image)!)
                
                self.productImage.image = UIImage(data: data!)
                
            }

            
            
            
        }
        
        let imageTap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapMediaInTweet(_:)))
        let imageTap2:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapMediaInTweet(_:)))
        
        self.profilePicImage.addGestureRecognizer(imageTap2)
        self.productImage.addGestureRecognizer(imageTap)

    }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func didTapMediaInTweet(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        
        newImageView.frame = self.view.frame
        
        newImageView.backgroundColor = UIColor.black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissFullScreenImage))
        
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        
    }
    func dismissFullScreenImage(sender: UITapGestureRecognizer){
        sender.view?.removeFromSuperview()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

}
