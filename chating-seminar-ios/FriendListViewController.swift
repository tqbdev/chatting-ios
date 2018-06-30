//
//  FriendListViewController.swift
//  chating-seminar-ios
//
//  Created by An Nguyen on 4/21/18.
//  Copyright © 2018 Tran Quoc Bao. All rights reserved.
//

import UIKit
import Firebase
import Photos
var ref: DatabaseReference?

var currentUser:User?

class FriendListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    lazy var storage = Storage.storage()
    
    var senderDisplayName: String?
    @IBOutlet weak var emailTextField: UITextField?
    @IBOutlet weak var UserAvatar: UIImageView!
    @IBOutlet weak var emailTableView: UITableView?
    var emailList: [(id:String,email:String)] = [(String,String)]()
    var user:User?
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField?.delegate = self
        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(self.menuAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(self.createAction))
        self.title = "Friends List"
        
        ref = Database.database().reference()
        
        UserAvatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleSelectUserAvatar)))
        UserAvatar.isUserInteractionEnabled = true
        
        addOnlineUser()
        loadUserAvatar()
    }
    
    
    // MARK: Firebase storage avatar
    func loadUserAvatar() {
        let storageRef = storage.reference()
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let filePath = "file:\(documentsDirectory)/" + (Auth.auth().currentUser?.email!)! + ".jpg"
        guard let fileURL = URL(string: filePath) else { return }
        let storagePath = "profileAvatars/" + (Auth.auth().currentUser?.email!)! + ".jpg"
        
        // [START downloadimage]
        storageRef.child(storagePath).write(toFile: fileURL, completion: { (url, error) in
            if let error = error {
                print("Error downloading:\(error)")
                print ("Download Failed")
                return
            } else if let imagePath = url?.path {
                print ("Download Succeeded!")
                self.UserAvatar.image = UIImage(contentsOfFile: imagePath)
                self.UserAvatar.layer.cornerRadius = self.UserAvatar.layer.bounds.width/2
                self.UserAvatar.layer.masksToBounds = true
            }
        })
        // [END downloadimage]
    }
    
    func loadAvatar(email: String, imageView: UIImageView) {
        let storageRef = storage.reference()
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let filePath = "file:\(documentsDirectory)/" + email + ".jpg"
        guard let fileURL = URL(string: filePath) else { return }
        let storagePath = "profileAvatars/" + email + ".jpg"
        
        // [START downloadimage]
        storageRef.child(storagePath).write(toFile: fileURL, completion: { (url, error) in
            if let error = error {
                print("Error downloading:\(error)")
                print ("Download Failed" + email)
                return
            } else if let imagePath = url?.path {
                print ("Download Succeeded!" + email)
                imageView.image = UIImage(contentsOfFile: imagePath)
            }
        })
        // [END downloadimage]
    }
    
    @objc func handleSelectUserAvatar() {
        let alert = UIAlertController(title: "Do you wanna change avatar?", message: "", preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "OK", style: .destructive) {
            (action) in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil)
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] {
            selectedImageFromPicker = editedImage as? UIImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] {
            selectedImageFromPicker = originalImage as? UIImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            UserAvatar.image = selectedImage
            UserAvatar.layer.cornerRadius = UserAvatar.layer.bounds.width/2
            UserAvatar.layer.masksToBounds = true
        
            // Upload image avatar to storage firebase
            // [START uploadimage]
            guard let imageData = UIImageJPEGRepresentation(selectedImage, 0.8) else { return }
            let imagePath = "profileAvatars/" + (Auth.auth().currentUser?.email!)! + ".jpg"
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            let storageRef = self.storage.reference(withPath: imagePath)
            storageRef.putData(imageData, metadata: metaData) { (metadata, error) in
                if let error = error {
                    print ("Error uploading: \(error)")
                    return
                }
                print ("Uploaded avatar image")
            }
            // [START uploadimage]
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //
    
    override func viewWillAppear(_ animated: Bool) {
        emailList = []
        loadFriendList()
        emailTableView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func loadMessage() {
        let message = ref?.child("Message")
        DispatchQueue.global(qos: .background).async {
                message?.observe(.childAdded, with: {(snapshot) in
                    print("Global")
                    print(snapshot)
                })
        }
    }
    
    func loadFriendList() {
        let list = ref?.child("ListUser").child((user?.uid)!).child("FriendList")
        list?.observe(.childAdded, with: {
            (snapshot) in
            let postDict =  snapshot.value as? [String:Any]
            if( postDict != nil ){
                let emailFriend:String? = postDict!["email"] as? String
                if( emailFriend != nil) {
                    self.emailList.append((snapshot.key,emailFriend!))
                    self.emailTableView?.reloadData()
                }
            }
        })
    }
    
    func checkArrayFriend(email:String)->Bool{
        for e in emailList {
            if(e.email == email){
                return true
            }
        }
        return false
    }
    
    @objc func menuAction() {
        let actionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        actionMenu.addAction(UIAlertAction(title: "Log out", style: .destructive, handler:
            {
                (alert: UIAlertAction!) -> Void in
                        do {
                            try Auth.auth().signOut()
                            print("Logout successfully")
                            self.navigationController?.popViewController(animated: true)
                        } catch {
                            print(error)
                        }
        }))
        actionMenu.addAction(UIAlertAction(title: "Cancel",style: .cancel, handler:nil))
        self.present(actionMenu, animated: true, completion: nil)
    }

    @objc func createAction() {
        self.view.endEditing(true)

        var emailTxt:String? = emailTextField?.text
        if(emailTxt != nil){
            if(checkArrayFriend(email: emailTxt!)) {
                self.emailTextField?.text = ""
                let arlet = UIAlertController(title: nil, message: "Email already added", preferredStyle: .alert)
                arlet.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(arlet, animated: true, completion: {
                    self.emailTextField?.text = ""
                })
                return
            }
            ref?.child("ListUser").observe(.childAdded, with:{
                (snapshot) in
                let postDict = snapshot.value as? [String:Any]
                if(postDict != nil){
                    let email:String = postDict!["email"] as! String
                    let user = Auth.auth().currentUser
                    if(emailTxt?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) != ""){
                    if(emailTxt == user?.email) {
                        let arlet = UIAlertController(title: nil, message: "Can't add yourself", preferredStyle: .alert)
                        arlet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        self.present(arlet, animated: true, completion: {
                            self.emailTextField?.text = ""
                            
                        })
                    }
                        if(emailTxt == email ){
                            print(emailTxt!)
                        //self.emailList.append((snapshot.key,email))
                        self.emailTableView?.reloadData()
                        self.emailTextField?.text = ""
                        emailTxt = ""
                        //Add to Firebase Database
                        let friendUser = ["email":email,"new":0] as [String : Any]
                        let userID = ref?.child("ListUser").child(user!.uid)
                            .child("FriendList").child(snapshot.key)
                        userID?.setValue(friendUser)
                        let thisUser = ["email":user!.email!,"new":0] as [String : Any]
                        ref?.child("ListUser").child(snapshot.key).child("FriendList").child(user!.uid).setValue(thisUser)
                        return
                    }
                }
            }
            })
            }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        createAction()
        return true
    }
    
    func addOnlineUser() {
        user = Auth.auth().currentUser
        let id = ref?.child("ListUser").child((user?.uid)!)
        id?.observe(.value, with: {
        (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? nil
            if((postDict) == nil){
                if let user = self.user {
                    let uid = user.uid
                    let email = user.email
                    let list = ref?.child("ListUser")
                    let user = ["email":email]
                    let userId = list?.child(uid)
                    userId?.setValue(user)
                }
            }
        })

    }
    
    // MARK: Table View list Friend
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emailList.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "GoToChat"){
            if let destination = segue.destination as? ChatViewController {
                if let s = sender as? (id:String,email:String) {
                    destination.infoPass = s
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "GoToChat", sender: emailList[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmailViewCell") as! TableViewCell
        let s = emailList[indexPath.row]
        cell.EmailText.text = s.email
        
        loadAvatar(email: s.email, imageView: cell.FriendAvatar)
        return cell
    }
}
