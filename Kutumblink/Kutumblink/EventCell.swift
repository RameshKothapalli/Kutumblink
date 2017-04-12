//
//  EventCell.swift
//  Kutumblink
//
//  Created by Apple on 07/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {

    @IBOutlet weak var lblEventTitle: UILabel!
    @IBOutlet weak var lblEventDescription: UILabel!
    @IBOutlet weak var lblEventDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
