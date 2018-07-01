//
//  LeftViewController.swift
//  chating-seminar-ios
//
//  Created by Tran Quoc Bao on 7/1/18.
//  Copyright © 2018 Tran Quoc Bao. All rights reserved.
//

import UIKit

import Firebase
import Photos

protocol LogoutDelegate {
    func logout()
}

class LeftViewController: CustomSlideViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var delegate: LogoutDelegate?
    
    lazy var storage = Storage.storage()

    @IBOutlet weak var userAvatar: UIImageView!
    
    @IBAction func getInfoView(_ sender: UIButton) {
    }
    
    @IBAction func goToPersonalChatView(_ sender: UIButton) {
    }
    
    @IBAction func goToGroupChatView(_ sender: UIButton) {
    }
    
    @IBAction func logoutAction(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            print("Logout successfully")
            delegate?.logout()
        } catch {
            print(error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadUserAvatar()
    userAvatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleSelectUserAvatar)))
        userAvatar.isUserInteractionEnabled = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            userAvatar.image = selectedImage
            userAvatar.layer.cornerRadius = userAvatar.layer.bounds.width/2
            userAvatar.layer.masksToBounds = true
            
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
                self.userAvatar.image = UIImage(contentsOfFile: imagePath)
                self.userAvatar.layer.cornerRadius = self.userAvatar.layer.bounds.width/2
                self.userAvatar.layer.masksToBounds = true
            }
        })
        // [END downloadimage]
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
