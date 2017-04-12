//
//  KLSelectedContactPicker.swift
//  sampleContacts
//
//  Created by Apple on 06/02/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import MessageUI
import CoreData

protocol KLSelectedContactsPickerDelegate {
    func KLSelectedContactsPicker(_: KLSelectedContactPicker, didContactFetchFailed error: NSError)
    func KLSelectedContactsPicker(_: KLSelectedContactPicker, didCancel error: NSError)
    func KLSelectedContactsPicker(_: KLSelectedContactPicker, didSelectContact contact: EPContact)
    func KLSelectedContactsPicker(_: KLSelectedContactPicker, didSelectMultipleContacts contacts: [EPContact])
}

extension KLSelectedContactsPickerDelegate {
    func KLSelectedContactsPicker(_: KLSelectedContactPicker, didContactFetchFailed error: NSError) { }
    func KLSelectedContactsPicker(_: KLSelectedContactPicker, didCancel error: NSError) { }
    func KLSelectedContactsPicker(_: KLSelectedContactPicker, didSelectContact contact: EPContact) { }
    func KLSelectedContactsPicker(_: KLSelectedContactPicker, didSelectMultipleContacts contacts: [EPContact]) { }
}

typealias ContactsHandler1 = (_ contacts : [CNContact] , _ error : NSError?) -> Void

class KLSelectedContactPicker: UIViewController ,UISearchResultsUpdating, UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,CNContactViewControllerDelegate,ActionViewDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,AddNewGroupViewControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource{
   
    @IBOutlet weak var tblContacts: UITableView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    open var contactDelegate: KLSelectedContactsPickerDelegate?
    var contactsStore: CNContactStore?
    var resultSearchController = UISearchController()
    var orderedContacts = [String: [CNContact]]() //Contacts ordered in dicitonary alphabetically
    var sortedContactKeys = [String]()
    
    var selectedContacts = [EPContact]()
    var filteredContacts = [CNContact]()
    
    var subtitleCellValue = SubtitleCellValue.phoneNumber
    var multiSelectEnabled: Bool = false //Default is single selection contact
    
    var actionView: UIView = UIView()

    var selectedGroup:Groups!

    var arrGroups:NSMutableArray! = []
    
    var selectedinPickerGroup:Groups!
    
    var actionType:String!
    

    // MARK: - Lifecycle Methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.title = EPGlobalConstants.Strings.contactsTitle
        self.navigationController?.navigationBar.barTintColor = navigationBarColor

        self.navigationItem.title = selectedGroup.groupName

        registerContactCell()
        inititlizeBarButtons()
//        initializeSearchBar()
//        reloadContacts()
        
