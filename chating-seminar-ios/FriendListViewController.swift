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

class FriendListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, UINavigationControllerDelegate, SildeMenuDelegate {
    lazy var storage = Storage.storage()
    
    var leftVC: LeftViewController?
    
    var senderDisplayName: String?
    @IBOutlet weak var UserAvatar: UIImageView!
    @IBOutlet weak var emailTableView: UITableView?
    var emailList: [(id:String,email:String)] = [(String,String)]()
    var user:User?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(self.menuAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(self.createAction))
        self.title = "Friends List"
        
        initProfileViewController()
        addGesture()
        
        ref = Database.database().reference()
        
        addOnlineUser()
    }
    
    fileprivate func initProfileViewController() {
        let leftVC = storyboard?.instantiateViewController(withIdentifier: "LeftViewController") as! LeftViewController
        leftVC.delegate = self
        if let frame = UIApplication.shared.windows.last?.frame {
            leftVC.resetWidth(parentWidth: frame.width)
            leftVC.shadowColor = UIColor(red: 46.0/255, green: 24.0/255, blue: 82.0/255, alpha: 0.7)
            leftVC.hasShadow = true
            UIApplication.shared.windows.last?.addSubview(leftVC.view)
        }
        self.leftVC = leftVC
    }
    
    fileprivate func addGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapInSelf))
        self.view.addGestureRecognizer(gesture)
    }
    
    fileprivate func showLeftViewController() {
        leftVC?.expand()
    }
    
    @objc func tapInSelf() {
        leftVC?.close()
    }
    
    // MARK: Logout successfull
    func logout() {
        leftVC?.close()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: gotoInfoView
    func gotoInfoView() {
        let infoVC = storyboard?.instantiateViewController(withIdentifier: "infoView")
        //present(infoVC!, animated: true, completion: nil)
        navigationController?.pushViewController(infoVC!, animated: true)
    }
    
    // MARK: Firebase storage avatar
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
        showLeftViewController()
    }

    @objc func createAction() {
        let alertView = UIAlertController(title: "Add Friend", message: "", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .destructive) { (action) in
            let emailTextField = alertView.textFields![0] as UITextField
            let emailTxt = emailTextField.text
            if(emailTxt != nil){
                if(self.checkArrayFriend(email: emailTxt!)) {
                    let arlet = UIAlertController(title: nil, message: "Email already added", preferredStyle: .alert)
                    arlet.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(arlet, animated: true, completion: nil)
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
                                self.present(arlet, animated: true, completion: nil)
                            }
                            else if(emailTxt == email ){
                                //self.emailList.append((snapshot.key,email))
                                self.emailTableView?.reloadData()
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
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertView.addTextField { (textField) in
            textField.placeholder = "Enter email"
        }
        
        alertView.addAction(okAction)
        alertView.addAction(cancelAction)
        
        present(alertView, animated: true, completion: nil)
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
                    let user = ["email":email, "dob": nil, "name": nil]
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
