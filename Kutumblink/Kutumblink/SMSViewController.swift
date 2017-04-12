//
//  SMSViewController.swift
//  Kutumblink
//
//  Created by Apple on 10/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import MessageUI

class SMSViewController: BaseViewController,MFMessageComposeViewControllerDelegate {
    /*!
     @method     messageComposeViewController:didFinishWithResult:
     @abstract   Delegate callback which is called upon user's completion of message composition.
     @discussion This delegate callback will be called when the user completes the message composition.
     How the user chose to complete this task will be given as one of the parameters to the
     callback.  Upon this call, the client should remove the view associated with the controller,
     typically by dismissing modally.
     @param      controller   The MFMessageComposeViewController instance which is returning the result.
     @param      result       MessageComposeResult indicating how the user chose to complete the composition process.
     */
    


    @IBOutlet weak var txtvwMessage: UITextView!
    var contactList: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        txtvwMessage.layer.borderColor = UIColor.lightGray.cgColor
        txtvwMessage.layer.borderWidth = 2.0
        txtvwMessage.layer.cornerRadius = 2.0

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @available(iOS 4.0, *)
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func sendSMS(_ sender: Any) {
        
        if (txtvwMessage.text?.characters.count)! < 1
        {
            showAlertWithTitle(title: "", message: "Please enter message.", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
            }, alertCancel: { Void in
                
            })
            return;
        }
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = txtvwMessage.text
            controller.recipients = contactList
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        else{
            showAlertWithTitle(title: "", message: "SMS service not available.", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
            }, alertCancel: { Void in
                
            })
            return;
        }

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
