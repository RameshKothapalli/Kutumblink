//
//  GroupCell.swift
//  Kutumblink
//
//  Created by Apple on 07/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {

    @IBOutlet weak var imgvwGroup: UIImageView!
    @IBOutlet weak var lblGroupName: UILabel!
    
    @IBOutlet weak var lblContactCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
