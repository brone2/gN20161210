//
//  deliveryCompletePopUp.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 3/8/17.
//  Copyright © 2017 Neil Bronfin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class deliveryCompletePopUp: UIViewController {

    
    @IBOutlet var introTextLabel: UILabel!
    @IBOutlet var animateView: UIView!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var tokenImage: UIImageView!
    @IBOutlet var greyView: UIView!
    @IBOutlet var greatJobTextLabel: UILabel!
    @IBOutlet var coverUpGreyView: UIView!
    @IBOutlet var completedRequestLabel: UILabel!
    @IBOutlet var introText: UILabel!
    @IBOutlet var goToAppButton: customButton!
    var fallToY:CGFloat?
    
    var requestPopUp:NSDictionary?
    var timer = Timer()
    var time = 0
    
    @IBOutlet var fallButtonImage1: UIImageView!
    @IBOutlet var fallButtonImage2: UIImageView!
    
    @IBOutlet var fallButton3: UIImageView!
    @IBOutlet var fallButtonImage4: UIImageView!
    
    var isIntro = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.animateView.layer.cornerRadius = 3
        self.animateView.layer.masksToBounds = true
        
        self.goToAppButton.isHidden = true
        
    if !isIntro {
        let deliverToName = self.requestPopUp?["requesterName"] as! String
        let itemName = self.requestPopUp?["itemName"] as! String
        let tokensOffered = self.requestPopUp?["tokensOffered"] as! Int
       
        

        
        if tokensOffered == 1 {
            
            self.textLabel.text = "\(deliverToName) has marked their request of \(itemName) as complete! One token will now be transferred to your account "
            self.tokenImage.image = UIImage(named: "1handshakeIcon.png")
            
        } else {
            
            self.textLabel.text = "\(deliverToName) has marked their request of \(itemName) as complete! Two tokens will now be transferred to your account "
            self.tokenImage.image = UIImage(named: "2handshakeIcon.png")
            
            
     
            
        }
    } else {
        
        self.introText.text = "Now it is your turn to make a request! If anything is unclear, select the blue or yellow question marks for an explanation. "
        self.tokenImage.isHidden = true
        self.textLabel.isHidden = true
        self.completedRequestLabel.isHidden = true
        self.goToAppButton.isHidden = false
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        //self.goToAppButton.center = CGPoint(x: screenWidth/2 - 112/2, y: 438)
        //self.goToAppButton.frame = CGRect(x: (screenWidth/2) - (112/2), y: 438, width: 112, height: 35)
        self.goToAppButton.center = CGPoint(x: screenWidth/2, y: 438)
        
        
        }
        
      timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(deliveryCompletePopUp.startTimer), userInfo: nil, repeats: true)
        
    }
    
   func startTimer() {
        time += 1
        if time == 4 && !isIntro {
            self.hideInitalViews()
        }
    

    
    }
    
    func hideInitalViews() {
        
        timer.invalidate()
        self.coverUpGreyView.isHidden = true
        self.fallButtonImage1.isHidden = true
        self.fallButtonImage2.isHidden = true
        self.fallButton3.isHidden = true
        self.fallButtonImage4.isHidden = true
        self.greatJobTextLabel.isHidden = true
        
    }


    override func viewDidAppear(_ animated: Bool) {
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        //let screenHeight = screenSize.height
        let screenWidth = screenSize.height
       
        self.fallButtonImage1.center = CGPoint(x: 55, y: -20)
        self.fallButtonImage2.center = CGPoint(x: screenWidth/2 - screenWidth/3.4, y: -20)
        self.fallButton3.center = CGPoint(x: screenWidth/2 - screenWidth/8, y: -20)
        
        if isLargeScreen{
        self.fallButtonImage4.center = CGPoint(x: screenWidth - 365, y: -20)
        } else {
            self.fallButtonImage4.center = CGPoint(x: screenWidth - 340, y: -20)
        }
        
        self.fallButtonImage1.alpha = 1
        self.fallButtonImage2.alpha = 1
        self.fallButton3.alpha = 1
        self.fallButtonImage4.alpha = 1
        
        
        //move it back in
        
        UIView.animate(withDuration: 2){
       
        self.completedRequestLabel.alpha = 1
        self.goToAppButton.alpha  = 1
            
        }
        
        
        
        if isIntro{
            self.fallToY = self.view.frame.height - 60
        } else {
            self.fallToY = self.view.frame.height - 60 + 20
        }

        UIView.animate(withDuration: 4){
            self.fallButtonImage1.center = CGPoint(x: 55, y: self.fallToY!)
            self.fallButtonImage2.center = CGPoint(x: screenWidth/2 - screenWidth/3.4, y: self.fallToY!)
            self.fallButton3.center = CGPoint(x: screenWidth/2 - screenWidth/8, y: self.fallToY!)
            
            if isLargeScreen {
            self.fallButtonImage4.center = CGPoint(x: screenWidth - 365, y: self.fallToY!)
            } else {
                self.fallButtonImage4.center = CGPoint(x: screenWidth - 340, y: self.fallToY!)
            }
        }
        
        
    }
    
    @IBAction func didTapGoToApp(_ sender: Any) {
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    @IBAction func didTapOk(_ sender: Any) {
        
        self.performSegue(withIdentifier: "introToRequest", sender: nil)
    }
  

}
