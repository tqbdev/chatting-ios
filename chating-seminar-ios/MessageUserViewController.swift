	//
//  MessageUserViewController.swift
//  chating-seminar-ios
//
//  Created by Tran Quoc Bao on 4/18/18.
//  Copyright © 2018 Tran Quoc Bao. All rights reserved.
//

import UIKit
import Firebase
import Crashlytics

class MessageUserViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(self.logOutAction))
    }
    
    @IBAction func crashButtonTapped(_ sender: AnyObject) {
        Crashlytics.sharedInstance().crash()
    }	
    
    @objc func logOutAction() {
        do {
            try Auth.auth().signOut()
            print("Logout successfully")
        } catch {
            print(error)
        }
        
        self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