        actionButton.isEnabled = false
        clearButton.isEnabled = false
        self.tblContacts.delegate = self
        self.tblContacts.dataSource = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        reloadContacts()
    }
     
    func updateContactInfo(selectedGroup:Groups)  {
        
        self.selectedGroup = selectedGroup
        reloadContacts()
    }
    
    func initializeSearchBar() {
        self.resultSearchController = ( {
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.delegate = self
            self.tblContacts.tableHeaderView = controller.searchBar
            return controller
        })()
    }
    
    func inititlizeBarButtons() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(onTouchCancelButton))
        self.navigationItem.leftBarButtonItem = cancelButton
        
        if multiSelectEnabled {
//            let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(onTouchDoneButton))
            let doneButton = UIBarButtonItem(title: "Edit", style: .done, target: self, action:   #selector(onTouchDoneButton))

            self.navigationItem.rightBarButtonItem = doneButton
            
        }
    }
    
    fileprivate func registerContactCell() {
        
        let podBundle = Bundle(for: self.classForCoder)
        if let bundleURL = podBundle.url(forResource: EPGlobalConstants.Strings.bundleIdentifier, withExtension: "bundle") {
            
            if let bundle = Bundle(url: bundleURL) {
                
                let cellNib = UINib(nibName: EPGlobalConstants.Strings.KLSelectedContactCellNibIdentifier, bundle: bundle)
                self.tblContacts.register(cellNib, forCellReuseIdentifier: "Cell")
            }
            else {
                assertionFailure("Could not load bundle")
            }
        }
        else {
            
            let cellNib = UINib(nibName: EPGlobalConstants.Strings.KLSelectedContactCellNibIdentifier, bundle: nil)
            self.tblContacts.register(cellNib, forCellReuseIdentifier: "Cell")
        }
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Initializers
    
//    convenience public init(delegate: KLSelectedContactsPickerDelegate?) {
//        self.init(delegate: delegate, multiSelection: false)
//    }
//    
//    convenience public init(delegate: KLSelectedContactsPickerDelegate?, multiSelection : Bool) {
//        self.init()
//        self.multiSelectEnabled = multiSelection
//        contactDelegate = delegate
//    }
    
    convenience public init(delegate: KLSelectedContactsPickerDelegate?, multiSelection : Bool, subtitleCellType: SubtitleCellValue,SelectedGroup:Groups) {
        self.init()
        self.multiSelectEnabled = multiSelection
        contactDelegate = delegate
        subtitleCellValue = subtitleCellType
        selectedGroup = SelectedGroup
    }
    
    
    // MARK: - Contact Operations
    
    open func reloadContacts() {
        getContacts( {(contacts, error) in
            if (error == nil) {
                DispatchQueue.main.async(execute: {
                    self.tblContacts.reloadData()
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
                self.contactDelegate?.KLSelectedContactsPicker(self, didContactFetchFailed: error)
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
            var contactsArray = [CNContact]()
            self.orderedContacts.removeAll()
            self.sortedContactKeys.removeAll()

            let contactFetchRequest = CNContactFetchRequest(keysToFetch: allowedContactKeys())
            
            do {
                try contactsStore?.enumerateContacts(with: contactFetchRequest, usingBlock: { (contact, stop) -> Void in
                    //Ordering contacts based on alphabets in firstname
                    if (self.selectedGroup.groupContacts?.characters.count)! > 0
                    {
                        let arrCIdentifiers = self.selectedGroup.groupContacts?.components(separatedBy: ",")
                        
                        if (arrCIdentifiers?.contains(contact.identifier))!
                        {
                            contactsArray.append(contact)
                            var key: String = "#"
                            //If ordering has to be happening via family name change it here.
                            if let firstLetter = contact.givenName[0..<1] , firstLetter.containsAlphabets() {
                                key = firstLetter.uppercased()
                            }
                            var contacts = [CNContact]()
                            
                            if let segregatedContact = self.orderedContacts[key] {
                                contacts = segregatedContact
                            }
                            contacts.append(contact)
                            self.orderedContacts[key] = contacts
                        }
                    }
                    
                })
                self.sortedContactKeys = Array(self.orderedContacts.keys).sorted(by: <)
                if self.sortedContactKeys.first == "#" {
                    self.sortedContactKeys.removeFirst()
                    self.sortedContactKeys.append("#")
                }
                completion(contactsArray, nil)
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
    
    // MARK: - Table View DataSource
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        if resultSearchController.isActive { return 1 }
        
        if sortedContactKeys.count > 0 {
            self.tblContacts.backgroundView = nil
            return sortedContactKeys.count

        }
        else{
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            emptyLabel.text = "No contacts available in this group. Please add contacts"
            emptyLabel.numberOfLines = 0
            emptyLabel.textAlignment = .center
            self.tblContacts.backgroundView = emptyLabel
            self.tblContacts.separatorStyle = UITableViewCellSeparatorStyle.none
        }
     
        return 0
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if resultSearchController.isActive {
             return filteredContacts.count
         }
        if let contactsForSection = orderedContacts[sortedContactKeys[section]] {
            return contactsForSection.count
        }
         return 0
    }
    
    // MARK: - Table View Delegates
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! KLSelectedContactCell
        cell.accessoryType = UITableViewCellAccessoryType.none
        cell.checkBox.isSelected = false
        
        //Convert CNContact to EPContact
        let contact: EPContact
        
        if resultSearchController.isActive {
            contact = EPContact(contact: filteredContacts[(indexPath as NSIndexPath).row])
        } else {
            guard let contactsForSection = orderedContacts[sortedContactKeys[(indexPath as NSIndexPath).section]] else {
                assertionFailure()
                return UITableViewCell()
            }
            
            contact = EPContact(contact: contactsForSection[(indexPath as NSIndexPath).row])
        }
        
        if multiSelectEnabled  && selectedContacts.contains(where: { $0.contactId == contact.contactId }) {
            //            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            cell.checkBox.isSelected = true
            
        }
        cell.checkBox.addTarget(self, action:#selector(btnSelectContactAction(sender:)), for: .touchUpInside)
        if self.selectedGroup != nil {
            cell.updateContactsinUI(contact, indexPath: indexPath, subtitleType: subtitleCellValue, selectedGroup:self.selectedGroup)
        }
        else{
            cell.updateContactsinUI(contact, indexPath: indexPath, subtitleType: subtitleCellValue)
        }

        return cell
    }
    func btnSelectContactAction(sender: UIButton){
        
        if let superview = sender.superview {
            if let cell = superview.superview as? KLSelectedContactCell {
                //                   let indexPath = self.tableView.indexPath(for: cell)
                
                let selectedContact =  cell.contact!
                if multiSelectEnabled {
                    
                    if cell.checkBox.isSelected == true{
                        cell.checkBox.isSelected = false
                        selectedContacts = selectedContacts.filter(){
                            return selectedContact.contactId != $0.contactId
                        }
                    }
                    else{
                        cell.checkBox.isSelected = true
                        selectedContacts.append(selectedContact)
                    }
                }
                else {
                    //Single selection code
                    resultSearchController.isActive = false
                    self.dismiss(animated: true, completion: {
                        DispatchQueue.main.async {
                            self.contactDelegate?.KLSelectedContactsPicker(self, didSelectContact: selectedContact)
                        }
                    })
                }
                if selectedContacts.count > 0{
                    actionButton.isEnabled = true
                    clearButton.isEnabled = true
                }
                else{
                    actionButton.isEnabled = false
                    clearButton.isEnabled = false
                }
            }
        }
    }
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let store = CNContactStore()
        
        let cell = tableView.cellForRow(at: indexPath) as! KLSelectedContactCell
        let selectedContact =  cell.contact!
        if multiSelectEnabled {
            
            let identifier:String = selectedContact.contactId!
            let predicate: NSPredicate = CNContact.predicateForContacts(withIdentifiers: [identifier])
            let descriptor = CNContactViewController.descriptorForRequiredKeys()
            let contacts: [CNContact]
            do {
                contacts = try store.unifiedContacts(matching: predicate, keysToFetch: [descriptor])
            } catch {
                contacts = []
            }
            // Display "Appleseed" information if found in the address book
            if !contacts.isEmpty {
                let contact = contacts[0]
                let cvc = CNContactViewController(for: contact)
                cvc.delegate = self
                // Allow users to edit the person’s information
                cvc.allowsEditing = true
                //cvc.contactStore = self.store //seems to work without setting this.
                self.navigationController?.pushViewController(cvc, animated: true)
            } else {
                // Show an alert if "Appleseed" is not in Contacts
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54.0
    }
    
//    open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
//        if resultSearchController.isActive { return 0 }
//        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: UITableViewScrollPosition.top , animated: false)
//        return sortedContactKeys.index(of: title)!
//    }
//    
//    open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        if resultSearchController.isActive { return nil }
//        return sortedContactKeys
//    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if resultSearchController.isActive { return nil }
        return sortedContactKeys[section]
    }
    
    // MARK: - Button Actions
    
    func onTouchCancelButton() {
        contactDelegate?.KLSelectedContactsPicker(self, didCancel: NSError(domain: "EPContactPickerErrorDomain", code: 2, userInfo: [ NSLocalizedDescriptionKey: "User Canceled Selection"]))
        self.navigationController?.popViewController(animated: true)
    }
    
    func onTouchDoneButton() {
//        contactDelegate?.KLSelectedContactsPicker(self, didSelectMultipleContacts: selectedContacts)
//        dismiss(animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let AddGroup = storyboard.instantiateViewController(withIdentifier: "AddNewGroup") as! AddNewGroupViewController
        AddGroup.selectedGroup = selectedGroup
        AddGroup.delegate = self
        self.navigationController!.pushViewController(AddGroup, animated: true)

    }
    
    // MARK: - Search Actions
    
    open func updateSearchResults(for searchController: UISearchController)
    {
        if let searchText = resultSearchController.searchBar.text , searchController.isActive {
            
            let predicate: NSPredicate
            if searchText.characters.count > 0 {
                predicate = CNContact.predicateForContacts(matchingName: searchText)
            } else {
                predicate = CNContact.predicateForContactsInContainer(withIdentifier: contactsStore!.defaultContainerIdentifier())
            }
            
            let store = CNContactStore()
            do {
                filteredContacts = try store.unifiedContacts(matching: predicate,
                                                             keysToFetch: allowedContactKeys())
                //print("\(filteredContacts.count) count")
                
                self.tblContacts.reloadData()
                
            }
            catch {
                print("Error!")
            }
        }
    }
    
    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        DispatchQueue.main.async(execute: {
            self.tblContacts.reloadData()
        })
    }
    
    @IBAction func chooseAction(_ sender: Any) {
        

        let tempView:UIView = UIView (frame: self.view.frame)
        tempView.backgroundColor = UIColor.clear
        tempView.isUserInteractionEnabled = true
        tempView.tag = 100

        let btnClose:UIButton = UIButton(frame: tempView.frame)
        btnClose.backgroundColor = UIColor.clear
        btnClose.addTarget(self, action: #selector(KLSelectedContactPicker.removeSubview), for: .touchUpInside)
        tempView.addSubview(btnClose)

        let actionView: ActionView = ActionView(frame: CGRect(x: 80, y: 110, width: 240, height: 240))
        actionView.layer.borderColor = UIColor.lightGray.cgColor
        actionView.layer.cornerRadius = 2.0
        actionView.delegate = self
        actionView.layer.borderWidth = 3.0
        actionView.backgroundColor = UIColor.init(colorLiteralRed: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        actionView.isUserInteractionEnabled = true
        let arrActions:NSMutableArray = ["Send Text Message","Send Email","Copy to Group","Remove from Group","Add Event","Email Contact Info"]
        let arrActionImages:NSMutableArray = ["sms","email","add","remove","event","info"]
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
        if actionType == "Send Text Message" {
            
            var stringContacts: [String] = []

            for contact in selectedContacts
            {
                if contact.phoneNumbers.count > 0 {
                    let MobNumVar:String = contact.phoneNumbers[0].phoneNumber
                    stringContacts.append(MobNumVar)
                }
            }

            print(stringContacts)
            if stringContacts.count >  0{
                if (MFMessageComposeViewController.canSendText()) {
                    
                    self.actionType = "Text message"
                    let controller = MFMessageComposeViewController()
                    controller.recipients = stringContacts
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
            else{
                showAlertWithTitle(title: "", message: "Selected contacts do not have phone number.", forTarget: self, buttonOK: "" , buttonCancel: "OK", alertOK: { (okTitle:String) in
                    
                }, alertCancel: { Void in
                    
                })
                return;
            }
        }
        else if actionType == "Send Email" {
            
            var stringContacts: [String] = []
            
            for contact in selectedContacts
            {
                if contact.emails.count > 0 {
                    let email:String = contact.emails[0].email
                     stringContacts.append(email)
                }
            }
            print(stringContacts)
            
            if stringContacts.count >  0{

                if stringContacts.count !=  selectedContacts.count{
                    showAlertWithTitle(title: "", message:String(format:"One or more of the selected contacts do not have email.",selectedContacts.count-stringContacts.count) , forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
                        if( MFMailComposeViewController.canSendMail() ) {
                            self.actionType = "Email"
                            
                            let mailComposer = MFMailComposeViewController()
                            mailComposer.mailComposeDelegate = self
                            mailComposer.setToRecipients(stringContacts)
                            self.present(mailComposer, animated: true, completion: nil)
                        } else {
                            self.showSendMailErrorAlert()
                        }
                    }, alertCancel: { Void in
                        
                    })
                    return;
                }
                else{
                    if( MFMailComposeViewController.canSendMail() ) {
                        self.actionType = "Email"
                        
                        let mailComposer = MFMailComposeViewController()
                        mailComposer.mailComposeDelegate = self
                        mailComposer.setToRecipients(stringContacts)
                        self.present(mailComposer, animated: true, completion: nil)
                    } else {
                        self.showSendMailErrorAlert()
                    }
                }
            }
            else{
                showAlertWithTitle(title: "", message: "Selected contacts do not have email.", forTarget: self, buttonOK: "" , buttonCancel: "OK", alertOK: { (okTitle:String) in
                    
                }, alertCancel: { Void in
                    
                })
                return;
            }
        }
        else if actionType == "Remove from Group"
        {
            showAlertWithTitle(title: "Remove contacts from group", message: "Are you sure?", forTarget: self, buttonOK: "OK" , buttonCancel: "Cancel", alertOK: { (okTitle:String) in
                
                var arrCIdentifiers:[String] = (self.selectedGroup.groupContacts?.components(separatedBy: ","))!
                
                for str in arrCIdentifiers
                {
                    if self.selectedContacts.contains(where: { $0.contactId == str })
                    {
                        let index:Int = arrCIdentifiers.index (of: str)!
                        arrCIdentifiers.remove(at: index)
                    }
                }
                
                var selectedContactList:String = ""
                for str in arrCIdentifiers {
                    if selectedContactList.characters.count > 0{
                        selectedContactList = String(format:"%@,%@",selectedContactList,str)
                    }
                    else{
                        selectedContactList = String(format:"%@",str)
                    }
                }
                print(selectedContactList)
                
                self.selectedGroup.groupContacts = selectedContactList
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
                showAlertWithTitle(title: "", message: "Contact(s) removed successfully.", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
                    self.reloadContacts()
                    
                }, alertCancel: { Void in
                    
                })
                return;


            }, alertCancel: { Void in
                
            })
            return;

        }
        else if actionType == "Copy to Group"
        {
            // add to group
            self.getGroups ()
            
        }
        else if actionType == "Add Event"
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            let AddGroup = storyboard.instantiateViewController(withIdentifier: "AddNewEvent") as! AddNewEventViewController
            AddGroup.isaddEventFromContact = true
            AddGroup.selectedContacts = self.selectedContacts
            self.navigationController!.pushViewController(AddGroup, animated: true)

        }
        else if actionType == "Email Contact Info"
        {
            let contactStore = CNContactStore()
            var contacts = [CNContact]()
             
            let fetchRequest = CNContactFetchRequest(keysToFetch:[CNContactVCardSerialization.descriptorForRequiredKeys()])
            
            do{
                
                try contactStore.enumerateContacts(with: fetchRequest, usingBlock: {
                    contact, cursor in
                    if self.selectedContacts.contains(where: { $0.contactId == contact.identifier})
                    {
                        contacts.append(contact)
                    }
                    })
                self.saveContactsLocally(contacts: contacts)

                
            } catch {
                print("Get contacts \(error)")
            }
        }

    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true, completion: {
            if result == .cancelled {
                let alertController = UIAlertController(title: "", message: String(format:"%@ cancelled.",self.actionType), preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
                }))
                
                self.present(alertController, animated: true, completion: nil)
            }
            else if result == .sent{
                let alertController = UIAlertController(title: "", message: String(format:"%@ sent.",self.actionType), preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
                }))
                
                self.present(alertController, animated: true, completion: nil)
            }
            else{
                    let alertController = UIAlertController(title: "", message: String(format:"%@ failed.",self.actionType), preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
            }
            
        })
     }
    
    func showSendMailErrorAlert() {
        
        showAlertWithTitle(title: "Could Not Send Email", message: "Your device could not send e-mail. Please check e-mail configuration and try again.", forTarget: self, buttonOK: "" , buttonCancel: "OK", alertOK: { (okTitle:String) in
            
        }, alertCancel: { Void in
            
        })
        return;
        
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

    func saveContactsLocally(contacts:[CNContact])  {
    
        print(contacts)
        
        if( MFMailComposeViewController.canSendMail() ) {
            print("Can send email.")
            
            self.actionType = "Email Contact Info"

            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            //Set the subject and message of the email
            mailComposer.setSubject("Contacts vcard from Kutumblink")

            for cnContact in contacts {
                do {
                    let vcardFromContacts:NSData
                    try vcardFromContacts = CNContactVCardSerialization.data(with: [cnContact] ) as NSData
                    let str = String(format:"%@ Contact.vcf",cnContact.givenName)

                    mailComposer.addAttachmentData(vcardFromContacts as Data, mimeType: "vcf", fileName: str)

                }
                catch{
                    
                }
            }
            self.present(mailComposer, animated: true, completion: nil)
        }
    }
    func getPickerForGroups() {
        
        actionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 260.0)

        let picker = UIPickerView()

        let kSCREEN_WIDTH  =    UIScreen.main.bounds.size.width
        
        picker.frame = CGRect(x: 0.0, y: 44.0,width: kSCREEN_WIDTH, height: 216.0)
        picker.dataSource = self
        picker.delegate = self
        picker.showsSelectionIndicator = true;
        picker.backgroundColor = UIColor.white
        
        let pickerDateToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: kSCREEN_WIDTH, height: 44))
        pickerDateToolbar.barStyle = UIBarStyle.black
        pickerDateToolbar.barTintColor = UIColor.black
        pickerDateToolbar.isTranslucent = true
        
        var barItems = [UIBarButtonItem]()
        
        let titleCancel = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(KLSelectedContactPicker.cancelPickerSelectionButtonClicked(_:)))
        barItems.append(titleCancel)
        
        var flexSpace: UIBarButtonItem
        flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        barItems.append(flexSpace)

        picker.selectRow(0, inComponent: 0, animated: false)
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(KLSelectedContactPicker.pickerDoneClicked(_:)))

        barItems.append(doneBtn)

        pickerDateToolbar.setItems(barItems, animated: true)
        
        actionView.addSubview(pickerDateToolbar)
        actionView.addSubview(picker)
        
        let window = UIApplication.shared.keyWindow

        if (window != nil) {
            window!.addSubview(actionView)
        }
        else
        {
            self.view.addSubview(actionView)
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.actionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 260.0, width: UIScreen.main.bounds.size.width, height: 260.0)
            
        })

    }
    func cancelPickerSelectionButtonClicked(_ sender: UIBarButtonItem) {
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.actionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 260.0)
            
            }, completion: { _ in
                for obj: AnyObject in self.actionView.subviews {
                    if let view = obj as? UIView
                    {
                        view.removeFromSuperview()
                    }
                }
        })
    }
    
    func pickerDoneClicked(_ sender: UIBarButtonItem) {
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.actionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 260.0)
            
            }, completion: { _ in
                for obj: AnyObject in self.actionView.subviews {
                    if let view = obj as? UIView
                    {
                        view.removeFromSuperview()
                    }
                }
                
                showAlertWithTitle(title: "Add contacts to the group.", message: "Are you sure?", forTarget: self, buttonOK: "OK" , buttonCancel: "Cancel", alertOK: { (okTitle:String) in
                    
                    var arrContacts:[String] = (self.selectedinPickerGroup.groupContacts?.components(separatedBy: ","))!
                        var selectedContactList:String = ""
                        for contact in self.selectedContacts {
                            if (arrContacts.contains(contact.contactId!))
                            {
                                // No need to add the contact again
                            }
                            else{
                                if selectedContactList.characters.count > 0{
                                    selectedContactList = String(format:"%@,%@",selectedContactList,contact.contactId!)
                                }
                                else{
                                    selectedContactList = String(format:"%@",contact.contactId!)
                                }
                            }
                        }
                    
                    if (self.selectedinPickerGroup.groupContacts?.characters.count)! > 0{
                        if selectedContactList.characters.count > 0{
                           self.selectedinPickerGroup.groupContacts = String(format:"%@,%@",self.selectedinPickerGroup.groupContacts!,selectedContactList)
                        }
                        else{
                            self.selectedinPickerGroup.groupContacts = String(format:"%@",self.selectedinPickerGroup.groupContacts!)
                        }
                    }
                    else{
                        if selectedContactList.characters.count > 0{
                            self.selectedinPickerGroup.groupContacts = String(format:"%@",selectedContactList)
                        }
                        else{
                            self.selectedinPickerGroup.groupContacts = ""
                        }

                    }
                    
                    self.selectedinPickerGroup.groupID = self.selectedinPickerGroup.groupID
                    self.selectedinPickerGroup.groupName = self.selectedinPickerGroup.groupName
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                  
                    showAlertWithTitle(title: "", message: "Contact(s) copied successfully.", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
                        self.selectedContacts.removeAll()
                        self.tblContacts.reloadData()
                        
                    }, alertCancel: { Void in
                        
                    })
                    return;

                    
                }, alertCancel: { Void in
                    
                })
                return;


                
        })
    }
    
    
    func saveUser(sender: UIButton){
        // Your code when select button is tapped
    }
    
    func cancelSelection(sender: UIButton){
        print("Cancel");
        self.dismiss(animated: true, completion: nil);
        // We dismiss the alert. Here you can add your additional code to execute when cancel is pressed
    }

    
    // sms
   
