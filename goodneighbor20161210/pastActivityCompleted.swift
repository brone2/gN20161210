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
        print(relevantPastInfo)
        
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
        
        cell.requestedTimeLabel.text = "Requested on \(self.relevantPastInfo[indexPath.row]?["requestedTime"] as! String)"
        
        let tokenCountHelp:Int = (self.relevantPastInfo[indexPath.row]?["tokensOffered"] as? Int)!
        
        if tokenCountHelp == 1 {
            cell.coinImage.image = UIImage(named: "1FullToken.png")
        }
        if tokenCountHelp == 2 {
            cell.coinImage.image = UIImage(named: "2FullToken.png")
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    } 

}
