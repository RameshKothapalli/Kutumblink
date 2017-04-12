//
//  AddNewEventViewController.swift
//  Kutumblink
//
//  Created by Apple on 07/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import CoreData
import Contacts
import ContactsUI

class AddNewEventViewController: BaseViewController , UITextFieldDelegate,UITextViewDelegate,EPPickerDelegate,SortingViewControllerDelegate{

    @IBOutlet weak var txtfldDate: UITextField!
    @IBOutlet weak var txtfldTitle: UITextField!
    @IBOutlet weak var txtVwDescription: UITextView!
    var selectedDate:NSDate = NSDate()
    var selectedEvent:Events!

    var isaddEventFromContact = false
    var selectedContacts = [EPContact]()

    @IBOutlet weak var btnAddContact: UIButton!
    @IBOutlet weak var btnSortOrder: UIButton!
    
    var selectedSortingType:String!
    var contactsStore: CNContactStore?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txtfldDate.delegate = self
        txtfldTitle.delegate = self
        txtVwDescription.delegate = self
        
        self.navigationItem.title = "Add Event"
        self.navigationController?.navigationBar.barTintColor = navigationBarColor
        if (selectedEvent != nil)  {
            self.navigationItem.title = "Edit Event"
        }
        let paddingView:UIView = UIView (frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        txtfldDate.leftViewMode = .always
        txtfldDate.leftView = paddingView

        let paddingRightView:UIImageView = UIImageView (frame: CGRect(x: 10, y: 0, width: 50, height: 30))
        paddingRightView.image = UIImage (named:"eventcalendar")
        paddingRightView.contentMode = .scaleAspectFit
        txtfldDate.rightViewMode = .always
        txtfldDate.rightView = paddingRightView

 
        txtfldDate.layer.borderColor = UIColor.lightGray.cgColor
        txtfldDate.layer.borderWidth = 2.0
        txtfldDate.layer.cornerRadius = 2.0
        
        btnAddContact.layer.borderColor = UIColor.lightGray.cgColor
        btnAddContact.layer.borderWidth = 1.0
        btnAddContact.layer.cornerRadius = 1.0

        btnSortOrder.layer.borderColor = UIColor.lightGray.cgColor
        btnSortOrder.layer.borderWidth = 1.0
        btnSortOrder.layer.cornerRadius = 1.0

        let paddingView1:UIView = UIView (frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        txtfldTitle.leftViewMode = .always
        txtfldTitle.leftView = paddingView1

        txtfldTitle.layer.borderColor = UIColor.lightGray.cgColor
        txtfldTitle.layer.borderWidth = 2.0
        txtfldTitle.layer.cornerRadius = 2.0
       
        txtVwDescription.layer.borderColor = UIColor.lightGray.cgColor
        txtVwDescription.layer.borderWidth = 2.0
        txtVwDescription.layer.cornerRadius = 2.0
        
        txtfldDate?.inputView = getPickerForDate()
        txtfldDate?.addCancelDoneOnKeyboardWithTarget(self, cancelAction: #selector(dismissKeyboard), doneAction: #selector(dismissKeyboardWithdateSelected), shouldShowPlaceholder: false)

        if (selectedEvent != nil)  {
            let formatter = DateFormatter();
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            txtfldDate.text  = formatter.string(from: selectedEvent.eventDate as! Date)
            selectedDate = selectedEvent.eventDate!
            txtfldTitle.text = selectedEvent.eventTitle
            txtVwDescription.text = selectedEvent.eventDescription
            selectedSortingType = selectedEvent.sortOrder
            btnSortOrder.setTitle(String(format:" Sort Order  -   %@",selectedSortingType), for: .normal)
            self.reloadContacts ()

        }
        else{
            selectedSortingType = "Default"
            btnSortOrder.setTitle(String(format:" Sort Order  -   %@",selectedSortingType), for: .normal)

        }
        
    }
    open func reloadContacts() {
        getContacts( {(contacts, error) in
            if (error == nil) {
                DispatchQueue.main.async(execute: {
                    
                    for cnContact in contacts
                    {
                        let epConatct:EPContact = EPContact (contact: cnContact)
                        self.selectedContacts.append(epConatct)
                    }
                })
            }
        })
    }
    func getContacts(_ completion:  @escaping ContactsHandler1) {
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
                    self.getContacts(completion)
                }
            })
            
        case  CNAuthorizationStatus.authorized:
            //Authorization granted by user for this app.
            
            let contactFetchRequest = CNContactFetchRequest(keysToFetch: allowedContactKeys())
            
