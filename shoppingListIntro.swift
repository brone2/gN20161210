//
//  shoppingListIntro.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 3/10/17.
//  Copyright © 2017 Neil Bronfin. All rights reserved.
//

import UIKit

class shoppingListIntro: UIViewController {

    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var greyBackground: UIView!
    
    var leadingConstraint: NSLayoutConstraint?
    var leadingConstraintValue:CGFloat?
    
    var isIntro = true
    
    var nextCount = 0
    
    @IBAction func didTapSkip(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "introToFallCoin", sender: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        if isLargeScreen {
            self.leadingConstraintValue = -255.0
        } else {
            self.leadingConstraintValue = -235.0
        }
        
        self.leadingConstraint = self.backgroundImage.topAnchor.constraint(equalTo: self.greyBackground.topAnchor, constant: self.leadingConstraintValue!)
        NSLayoutConstraint.activate([self.leadingConstraint!])
            
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func didTapNext(_ sender: Any) {
        
        self.nextCount += 1
        
        if self.nextCount ==  1{
            
            if isLargeScreen {
                self.leadingConstraintValue = -260.0
            } else {
                self.leadingConstraintValue = -240.0
            }
            
            self.leadingConstraint?.isActive = false
            self.leadingConstraint = self.backgroundImage.topAnchor.constraint(equalTo: self.greyBackground.topAnchor, constant: self.leadingConstraintValue!)
            NSLayoutConstraint.activate([self.leadingConstraint!])
            
            
            self.textLabel.text = "Once Justin purchases the snickers, he taps \"Purchase Complete\" and enters $1.25. Neil is notified he must repay Justin $1.25 upon delivery."
            
            self.backgroundImage.image = UIImage(named: "purchaseCompleteIntro4.png")
            
        } else if self.nextCount == 2 {
            
            self.textLabel.text = "Justin arrives at Neil's apartment and delivers the Snickers. Neil venmos Justin $1.25 and selects \"Mark as Complete\" to close the request."
            
            self.backgroundImage.image = UIImage(named: "justinComplete2.png")

            
        } else if self.nextCount == 3 {
            
            self.textLabel.text = "One Token is transferred from Neil's account to Justin's for the delivery. Neil can only earn more tokens by making deliveries himself."
            
            self.backgroundImage.image = UIImage(named: "justinIsClosed3.png")
            
        }   else    {
            
            self.performSegue(withIdentifier: "introToFallCoin", sender: nil)
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //
        
        
        
        if segue.identifier == "introToFallCoin" {
            
            let newViewController = segue.destination as! deliveryCompletePopUp
            newViewController.isIntro = true
            
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
