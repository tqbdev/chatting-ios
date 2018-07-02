//
//  GroupMessageCell.swift
//  chating-seminar-ios
//
//  Created by An Nguyen on 7/2/18.
//  Copyright © 2018 Tran Quoc Bao. All rights reserved.
//

import UIKit

class GroupMessageCell: UITableViewCell {

    @IBOutlet weak var messText: UILabel!
    @IBOutlet weak var vwMessage: UIView!
    @IBOutlet weak var lbText: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        imgAvatar.layer.cornerRadius = 25
        imgAvatar.layer.borderWidth = 0.5
        imgAvatar.layer.borderColor = UIColor.clear.cgColor
        
        vwMessage.layer.cornerRadius = 10
        vwMessage.layer.borderWidth = 0.5
        vwMessage.layer.borderColor = UIColor.clear.cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