            do {
                var contactsArray = [CNContact]()
                
                try contactsStore?.enumerateContacts(with: contactFetchRequest, usingBlock: { (contact, stop) -> Void in
                    //Ordering contacts based on alphabets in firstname
                    if self.selectedEvent != nil {
                        if (self.selectedEvent.contacts?.characters.count)! > 0
                        {
                            let arrCIdentifiers = self.selectedEvent.contacts?.components(separatedBy: ",")
                            
                            if (arrCIdentifiers?.contains(contact.identifier))!
                            {
                                contactsArray.append(contact)
                            }
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
    



    func updateDate(datePicker:UIDatePicker) ->  Void{
        let formatter = DateFormatter();
         formatter.dateStyle = .short
        formatter.timeStyle = .short
        self.txtfldDate?.text = formatter.string(from: datePicker.date)
        selectedDate = datePicker.date as NSDate;
        
    }
    
    @IBAction func btnSaveEventClicked(_ sender: Any) {
        
        if (txtfldDate.text?.characters.count)! < 1
        {
            showAlertWithTitle(title: "", message: "Please enter date.", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
            }, alertCancel: { Void in
                
            })
            return;
        }
        if (txtfldTitle.text?.characters.count)! < 1
        {
            showAlertWithTitle(title: "", message: "Please enter title.", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
            }, alertCancel: { Void in
                
            })
            return;
        }
        if (txtVwDescription.text?.characters.count)! < 1
        {
            showAlertWithTitle(title: "", message: "Please enter description.", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
            }, alertCancel: { Void in
                
            })
            return;
        }

        if selectedEvent == nil{
            
//            let eventInfo = Events(context: managedContext)
            let eventInfo:Events!
            if #available(iOS 10.0, *) {
                eventInfo = Events(context: managedContext)
            } else {
                // Fallback on earlier versions
                
                let entity =  NSEntityDescription.entity(forEntityName: "Events",
                                                         in:managedContext)
                
                eventInfo = Events(entity: entity!,
                                       insertInto: managedContext)
                
            }

            let groupIDCount = self.getMaxEventId()
            eventInfo.eventId = groupIDCount+1
            eventInfo.eventTitle = self.txtfldTitle.text
            eventInfo.eventDate = selectedDate
            eventInfo.eventDescription = self.txtVwDescription.text
            eventInfo.sortOrder = selectedSortingType
            var selectedContactList:String = ""
            for contact in self.selectedContacts {
                if selectedContactList.characters.count > 0{
                    selectedContactList = String(format:"%@,%@",selectedContactList,contact.contactId!)
                }
                else{
                    selectedContactList = String(format:"%@",contact.contactId!)
                }
            }
            eventInfo.contacts = selectedContactList
            selectedEvent = eventInfo
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            self.setUpLocalNotification(eventInfo: selectedEvent)

        }
        else{
            let todoItem = TodoItem(deadline: selectedEvent.eventDate as! Date, title: selectedEvent.eventTitle!, UUID: "",description:selectedEvent.eventDescription!,contacts:selectedEvent.contacts!)
            TodoList.sharedInstance.removeItem(todoItem)

            selectedEvent.eventId = selectedEvent.eventId
            selectedEvent.eventTitle = self.txtfldTitle.text
            selectedEvent.eventDate = selectedDate
            selectedEvent.contacts = selectedEvent.contacts
            selectedEvent.sortOrder = selectedSortingType
            var selectedContactList:String = ""
            for contact in self.selectedContacts {
                if selectedContactList.characters.count > 0{
                    selectedContactList = String(format:"%@,%@",selectedContactList,contact.contactId!)
                }
                else{
                    selectedContactList = String(format:"%@",contact.contactId!)
                }
            }
            selectedEvent.contacts = selectedContactList

            selectedEvent.eventDescription = self.txtVwDescription.text
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            self.setUpLocalNotification(eventInfo: selectedEvent)
        }
        showAlertWithTitle(title: "Event is saved.", message: "", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
            
            self.navigationController?.popViewController(animated: true)
            }, alertCancel: { Void in })
    }
    func setUpLocalNotification(eventInfo:Events) {
        
        let todoItem = TodoItem(deadline: eventInfo.eventDate as! Date, title: eventInfo.eventTitle!, UUID: "",description:eventInfo.eventDescription!,contacts:eventInfo.contacts!)
        TodoList.sharedInstance.addItem(todoItem) // schedule a local notification to persist this item
        let _ = self.navigationController?.popToRootViewController(animated: true) // return to list view
        
    }

    @IBAction func sortOrder(_ sender: Any) {
        let AddGroup = self.storyboard!.instantiateViewController(withIdentifier: "SortingView") as! SortingViewController
        AddGroup.delegate = self
        AddGroup.selectedSortingType = selectedSortingType
        self.navigationController!.pushViewController(AddGroup, animated: true)
    }
    func updateSortingType(actionType: String)
    {
        selectedSortingType = actionType
        //        tblGroupDetails.reloadData()
        btnSortOrder.setTitle(String(format:" Sort Order  -   %@",selectedSortingType), for: .normal)
    }

    
    @IBAction func addContact(_ sender: Any) {
        let contactPickerScene = EPContactsPicker(delegate: self, multiSelection:true, subtitleCellType: SubtitleCellValue.phoneNumber)
        if self.selectedContacts.count > 0 {
            contactPickerScene.selectedContacts = self.selectedContacts
        }
        let navigationController = UINavigationController(rootViewController: contactPickerScene)
        self.present(navigationController, animated: true, completion: nil)

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
        
        if self.selectedEvent != nil {
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
        }
     }

    func getMaxEventId() -> Int {
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Events")
        
        fetchRequest.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: "eventId", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let group = try managedContext.fetch(fetchRequest)
            print(group)
            if group.count == 0 {
                return 0
            }
            let max = group.first
            print(max?.value(forKey: "eventId") as! Int!)
            return (max?.value(forKey: "eventId") as! Int)
        } catch _ {
            
        }
        return 0
    }
    
    func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }

    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func dismissKeyboardWithdateSelected(){
        self.view.endEditing(true)
    }
    
    func getPickerForDate() -> UIDatePicker {
        let datePicker:UIDatePicker = UIDatePicker()
        datePicker.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216)
        datePicker.datePickerMode = .dateAndTime
        datePicker.date = NSDate() as Date
        datePicker.minimumDate = NSDate(timeIntervalSinceNow:0) as Date
        
        datePicker.addTarget(self, action: #selector(updateDate(datePicker:)), for: .valueChanged)
        return datePicker
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:   - textfield delegate methods
    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5);
    
    func textRectforBoundsForBounds(_ bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    func placeholderRectforBoundsForBounds(_ bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
     func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
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


