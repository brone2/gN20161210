//
//  loginViewController.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/8/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import FBSDKLoginKit
import CoreLocation



var autoLoginTryCount = 0

class loginViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    /**
     Sent to the delegate when the button was used to logout.
     - Parameter loginButton: The button that was clicked.
 */
 
    
   /* public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logged out")
    }*/

    var imageData:Data?
    var storageRef = FIRStorage.storage().reference()
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var profilePicImage: UIImageView!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var nameLabel: UITextField!
    
    @IBOutlet var image: UIImageView!
    var loggedInUserData: AnyObject?
    var databaseRef = FIRDatabase.database().reference()
    var loginHelp = 1
    var url: String?
    var proPicURL: String?
    var proPic = 0
    
    var loggedInUserId: String?
   
    
    @IBAction func didTapSignUp(_ sender: UIButton) {
        
        self.loginHelp = 2
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            
        if self.proPic != 1 {
            
            let alertNoPic = UIAlertController(title: "Please add profile picture", message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            alertNoPic.addAction(UIAlertAction(title: "ok", style: .default, handler: { (action) in
                return
            }))
            self.present(alertNoPic, animated: true, completion: nil)
            
            
        } else {
        
        print("signing up!")
        
        //Create User, Log in User and save user to database
        FIRAuth.auth()?.createUser(withEmail: self.emailLabel.text!, password: self.passwordLabel.text!, completion: { (user, error) in
            
            if error != nil {
                self.errorLabel.text = error?.localizedDescription
            }else {
                
                self.errorLabel.text = "Successful registration!"
                
                FIRAuth.auth()?.signIn(withEmail: self.emailLabel.text!, password: self.passwordLabel.text!, completion: { (user, error) in
                    if error != nil {
                        
                    }else{
                        // here need to have upload photo
                        let key = self.databaseRef.child("request").childByAutoId().key
                        
                        _ = self.storageRef.child("request/\(user!.uid)/media/\(key)")
                        
                        let metadata = FIRStorageMetadata()
                        //Choose png of jpeg or whatever
                        metadata.contentType = "image/png"
                        
                        if self.imageData  != nil{
                            let profilePicStorageRef = self.storageRef.child("request/\(key)/image_request")
                            
                            _ = profilePicStorageRef.put(self.imageData!, metadata: metadata,  completion: { (metadata, error) in
                                
                                if error != nil{
                                    
                                }else{
                                    print(user!.uid)
                                    //*May be an issue later that this child is being updated ahead of all the other ones in childUpdates, may throw timing elsewhere
                                    let downloadUrl = metadata!.downloadURL()
                                    self.databaseRef.child("users").child(user!.uid).child("profilePicReference").setValue(downloadUrl!.absoluteString)
                                    print(downloadUrl!.absoluteString)
                                }
                            })
                        }
                        
                        let childUpdates = ["/users/\(user!.uid)/name":self.nameLabel.text!,"/users/\(user!.uid)/cellPhoneNumber":"0","/users/\(user!.uid)/buildingName":"N/A","/users/\(user!.uid)/deliveryCount":0, "/users/\(user!.uid)/recieveCount":0, "/users/\(user!.uid)/tokenCount":3,"/users/\(user!.uid)/email":self.emailLabel.text!, "/users/\(user!.uid)/longitude":0.0000000000, "/users/\(user!.uid)/latitude":0.0000000000,"/users/\(user!.uid)/deliveryRadius": 1.0000987] as [String : Any]
                        
                        print(childUpdates)
                        
                        //,"/users/\(user!.uid)/profilePicReference":downloadUrl!
                        //Update
                        self.databaseRef.updateChildValues(childUpdates)
                        
                        self.performSegue(withIdentifier: "goToTerms", sender: nil)
                    }
                })
            }
        })
        
    }
    }
    }
    
    @IBAction func didTapLogInButton(_ sender: Any) {
        
       
        self.loginHelp = 2
        print("hey boss")
        FIRAuth.auth()?.signIn(withEmail: self.emailLabel.text!, password: self.passwordLabel.text!, completion: { (user, error) in
            if error != nil{
                self.errorLabel.text = error?.localizedDescription
                
            }else{
                
                FIRAuth.auth()
                
                print("tuuuuuu")
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                
                self.loggedInUserId = FIRAuth.auth()?.currentUser?.uid
                
                //get user name
                self.databaseRef.child("users").child(self.loggedInUserId!).observeSingleEvent(of: .value) { (snapshot:FIRDataSnapshot) in
                    
                    self.loggedInUserData = snapshot.value as? NSDictionary
                    
                    loggedInUserName = self.loggedInUserData?["name"] as! String
                    myProfilePicRef = self.loggedInUserData?["profilePicReference"] as! String
                    myCellNumber = self.loggedInUserData?["cellPhoneNumber"] as! String
                    currentTokenCount = self.loggedInUserData?["tokenCount"] as! Int
                    
                    if let myLatitude = self.loggedInUserData?["latitude"] as? CLLocationDegrees{
                        if let myLongitude = self.loggedInUserData?["longitude"] as? CLLocationDegrees{
                            myLocation = CLLocation(latitude: myLatitude, longitude: myLongitude)
                        }
                    }
                    
                    myRadius  = self.loggedInUserData?["deliveryRadius"] as? Float
                    
                    
                    let homeViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "shoppingList")
                    
                    //send user to homescreen
                    self.present(homeViewController, animated: true, completion: nil)
                }
            }
        })

        
    }
    func didTapImageIcon(_ sender:UITapGestureRecognizer){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage?
        self.image.image = image
        self.imageData = UIImageJPEGRepresentation(image!, 0.2)
        self.dismiss(animated: true, completion: nil)
        self.proPic = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
  
   //try! FIRAuth.auth()?.signOut()
        
        let imageTap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImageIcon(_:)))
        image.addGestureRecognizer(imageTap)
       
        self.checkUser()
     }
    
    
    func checkUser(){
    
        if self.loginHelp == 1 {
        
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            if user != nil {
                if self.loginHelp == 1 {
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    //Send the user to the view with the Identifier which means storyboard ID
                    
                    self.loggedInUserId = FIRAuth.auth()?.currentUser?.uid
                    
                    //get user name
                    self.databaseRef.child("users").child(self.loggedInUserId!).observeSingleEvent(of: .value) { (snapshot:FIRDataSnapshot) in
                        
                        self.loggedInUserData = snapshot.value as? NSDictionary
                        
                        print(self.loginHelp)
                        loggedInUserName = self.loggedInUserData?["name"] as! String
                        myProfilePicRef = self.loggedInUserData?["profilePicReference"] as! String
                        myCellNumber = self.loggedInUserData?["cellPhoneNumber"] as! String
                        currentTokenCount = self.loggedInUserData?["tokenCount"] as! Int
                        
                        if let myLatitude = self.loggedInUserData?["latitude"] as? CLLocationDegrees{
                            if let myLongitude = self.loggedInUserData?["longitude"] as? CLLocationDegrees{
                                myLocation = CLLocation(latitude: myLatitude, longitude: myLongitude)
                            }
                        }
                        
                        myRadius  = self.loggedInUserData?["deliveryRadius"] as? Float
                        
                        
                        let homeViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "shoppingList")
                        self.present(homeViewController, animated: true, completion: nil)
                    }
                }
            }
        })
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.loginHelp = 2
            print(self.loginHelp)
    }
    }

    
    func signUp(){
    
        self.loginHelp = 2
        print("whoooooooo")
        
        if self.proPic != 1 {
            
            let alertNoPic = UIAlertController(title: "Please add profile picture", message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            alertNoPic.addAction(UIAlertAction(title: "ok", style: .default, handler: { (action) in
                return
            }))
        self.present(alertNoPic, animated: true, completion: nil)
    
    
        } else {
        //Create User, Log in User and save user to database
        FIRAuth.auth()?.createUser(withEmail: self.emailLabel.text!, password: self.passwordLabel.text!, completion: { (user, error) in
            
            if error != nil {
                self.errorLabel.text = error?.localizedDescription
            }else {
                
                self.errorLabel.text = "Successful registration!"
                
                FIRAuth.auth()?.signIn(withEmail: self.emailLabel.text!, password: self.passwordLabel.text!, completion: { (user, error) in
                    if error != nil {
                        
                    }else{
                       // here need to have upload photo
                        let key = self.databaseRef.child("request").childByAutoId().key
                        
                         _ = self.storageRef.child("request/\(user!.uid)/media/\(key)")
                        
                        let metadata = FIRStorageMetadata()
                        //Choose png of jpeg or whatever
                        metadata.contentType = "image/png"
                        
                        if self.imageData  != nil{
                            let profilePicStorageRef = self.storageRef.child("request/\(key)/image_request")
                            
                            _ = profilePicStorageRef.put(self.imageData!, metadata: metadata,  completion: { (metadata, error) in
                                
                                if error != nil{
                                    
                                }else{
                                    print(user!.uid)
                                    //*May be an issue later that this child is being updated ahead of all the other ones in childUpdates, may throw timing elsewhere
                                    let downloadUrl = metadata!.downloadURL()
                                self.databaseRef.child("users").child(user!.uid).child("profilePicReference").setValue(downloadUrl!.absoluteString)
                                    print(downloadUrl!.absoluteString)
                                }
                            })
                        }

                        let childUpdates = ["/users/\(user!.uid)/name":self.nameLabel.text!,"/users/\(user!.uid)/buildingName":"N/A","/users/\(user!.uid)/cellPhoneNumber":"0","/users/\(user!.uid)/deliveryCount":0, "/users/\(user!.uid)/recieveCount":0, "/users/\(user!.uid)/tokenCount":3,"/users/\(user!.uid)/email":self.emailLabel.text!] as [String : Any]
                        //,"/users/\(user!.uid)/profilePicReference":downloadUrl!
                        //Update
                      self.databaseRef.updateChildValues(childUpdates)
                        
                        
                    }
                })
            }
        })

    }
    }
    
    /*
    func didTapActualLogin() {
        print("raaaaan")
      /*
        FIRAuth.auth()?.signIn(withEmail: self.emailLabel.text!, password: self.passwordLabel.text!, completion: { (user, error) in
            if error != nil{
                
                
            }else{
                
                FIRAuth.auth()
                
                 print("tuuuuuu")
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                
                self.loggedInUserId = FIRAuth.auth()?.currentUser?.uid
                
                //get user name
                self.databaseRef.child("users").child(self.loggedInUserId!).observeSingleEvent(of: .value) { (snapshot:FIRDataSnapshot) in
                    
                    self.loggedInUserData = snapshot.value as? NSDictionary
                    
                    loggedInUserName = self.loggedInUserData?["name"] as! String
                    myProfilePicRef = self.loggedInUserData?["profilePicReference"] as! String
                    myCellNumber = self.loggedInUserData?["cellPhoneNumber"] as! String
                    currentTokenCount = self.loggedInUserData?["tokenCount"] as! Int
                    
                    if let myLatitude = self.loggedInUserData?["latitude"] as? CLLocationDegrees{
                        if let myLongitude = self.loggedInUserData?["longitude"] as? CLLocationDegrees{
                            myLocation = CLLocation(latitude: myLatitude, longitude: myLongitude)
                        }
                    }
                    
                    myRadius  = self.loggedInUserData?["deliveryRadius"] as? Float
                    
                    
                    let homeViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "shoppingList")
                    
                    //send user to homescreen
                    self.present(homeViewController, animated: true, completion: nil)
                }
            }
        })
        */
     }
 */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /* GOES IN VIEW DID LOAD
     let loginButton = FBSDKLoginButton()
     view.addSubview(loginButton)
     //frame's are obselete, please use constraints instead because its 2016 after all
     loginButton.frame = CGRect(x: 16, y: 520, width: view.frame.width - 32, height: 50)
     
     loginButton.delegate = self
     }
     
     func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
     self.loginHelp = 4
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
     
     let userId = (FIRAuth.auth()?.currentUser?.uid)!
     
     let childUpdatesFbook = ["/users/\(userId)/name":dict["first_name"]!,"/users/\(userId)/buildingName":"N/A","/users/\(userId)/cellPhoneNumber":"0","/users/\(userId)/deliveryCount":0, "/users/\(userId)/recieveCount":0, "/users/\(userId)/tokenCount":3,"/users/\(userId)/profilePicReference":self.url!] as [String : Any]
     
     //Update
     self.databaseRef.updateChildValues(childUpdatesFbook)
     
     self.performSegue(withIdentifier: "goToTerms", sender: nil)
     
     })} })
     print("Successfully logged in with facebook...")
     }*/

    
    
}
