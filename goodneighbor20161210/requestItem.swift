//
//  requestItem.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 12/8/16.
//  Copyright © 2016 Neil Bronfin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import CoreLocation



class requestItem: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    var databaseRef = FIRDatabase.database().reference()
    var storageRef = FIRStorage.storage().reference()
    var tokensOffered = 1
    var loggedInUser:String!
    var requesterName:String?
    var loggedInUserData:NSDictionary?
    var requesterLatitude:CLLocationDegrees?
    var requesterLongitude:CLLocationDegrees?
    var requesterBuildingName:String?
    var requesterTokenCount:Int?
    var isAccepted = false
    var imageData:Data?
    var requestedTime = NSDate()
    var date:String?
    var profilePicReference:String!
    var saveKeyPath: String?
    var saveKey: String?
    var downloadUrlAbsoluteString: String?
    
    @IBOutlet var oneTokenLabel: UILabel!
    @IBOutlet var twoTokenLabel: UILabel!
 
    @IBOutlet weak var twoTokenImage: UIImageView!
    @IBOutlet weak var oneTokenImage: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var priceLabel: UITextField!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var locationButton: UIButton!
    
    
    @IBOutlet var detailInfoLabel: UILabel!
    @IBOutlet var tokensOfferedLabel: UILabel!
    @IBOutlet var deliverToLabel: UILabel!
    @IBOutlet var maxPayLabel: UILabel!
    @IBOutlet var itemNameLabel: UILabel!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isSmallScreen == true {
            
            self.image.isHidden = true
            let smallFont:CGFloat = 12.0
            self.detailInfoLabel.font = UIFont.systemFont(ofSize: smallFont)
            self.tokensOfferedLabel.font = UIFont.systemFont(ofSize: smallFont)
            self.deliverToLabel.font = UIFont.systemFont(ofSize: smallFont)
            self.maxPayLabel.font = UIFont.systemFont(ofSize: smallFont)
            self.itemNameLabel.font = UIFont.systemFont(ofSize: smallFont)
            self.oneTokenLabel.font = UIFont.systemFont(ofSize: smallFont)
            self.twoTokenLabel.font = UIFont.systemFont(ofSize: smallFont)
        }
        
        self.nameLabel.delegate = self
        self.priceLabel.delegate = self
        
        
        self.loggedInUser = FIRAuth.auth()?.currentUser?.uid

        descriptionTextView.text = "Please enter description of the product and arrangements for delivery"
        descriptionTextView.textColor = UIColor.lightGray
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        
        self.locationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        
        //retrieve user info
        self.databaseRef.child("users").child(self.loggedInUser!).observeSingleEvent(of: .value) { (snapshot:FIRDataSnapshot) in
            
            self.loggedInUserData = snapshot.value as? NSDictionary
            
            self.requesterName = self.loggedInUserData?["name"] as? String
            
            loggedInUserName = self.requesterName
            
            self.profilePicReference = self.loggedInUserData?["profilePicReference"] as? String
            
            self.requesterLongitude = self.loggedInUserData?["longitude"] as! CLLocationDegrees?
            
            self.requesterLatitude = self.loggedInUserData?["latitude"] as! CLLocationDegrees?
            
            self.requesterBuildingName = self.loggedInUserData?["buildingName"] as? String
        }
        
        //Get date and time information
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm MMM dd"
        let result = formatter.string(from: requestedTime as Date)
        self.date = result
        
        //imageGestureRecognizers
        //oneToken
        let oneTokenImageTap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapOneToken(_:)))
        oneTokenImage.addGestureRecognizer(oneTokenImageTap)
        
        let twoTokenImageTap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapTwoToken(_:)))
        twoTokenImage.addGestureRecognizer(twoTokenImageTap)
        
        let imageTap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImageIcon(_:)))
        image.addGestureRecognizer(imageTap)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(descriptionTextView.textColor == UIColor.lightGray){
            self.descriptionTextView.text = ""
            self.descriptionTextView.textColor = UIColor.black
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.priceLabel.text = "$"
        self.priceLabel.textColor = UIColor.black
    }
    
    @IBAction func didTapRequest(_ sender: Any) {
        
    self.databaseRef.child("users").child(self.loggedInUser!).observeSingleEvent(of: .value) { (snapshot:FIRDataSnapshot) in
        
        currentTokenCount = self.loggedInUserData?["tokenCount"] as? Int
        
        if self.priceLabel.text == "" || self.priceLabel.text == "" || self.priceLabel.text == "$" || self.descriptionTextView.text! == "" {
            let alertNotEnough = UIAlertController(title: "Missing Required Fields", message: "Please fill out all required fields", preferredStyle: UIAlertControllerStyle.alert)
            
            alertNotEnough.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                return
            }))
            self.present(alertNotEnough, animated: true, completion: nil)
        }
        
        if self.tokensOffered > currentTokenCount {
            
            let alertNotEnough = UIAlertController(title: "Make some deliveries!", message: "Unfortunately, you do not have enough tokens for this request. Solve this problem by helping your neighbors with some deliveries!", preferredStyle: UIAlertControllerStyle.alert)
            
            alertNotEnough.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                
            }))
            self.present(alertNotEnough, animated: true, completion: nil)
        } else {
        let alert = UIAlertController(title: "Neighberhood Shopping List", message: "I agree to pay a maximum of \(self.priceLabel.text!) for \(self.nameLabel.text!). Once this item has been accepted for delivery it cannot be cancelled", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
        }))
        
       alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            
        self.prepareUploadRequest()
            
       /*
        if myCellNumber == "0"{
            self.performSegue(withIdentifier: "goToPhone", sender: nil)
        }*/
            
       /* let alertDeliveryComplete = UIAlertController(title: "Request posted!", message: "Your delivery request has been posted to the neighberhood shopping List! Please be alert for a neighbor reaching out to deliver this item", preferredStyle: UIAlertControllerStyle.alert)
            
            alertDeliveryComplete.addAction(UIAlertAction(title: "ok", style: .default, handler: { (action) in
                
            self.segueToShoppingList()
                
        }))
             self.present(alertDeliveryComplete, animated: true, completion: nil)*/
            
        }))
        self.present(alert, animated: true, completion: nil)
        }
    }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //
        
        if segue.identifier == "goToPhone" {
            
            let secondViewController = segue.destination as! submitPhoneNumberView
            secondViewController.saveKey =  self.saveKey
        }
        
    }

    func didTapOneToken(_ sender: UITapGestureRecognizer) {
        
        if self.tokensOffered == 2 {
            self.oneTokenImage.image = UIImage(named: "1FullToken.png")
            self.twoTokenImage.image = UIImage(named: "blackWhite2Coin.png")
            self.tokensOffered = 1
        }
}
    
    func didTapTwoToken(_ sender: UITapGestureRecognizer) {
        
        if self.tokensOffered == 1 {
            self.twoTokenImage.image = UIImage(named: "2FullToken.png")
            self.oneTokenImage.image = UIImage(named: "blackWhite1Coin.png")
            self.tokensOffered = 2
        }
}
    
    func didTapImageIcon(_ sender:UITapGestureRecognizer){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)   
    }
    
    @IBAction func didTapDeliverTo(_ sender: UIButton) {
        
        let myActionSheet = UIAlertController(title:"Delivery Location",message:"Please select where you would like item delivered",preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let aptLobby = UIAlertAction(title: "Will meet in Apt. Lobby", style: UIAlertActionStyle.default) { (action) in
            sender.setTitle("Will meet in Apt. Lobby", for: [])
        }
        
        let myFloor = UIAlertAction(title: "Will meet on my floor", style: UIAlertActionStyle.default) { (action) in
            sender.setTitle("Will meet on my floor", for: [])
        }
        
        let myDoor = UIAlertAction(title: "My door", style: UIAlertActionStyle.default) { (action) in
            sender.setTitle("My door", for: [])
        }
        
        let buildingDesk = UIAlertAction(title: "Front Desk", style: UIAlertActionStyle.default) { (action) in
            sender.setTitle("Front Desk", for: [])
        }
        
        let otherChoice = UIAlertAction(title: "Other", style: UIAlertActionStyle.default) { (action) in
            
            var enterLocationTextField: UITextField?
            
            let alertController = UIAlertController(
                title: "Enter Delivery Location",
                message: "",
                preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(
            title: "Cancel", style: UIAlertActionStyle.default) {
                (action) -> Void in
            }
            
            let completeAction = UIAlertAction(
            title: "Enter", style: UIAlertActionStyle.default) {
                (action) -> Void in
                
                if let deliveryLocation = enterLocationTextField?.text {
                    sender.setTitle(deliveryLocation, for: [])
                }
                
            }
            
            alertController.addTextField {
                (txtUsername) -> Void in
                enterLocationTextField = txtUsername
                enterLocationTextField!.placeholder = "ex: Outside Olin Library"
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(completeAction)
            
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        
        myActionSheet.addAction(myDoor)
        myActionSheet.addAction(myFloor)
        myActionSheet.addAction(aptLobby)
        myActionSheet.addAction(buildingDesk)
        myActionSheet.addAction(otherChoice)
        
        self.present(myActionSheet, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage?
        self.image.image = image
        self.imageData = UIImageJPEGRepresentation(image!, 0.2)
        self.dismiss(animated: true, completion: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func prepareUploadRequest() {
        
        //Begin request upload
        //Save Request to firebase
        //Save Picture
        let key = self.databaseRef.child("request").childByAutoId().key
        
        _ = self.storageRef.child("request/\(self.loggedInUser)/media/\(key)")
        
        let metadata = FIRStorageMetadata()
        //Choose png of jpeg or whatever
        metadata.contentType = "image/png"
        
        if self.imageData  != nil{
        
        let profilePicStorageRef = self.storageRef.child("productImages/\(key)/image_request")
          
        _ = profilePicStorageRef.put(self.imageData!, metadata: metadata,  completion: { (metadata, error) in
            
            if error != nil{
                
            }else{
                
                let downloadUrl = metadata!.downloadURL()
                self.downloadUrlAbsoluteString = downloadUrl!.absoluteString
                self.finalizeUploadRequest(key: key)
            }
        })
        } else {
            self.finalizeUploadRequest(key: key)
        }
    }
    
    //Make this a seperate function because of multi threading issue with saving the image to firebase
    func finalizeUploadRequest(key: String) {
    
        //Save text
    
        let pricePath = "/request/\(key)/price"
        let priceLabelValue = self.priceLabel.text! as String
        
        let tokenPath = "/request/\(key)/tokensOffered"
        let tokensLabelValue = self.tokensOffered
        
        let descriptionPath = "/request/\(key)/description"
        let descriptionLabelValue = self.descriptionTextView.text! as String
        
        let requesterNamePath = "/request/\(key)/requesterName"
        let requesterNameValue = self.requesterName! as String
        
        let itemNamePath = "/request/\(key)/itemName"
        let itemNameValue = self.nameLabel.text! as String
        
        let requestedTimePath = "/request/\(key)/requestedTime"
        let requestedTimeValue = self.date
        
        let longitudePath = "/request/\(key)/longitude"
        let longitudeValue = self.requesterLongitude! as CLLocationDegrees
        
        
        let buildingNamePath = "/request/\(key)/buildingName"
        let buildingNamePathValue = self.requesterBuildingName! as String
        //let buildingNamePathValue = "hello"
        
        let latitudePath = "/request/\(key)/latitude"
        let latitudeValue = self.requesterLatitude! as CLLocationDegrees
        
        let requesterUIDPath = "/request/\(key)/requesterUID"
        let requesterUIDValue = self.loggedInUser as String
        
        let requesterCellPath = "/request/\(key)/requesterCell"
        let requesterCellValue = myCellNumber as String
        
        let profilePicReferencePath = "/request/\(key)/profilePicReference"
        let profilePicReferenceValue = self.profilePicReference
        
        let isAcceptedPath = "/request/\(key)/isAccepted"
        let isAcceptedValue = self.isAccepted as Bool
        
        let deliverToPath = "/request/\(key)/deliverTo"
        let deliverToValue = self.locationButton.currentTitle! as String
        
        let isCompletePath = "/request/\(key)/isComplete"
        let isCompleteValue = false
        
        let timeStampPath = "/request/\(key)/timeStamp"
        
        //Set key value for later reference
        let requestKeyPath = "/request/\(key)/requestKey"
        let keyValue = key as String
        
        self.saveKeyPath = requestKeyPath
        self.saveKey = keyValue
        
        if self.imageData != nil{
            
            let downloadUrlAbsoluteStringPath = "/request/\(key)/productImage"
            let downloadUrlAbsoluteStringValue = self.downloadUrlAbsoluteString
            
            let childUpdates:Dictionary<String, Any> = [timeStampPath: [".sv": "timestamp"],profilePicReferencePath: profilePicReferenceValue!,downloadUrlAbsoluteStringPath:downloadUrlAbsoluteStringValue!, requesterCellPath: requesterCellValue,pricePath: priceLabelValue, buildingNamePath: buildingNamePathValue, itemNamePath: itemNameValue,tokenPath: tokensLabelValue,descriptionPath:descriptionLabelValue,requesterNamePath:requesterNameValue,deliverToPath:deliverToValue,longitudePath:longitudeValue,latitudePath:latitudeValue,requestedTimePath:requestedTimeValue!,requesterUIDPath:requesterUIDValue,isAcceptedPath:isAcceptedValue,isCompletePath:isCompleteValue,requestKeyPath:keyValue]
            
        self.databaseRef.updateChildValues(childUpdates)
            
        if myCellNumber == "0"{
                self.performSegue(withIdentifier: "goToPhone", sender: nil)
            } else {
            
        self.requestReset()
            
            }
        }
            
        /*else if self.imageData == nil && isSmallScreen == false // No image and not iphone 5
            
        {
   
        let alertNoPic = UIAlertController(title: "No Product Image Entered", message: "Providing an image of the product will make it easier for your neighbor to correctly fulfill your request. Please add a product image from you phone if possible", preferredStyle: UIAlertControllerStyle.alert)
            
        alertNoPic.addAction(UIAlertAction(title: "Return to request", style: .default, handler: { (action) in
                return
            }))
            alertNoPic.addAction(UIAlertAction(title: "Post without picture", style: .default, handler: { (action) in
 
                let childUpdates:Dictionary<String, Any> = [timeStampPath: [".sv": "timestamp"],profilePicReferencePath: profilePicReferenceValue!, requesterCellPath: requesterCellValue,pricePath: priceLabelValue, buildingNamePath: buildingNamePathValue, itemNamePath: itemNameValue,tokenPath: tokensLabelValue,descriptionPath:descriptionLabelValue,requesterNamePath:requesterNameValue,deliverToPath:deliverToValue,longitudePath:longitudeValue,latitudePath:latitudeValue,requestedTimePath:requestedTimeValue!,requesterUIDPath:requesterUIDValue,isAcceptedPath:isAcceptedValue,isCompletePath:isCompleteValue,requestKeyPath:keyValue]

                self.databaseRef.updateChildValues(childUpdates)
                
                if myCellNumber == "0"{
                    self.performSegue(withIdentifier: "goToPhone", sender: nil)
                } else {
                self.requestReset()
                }
            }))
            self.present(alertNoPic, animated: true, completion: nil)
        }*/
        
        
        //else if self.imageData == nil && isSmallScreen == true // No image and is iphone 5
        else
        {
            
            let childUpdates:Dictionary<String, Any> = [timeStampPath: [".sv": "timestamp"],profilePicReferencePath: profilePicReferenceValue!, requesterCellPath: requesterCellValue,pricePath: priceLabelValue, buildingNamePath: buildingNamePathValue, itemNamePath: itemNameValue,tokenPath: tokensLabelValue,descriptionPath:descriptionLabelValue,requesterNamePath:requesterNameValue,deliverToPath:deliverToValue,longitudePath:longitudeValue,latitudePath:latitudeValue,requestedTimePath:requestedTimeValue!,requesterUIDPath:requesterUIDValue,isAcceptedPath:isAcceptedValue,isCompletePath:isCompleteValue,requestKeyPath:keyValue]
            
            self.databaseRef.updateChildValues(childUpdates)
            
            if myCellNumber == "0"{
                self.performSegue(withIdentifier: "goToPhone", sender: nil)
            } else {
                self.requestReset()
            }
            
        }
        
        
    }
    
    func requestReset(){
        
        //Clear all textfields and reset image
        self.nameLabel.text = ""
        self.priceLabel.text = ""
        self.descriptionTextView.text = ""
        self.image.image = UIImage(named: "saveImage2.png")
        
        
        let alertDeliveryComplete = UIAlertController(title: "Request posted!", message: "Your delivery request has been posted to the neighberhood shopping List! Please be alert for a neighbor reaching out to deliver this item", preferredStyle: UIAlertControllerStyle.alert)
        
        alertDeliveryComplete.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            self.segueToShoppingList()
            
        }))
        self.present(alertDeliveryComplete, animated: true, completion: nil)
    }
    
    func segueToShoppingList() {
        performSegue(withIdentifier: "requestToShoppingList", sender: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
 func textFieldShouldReturn(_ textField: UITextField) -> Bool{
    self.view.endEditing(true)
    return false
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    func checkLocationOnRequest()  {
        //check if location there at matches home
    }
    
}

