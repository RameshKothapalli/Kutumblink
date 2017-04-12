//
//  GroupDetailsCell.swift
//  Kutumblink
//
//  Created by Apple on 07/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class GroupDetailsCell: UITableViewCell {

    @IBOutlet weak var lblGroupOptionText: UILabel!
    @IBOutlet weak var imgvwArrow: UIImageView!
    
    @IBOutlet weak var imgvw_Separator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
