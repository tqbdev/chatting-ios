//
//  GroupChatViewController.swift
//  chating-seminar-ios
//
//  Created by An Nguyen on 7/2/18.
//  Copyright © 2018 Tran Quoc Bao. All rights reserved.
//

import UIKit
import Firebase

class GroupChatViewController: UIViewController,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChatLog.count
    }
    
    @IBOutlet weak var chatTableView: UITableView!
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat:(type:Bool,message:String,time:Int) = ChatLog[indexPath.row]
//        let cell = chatTableView.dequeueReusableCell(withIdentifier: (!chat.type) ? "RightMessageCell" : "LeftMessageCell") as! GroupMessageCell
        let cellid = !chat.type ? "RightMessageCell" : "LeftMessageCell"
        let cell = chatTableView.dequeueReusableCell(withIdentifier: cellid) as! GroupMessageCell
        cell.messText.text = chat.message
                //let cell = chatTableView.dequeueReusableCell(withIdentifier:"LeftMessageCell") as! MessageCell
        return cell
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.ChatLog.count-1, section: 0)
            self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var bottom: NSLayoutConstraint!
    var infoPass:(id:String,name:String)?
    var user:User?
    var ChatLog:[(type:Bool,message:String,time:Int)] = [(Bool,String,Int)]()
    override func viewDidLoad() {
        super.viewDidLoad()
        user = Auth.auth().currentUser
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        loadMessage()
        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var sendMessage: UIButton!
    @IBAction func sendMessage(_ sender: Any) {
//        let idMess = ref?.child("Chat").child(userID!+"_"+(self.infoPass?.id)!)
//        let idMess1 = ref?.child("Chat").child((self.infoPass?.id)! + "_" + userID!)
//        let childMess = idMess?.childByAutoId()
//        let childMess1 = idMess1?.child((childMess?.key)!)
//        let text = self.inputText.text
//        let time = Int(NSDate().timeIntervalSince1970)
//        let value = ["type":"Send","text":text!,"timestamp":time] as [String : Any]
//        let value1 = ["type":"Get","text":text!,"timestamp":time] as [String : Any]
//        childMess?.setValue(value)
//        childMess1?.setValue(value1)
//
//
//        let newMess = ref?.child("ListUser").child((infoPass?.id)!).child("FriendList").child(userID!).child("new")
//        self.chetTableView.reloadData()
//        newMess?.observeSingleEvent(of: .value, with: {(snapshot) in
//            var value = snapshot.value as! Int
//            value = value + 1
//            newMess?.setValue(value)
//        })
//
//        self.inputText.text = ""
        
        let idMess = ref?.child("Groups").child((infoPass?.id)!).child("Chat").childByAutoId()
        let text = self.inputText.text
        let time = Int(NSDate().timeIntervalSince1970)
        let value = ["user":user?.uid,"text":text!,"timestamp":time] as [String : Any]
        idMess?.setValue(value)
        
        
        self.inputText.text = ""
    }
    
    @objc func loadMessage() {
        let message = ref?.child("Groups").child((infoPass?.id)!).child("Chat")
        message?.observe(.childAdded, with: {(snapshot) in
            if let dic = snapshot.value as? [String:Any]{
//                let type = dic["type"] as! String
//                let mess = dic["text"]
//                let time = dic["timestamp"]
//                //self.ChatLog.insert((true,mess as! String,time as! Int), at: 0)
//                self.ChatLog.append((type: (type == "Get"),
//                                     message:mess as! String,
//                                     time:time as! Int))
//                self.chetTableView.reloadData()
                print(dic)
                let type = dic["user"] as! String == self.user?.uid ? "Send" : "Get"
                let mess = dic["text"]
                let time = dic["timestamp"]
                ref?.child("ListUser").child(dic["user"] as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dic = snapshot.value as? [String:Any] {
                        let email = dic["email"]
                        print(email)
                        self.ChatLog.append((type: (type == "Get"),
                                             message:mess as! String,
                                             time:time as! Int))
                        self.chatTableView.reloadData()
                        self.scrollToBottom()
                    }
                })

            }
            
        })
        
//        let newMess = ref?.child("ListUser").child((self.infoPass?.id)!).child("FriendList").child(self.userID!).child("new")
//        newMess?.observeSingleEvent(of: .value, with: {(snapshot) in
//            _ = snapshot.value as! Int
//            newMess?.setValue(0)
//        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //sendMessage()
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func keyboardWasShow(noti: Notification){
        let keyboardFrame = (noti.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.animate(withDuration: 0.1 ){
            self.bottom.constant = keyboardFrame.size.height + 20
            self.loadViewIfNeeded()
        }
    }
    
    @objc func keyboardWasHide(noti: Notification){
        UIView.animate(withDuration: 0.3 ){
            self.bottom.constant = 0
            self.loadViewIfNeeded()
        }
    }

}
