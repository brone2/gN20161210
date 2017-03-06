//
//  explanationShoppingList.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 2/12/17.
//  Copyright © 2017 Neil Bronfin. All rights reserved.
//

import UIKit

class explanationShoppingList: UIViewController {

    
    
    var isIntro = false
    var yPoint:CGFloat = 360
    var distanceBetweenButtons: CGFloat = 35
    
    @IBOutlet var explanationLabel: UILabel!
    @IBOutlet var deliveryLocationButton: UIButton!
    @IBOutlet var itemRequestButton: UIButton!
    @IBOutlet var willingToPayButton: UIButton!
    @IBOutlet var tokenButton: UIButton!
    @IBOutlet var pickUpButton: UIButton!
    @IBOutlet var continueButton: customButton!
    
    @IBOutlet var exampleImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !self.isIntro {
            self.continueButton.setTitle("OK", for: [])
        }
        
        if isSmallScreen {
            
            self.yPoint = 330
            self.distanceBetweenButtons = 25
            
            self.itemRequestButton.frame = CGRect(x: 34, y: yPoint, width: 169, height: 30)
            self.itemRequestButton.contentHorizontalAlignment = .left
            
            self.deliveryLocationButton.frame = CGRect(x: 34, y: (yPoint + distanceBetweenButtons), width: 469, height: 30)
            self.deliveryLocationButton.contentHorizontalAlignment = .left
            
            self.pickUpButton.frame = CGRect(x: 34, y: yPoint + 2*distanceBetweenButtons, width: 469, height: 30)
            self.pickUpButton.contentHorizontalAlignment = .left
            
            self.tokenButton.frame = CGRect(x: 34, y: yPoint + 3*distanceBetweenButtons, width: 469, height: 30)
            self.tokenButton.contentHorizontalAlignment = .left
            
            self.willingToPayButton.frame = CGRect(x: 34, y: yPoint + 4*distanceBetweenButtons, width: 469, height: 30)
            self.willingToPayButton.contentHorizontalAlignment = .left
            
            
            
            if self.isIntro {
                self.continueButton.frame = CGRect(x: view.frame.width/2 - 70, y: yPoint + 165, width: 140, height: 30)
            } else {
                self.continueButton.frame = CGRect(x: view.frame.width/2 - 50, y: yPoint + 165, width: 100, height: 30)
            }
            
            self.exampleImage.frame = CGRect(x: 0, y: 200, width: view.frame.width, height: 83)
            
            self.explanationLabel.frame = CGRect(x: 21, y: 30, width: view.frame.width - 40, height: 189)
            
            //self.explanationLabel.font = UIFont.systemFont(ofSize: 13.0)
            
        }  else  { //Normal (iPhone 6) size
        
            if isLargeScreen {
                  self.explanationLabel.frame = CGRect(x: view.frame.width/2 - 332/2, y: 50, width: 332, height: 189)
            } else {
                  self.explanationLabel.frame = CGRect(x: 21, y: 50, width: 332, height: 189)

            }
        
        self.itemRequestButton.frame = CGRect(x: 34, y: yPoint, width: 169, height: 30)
        self.itemRequestButton.contentHorizontalAlignment = .left
        
        self.deliveryLocationButton.frame = CGRect(x: 34, y: (yPoint + distanceBetweenButtons), width: 469, height: 30)
        self.deliveryLocationButton.contentHorizontalAlignment = .left
        
        self.pickUpButton.frame = CGRect(x: 34, y: yPoint + 2*distanceBetweenButtons, width: 469, height: 30)
        self.pickUpButton.contentHorizontalAlignment = .left
        
        self.tokenButton.frame = CGRect(x: 34, y: yPoint + 3*distanceBetweenButtons, width: 469, height: 30)
        self.tokenButton.contentHorizontalAlignment = .left
        
        self.willingToPayButton.frame = CGRect(x: 34, y: yPoint + 4*distanceBetweenButtons, width: 469, height: 30)
        self.willingToPayButton.contentHorizontalAlignment = .left
        
        
            
            if self.isIntro {
                self.continueButton.frame = CGRect(x: view.frame.width/2 - 70, y: yPoint + 195, width: 140, height: 30)
            } else {
                self.continueButton.frame = CGRect(x: view.frame.width/2 - 50, y: yPoint + 195, width: 100, height: 30)
            }
        
        self.exampleImage.frame = CGRect(x: 0, y: 200, width: view.frame.width, height: 83)
        
      
        }
        

        // Do any additional setup after loading the view.
    }

    @IBAction func didTapItemRequested(_ sender: Any) {
        
        self.makeAlert(title: "Item Requested", message: "Enter in the item name, in this example a Dozen eggs is requested")
    }
    
    
    @IBAction func didTapNameDelivery(_ sender: Any) {
        
        self.makeAlert(title: "Name and Delivery Location", message: "This line will tell you the persons name and delivery location. In this example, Neil is the requestor. Neil lives 0.1 miles away from your delivery location in a dorm called Dardick")
    }
    
    @IBAction func didTapPickUp(_ sender: Any) {
        
        self.makeAlert(title: "Pick up Location", message: "This line tells you where the requestor will meet you to pick up the item. In this example, Neil has requested that he meet you in his dorm lobby to pick up the item")
    }
    
    @IBAction func didTapToken(_ sender: Any) {
        
         self.makeAlert(title: "Tokens Offered for Delivery", message: "In order to make a request, the requestor must offer one or two tokens to the delivering Goodneighbor. Here, Neil has offered two tokens, suggesting he urgently wants a dozen eggs. A requestor can offer one token, in which case the image on the right side would be of a single coin. Once the delivery is completed, the delivering Goodneighbor will be paid these tokens from the requestor's account")
        
    }
    
    @IBAction func didTapWillingToPay(_ sender: Any) {
        
          self.makeAlert(title: "Willing to Pay", message: "The requestor must repay the delivering Goodneighbor the amount paid to purchase the item. As the requestor is unlikely to know the exact price the item cost in the store, he/she will enter the highest price they are willing to pay, so that they do not end up paying more for the item than they are willing to. For example, if I wanted a snickers bar, but did not want to pay a price of more than $3.00, I would enter $3.00. If someone was at a store and could find a snickers bar for $2.00, they would accept the delivery, and upon delivery I would pay them $2.00. However, had the price of the snickers bar been $4.00, they should not accept this delivery, because the price they would purchase it for is more than I am willing to pay")
   
    }
    
    
    @IBAction func didTapContinue(_ sender: Any) {
        
        if self.isIntro{
            self.performSegue(withIdentifier: "listExpToReqExp", sender: nil)
        } else {
            self.performSegue(withIdentifier: "expToList", sender: nil)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
  /*  @IBAction func didTapOk(_ sender: Any) {
        if self.isIntro{
        self.performSegue(withIdentifier: "listExpToReqExp", sender: nil)
        } else {
            self.performSegue(withIdentifier: "expToList", sender: nil)
        }
    }*/

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //
        
        if segue.identifier == "listExpToReqExp" {
            
            let secondViewController = segue.destination as! explanationRequest
            secondViewController.isIntro = self.isIntro
            
            
        }
    }
    
    func makeAlert(title: String, message: String)  {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            //do nothing
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }


}