// email
    func configuredMailComposeViewController(contacts:NSArray) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(contacts as? [String])
        mailComposerVC.setSubject("Sending you an in-app e-mail...")
        mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
        
        return mailComposerVC
    }
    
   

    @IBAction func clearSelectedContacts(_ sender: Any) {
        
        actionButton.isEnabled = false
        clearButton.isEnabled = false

        selectedContacts.removeAll()
        tblContacts.reloadData()
    }
    func getGroups()  {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Groups")
        do {
            let groups = try managedContext.fetch(fetchRequest) as! [Groups]
            if arrGroups.count > 0 {
                arrGroups.removeAllObjects()
            }
            for group in groups {
                debugPrint(group.groupID)
                arrGroups.add(group)
            }
            debugPrint(arrGroups)
    
            arrGroups.remove(selectedGroup)
            
            if  arrGroups.count > 0 {
                self.getPickerForGroups ()
            }
            else{
                showAlertWithTitle(title: "", message: "There are no groups to add this contact into.", forTarget: self, buttonOK: "" , buttonCancel: "OK", alertOK: { (okTitle:String) in
                                        
                }, alertCancel: { Void in
                    
                })
                return;
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.arrGroups.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let group = self.arrGroups.object(at: row) as! Groups
        
        selectedinPickerGroup = self.arrGroups.object(at: 0) as! Groups

        return group.groupName
    }
     func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
     {
        selectedinPickerGroup = self.arrGroups.object(at: row) as! Groups
    }

   

}

