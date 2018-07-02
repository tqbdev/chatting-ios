//
//  AddGroupViewController.swift
//  chating-seminar-ios
//
//  Created by An Nguyen on 7/2/18.
//  Copyright © 2018 Tran Quoc Bao. All rights reserved.
//

import UIKit
import Firebase

class AddGroupViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var GroupName: UITextField!
    @IBAction func GroupName(_ sender: Any) {
    }
    lazy var storage = Storage.storage()
    @IBOutlet weak var friendTable: UITableView!
    var user:User?
    var emailList: [(id:String,email:String)] = [(String,String)]()
    override func viewDidLoad() {
        super.viewDidLoad()
        user = Auth.auth().currentUser
        friendTable.allowsMultipleSelection = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(self.createAction))
        loadFriendList()
        // Do any additional setup after loading the view.
    }
    
    @objc fileprivate func createAction(){
        if(GroupName.text?.trimmingCharacters(in: .whitespaces).count==0){
            let alert = UIAlertController(title: "Alert", message: "Group Name", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        let selectedRow = friendTable.indexPathsForSelectedRows
        var selected: [(id:String,email:String)] = [(String,String)]()
        for index in selectedRow! {
            selected.append(emailList[index[1]])
        }
        if(selected.count>0){
            let group = ref?.child("Groups").childByAutoId()
            let key = group?.key
            group?.setValue(["size":selected.count+1,"name":GroupName.text?.trimmingCharacters(in: .whitespaces)])
            group?.child("members").childByAutoId().setValue(["id":user?.uid])
            ref?.child("ListUser").child((user?.uid)!).child("Groups").childByAutoId().setValue(key)
            for e in selected {
                group?.child("members").childByAutoId().setValue(["id":e.id])
                ref?.child("ListUser").child(e.id).child("Groups").childByAutoId().setValue(key)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadFriendList() {
        let list = ref?.child("ListUser").child((user?.uid)!).child("FriendList")
        list?.observe(.childAdded, with: {
            (snapshot) in
            let postDict =  snapshot.value as? [String:Any]
            if( postDict != nil ){
                let emailFriend:String? = postDict!["email"] as? String
                if( emailFriend != nil) {
                    print(snapshot)
                    self.emailList.append((snapshot.key,emailFriend!))
                    self.friendTable?.reloadData()
                }
            }
        })
    }
    
    //Table list
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emailList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddGroupViewCell") as! SelectedUserViewCell
        let s = emailList[indexPath.row]
        cell.name.text = s.email
        Utils.loadAvatar(email: s.email, imageView: cell.avatart, storage: storage)
        return cell
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
