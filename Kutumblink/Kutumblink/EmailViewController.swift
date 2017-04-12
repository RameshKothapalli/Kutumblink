//
//  EmailViewController.swift
//  Kutumblink
//
//  Created by Apple on 10/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import MessageUI

class EmailViewController: BaseViewController ,MFMailComposeViewControllerDelegate{

    @IBOutlet weak var txtfldSubject: UITextField!
    @IBOutlet weak var txtvwBody: UITextView!
    var contactList: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txtfldSubject.layer.borderColor = UIColor.lightGray.cgColor
        txtfldSubject.layer.borderWidth = 2.0
        txtfldSubject.layer.cornerRadius = 2.0

        txtvwBody.layer.borderColor = UIColor.lightGray.cgColor
        txtvwBody.layer.borderWidth = 2.0
        txtvwBody.layer.cornerRadius = 2.0

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendEmail(_ sender: Any) {
        
//        if (txtfldSubject.text?.characters.count)! < 1
//        {
//            showAlertWithTitle(title: "", message: "Please enter subject.", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
//            }, alertCancel: { Void in
//                
//            })
//            return;
//        }
//        
//        if (txtvwBody.text?.characters.count)! < 1
//        {
//            showAlertWithTitle(title: "", message: "Please enter email body.", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
//            }, alertCancel: { Void in
//                
//            })
//            return;
//        }
        if( MFMailComposeViewController.canSendMail() ) {
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setSubject(txtfldSubject.text!)
            mailComposer.setToRecipients(contactList)
            mailComposer.setMessageBody(txtvwBody.text, isHTML: false)
            self.present(mailComposer, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }

    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
    }

    func showSendMailErrorAlert() {
        
        showAlertWithTitle(title: "Could Not Send Email", message: "Your device could not send e-mail. Please check e-mail configuration and try again.", forTarget: self, buttonOK: "" , buttonCancel: "OK", alertOK: { (okTitle:String) in
            
        }, alertCancel: { Void in
            
        })
        return;
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
