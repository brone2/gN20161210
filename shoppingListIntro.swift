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
            
            
            self.textLabel.text = "Once Justin purchases the snickers, he taps \"Purchase Complete\" and enters $1.25. Taylor is notified she must repay Justin $1.25 upon delivery."
            
            self.backgroundImage.image = UIImage(named: "pComplete.png") //UIImage(named: "purchaseCompleteIntro4.png")
            
        } else if self.nextCount == 2 {
            
            self.textLabel.text = "Justin arrives at Taylor's apartment and delivers the Snickers. Taylor venmos Justin $3.25 ($1.25 for the snickers and $2.00 delivery fee) and selects \"Mark as Complete\" to close the request."
            
            self.backgroundImage.image = UIImage(named: "purchaseCompleteIntro4.png")

            
        } else if self.nextCount == 3 {
            
            self.textLabel.text = "The delivery is complete thanks to Goodneighbor Justin!"
            
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
