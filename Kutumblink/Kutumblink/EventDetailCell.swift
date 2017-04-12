//
//  EventDetailCell.swift
//  Kutumblink
//
//  Created by Apple on 24/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class EventDetailCell: UITableViewCell {

    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
