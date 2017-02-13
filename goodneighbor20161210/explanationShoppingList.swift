//
//  explanationShoppingList.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 2/12/17.
//  Copyright © 2017 Neil Bronfin. All rights reserved.
//

import UIKit

class explanationShoppingList: UIViewController {

    @IBOutlet var grayView: UIView!
    
    var isIntro = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.grayView.frame = CGRect(x: 50, y: 500, width: 330, height: 590)

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
        self.performSegue(withIdentifier: "listExpToReqExp", sender: nil)
        } else {
            self.performSegue(withIdentifier: "expToList", sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //
        
        if segue.identifier == "listExpToReqExp" {
            
            let secondViewController = segue.destination as! explanationRequest
            secondViewController.isIntro = self.isIntro
            
            
        }
    }

}
