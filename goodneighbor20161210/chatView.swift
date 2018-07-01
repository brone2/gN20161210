//
//  chatView.swift
//  goodneighbor20161210
//
//  Created by Neil Bronfin on 6/8/17.
//  Copyright © 2017 Neil Bronfin. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase
import FirebaseDatabase
import FirebaseAuth
import Photos
import SDWebImage
import OneSignal

class chatView: JSQMessagesViewController {
    
    //Will need to have segue for otherUserId with other user info

    private let imageURLNotSetKey = "NOTSET"
    var otherUserId: String?
    var otherUserName: String?
    var otherUserNotifId: String?
    var otherUserImageRef: String?
    private var newMessageRefHandle: FIRDatabaseHandle?
    var messageRef: FIRDatabaseReference!
    var databaseRef: FIRDatabaseReference!
    var loggedInUserData:FIRUser!
    var loggedInUserId:String?
    private var updatedMessageRefHandle: FIRDatabaseHandle?
    var storageRef = FIRStorage.storage().reference()
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    var generalRequestChat = false
    var requestKey: String?
    var isRequesterViewing = false
    var isRun = false
    
    private var messages = [JSQMessage]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.databaseRef = FIRDatabase.database().reference()
        self.loggedInUserData = FIRAuth.auth()?.currentUser
        self.loggedInUserId = self.loggedInUserData.uid
        
        //This loads the messages onto the view
        observeMessages()
        
        self.senderId = self.loggedInUserId
        self.senderDisplayName = loggedInUserName
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back",style: .plain, target: self, action:  #selector(self.returnFromChat))
        
        navigationItem.title = self.otherUserName!
        
        let attrs = [
            NSForegroundColorAttributeName: colorBlue,
            NSFontAttributeName: UIFont(name: "Georgia-Bold", size: 24)!
        ]
        
