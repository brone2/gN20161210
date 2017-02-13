//
//  beginIntro.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 2/12/17.
//  Copyright © 2017 Neil Bronfin. All rights reserved.
//

import UIKit

class beginIntro: UIViewController {
    
    var isIntro:Bool?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapContinue(_ sender: Any) {
        
        self.performSegue(withIdentifier: "beginExp", sender: nil)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //
        
        if segue.identifier == "beginExp" {
            
            let secondViewController = segue.destination as! explanationShoppingList
            secondViewController.isIntro = self.isIntro!
          
            
        }
    }

}
