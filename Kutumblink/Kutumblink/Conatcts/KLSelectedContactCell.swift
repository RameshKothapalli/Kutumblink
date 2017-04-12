//
//  KLSelectedContactCell.swift
//  sampleContacts
//
//  Created by Apple on 06/02/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class KLSelectedContactCell: UITableViewCell {

    @IBOutlet weak var checkBox: UIButton!
    @IBOutlet weak var contactName: UILabel!
        
    @IBOutlet weak var imgvwPhone: UIImageView!
    @IBOutlet weak var imgvwEmail: UIImageView!
    
    var contact: EPContact?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        selectionStyle = UITableViewCellSelectionStyle.none
     }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func updateContactsinUI(_ contact: EPContact, indexPath: IndexPath, subtitleType: SubtitleCellValue) {
        self.contact = contact
        //Update all UI in the cell here
        self.contactName?.text = contact.displayName()
        self.imgvwEmail.isHidden = true
        self.imgvwPhone.isHidden = true
        if contact.phoneNumbers.count > 0 {
            self.imgvwPhone.isHidden = false
        }
        if contact.emails.count > 0 {
            self.imgvwEmail.isHidden = false
        }
     }
    func updateContactsinUI(_ contact: EPContact, indexPath: IndexPath, subtitleType: SubtitleCellValue,selectedGroup:Groups) {
        self.contact = contact
        //Update all UI in the cell here
        
        if selectedGroup.groupOrder  == "" {
            self.contactName?.text = contact.displayName()
        }
        else if selectedGroup.groupOrder  == "Default"{
            self.contactName?.text = contact.displayFirstNameOrder()
        }

        else if selectedGroup.groupOrder  == "By First Name"{
            self.contactName?.text = contact.displayFirstNameOrder()
        }
        else if selectedGroup.groupOrder  == "By Last Name"{
            self.contactName?.text = contact.displayLastNameOrder()
        }
        self.imgvwEmail.isHidden = true
        self.imgvwPhone.isHidden = true
        if contact.phoneNumbers.count > 0 {
            self.imgvwPhone.isHidden = false
        }
        if contact.emails.count > 0 {
            self.imgvwEmail.isHidden = false
        }
    }
    
}
