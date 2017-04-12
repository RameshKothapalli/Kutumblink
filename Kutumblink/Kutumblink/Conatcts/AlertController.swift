//
//  AlertController.swift
//  Teacher
//
//  Created by Chinna Addepally on 5/19/16.
//  Copyright © 2016 iFlyTechSoft. All rights reserved.
//

import Foundation
import UIKit

let CONNECTIONFAILUREALERT:String = "Please check your internet connection."

func showAlertWithTitle(title:String,message:String,forTarget:AnyObject,buttonOK:String,buttonCancel:String,alertOK:@escaping (String)->(),alertCancel:@escaping (Void)->()){
    
    let alertController:UIAlertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
    if buttonCancel.characters.count > 0 {
        let cancelAction:UIAlertAction = UIAlertAction.init(title: buttonCancel, style: .default, handler: { UIAlertAction in
            alertCancel()
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(cancelAction)
    }
    
    if buttonOK.characters.count > 0 {
        let OKButtonAction:UIAlertAction  = UIAlertAction.init(title: buttonOK, style: .default, handler: { UIAlertAction in
            alertOK("OK")
        })
        
        alertController .addAction(OKButtonAction)
    }
    
    forTarget.present(alertController, animated: true, completion: nil)
}


class AlertController {
    //Use If Required
    static let sharedInstance = AlertController()

}

