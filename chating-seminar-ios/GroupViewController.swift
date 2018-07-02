//
//  GroupViewController.swift
//  chating-seminar-ios
//
//  Created by An Nguyen on 7/1/18.
//  Copyright © 2018 Tran Quoc Bao. All rights reserved.
//

import UIKit
import Firebase

class GroupViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return grouplList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupViewCell") as! GroupViewCell
        let s = grouplList[indexPath.row]
        cell.Name.text = s.name
        //loadAvatar(email: s.email, imageView: cell.FriendAvatar)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toGroupChat"){
            if let destination = segue.destination as? GroupChatViewController {
                if let s = sender as? (id:String,name:String) {
                    destination.infoPass = s
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toGroupChat", sender: grouplList[indexPath.row])
    }
    
    var grouplList: [(id:String,name:String)] = [(String,String)]()
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadGroups()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var GroupTable: UITableView!
    @IBAction func CreateGroup(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toAddGroup", sender: nil)
    }
    
    func LoadGroups(){
        let user = Auth.auth().currentUser
        ref?.child("ListUser").child((user?.uid)!).child("Groups").observe(.childAdded, with: { (snapshot) in
            print(snapshot.value as! String)
            let keyGroup = snapshot.value as! String
            ref?.child("Groups").child(keyGroup).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dic = snapshot.value as? [String:Any]{
                    let name = dic["name"] as! String
                    let id = snapshot.key as String
                    self.grouplList.append((id: id, name: name))
                    self.GroupTable.reloadData()
                }

            })
        })
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
