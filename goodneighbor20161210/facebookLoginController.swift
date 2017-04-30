//
//  facebookLoginController.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/21/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//

import UIKit
import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import FBSDKLoginKit
import CoreLocation

class facebookLoginController: UIViewController, FBSDKLoginButtonDelegate {
    
    var url: String?
    var loggedInUserData: AnyObject?
    var databaseRef = FIRDatabase.database().reference()
    var proPicURL: String?
    var loggedInUserId: String?
    var pushNotifID: String?
    
    @IBOutlet var signUpButtonOutlet: customButton!
    
    
    
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logged out")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let loginButton = FBSDKLoginButton()
        view.addSubview(loginButton)
        //frame's are obselete, please use constraints instead because its 2016 after all
        loginButton.frame = CGRect(x: 16, y: 220, width: view.frame.width - 32, height: 50)
        loginButton.delegate = self
        signUpButtonOutlet.frame =  CGRect(x: 16, y: 280, width: view.frame.width - 32, height: 50)
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil {
            print(error)
            return
        }else{
            
            let accessToken = FBSDKAccessToken.current()
            guard let accessTokenString = accessToken?.tokenString else {return}
            let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
            
            //Facebook sign in. Error to be fixed here from mom and elaine complaints
            FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
                if error != nil{
                    
                }else{
                    
                }
                
                DispatchQueue.main.async{
                    
                    //Get all the facebook user data!!!
                    FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, first_name, gender, picture.type(large)"]).start(completionHandler: { (connection, result, err) in
                        let dict = result as! NSDictionary
                        let pict = dict["picture"] as! NSDictionary
                        let data = pict["data"] as! NSDictionary
                        self.url = data["url"] as? String
                        let fullName = dict["name"] as! String
                        let gender = dict["gender"] as! String
                        
                        userFullName = fullName
                        
                        let randomNum:UInt32 = arc4random_uniform(1000)
                        let someString:String = String(randomNum)
                        
                        let referralCode = dict["first_name"]! as! String + someString
                        userReferralCode = referralCode
                        
                        let latitude = 0.0000000000
                        let longitude = 0.0000000000
                        let deliveryRadius = 1.0000987
                        
                        
                        let userUId = (FIRAuth.auth()?.currentUser?.uid)!
                        
                        let childUpdatesFbook = ["/users/\(userUId)/name":dict["first_name"]!,"/users/\(userUId)/fullName":dict["name"]!,"/users/\(userUId)/gender":dict["gender"]!,"/users/\(userUId)/buildingName":"N/A","/users/\(userUId)/cellPhoneNumber":"0","/users/\(userUId)/deliveryCount":0, "/users/\(userUId)/recieveCount":0, "/users/\(userUId)/tokenCount":2,"/users/\(userUId)/profilePicReference":self.url!, "/users/\(userUId)/longitude":longitude, "/users/\(userUId)/latitude":latitude, "/users/\(userUId)/deliveryRadius":deliveryRadius, "/users/\(userUId)/referralCode":userReferralCode!] as [String : Any]
                        
                        //Update
                        self.databaseRef.updateChildValues(childUpdatesFbook)
                        
                        //Set user properties
                        FIRAnalytics.setUserPropertyString(fullName, forName: "fullName")
                        FIRAnalytics.setUserPropertyString(gender, forName: "maleOrFemale")
                        
                        self.performSegue(withIdentifier: "fBookToTerms", sender: nil)
                        
                    })} })
            print("Successfully logged in with facebook...")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        
        autoLoginHelp = 1
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


}
