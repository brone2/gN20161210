//
//  beginIntro.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 2/12/17.
//  Copyright © 2017 Neil Bronfin. All rights reserved.
//

import UIKit

class beginIntro: UIViewController {
    
    var isIntro = true

    @IBOutlet var realGrayView: UIView!
    @IBOutlet var grayView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.realGrayView.layer.cornerRadius = 3
        self.realGrayView.layer.masksToBounds = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapContinue(_ sender: Any) {
        
        //self.performSegue(withIdentifier: "beginExp", sender: nil)
        
        self.performSegue(withIdentifier: "beginExample", sender: nil)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //
        
        /*if segue.identifier == "beginExample" {
            
            let secondViewController = segue.destination as! snickerIntroPage
            secondViewController.isIntro = self.isIntro
          
            
        }*/
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
