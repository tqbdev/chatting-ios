//
//  LoginViewController.swift
//  chating-seminar-ios
//
//  Created by Tran Quoc Bao on 4/18/18.
//  Copyright © 2018 Tran Quoc Bao. All rights reserved.
//

import UIKit
import Firebase
import Crashlytics

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    func showNoticeMessage(title: String, message: String, okHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: okHandler))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func testCrashBtnAction(_ sender: Any) {
        Crashlytics.sharedInstance().crash()
    }
    
    @IBAction func testBtnAction(_ sender: Any?){

        
        Auth.auth().signIn(withEmail: "tranminhannguyen@gmail.com", password: "1234567") {
            (user, error) in
            if let error = error {
                self.showNoticeMessage(title: "Login error", message: error.localizedDescription)
                return
            }
            let  friendlistUserVC = self.storyboard?.instantiateViewController(withIdentifier: "FriendListViewController") as! FriendListViewController
            self.navigationController?.pushViewController(friendlistUserVC, animated: true)
            
        }
    }
    
    @IBAction func loginBtnAction(_ sender: UIButton) {
        if let email = self.userEmail.text, let password = self.userPassword.text {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if let error = error {
                    self.showNoticeMessage(title: "Login error", message: error.localizedDescription)
                    return
                }
                
                if let user = user {
                    if !user.isEmailVerified {
                        let alertVC = UIAlertController(title: "Login error", message: "Sorry. Your email address has not yet been verified. Do you want us to send another verification email to \(self.userEmail.text!).", preferredStyle: .alert)
                        let alertActionOkay = UIAlertAction(title: "Okay", style: .destructive) {
                            (_) in
                            user.sendEmailVerification(completion: nil)
                        }
                        let alertActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                        
                        alertVC.addAction(alertActionOkay)
                        alertVC.addAction(alertActionCancel)
                        self.present(alertVC, animated: true, completion: nil)
                    }
                    else {
                        // TODO: switch screen
                        print("Login successfully")
                        let friendlistUserVC = self.storyboard?.instantiateViewController(withIdentifier: "FriendListViewController") as! FriendListViewController
                        
                        //messageUserVC.delegate = self
                        //messageUserVC.oldStudent = oldStudent as? Student
                        self.navigationController?.pushViewController(friendlistUserVC, animated: true)
                    }
                }
            }
        } else {
            showNoticeMessage(title: "Login error", message: "Email or Password field cannot empty.")
        }
    }
    
    @IBAction func signupBtnAction(_ sender: UIButton) {
        let alertView = UIAlertController(title: "Sign up", message: "Sign up an account for chating", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .destructive) { (action) in
            let emailTextField = alertView.textFields![0] as UITextField
            let passwordTextField = alertView.textFields![1] as UITextField
            let passwordRetypeTextField = alertView.textFields![2] as UITextField
            
            let email = emailTextField.text
            let password = passwordTextField.text
            
            if email != nil && email != "" {
                if password != nil && password != "" {
                    if (passwordTextField.text == passwordRetypeTextField.text) {
                        Auth.auth().createUser(withEmail: email!, password: password!) { (user, error) in
                            if let error = error {
                                self.showNoticeMessage(title: "Sign up error", message: error.localizedDescription)
                                return
                            }
                            
                            if let user = user {
                                if !user.isEmailVerified {
                                    self.showNoticeMessage(title: "Please notice", message: "You email need to be verified. Please check mail and confirm.") { (action) in
                                        user.sendEmailVerification(completion: nil)
                                    }
                                }
                            }
                            }
                    }
                    else {
                        self.showNoticeMessage(title: "Sign up error", message: "Password does not match.") { (action) in
                            self.present(alertView, animated: true, completion: nil)
                        }
                    }
                }
                else {
                    self.showNoticeMessage(title: "Sign up error", message: "Password field cannot empty.") { (action) in
                        self.present(alertView, animated: true, completion: nil)
                    }
                }
            } else {
                self.showNoticeMessage(title: "Sign up error", message: "Email field cannot empty.") { (action) in
                    self.present(alertView, animated: true, completion: nil)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertView.addTextField { (textField) in
            textField.placeholder = "Enter email"
        }
        
        alertView.addTextField { (textField) in
            textField.placeholder = "Enter password"
            textField.isSecureTextEntry = true
        }
        
        alertView.addTextField { (textField) in
            textField.placeholder = "Re-type password"
            textField.isSecureTextEntry = true
        }
        
        alertView.addAction(okAction)
        alertView.addAction(cancelAction)
        
        present(alertView, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Hide keyboard when press return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true
    }


}
