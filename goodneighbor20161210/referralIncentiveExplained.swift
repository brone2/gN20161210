//
//  referralIncentiveExplained.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 2/9/17.
//  Copyright © 2017 Neil Bronfin. All rights reserved.
//

import UIKit

class referralIncentiveExplained: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func didTapDismiss(_ sender: customButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
