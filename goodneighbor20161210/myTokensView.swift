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
    
    @IBOutlet var tokenBlueView: UIView!
    
    let databaseRef = FIRDatabase.database().reference()
    
    var myTokens:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
