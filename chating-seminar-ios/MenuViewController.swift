//
//  MenuViewController.swift
//  chating-seminar-ios
//
//  Created by An Nguyen on 7/2/18.
//  Copyright © 2018 Tran Quoc Bao. All rights reserved.
//

import UIKit

import Firebase
import Photos

class MenuViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
     var delegate: SildeMenuDelegate?
    lazy var storage = Storage.storage()

    @IBOutlet weak var userAvatar: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils.loadAvatar(email: (Auth.auth().currentUser?.email)!, imageView: userAvatar, storage: storage)
        // Do any additional setup after loading the view.
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
    
    @IBAction func Logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            print("Logout successfully")
            self.navigationController?.popToRootViewController(animated: true)
        } catch {
            print(error)
        }
    }
    @IBOutlet weak var Logout: UIButton!
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
