//
//  FAQCell.swift
//  Kutumblink
//
//  Created by Admin on 27/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class FAQCell: UITableViewCell {

    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var lblAnswer: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