        UINavigationBar.appearance().titleTextAttributes = attrs
        
    }

    func returnFromChat(){
        
        if isRequesterViewing {
            self.databaseRef.child("request").child(self.requestKey!).child("isNewMessageRequester").setValue(false)
        } else {
            self.databaseRef.child("request").child(self.requestKey!).child("isNewMessageAccepter").setValue(false)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
//sendMessage

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        // 1
    
        let itemRef = databaseRef.child("messages").childByAutoId()
        
        // 2
        
        let messageItem = [
            "senderId": self.loggedInUserId,
            "senderName": loggedInUserName,
            "text": text!,
            "otherUserId": self.otherUserId
        ]
        
        collectionView.reloadData()
        
        // 3
        itemRef.setValue(messageItem)
        
        // 4
        // Save to show new message
   

        if isRequesterViewing {
            self.databaseRef.child("request").child(self.requestKey!).child("isNewMessageAccepter").setValue(true)
        } else {
            self.databaseRef.child("request").child(self.requestKey!).child("isNewMessageRequester").setValue(true)
        }
        
        //Send Push Notif to requester
        if self.isRun && isRequesterViewing {
        OneSignal.postNotification(["contents" : ["en": "\(loggedInUserName!): \(text!)"],"include_player_ids": [self.otherUserNotifId],//"ios_sound": "nil",
                                    "data": ["type": "run"]])
        } else {
            OneSignal.postNotification(["contents" : ["en": "\(loggedInUserName!): \(text!)"],"include_player_ids": [self.otherUserNotifId],//"ios_sound": "nil",
                "data": ["type": "request"]])
        }
        
        
        
        // 5
        finishSendingMessage()
        //isTyping = false
        
        //6 Check if is general request message then update
        print("heeeeee")
        if generalRequestChat {
            
            let accepterNotifPath  = "/request/\(self.requestKey!)/accepterNotifId"
            let accepterNamePath = "/request/\(self.requestKey!)/accepterName"
            let accepterUIDPath = "/request/\(self.requestKey!)/accepterUID"
            
            let childUpdateChat:Dictionary<String, Any> = [accepterNotifPath:myNotif,accepterNamePath:loggedInUserName,accepterUIDPath:loggedInUserId]
            
            self.databaseRef.updateChildValues(childUpdateChat)
        print("UPDATED")
        }
        
    }

    
    func sendPhotoMessage() -> String? {
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = [
            "photoURL": imageURLNotSetKey,
            "senderId": senderId!,
            ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        return itemRef.key
    }
    
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["photoURL": url])
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)) {
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        } else {
            picker.sourceType = UIImagePickerControllerSourceType.camera
            
        }
        
        present(picker, animated: true, completion:nil)
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        print(messages)
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    
    //Deals with the bubbles
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        print(senderId)
        print(message.senderId)
        print(messages[indexPath.item])
        
        if message.senderId == self.loggedInUserId { // 2
            //If you sent it will give certain bubble view
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId { // 1
            cell.textView?.textColor = UIColor.white // 2
        } else {
            cell.textView?.textColor = UIColor.black // 3
        }
        
        return cell
    }
    
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    //This gives the persons name
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
        let message = messages[indexPath.item]
        switch message.senderId {
        case senderId:
            return nil
        default:
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
        }
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    //load messages
    private func observeMessages() {
        messageRef = self.databaseRef.child("messages")
        
        //pull all message data and then filter to see match of current user with senderID or otherUserID
        self.messageRef.observe(.childAdded, with: { (snapshot: FIRDataSnapshot) in
            
            let key = snapshot.key
            let snapshot = snapshot.value as? Dictionary<String, String>
            
            let snapSenderId = snapshot?["senderId"]
            print(snapshot)
            print("here it is")
            print(snapSenderId)
            let snapOtherUserId = snapshot?["otherUserId"]
            print(snapOtherUserId)
            if((self.loggedInUserId == snapSenderId && self.otherUserId == snapOtherUserId) || (self.loggedInUserId == snapOtherUserId && self.otherUserId == snapSenderId)){
                
                let messageData = snapshot
                
                if let id = messageData?["senderId"] as String!, let name = messageData?["senderName"] as String!, let text = messageData?["text"] as String!, text.characters.count > 0 {
                    self.addMessage(withId: id, name: name, text: text)
                    self.finishReceivingMessage()
                } else if let id = messageData?["senderId"] as String!, let photoURL = messageData?["photoURL"] as String! {
                    if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                        self.addPhotoMessage(withId: id, key: key, mediaItem: mediaItem)
                        
                        if photoURL.hasPrefix("https://") {
                            self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                        }
                    }
                } else {
                    print("Error! Could not decode message data")
                }
            }
        })
        
        // We can also use the observer method to listen for
        // changes to existing messages.
        // We use this to be notified when a photo has been stored
        // to the Firebase Storage, so we can update the message data
        updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let photoURL = messageData["photoURL"] as String! {
                // The photo has been updated.
                if let mediaItem = self.photoMessageMap[key] {
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key)
                    
                }
            }
        })
        collectionView.reloadData()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            print(mediaItem)
            if (mediaItem.image == nil) {
                photoMessageMap[key] = mediaItem
            }
            print(mediaItem)
            collectionView.reloadData()
        }
    }
    
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        let storageRef = FIRStorage.storage().reference(forURL: photoURL)
        storageRef.data(withMaxSize: INT64_MAX){ (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            
            storageRef.metadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                
                if (metadata?.contentType == "image/gif") {
                    //    mediaItem.image = UIImage.gifWithData(data!)
                } else {
                    mediaItem.image = UIImage.init(data: data!)
                }
                self.collectionView.reloadData()
                
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            })
        }
    }
    
    
    
    
}

extension chatView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let key = databaseRef.child("messages").childByAutoId().key
        
        let pictureStorageRef = self.storageRef.child("user_profiles/\(self.loggedInUserId)/media/\(key)")
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage?
        
        let metadata = FIRStorageMetadata()
        //Choose png of jpg or whatever
        metadata.contentType = "image/jpg"
        
        
        let imageData = UIImageJPEGRepresentation(image!, 0.1)
        
        let uploadTask = pictureStorageRef.put(imageData!, metadata: metadata,  completion: { (metadata, error) in
            
            if error != nil{
                print(error?.localizedDescription)
                
            }else{
                
                let downloadUrl = metadata!.downloadURL()
                
                let itemRef = self.messageRef.childByAutoId()
                
                let messageItem = [
                    "photoURL": downloadUrl!.absoluteString,
                    "senderId": self.senderId!,
                    "senderName": loggedInUserName,
                    "otherUserId": self.otherUserId
                ]
                
                itemRef.setValue(messageItem)
                
            }
        })
        self.dismiss(animated: true, completion: nil)
    }
    
  
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

let colorBlue = UIColor(hex: "0093DA")
let colorYellow = UIColor(hex: "FFE63F")
