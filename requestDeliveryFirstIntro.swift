//
//  requestDeliveryFirstIntro.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 3/10/17.
//  Copyright © 2017 Neil Bronfin. All rights reserved.
//

import UIKit

class requestDeliveryFirstIntro: UIViewController {

    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var requestLabel: UILabel!
    @IBOutlet var tokenLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var enterItemNameLabel: UILabel!
    @IBOutlet var bottomGrayLabel: UIView!
    @IBOutlet var detailDescripLabel: UILabel!
    @IBOutlet var greyView: UIView!
    @IBOutlet var nextButton: customButton!
    @IBOutlet var venmoGreyLabel: UIView!
    var leadingConstraint: NSLayoutConstraint?
    var leadingConstraintValue:CGFloat?
    
    var continueCount = 0
    
    
    @IBAction func didTapNext(_ sender: Any) {
        
        self.continueCount += 1
        
        self.nextMove()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //isLargeScreen = true
        self.nextMove()
       

        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func nextMove()  {
        
        let yButtonNumber:CGFloat = 70.0
        if self.continueCount == 0 {
            self.priceLabel.isHidden = true
            self.descriptionLabel.isHidden = true
            self.tokenLabel.isHidden = true
            self.requestLabel.isHidden = true
            self.detailDescripLabel.isHidden = true
            
            self.enterItemNameLabel.frame = CGRect(x: 18, y: 15, width: 375, height: 21)
            
            self.nextButton.frame = CGRect(x: view.frame.width/2 - self.nextButton.frame.width/2, y: yButtonNumber, width: 105, height: 30)
            
            if isLargeScreen {
                self.leadingConstraintValue = 134.0
            } else {
                self.leadingConstraintValue = 130.0
            }
         
             self.leadingConstraint = self.greyView.topAnchor.constraint(equalTo: self.backgroundImage.topAnchor, constant: self.leadingConstraintValue!)
            NSLayoutConstraint.activate([self.leadingConstraint!])

            
        } else if self.continueCount == 1 {
        
            self.priceLabel.isHidden = false
            self.enterItemNameLabel.isHidden = true
            self.enterItemNameLabel.frame = CGRect(x: 18, y: 15, width: 375, height: 21)
            
              self.nextButton.frame = CGRect(x: view.frame.width/2 - self.nextButton.frame.width/2, y: yButtonNumber, width: 105, height: 30)

            if isLargeScreen {
                self.leadingConstraintValue = 200.0
                self.venmoGreyLabel.frame = CGRect(x: 240, y: 154, width: 136, height: 42)
            } else {
                self.leadingConstraintValue = 180.0
                self.venmoGreyLabel.frame = CGRect(x: 213, y: 137, width: 136, height: 42)
            }
            
        self.leadingConstraint?.isActive = false
        self.leadingConstraint = self.greyView.topAnchor.constraint(equalTo: self.backgroundImage.topAnchor, constant: self.leadingConstraintValue!)
            NSLayoutConstraint.activate([self.leadingConstraint!])
            
        }else if self.continueCount == 2 {
            
            self.venmoGreyLabel.isHidden = true
            self.priceLabel.text = "Taylor selects to pay via Venmo"
            
            
            
        }else if self.continueCount == 3 {
           
            self.detailDescripLabel.isHidden = false
            self.priceLabel.isHidden = true
            self.detailDescripLabel.frame = CGRect(x: 18, y: 15, width: 375, height: 21)
            
            self.nextButton.frame = CGRect(x: view.frame.width/2 - self.nextButton.frame.width/2, y: yButtonNumber, width: 105, height: 30)
            
            if isLargeScreen {
                self.leadingConstraintValue = 380.0
            } else {
                self.leadingConstraintValue = 340.0
            }
            
            self.leadingConstraint?.isActive = false
            self.leadingConstraint = self.greyView.topAnchor.constraint(equalTo: self.backgroundImage.topAnchor, constant: self.leadingConstraintValue!)
            NSLayoutConstraint.activate([self.leadingConstraint!])
            
        } else if self.continueCount == 4 {
           
            self.tokenLabel.isHidden = false
            self.detailDescripLabel.isHidden = true
            self.tokenLabel.frame = CGRect(x: 18, y: 15, width: 375, height: 21)
            self.nextButton.frame = CGRect(x: view.frame.width/2 - self.nextButton.frame.width/2, y: yButtonNumber, width: 105, height: 30)
            
            if isLargeScreen {
                self.leadingConstraintValue = 510.0
            } else {
                self.leadingConstraintValue = 460.0
            }
            
            self.leadingConstraint?.isActive = false
            self.leadingConstraint = self.greyView.topAnchor.constraint(equalTo: self.backgroundImage.topAnchor, constant: self.leadingConstraintValue!)
            NSLayoutConstraint.activate([self.leadingConstraint!])
            
        } else if self.continueCount == 5 {
            
            self.performSegue(withIdentifier: "reqBackIntro", sender: nil)
            /*self.requestLabel.isHidden = false
            self.tokenLabel.isHidden = true
            
            self.requestLabel.frame = CGRect(x: 18, y: 15, width: 375, height: 21)
            self.nextButton.frame = CGRect(x: view.frame.width/2 - self.nextButton.frame.width/2, y: yButtonNumber, width: 105, height: 30)
            
             self.greyView.frame = CGRect(x: 0, y: 597, width: 375, height: 70)
            
        */}
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //
        
        
            
            if segue.identifier == "reqBackIntro" {
                
                let newViewController = segue.destination as! snickerIntroPage
                newViewController.continueCount = 2
                
            }
        
        
            
            
            
            if segue.identifier == "skipToComplete2" {
                
                let newViewController = segue.destination as! deliveryCompletePopUp
                newViewController.isIntro = true
                
            }
            
        

        
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
