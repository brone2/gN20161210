//
//  pastActivityCompleted.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/11/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

/*
 @IBOutlet var coinImage: UIImageView!
 @IBOutlet var personNameLabel: UILabel!
 @IBOutlet var requestedTimeLabel: UILabel!
 @IBOutlet var nameLabel: UILabel!
 @IBOutlet var profilePic: UIImageView!
 */

class pastActivityCompleted: UIViewController, UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var table: UITableView!
    @IBOutlet var navBar: UINavigationBar!
    
    var relevantPastInfo = [NSDictionary?]()
    var navBarTitle:String?
    
    var databaseRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.topItem!.title = self.navBarTitle
        let attrs = [
            NSForegroundColorAttributeName: colorBlue,
            NSFontAttributeName: UIFont(name: "Georgia-Bold", size: 20)!
        ]
        
        UINavigationBar.appearance().titleTextAttributes = attrs
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.relevantPastInfo.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:mePastCompletedCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! mePastCompletedCell
        
        cell.nameLabel.text = self.relevantPastInfo[indexPath.row]?["itemName"] as? String
        
        cell.complaintButton.tag = indexPath.row
        
        cell.requestedTimeLabel.text = "Requested on \(self.relevantPastInfo[indexPath.row]?["requestedTime"] as! String)"
        
        let tokenCountHelp:Int = (self.relevantPastInfo[indexPath.row]?["tokensOffered"] as? Int)!
        
        if tokenCountHelp == 1 {
            cell.coinImage.image = UIImage(named: "1handshakeIcon.png")
        }
        if tokenCountHelp == 2 {
            cell.coinImage.image = UIImage(named: "2handshakeIcon.png")
        }
        
        //If viewing my deliveries
        if self.navBarTitle == "Completed Deliveries"{
            
         cell.personNameLabel.text = "Delivered to \(self.relevantPastInfo[indexPath.row]?["requesterName"] as! String)"
            
            DispatchQueue.main.async{
                if let image = self.relevantPastInfo[indexPath.row]?["profilePicReference"] as? String {
                    
                    let url = URL(string: image)
                    
                    cell.profilePic!.sd_setImage(with: url, placeholderImage: UIImage(named:"saveImage2.png")!)  
                }}
            
            cell.profilePic.layer.cornerRadius = 27.5
            cell.profilePic.layer.masksToBounds = true
            cell.profilePic.contentMode = .scaleAspectFit
            cell.profilePic.layer.borderWidth = 2.0
            cell.profilePic.layer.borderColor = UIColor(red: 16/255, green: 126/255, blue: 207/255, alpha: 1).cgColor
            

            
        } else { //if selects my requests
            
            cell.personNameLabel.text = "Delivered by \(self.relevantPastInfo[indexPath.row]?["accepterName"] as! String)"
            
            DispatchQueue.main.async{
                if let image = self.relevantPastInfo[indexPath.row]?["accepterProfilePicRef"] as? String {
                    
                    let url = URL(string: image)
                    
                    cell.profilePic!.sd_setImage(with: url, placeholderImage: UIImage(named:"saveImage2.png")!)
                }}
            
            cell.profilePic.layer.cornerRadius = 27.5
            cell.profilePic.layer.masksToBounds = true
            cell.profilePic.contentMode = .scaleAspectFit
            cell.profilePic.layer.borderWidth = 2.0
            cell.profilePic.layer.borderColor = UIColor(red: 16/255, green: 126/255, blue: 207/255, alpha: 1).cgColor

        }
        return cell
    }
    
    
    @IBAction func didTapFileComplaint(_ sender: UIButton) {
        
        let indexTag = sender.tag
        
        let myActionSheet = UIAlertController(title:"File Complaint",message:"Please let us know the issue encountered during the delivery",preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let aptLobby = UIAlertAction(title: "Payment issues", style: UIAlertActionStyle.default) { (action) in
            self.saveComplaint(issue: "Payment issues",indexTag: indexTag)
        }
        
        let myFloor = UIAlertAction(title: "Failed to meet at agreed location", style: UIAlertActionStyle.default) { (action) in
            self.saveComplaint(issue: "Failed to meet at agreed location",indexTag: indexTag)
        }
        
        let myDoor = UIAlertAction(title: "Rude/offensive", style: UIAlertActionStyle.default) { (action) in
            self.saveComplaint(issue: "Rude/offensive",indexTag: indexTag)
        }
        
        let buildingDesk = UIAlertAction(title: "Not on Time", style: UIAlertActionStyle.default) { (action) in
            self.saveComplaint(issue: "Not on Time",indexTag: indexTag)
        }
        
        let neighborChoice = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
            
        }
        
        myActionSheet.addAction(myDoor)
        myActionSheet.addAction(myFloor)
        myActionSheet.addAction(aptLobby)
        myActionSheet.addAction(buildingDesk)
        myActionSheet.addAction(neighborChoice)
        
        self.present(myActionSheet, animated: true, completion: nil)
        
        
    }
    
    func saveComplaint(issue: String, indexTag: Int) {
        
        let alertComplaintComplete = UIAlertController(title: "File Complaint", message: "A complaint against the selected user will be filed", preferredStyle: UIAlertControllerStyle.alert)
        
        alertComplaintComplete.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            return
        }))
        
        alertComplaintComplete.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            
        let key = self.databaseRef.child("complaint").childByAutoId().key
        
        if self.navBarTitle == "Completed Deliveries" {
            
            let complaintAgainst = self.relevantPastInfo[indexTag]?["requesterUID"] as! String
            let complaintBy = self.relevantPastInfo[indexTag]?["accepterUID"] as! String
            
            let complaintAgainstPath = "/complaint/\(key)/complaintAgainst"
            let complaintByPath = "/complaint/\(key)/complaintBy"
            let keyPath = "/complaint/\(key)/key"
            let complaintType = "/complaint/\(key)/type"
            
            let childUpdateComplaint:Dictionary<String, Any> = [complaintAgainstPath:complaintAgainst,complaintByPath:complaintBy,keyPath:key,complaintType:issue]
            
            self.databaseRef.updateChildValues(childUpdateComplaint)

            
        }
        else
        {
            
            let complaintAgainst = self.relevantPastInfo[indexTag]?["accepterName"] as! String
            let complaintBy = self.relevantPastInfo[indexTag]?["requesterName"] as! String
            
            let complaintAgainstPath = "/complaint/\(key)/complaintAgainst"
            let complaintByPath = "/complaint/\(key)/complaintBy"
            let keyPath = "/complaint/\(key)/key"
            let complaintType = "/complaint/\(key)/type"
            
            let childUpdateComplaint:Dictionary<String, Any> = [complaintAgainstPath:complaintAgainst,complaintByPath:complaintBy,keyPath:key,complaintType:issue]
            
            self.databaseRef.updateChildValues(childUpdateComplaint)

            
        }
            
        }))
    
        self.present(alertComplaintComplete, animated: true, completion: nil)
        
    }
    
    // Go to the message conversation

  
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    } 

}
