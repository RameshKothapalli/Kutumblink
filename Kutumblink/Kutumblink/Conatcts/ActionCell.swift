//
//  ActionCell.swift
//  sampleContacts
//
//  Created by Apple on 06/02/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class ActionCell: UITableViewCell {
    
    @IBOutlet weak var lblActionType: UILabel!
    @IBOutlet weak var imgvwType: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
