//
//  runDetail.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 6/14/17.
//  Copyright © 2017 Neil Bronfin. All rights reserved.
//

import UIKit
import OneSignal
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import SDWebImage
import CoreLocation

class runDetail: UIViewController {

    @IBOutlet var runByLabel: UILabel!
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var notesTextview: UITextView!
    
    var tokensOffered = 1
    
    var databaseRef = FIRDatabase.database().reference()
    var communityRuns = [NSDictionary?]()
    var selectedRowIndex:Int!
    var selectedRun:NSDictionary?
    
    @IBOutlet var grayView: UIView!
    @IBOutlet var runTimeLabel: UILabel!
    @IBOutlet var runTo: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.grayView.layer.cornerRadius = 5
        self.grayView.layer.masksToBounds = true
        
        self.notesTextview.layer.borderWidth = 1
        self.notesTextview.layer.borderColor = UIColor.black.cgColor
        
        self.notesTextview.text = self.communityRuns[self.selectedRowIndex]?["notesField"] as! String
        
        self.tokensOffered = self.communityRuns[self.selectedRowIndex]?["tokensOffered"] as! Int
        
        self.runTo.text = self.communityRuns[self.selectedRowIndex]?["runTo"] as? String
        
        self.runByLabel.text = String("Run by \(self.communityRuns[self.selectedRowIndex]?["runnerName"] as! String)")
        
        self.runTimeLabel.text = String("Will end around \(self.communityRuns[self.selectedRowIndex]?["timeRun"] as! String)")

        if let image = self.communityRuns[self.selectedRowIndex]?["profilePicReference"] as? String {
            
            let data = try? Data(contentsOf: URL(string: image)!)
            
            self.profilePic.image = UIImage(data: data!)
            
        }
        
        self.profilePic.layer.cornerRadius = 40
        self.profilePic.layer.masksToBounds = true
        self.profilePic.contentMode = .scaleAspectFit
        self.profilePic.layer.borderWidth = 2.0
        self.profilePic.layer.borderColor = UIColor(red: 16/255, green: 126/255, blue: 207/255, alpha: 1).cgColor
        
        let imageTap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapMediaInTweet(_:)))
        self.profilePic.addGestureRecognizer(imageTap)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func didTapRequest(_ sender: Any) {
        
        self.selectedRun = communityRuns[self.selectedRowIndex]
        
        self.performSegue(withIdentifier: "goToReqDelForRun", sender: nil)
        
        
    }
    
    
    
    @IBAction func didTapBack(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }

// Go to request segue prep
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //
        
        if segue.identifier == "goToReqDelForRun" {
            
            let secondViewController = segue.destination as! requestItem
            secondViewController.isRun =  true
            secondViewController.selectedRun =  self.selectedRun
            secondViewController.tokensOffered =  self.tokensOffered
        }
        
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
}
