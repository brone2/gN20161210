//
//  iLiveInView.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 7/15/17.
//  Copyright © 2017 Neil Bronfin. All rights reserved.
//

import UIKit

class iLiveInView: UIViewController {
    @IBOutlet var grayView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.grayView.layer.cornerRadius = 3
        self.grayView.layer.masksToBounds = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
