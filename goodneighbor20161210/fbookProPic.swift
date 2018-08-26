//
//  fbookProPic.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 7/9/17.
//  Copyright © 2017 Neil Bronfin. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase


class fbookProPic: UIViewController, FBSDKLoginButtonDelegate  {

    var databaseRef = FIRDatabase.database().reference()
    var url: String?
 
 
    
    
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
                    FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, first_name, picture.type(large)"]).start(completionHandler: { (connection, result, err) in
                        let dict = result as! NSDictionary
                        let pict = dict["picture"] as! NSDictionary
                        let data = pict["data"] as! NSDictionary
                        self.url = data["url"] as? String
                        
                        myProfilePicRef = self.url!
                        
                        let userUId = (FIRAuth.auth()?.currentUser?.uid)!
                        
                        let childUpdatesFbook = ["/users/\(userUId)/profilePicReference":self.url!] as [String : Any]
                        
                        //Update
                        self.databaseRef.updateChildValues(childUpdatesFbook)
                        
                        self.performSegue(withIdentifier: "picToRequest", sender: nil)
                        
                    })} })
            print("Successfully logged in with facebook...")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
