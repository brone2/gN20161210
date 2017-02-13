//
//  explanationTokens.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 2/12/17.
//  Copyright © 2017 Neil Bronfin. All rights reserved.
//

import UIKit

class explanationTokens: UIViewController {
    
    var isIntro = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapOk(_ sender: Any) {
        
        
        if self.isIntro{
            
            self.performSegue(withIdentifier: "reqExpToTokenExp", sender: nil)
            
        } else {
            
            self.performSegue(withIdentifier: "expToTokens", sender: nil)
            
        }
        
    }
    override var prefersStatusBarHidden: Bool {
        return true
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
