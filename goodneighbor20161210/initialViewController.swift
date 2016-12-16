//
//  initialViewController.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/8/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//

import UIKit

class initialViewController: UIViewController {
    
    var time = 0
    var timer = Timer()
    
    override var prefersStatusBarHidden: Bool {
        return true
    } 

    override func viewDidLoad() {
        super.viewDidLoad()

        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(initialViewController.startTimer), userInfo: nil, repeats: true)
    }
    
    func startTimer() {
        time += 1
        if time > 3 {
            timer.invalidate()
            performSegue(withIdentifier: "gotoLogin", sender: nil)
        }
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

}
