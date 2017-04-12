//
//  EventDetailsViewController.swift
//  Kutumblink
//
//  Created by Apple on 24/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import MessageUI

class EventDetailsViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource,ActionViewDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,EPPickerDelegate {

    @IBOutlet weak var tblEventDetails: UITableView!
    var selectedEvent:Events!
    var selectedContacts = [EPContact]()
    var contactsStore: CNContactStore?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "Event Details"
        self.navigationController?.navigationBar.barTintColor = navigationBarColor

        let rightButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action:   #selector(EventDetailsViewController.EditEvent))
        self.navigationItem.rightBarButtonItem = rightButtonItem

        tblEventDetails.delegate = self
        tblEventDetails.dataSource = self
        
        self.tblEventDetails.estimatedRowHeight = 80
        self.tblEventDetails.rowHeight = UITableViewAutomaticDimension

        if (selectedEvent.contacts?.characters.count)! > 0 {
             self.importAllContacts()
        }

    }

    func EditEvent()  {
        let AddGroup = self.storyboard!.instantiateViewController(withIdentifier: "AddNewEvent") as! AddNewEventViewController
        AddGroup.selectedEvent = selectedEvent
        self.navigationController!.pushViewController(AddGroup, animated: true)
    }
    func importAllContacts()  {
        
        getAllContacts( {(contacts, error) in
            if (error == nil) {
                DispatchQueue.main.async(execute: {
                    self.tblEventDetails.reloadData()
                    
                 })
            }
        })
        
    }
    func getAllContacts(_ completion:  @escaping ContactsHandler1) {
        if contactsStore == nil {
            //ContactStore is control for accessing the Contacts
            contactsStore = CNContactStore()
        }
        let error = NSError(domain: "EPContactPickerErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "No Contacts Access"])
        
        switch CNContactStore.authorizationStatus(for: CNEntityType.contacts) {
        case CNAuthorizationStatus.denied, CNAuthorizationStatus.restricted:
            //User has denied the current app to access the contacts.
            
            let productName = Bundle.main.infoDictionary!["CFBundleName"]!
            
            let alert = UIAlertController(title: "Unable to access contacts", message: "\(productName) does not have access to contacts. Kindly enable it in privacy settings ", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {  action in
                completion([], error)
                self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            
        case CNAuthorizationStatus.notDetermined:
            //This case means the user is prompted for the first time for allowing contacts
            contactsStore?.requestAccess(for: CNEntityType.contacts, completionHandler: { (granted, error) -> Void in
                //At this point an alert is provided to the user to provide access to contacts. This will get invoked if a user responds to the alert
                if  (!granted ){
                    DispatchQueue.main.async(execute: { () -> Void in
                        completion([], error! as NSError?)
                    })
                }
                else{
                    self.getAllContacts(completion)
                }
            })
            
        case  CNAuthorizationStatus.authorized:
            //Authorization granted by user for this app.
            
            let contactFetchRequest = CNContactFetchRequest(keysToFetch: allowedContactKeys())
            
            do {
                var contactsArray = [CNContact]()
                
                try contactsStore?.enumerateContacts(with: contactFetchRequest, usingBlock: { (contact, stop) -> Void in
                    //Ordering contacts based on alphabets in firstname
                    
                    if (self.selectedEvent.contacts?.characters.count)! > 0
                    {
                        let arrCIdentifiers = self.selectedEvent.contacts?.components(separatedBy: ",")
                        
                        if (arrCIdentifiers?.contains(contact.identifier))!
                        {
                            contactsArray.append(contact)
                            var key: String = "#"
                            //If ordering has to be happening via family name change it here.
                            if let firstLetter = contact.givenName[0..<1] , firstLetter.containsAlphabets() {
                                key = firstLetter.uppercased()
                            }
                            let epContact = EPContact(contact:contact)
                             self.selectedContacts.append(epContact)
                         }
                    }
                    
                })
                completion(contactsArray  , nil)
                
                
                
            }
                //Catching exception as enumerateContactsWithFetchRequest can throw errors
            catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
    }
    func allowedContactKeys() -> [CNKeyDescriptor]{
        //We have to provide only the keys which we have to access. We should avoid unnecessary keys when fetching the contact. Reducing the keys means faster the access.
        return [CNContactNamePrefixKey as CNKeyDescriptor,
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactOrganizationNameKey as CNKeyDescriptor,
                CNContactBirthdayKey as CNKeyDescriptor,
                CNContactImageDataKey as CNKeyDescriptor,
                CNContactThumbnailImageDataKey as CNKeyDescriptor,
                CNContactImageDataAvailableKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor,
        ]
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.selectedContacts.count) > 0 {
            return 4
        }
        return 3
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:EventDetailCell = tableView.dequeueReusableCell(withIdentifier: "EventDetailCell") as! EventDetailCell
        
        if indexPath.row == 0 {
            cell.type.text = "Event Title:"
            cell.value.text = selectedEvent.eventTitle
            cell.date?.isHidden = false

            let todoItem = TodoItem(deadline: selectedEvent.eventDate as! Date, title: selectedEvent.eventTitle!, UUID: "",description:selectedEvent.eventDescription!,contacts:selectedEvent.contacts!)
            if (todoItem.isOverdue) { // the current time is later than the to-do item's deadline
                cell.date?.textColor = UIColor.red
            } else {
                cell.date?.textColor = UIColor.black // we need to reset this because a cell with red subtitle may be returned by dequeueReusableCellWithIdentifier:indexPath:
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd yyyy h:mm a" // example: "Due Jan 01 at 12:00 PM"
            cell.date?.text = dateFormatter.string(from: todoItem.deadline as Date)
            cell.date?.adjustsFontSizeToFitWidth = true
        }
        else if indexPath.row == 1 {
            cell.type.text = "Event Description:"
            cell.value.text = selectedEvent.eventDescription
            cell.date?.isHidden = true
        }

        else if indexPath.row == 2 {
            if (self.selectedContacts.count) > 0 {
                cell.type.text = "Event Contacts:"
                var selectedContactList:String = ""
                for contact in self.selectedContacts {
                    if selectedContactList.characters.count > 0{
                        selectedContactList = String(format:"%@\n\n%@",selectedContactList,contact.displayName())
                    }
                    else{
                        selectedContactList = String(format:"%@",contact.displayName())
                    }
                }
                
                cell.value.text = selectedContactList
                cell.date?.isHidden = true
            }
            else{
                let cell: RemoveGroupCell = tableView.dequeueReusableCell(withIdentifier: "RemoveGroupCell") as! RemoveGroupCell
                cell.selectionStyle = .none
                
                cell.btnRemoveGroup.addTarget(self, action: #selector(btnRemoveEvent), for: .touchUpInside)
                return cell
            }
        }
        else{
            let cell: RemoveGroupCell = tableView.dequeueReusableCell(withIdentifier: "RemoveGroupCell") as! RemoveGroupCell
            cell.selectionStyle = .none
            
            cell.btnRemoveGroup.addTarget(self, action: #selector(btnRemoveEvent), for: .touchUpInside)
            return cell
        }

        
        return cell
    }
    func btnRemoveEvent()  {
        showAlertWithTitle(title: "Delete Event", message: "Are you sure?", forTarget: self, buttonOK: "OK" , buttonCancel: "Cancel", alertOK: { (okTitle:String) in
            
            
            let todoItem = TodoItem(deadline: self.selectedEvent.eventDate as! Date, title: self.selectedEvent.eventTitle!, UUID: "",description:self.selectedEvent.eventDescription!,contacts:self.selectedEvent.contacts!)
            
            TodoList.sharedInstance.removeItem(todoItem)
            managedContext.delete(self.selectedEvent)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            self.navigationController?.popViewController(animated: true)
            
        }, alertCancel: { Void in
            
        })
        return;
    }
    
    @IBAction func btnActionView(_ sender: Any) {
        
        let tempView:UIView = UIView (frame: self.view.frame)
        tempView.backgroundColor = UIColor.clear
        tempView.isUserInteractionEnabled = true
        tempView.tag = 100
        
        let btnClose:UIButton = UIButton(frame: tempView.frame)
        btnClose.backgroundColor = UIColor.clear
        btnClose.addTarget(self, action: #selector(KLSelectedContactPicker.removeSubview), for: .touchUpInside)
        tempView.addSubview(btnClose)
        
        let actionView: ActionView = ActionView(frame: CGRect(x: (self.view.frame.size.width-290)/2, y: 110, width: 290, height: 120))
        actionView.layer.borderColor = UIColor.lightGray.cgColor
        actionView.layer.cornerRadius = 2.0
        actionView.delegate = self
        actionView.layer.borderWidth = 3.0
        actionView.backgroundColor = UIColor.init(colorLiteralRed: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        actionView.isUserInteractionEnabled = true
        let arrActions:NSMutableArray = ["Add/Remove Event Contacts","Send Text Message","Send Email"]
        let arrActionImages:NSMutableArray = ["add","sms","email"]
        actionView.designScreen(arrActions:arrActions, arrActionImages:arrActionImages)
        tempView.addSubview(actionView)
        
        self.view.addSubview(tempView)
    }
    func removeSubview(){
        print("Start remove sibview")
        if let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }else{
            print("No!")
        }
    }

    func ActionButton(actionType: String)
    {
        self.removeSubview()
        
        if actionType ==  "Send Text Message"{
            if (MFMessageComposeViewController.canSendText()) {
                
                let controller = MFMessageComposeViewController()

                var stringContacts: [String] = []
                for contact in self.selectedContacts
                {
                    if contact.phoneNumbers.count > 0 {
                        let MobNumVar:String = contact.phoneNumbers[0].phoneNumber
                        stringContacts.append(MobNumVar)
                    }
                }
                

                if stringContacts.count > 0 {
                    controller.recipients = stringContacts
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd yyyy h:mm a" // example: "Due Jan 01 at 12:00 PM"
                let eventDate:String = dateFormatter.string(from: self.selectedEvent.eventDate as! Date)

                let eventdesc:String = String(format:"Event Details:\n%@\n\nEvent Date & Time:\n%@",self.selectedEvent.eventDescription!,eventDate)
                
                controller.subject = selectedEvent.eventTitle
                controller.body = eventdesc

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
        else if actionType == "Send Email" {
            
            var stringContacts: [String] = []
            
            for contact in self.selectedContacts
            {
                 if contact.emails.count > 0 {
                    let email:String = contact.emails[0].email
                    stringContacts.append(email)
                }
            }
            if( MFMailComposeViewController.canSendMail() ) {
                
                let mailComposer = MFMailComposeViewController()
                mailComposer.mailComposeDelegate = self
                if stringContacts.count > 0 {
                    mailComposer.setToRecipients(stringContacts)
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd yyyy h:mm a" // example: "Due Jan 01 at 12:00 PM"
                let eventDate:String = dateFormatter.string(from: self.selectedEvent.eventDate as! Date)
                
                var selectedContactList:String = ""
                for contact in self.selectedContacts {
                    if selectedContactList.characters.count > 0{
                        selectedContactList = String(format:"%@\n\n%@",selectedContactList,contact.displayName())
                    }
                    else{
                        selectedContactList = String(format:"%@",contact.displayName())
                    }
                }
                
                var eventdesc:String = String(format:"Event Date & Time:\n%@\n\nEvent Details:\n%@",eventDate,self.selectedEvent.eventDescription!)
                
                if selectedContactList.characters.count > 0
                {
                    eventdesc = String(format:"%@\n\nList of Contacts:\n%@",eventdesc,selectedContactList)
                }
                
                mailComposer.setSubject(self.selectedEvent.eventTitle!)
                mailComposer.setMessageBody(eventdesc, isHTML: false)
                self.present(mailComposer, animated: true, completion: nil)
            } else {
                showAlertWithTitle(title: "Could Not Send Email", message: "Your device could not send e-mail. Please check e-mail configuration and try again.", forTarget: self, buttonOK: "" , buttonCancel: "OK", alertOK: { (okTitle:String) in
                    
                }, alertCancel: { Void in
                    
                })
                return;
            }
        }
        else{
            let contactPickerScene = EPContactsPicker(delegate: self, multiSelection:true, subtitleCellType: SubtitleCellValue.phoneNumber)
            if self.selectedContacts.count > 0 {
                contactPickerScene.selectedContacts = self.selectedContacts
            }
            let navigationController = UINavigationController(rootViewController: contactPickerScene)
            self.present(navigationController, animated: true, completion: nil)

        }
    }
    //MARK: EPContactsPicker delegates
    func epContactPicker(_: EPContactsPicker, didContactFetchFailed error : NSError)
    {
        print("Failed with error \(error.description)")
    }
    
    func epContactPicker(_: EPContactsPicker, didSelectContact contact : EPContact)
    {
        print("Contact \(contact.displayName()) has been selected")
    }
    
    func epContactPicker(_: EPContactsPicker, didCancel error : NSError)
    {
        print("User canceled the selection");
    }
    
    func epContactPicker(_: EPContactsPicker, didSelectMultipleContacts contacts: [EPContact]) {
        print("The following contacts are selected")

        self.selectedContacts = contacts
        
        var selectedContactList:String = ""
        for contact in self.selectedContacts {
            if selectedContactList.characters.count > 0{
                selectedContactList = String(format:"%@,%@",selectedContactList,contact.contactId!)
            }
            else{
                selectedContactList = String(format:"%@",contact.contactId!)
            }
        }
        self.selectedEvent.contacts = selectedContactList
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        self.tblEventDetails.reloadData()
    }
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact1: CNContact?) {
        viewController.navigationController?.dismiss(animated: true)
        
        
    }

    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        controller.dismiss(animated: true, completion: {
            if result == .cancelled {
                let alertController = UIAlertController(title: "", message: "Text message cancelled.", preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
                }))
                
                self.present(alertController, animated: true, completion: nil)
            }
            else if result == .sent{
                let alertController = UIAlertController(title: "", message: "Text message sent.", preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
                }))
                
                self.present(alertController, animated: true, completion: nil)
            }
            else{
                let alertController = UIAlertController(title: "", message: "Text message failed.", preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
                }))
                
                self.present(alertController, animated: true, completion: nil)
            }
            
        })
        
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
}
