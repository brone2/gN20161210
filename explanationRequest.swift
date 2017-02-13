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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func didTapOk(_ sender: Any) {
        
        if self.isIntro{
            
            self.performSegue(withIdentifier: "reqExpToTokenExp", sender: nil)
            
        } else {
            
            self.performSegue(withIdentifier: "expToRequest", sender: nil)
            
        }
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //
        
        if segue.identifier == "reqExpToTokenExp" {
            
            let secondViewController = segue.destination as! explanationTokens
            secondViewController.isIntro = self.isIntro
            
            
        }
    }


}
