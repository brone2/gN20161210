//
//  explanationRequest.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 2/12/17.
//  Copyright © 2017 Neil Bronfin. All rights reserved.
//

import UIKit

class explanationRequest: UIViewController {
    
    var isIntro = false
    
    var yPoint:CGFloat = 334
    var distanceBetweenButtons: CGFloat = 38
    
    @IBOutlet var itemNameButton: UIButton!
    @IBOutlet var willingToPayButton: UIButton!
    
    @IBOutlet var venmoCashButton: UIButton!
    @IBOutlet var detailButton: UIButton!
    
    @IBOutlet var deliverToButton: UIButton!
    @IBOutlet var tokenButton: UIButton!
    @IBOutlet var imageButton: UIButton!

    @IBOutlet var inputsForRequestLabel: UILabel!
    @IBOutlet var continueButton: customButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !self.isIntro {
            self.continueButton.setTitle("OK", for: [])
        }

 
        if isSmallScreen {
            
            self.yPoint = 320
            
            self.distanceBetweenButtons = 30
            
            self.inputsForRequestLabel.frame = CGRect(x: view.frame.width/2 - self.inputsForRequestLabel.frame.width/2, y: yPoint - 96, width: 195, height: 36)
            
            if self.isIntro {
                self.continueButton.frame = CGRect(x: view.frame.width/2 - 50, y: yPoint + 185, width: 100, height: 30)
            } else {
                self.continueButton.frame = CGRect(x: view.frame.width/2 - 70, y: yPoint + 185, width: 140, height: 30)
            }

        } else {
            
         if self.isIntro {
            self.continueButton.frame = CGRect(x: view.frame.width/2 - 70, y: yPoint + 215, width: 140, height: 30)
         } else {
            self.continueButton.frame = CGRect(x: view.frame.width/2 - 50, y: yPoint + 215, width: 100, height: 30)
            }
            
            
            
        }
   
        
        self.yPoint = 260
        
        
        if isLargeScreen {
            self.inputsForRequestLabel.frame = CGRect(x: view.frame.width/2 - self.inputsForRequestLabel.frame.width/2, y: yPoint - 42, width: 195, height: 36)
        }
        
        self.itemNameButton.frame = CGRect(x: view.frame.width/2 - 169/2, y: yPoint, width: 169, height: 30)
        self.itemNameButton.contentHorizontalAlignment = .center
        
        self.willingToPayButton.frame = CGRect(x: view.frame.width/2 - 169/2, y: (yPoint + distanceBetweenButtons), width: 169, height: 30)
        self.willingToPayButton.contentHorizontalAlignment = .center
        
        self.venmoCashButton.frame = CGRect(x: view.frame.width/2 - 169/2, y: (yPoint + 2*distanceBetweenButtons), width: 169, height: 30)
        self.venmoCashButton.contentHorizontalAlignment = .center
        
        self.detailButton.frame = CGRect(x: view.frame.width/2 - 169/2, y: (yPoint + 3*distanceBetweenButtons), width: 169, height: 30)
        self.detailButton.contentHorizontalAlignment = .center
        
        self.tokenButton.frame = CGRect(x: view.frame.width/2 - 169/2, y: (yPoint + 4*distanceBetweenButtons), width: 169, height: 30)
        self.tokenButton.contentHorizontalAlignment = .center
        
        self.deliverToButton.frame = CGRect(x: view.frame.width/2 - 169/2, y: (yPoint + 5*distanceBetweenButtons), width: 169, height: 30)
        self.deliverToButton.contentHorizontalAlignment = .center
        
        self.imageButton.frame = CGRect(x: view.frame.width/2 - 169/2, y: (yPoint + 6*distanceBetweenButtons), width: 169, height: 30)
        self.imageButton.contentHorizontalAlignment = .center
        
        
        
    }

    @IBAction func didTapItemName(_ sender: Any) {
        
          self.makeAlert(title: "Item Requested", message: "Enter in the item name, for example 6 Pack of Coke")
        
    }
    
    @IBAction func didTapWillingToPay(_ sender: Any) {
        
           self.makeAlert(title: "Willing to Pay", message: "Enter here the maximum price you are willing to pay for the item you are requesting. For example, if I am requesting a Snickers, but would not be willing to pay more than $2.00 for it, I would enter $2.00. This way if someone is at the store and finds a Snickers for $3.00, they would know not to purchase it for me as I am not willing to pay that amount")
        
        
    }
    
    @IBAction func didTapVenmoCash(_ sender: Any) {
        
          self.makeAlert(title: "Venmo or Cash", message: "Select whether you would like to pay the delivering Goodneighbor using Cash or Venmo by touching the Venmo or Cash button")
        
    }
    
    @IBAction func didTapDetail(_ sender: Any) {
        
        self.makeAlert(title: "Detailed Information", message: "Enter here any extra details that will help make the delivery successful. For example, if you are requesting a 6 pack of coke, you could say I am looking for a 6 pack of 12 ounce Coke cans. When you arrive at my dorm, please call me and I will come down and meet you")
    }
    
    
    @IBAction func didTapDeliverTo(_ sender: Any) {
        
        self.makeAlert(title: "Deliver to", message: "Enter here where you would like to meet the deliverer to pick up the item")
        
    }
    
    
    @IBAction func didTapToken(_ sender: Any) {
        
        self.makeAlert(title: "Tokens", message: "Tokens are the currency of the pay-it-forward delivery system. To request a delivery, you must offer one or two tokens to the person delivering. When the delivery is complete, you will transfer this token(s) to the delivering Goodneighbor in addition to paying them the cost of the item.")
        
        //"Whenever you recieve a delivery, you must pay the deliverer the price of the item, and you must give them one or two tokens. You have the option to offer one or two tokens, by selecting the image of one or two tokens. It is advised that you offer two tokens if you would like a delivery urgently, as this will better incentivize Goodneighbors to accept your request."
        
    }
    
    @IBAction func didTapImage(_ sender: Any) {
        
        self.makeAlert(title: "Image (optional)", message: "It is highly suggested that you upload a photo from your phone's camera of the item you are requesting to ensure the deliverer is bringing the correct item")
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func didTapContinue(_ sender: Any) {
        
        if self.isIntro{
            
            self.performSegue(withIdentifier: "reqExpToTokenExp", sender: nil)
            
        } else {
            
            self.performSegue(withIdentifier: "expToRequest", sender: nil)
            
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

   
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //
        
        if segue.identifier == "reqExpToTokenExp" {
            
            let secondViewController = segue.destination as! explanationTokens
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
