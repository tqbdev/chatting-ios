//
//  SelectedUserViewCell.swift
//  chating-seminar-ios
//  Created by An Nguyen on 7/2/18.
//  Copyright © 2018 Tran Quoc Bao. All rights reserved.
//

import UIKit

class SelectedUserViewCell: UITableViewCell {
    
    @IBOutlet weak var avatart: UIImageView!
    @IBOutlet weak var name: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
    }

}
