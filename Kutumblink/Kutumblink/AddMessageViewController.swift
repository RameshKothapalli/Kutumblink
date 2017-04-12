//
//  AddMessageViewController.swift
//  Kutumblink
//
//  Created by Apple on 09/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import CoreData

class AddMessageViewController: BaseViewController {

    @IBOutlet weak var txtfldTitle: UITextField!
    
    @IBOutlet weak var txtvwLink: UITextView!
    

    var selectedMessage:Messages!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barTintColor = navigationBarColor
        self.navigationItem.title = "Add Message Link"

        // Do any additional setup after loading the view.
        let paddingView:UIView = UIView (frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        txtfldTitle.leftViewMode = .always
        txtfldTitle.leftView = paddingView
        txtfldTitle.layer.borderColor = UIColor.lightGray.cgColor
        txtfldTitle.layer.borderWidth = 2.0
        txtfldTitle.layer.cornerRadius = 2.0

        txtvwLink.layer.borderColor = UIColor.lightGray.cgColor
        txtvwLink.layer.borderWidth = 2.0
        txtvwLink.layer.cornerRadius = 2.0

        if (selectedMessage != nil)  {
            txtfldTitle.text = selectedMessage.messageTitle
            txtvwLink.text = selectedMessage.messageUrl
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func saveLink(_ sender: Any) {

    
        if (txtfldTitle.text?.characters.count)! < 1
        {
            showAlertWithTitle(title: "", message: "Please enter title.", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
            }, alertCancel: { Void in
                
            })
            return;
        }
        if (txtvwLink.text?.characters.count)! < 1
        {
            showAlertWithTitle(title: "", message: "Please enter link.", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
            }, alertCancel: { Void in
                
            })
            return;
        }
        if !(verifyUrl(urlString: txtvwLink.text)) {
            
            showAlertWithTitle(title: "", message: "Please enter valid url.", forTarget: self, buttonOK: "" , buttonCancel: "OK", alertOK: { (okTitle:String) in
                }, alertCancel: { Void in
                    
            })
            return;
        }
        
        if selectedMessage == nil{
            
            if checkMessageTitleAvailableInDB(messageTitle: self.txtfldTitle.text!) {
                showAlertWithTitle(title: "", message: "Message title already exists.", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
                }, alertCancel: { Void in })
                return;
            }

//            let messageInfo = Messages(context: managedContext)
            let messageInfo:Messages!
            if #available(iOS 10.0, *) {
                messageInfo = Messages(context: managedContext)
            } else {
                // Fallback on earlier versions
                
                let entity =  NSEntityDescription.entity(forEntityName: "Messages",
                                                         in:managedContext)
                
                messageInfo = Messages(entity: entity!,
                                   insertInto: managedContext)
                
            }

            let messageIDCount = self.getMaxEventId()
            messageInfo.messageId = messageIDCount+1
            messageInfo.messageTitle = self.txtfldTitle.text
            messageInfo.messageUrl = self.txtvwLink.text
            selectedMessage = messageInfo
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        else{
            if selectedMessage.messageTitle != self.txtfldTitle.text {
                if checkMessageTitleAvailableInDB(messageTitle: self.txtfldTitle.text!) {
                    showAlertWithTitle(title: "", message: "Message title already exists.", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
                    }, alertCancel: { Void in })
                    return;
                }
            }

            selectedMessage.messageId = selectedMessage.messageId
            selectedMessage.messageTitle = self.txtfldTitle.text
            selectedMessage.messageUrl = self.txtvwLink.text
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        showAlertWithTitle(title: "Message Link is saved.", message: "", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
            
            self.navigationController?.popViewController(animated: true)
            }, alertCancel: { Void in })
        
    }
    func checkMessageTitleAvailableInDB(messageTitle:String) -> Bool {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Messages")
        fetchRequest.predicate = NSPredicate(format: "messageTitle == %@", messageTitle)

        do {
            let messages = try managedContext.fetch(fetchRequest) as! [Messages]
            if messages.count > 0 {
                return true
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return false
    }

    
    func getMaxEventId() -> Int {
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Messages")
        
        fetchRequest.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: "messageId", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let group = try managedContext.fetch(fetchRequest)
            print(group)
            if group.count == 0 {
                return 0
            }
            let max = group.first
            print(max?.value(forKey: "messageId") as! Int!)
            return (max?.value(forKey: "messageId") as! Int)
        } catch _ {
            
        }
        return 0
    }

    
}
