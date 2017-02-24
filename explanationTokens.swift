//
//  explanationTokens.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 2/12/17.
//  Copyright © 2017 Neil Bronfin. All rights reserved.
//

import UIKit

class explanationTokens: UIViewController {
    
    @IBOutlet var continueButton: customButton!
    
    var yPoint:CGFloat = 334
    var distanceBetweenButtons: CGFloat = 35
    var isIntro = false

    @IBOutlet var exampleTextLabel: UILabel!
    @IBOutlet var forExampleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !self.isIntro {
            self.continueButton.setTitle("OK", for: [])
        }
        if isSmallScreen {
            
            self.forExampleLabel.frame = CGRect(x: view.frame.width/2 - self.forExampleLabel.frame.width/2, y: 290, width: 135.5, height: 24)
            
            self.exampleTextLabel.frame = CGRect(x: view.frame.width/2 - self.exampleTextLabel.frame.width/2, y: 310, width: 290, height: 168)
            
            
            
            if self.isIntro {
                self.continueButton.frame = CGRect(x: view.frame.width/2 - 70, y: 525, width: 140, height: 30)
            } else {
                self.continueButton.frame = CGRect(x: view.frame.width/2 - 50, y: 525, width: 100, height: 30)
            }
            
        } else {

            self.forExampleLabel.frame = CGRect(x: view.frame.width/2 - self.forExampleLabel.frame.width/2, y: 313, width: 135.5, height: 24)
            
            self.exampleTextLabel.frame = CGRect(x: view.frame.width/2 - self.exampleTextLabel.frame.width/2, y: 352, width: 290, height: 168)
            
            
            
            if self.isIntro {
                self.continueButton.frame = CGRect(x: view.frame.width/2 - 70, y: 562, width: 140, height: 30)
            } else {
                self.continueButton.frame = CGRect(x: view.frame.width/2 - 50, y: 562, width: 100, height: 30)
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapContinueButton(_ sender: Any) {
        
        if self.isIntro{
            
            self.makeAlert(title: "Thank you!", message: "Now that you understand the app, you can begin participating in the Goodneighbor Community! If anything is unclear, click on the blue and yellow question marks to get an explanation")
            
            
        } else {
            
            
            self.performSegue(withIdentifier: "expToTokens", sender: nil)
        }
        

    }
    
   
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func makeAlert(title: String, message: String)  {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "expTokenToList", sender: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }

   

    /*
    // MARK: - Navigation  expToTokens

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
