//
//  ContactUSViewController.swift
//  Kutumblink
//
//  Created by Apple on 15/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import MessageUI

class ContactUSViewController: BaseViewController,MFMailComposeViewControllerDelegate {

    @IBOutlet weak var txtfldName: UITextField!
     @IBOutlet weak var txtvwMessage: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Contact"
        self.navigationController?.navigationBar.barTintColor = navigationBarColor

        // Do any additional setup after loading the view.
        let paddingView1:UIView = UIView (frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        txtfldName.leftViewMode = .always
        txtfldName.leftView = paddingView1


        txtfldName.layer.borderColor = UIColor.lightGray.cgColor
        txtfldName.layer.borderWidth = 2.0
        txtfldName.layer.cornerRadius = 2.0

        
        txtvwMessage.layer.borderColor = UIColor.lightGray.cgColor
        txtvwMessage.layer.borderWidth = 2.0
        txtvwMessage.layer.cornerRadius = 2.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        
        controller.dismiss(animated: true, completion: {
            if result == .cancelled {
                let alertController = UIAlertController(title: "", message: String(format:"Email cancelled."), preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
                }))
                
                self.present(alertController, animated: true, completion: nil)
            }
            else if result == .sent{
                let alertController = UIAlertController(title: "", message: String(format:"Email sent."), preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
                }))
                
                self.present(alertController, animated: true, completion: nil)
            }
            else{
                let alertController = UIAlertController(title: "", message: String(format:"Email failed."), preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
                }))
                
                self.present(alertController, animated: true, completion: nil)
            }
            
        })
    }
    

    @IBAction func contactUSClicked(_ sender: Any) {
        
        if( MFMailComposeViewController.canSendMail() ) {
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
             mailComposer.setSubject(txtfldName.text!)
            mailComposer.setToRecipients(["contact@britezest.com"])
            mailComposer.setMessageBody(txtvwMessage.text, isHTML: false)
            self.present(mailComposer, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
 
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
