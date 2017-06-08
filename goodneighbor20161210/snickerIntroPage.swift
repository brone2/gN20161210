//
//  snickerIntroPage.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 3/10/17.
//  Copyright © 2017 Neil Bronfin. All rights reserved.
//

import UIKit

class snickerIntroPage: UIViewController {

    @IBOutlet var steveImage: UIImageView!
    @IBOutlet var meImage: UIImageView!
    
    @IBOutlet var neilText: UILabel!
    @IBOutlet var steveText: UILabel!
  
    var continueCount = 0
    
    override func viewDidAppear(_ animated: Bool) {
        self.controlFlow()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.steveImage.layer.cornerRadius = 50
        self.steveImage.layer.masksToBounds = true
        self.steveImage.contentMode = .scaleAspectFit
        
        self.meImage.layer.cornerRadius = 50
        self.meImage.layer.masksToBounds = true
        self.meImage.contentMode = .scaleAspectFit
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func didTapSkip(_ sender: Any) {
        
        self.performSegue(withIdentifier: "skipToComplete", sender: nil)
        
    }
    

    @IBAction func didTapNext(_ sender: Any) {
        
        self.continueCount += 1
            self.controlFlow()
        }
    
    func controlFlow()  {
        
        if self.continueCount == 0 {
            
            UIView.animate(withDuration: 1){
                self.neilText.alpha = 1
                self.meImage.alpha = 1
            }
        }
        if self.continueCount == 1 {
            
            self.performSegue(withIdentifier: "introSnickToReq", sender: nil)
            
            
        } else if self.continueCount == 2 {
           
            UIView.animate(withDuration: 1){
                self.steveText.alpha = 1
                self.steveImage.alpha = 1
            }
            
            
        } else if self.continueCount == 3 {
            
            self.performSegue(withIdentifier: "snickIntroList", sender: nil)
            
        } else {
            
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //
        
        
        
        if segue.identifier == "skipToComplete" {
            
            let newViewController = segue.destination as! deliveryCompletePopUp
            newViewController.isIntro = true
            
        }
        
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
