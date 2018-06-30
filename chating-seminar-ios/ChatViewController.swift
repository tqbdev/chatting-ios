//
//  ChatViewController.swift
//  chating-seminar-ios
//
//  Created by An Nguyen on 4/29/18.
//  Copyright © 2018 Tran Quoc Bao. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var ChatLog:[(type:Bool,message:String,time:Int)] = [(Bool,String,Int)]()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChatLog.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat:(type:Bool,message:String,time:Int) = ChatLog[indexPath.row]
        if(chat.type) {
            let cell = chetTableView.dequeueReusableCell(withIdentifier: "GetTableViewCell") as! GetTableViewCell
            cell.tv.text = chat.message
            return cell
        }
        else{
            let cell = chetTableView.dequeueReusableCell(withIdentifier: "SendTableViewCell") as! SendTableViewCell
            cell.tv.text = chat.message
            return cell
        }
    }
    
    var infoPass:(id:String,email:String)?
    
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var chetTableView: UITableView!
    @IBOutlet weak var bottom: NSLayoutConstraint!
    @IBOutlet weak var bottomContain: NSLayoutConstraint!
    @IBOutlet weak var inputText: UITextField!
    var userID:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        btnSend.setImage(#imageLiteral(resourceName: "go"), for: .highlighted)
        inputText.layer.cornerRadius = 15.0
        inputText.layer.borderWidth = 1.5
        inputText.layer.borderColor = UIColor.gray.cgColor
        chetTableView.keyboardDismissMode = .onDrag
        userID = Auth.auth().currentUser?.uid
        if( infoPass != nil ){
            self.title = infoPass?.email
        }
        
        loadMessage()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func loadMessage() {
        let message = ref?.child("Chat").child(userID!+"_"+(self.infoPass?.id)!)
        message?.observe(.childAdded, with: {(snapshot) in
            if let dic = snapshot.value as? [String:Any]{
                let type = dic["type"] as! String
                let mess = dic["text"]
                let time = dic["timestamp"]
                //self.ChatLog.insert((true,mess as! String,time as! Int), at: 0)
                self.ChatLog.append((type: (type == "Get"),
                                     message:mess as! String,
                                     time:time as! Int))
                self.chetTableView.reloadData()
            }
            
        })

        let newMess = ref?.child("ListUser").child((self.infoPass?.id)!).child("FriendList").child(self.userID!).child("new")
        newMess?.observeSingleEvent(of: .value, with: {(snapshot) in
            _ = snapshot.value as! Int
            newMess?.setValue(0)
        })
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
    
    @objc func sendMessage(){
        let idMess = ref?.child("Chat").child(userID!+"_"+(self.infoPass?.id)!)
        let idMess1 = ref?.child("Chat").child((self.infoPass?.id)! + "_" + userID!)
        let childMess = idMess?.childByAutoId()
        let childMess1 = idMess1?.child((childMess?.key)!)
        let text = self.inputText.text
        let time = Int(NSDate().timeIntervalSince1970)
        let value = ["type":"Send","text":text!,"timestamp":time] as [String : Any]
        let value1 = ["type":"Get","text":text!,"timestamp":time] as [String : Any]
        childMess?.setValue(value)
        childMess1?.setValue(value1)
        
        
        let newMess = ref?.child("ListUser").child((infoPass?.id)!).child("FriendList").child(userID!).child("new")
//        self.ChatLog.insert((type:false,
//                             message:self.inputText.text!,
//                             time:time)
        //self.ChatLog.append((type:false,message:self.inputText.text!,time:time))
        self.chetTableView.reloadData()
        newMess?.observeSingleEvent(of: .value, with: {(snapshot) in
            var value = snapshot.value as! Int
            value = value + 1
            newMess?.setValue(value)
        })
        
        self.inputText.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true 
    }
    
    @IBAction func btnSendClick(_ sender: Any) {
        sendMessage()
    }
    
    
}
