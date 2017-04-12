//
//  AddNewGroupCell.swift
//  Kutumblink
//
//  Created by Admin on 04/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

protocol AddNewGroupCellDelegate {
    func updateNavigationButton(isRightBarButtonEnabled: Bool)
    func UpdateGroupImage()

}

class AddNewGroupCell: UITableViewCell,UITextFieldDelegate {

    var delegate: AddNewGroupCellDelegate?

    @IBOutlet weak var btnGroupImage: UIButton!
    @IBOutlet weak var txtfldGroupName: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func btnGroupImageClicked(_ sender: Any) {
    
        self.delegate?.UpdateGroupImage()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true;
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        print(range.length)
        if range.length == 1 {
            if (textField.text?.characters.count)! > 1 {
                print("true")
                self.delegate?.updateNavigationButton(isRightBarButtonEnabled: true)
            }
            else{
                print("false")
                self.delegate?.updateNavigationButton(isRightBarButtonEnabled: false)
            }
        }
        else{
            self.delegate?.updateNavigationButton(isRightBarButtonEnabled: true)
        }
       
        return true;
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
}
