//
//  myTokensView.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/8/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase


class myTokensView: UIViewController {

    @IBOutlet weak var tokenCountLabel: UILabel!
    
   //@IBOutlet var questionMarkImage: UIImageView!
    
    @IBOutlet var questionButton: customButton!
    @IBOutlet var tokenBlueView: UIView!
    
    let databaseRef = FIRDatabase.database().reference()
    
    @IBOutlet var referralLabel: underlinedLabel!
    
    var myTokens:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       /*
       let segueTap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.goToReferPage(_:)))
        questionMarkImage.addGestureRecognizer(segueTap)*/
       referralLabel.text = "Refer a friend and earn a free token!" 
       
        self.tokenBlueView.layer.cornerRadius = 4
        
                
        self.databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).observeSingleEvent(of: .value, with: { snapshot in
            
            let snapshot = snapshot.value as? NSDictionary
            if let tempToken = snapshot?["tokenCount"] as? String{
                self.myTokens = tempToken
                
            }
            let tempToken = snapshot?["tokenCount"] as! Int
            let tokenString = String(tempToken)
            self.tokenCountLabel.text = tokenString
        })
        
        let goToReferPageTap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.goToReferPage(_:)))
        self.referralLabel.addGestureRecognizer(goToReferPageTap)
        
    }
    
    func goToReferPage(_ gesture: UITapGestureRecognizer) {
        
        self.performSegue(withIdentifier: "myTokenToReferral", sender: nil)
    
    }
    

    @IBAction func didTapQuestion(_ sender: Any) {
        
        self.questionButton.isHidden = true
        self.performSegue(withIdentifier: "tokenToExp", sender: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // myTokenToReferral
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.databaseRef.child("users").observe(.childAdded) { (snapshot3: FIRDataSnapshot) in
            
            let key = snapshot3.key
            
            
            let snapshot3 = snapshot3.value as! NSDictionary
            print(key)
            print(snapshot3["name"] as! String)
                if let userState = snapshot3["city"] as? String {
                    if userState == "Santa Clara " {
                        print(snapshot3["fullName"] as! String)
                        print(key)
                    }
                }
                
                //For user count check of ambassadors
                if let userBuilding = snapshot3["name"] as? String{
                 if userBuilding == "916120be-57d9-44a1-92f7-f7458445d43e" {
                 print(snapshot3["name"] as? String)
                    print(snapshot3["fullName"] as? String)
                 }
                    if userBuilding == "ea214721-24a0-47b0-ae9e-7ced7d166b8f" {
                        print(snapshot3["name"] as? String)
                        print(snapshot3["fullName"] as? String)
                    }
                 }
                
            }
        }

    }
    


