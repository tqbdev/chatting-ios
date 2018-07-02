//
//  Utils.swift
//  chating-seminar-ios
//
//  Created by An Nguyen on 7/2/18.
//  Copyright © 2018 Tran Quoc Bao. All rights reserved.
//

import Foundation
import Firebase

class Utils {

    static func loadAvatar(email: String, imageView: UIImageView, storage: Storage) {
        //var storage = Storage.storage()
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

}
