//
//  AddNewGroupViewController.swift
//  Kutumblink
//
//  Created by Admin on 04/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import CoreData
import Contacts
import ContactsUI

protocol  AddNewGroupViewControllerDelegate{
    func updateContactInfo(selectedGroup: Groups)
 
}

class AddNewGroupViewController: BaseViewController ,UITableViewDelegate,UITableViewDataSource,AddNewGroupCellDelegate,EPPickerDelegate,CNContactViewControllerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,SortingViewControllerDelegate,DefaultGroupsViewControllerDelegate,MailContactsViewControllerDelegate,GroupImagesViewControllerDelegate{

    @IBOutlet weak var tblGroupDetails: UITableView!
    let AddNewGroupCell = "AddNewGroupCell"
    var selectedGroup:Groups!

    var delegate: AddNewGroupViewControllerDelegate?
    var gmailContactdelegate: AddNewGroupViewControllerDelegate?

    var groups: [NSManagedObject] = []
    var groupDetails:NSMutableArray = []
    var selectedContacts = [EPContact]()
    
    var contactsStore: CNContactStore?
    var selectedSortingType:String!
    var selectedgroupImage:UIImage!
    var selectedgrouName:String!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let rightButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action:   #selector(AddNewGroupViewController.btnDoneAction))
        self.navigationItem.rightBarButtonItem = rightButtonItem

        // Do any additional setup after loading the view.
        tblGroupDetails.delegate = self
        tblGroupDetails.dataSource = self
        
 
        if selectedGroup == nil {
            self.navigationItem.title = "Add Group"
            self.updateNavigationButton(isRightBarButtonEnabled: false)
            selectedSortingType = "Default"
            selectedgroupImage = nil
        }
        else{
            self.navigationItem.title = selectedGroup.groupName
            selectedgrouName = selectedGroup.groupName
            selectedSortingType = selectedGroup.groupOrder
              self.getImage (withImageName: selectedGroup.groupImage!)
            self.reloadContacts ()
        }
    }
    
    func getImage(withImageName:String) {
        let fileManager = FileManager.default
        var Image:UIImage? = nil
        let imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent(withImageName)
        if fileManager.fileExists(atPath: imagePAth){
            Image = UIImage(contentsOfFile: imagePAth)!
            selectedgroupImage = Image
        }else{
            selectedgroupImage = UIImage(named:"defaultgroup")
            print("No Image")
        }
    }

    func updateGroupDetails(groupName: String)
    {
        let indexPath = NSIndexPath(row: 0, section: 0)
        let cell:AddNewGroupCell = self.tblGroupDetails.cellForRow(at: indexPath as IndexPath) as! AddNewGroupCell
        cell.txtfldGroupName.text = groupName
        selectedgrouName = groupName
        selectedgroupImage  = UIImage (named: groupName)
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }

    func updateSortingType(actionType: String)
    {
        selectedSortingType = actionType
//        tblGroupDetails.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {

        self.refreshArrayList ()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 0 {
            return 100
        }
        else if indexPath.row == groupDetails.count+1 {
            return 70.0
        }
        return 54.0;//Choose your custom row height
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupDetails.count + 2
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell:AddNewGroupCell = tableView.dequeueReusableCell(withIdentifier: AddNewGroupCell) as! AddNewGroupCell
            cell.accessoryType = .none
            cell.selectionStyle = .none
            if selectedGroup != nil {
                cell.txtfldGroupName.text = selectedgrouName
            }
            cell.txtfldGroupName.autocapitalizationType = .sentences
            
            cell.txtfldGroupName.rightViewMode = UITextFieldViewMode.always
            let btngroups = UIButton(frame: CGRect(x: 0, y: 5, width: 40, height: 30))
            btngroups.setImage(UIImage(named: "adddefaultgroups"), for: .normal)
            btngroups.contentMode = .scaleAspectFit
            cell.txtfldGroupName.rightView = btngroups
            btngroups.addTarget(self, action: #selector(btnAddDefaultgroups), for: .touchUpInside)


            if selectedgroupImage == nil
            {
                cell.btnGroupImage.setImage(UIImage(named:"defaultgroup"), for: .normal)
            }
            else{
                cell.btnGroupImage.setImage(selectedgroupImage, for: .normal)
            }
            cell.delegate = self
            return cell
        }
        else if indexPath.row == groupDetails.count+1
        {
            let cell: RemoveGroupCell = tableView.dequeueReusableCell(withIdentifier: "RemoveGroupCell") as! RemoveGroupCell
            cell.selectionStyle = .none

            cell.btnRemoveGroup.addTarget(self, action: #selector(btnRemoveGroup), for: .touchUpInside)
            return cell
        }
        let cell:GroupDetailsCell = tableView.dequeueReusableCell(withIdentifier: "GroupDetailsCell") as! GroupDetailsCell
        cell.selectionStyle = .none
        if indexPath.row == groupDetails.count{
            cell.lblGroupOptionText.text = String(format:"%@  -   %@",(groupDetails.object(at: indexPath.row-1) as? String)!,selectedSortingType!)
        }
        else{
            cell.lblGroupOptionText.text = (groupDetails.object(at: indexPath.row-1) as? String)
        }
        cell.imgvwArrow.isHidden = false
        
        return cell
        
    }
    func btnRemoveGroup() {
        
        if selectedGroup != nil {
            showAlertWithTitle(title: "Delete Group", message: "Are you sure?", forTarget: self, buttonOK: "OK" , buttonCancel: "Cancel", alertOK: { (okTitle:String) in
                self.removeImage(withImageName: self.selectedGroup.groupImage!)
                managedContext.delete(self.selectedGroup)
                
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                self.navigationController?.popToRootViewController(animated: true)
                }, alertCancel: { Void in })
            return;
        }
    }
    
    func removeImage(withImageName:String) {

        let fileManager = FileManager.default
        let filePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(withImageName)

         do {
            try fileManager.removeItem(atPath: filePath)
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }

    func btnAddDefaultgroups()  {
        let AddGroup = self.storyboard!.instantiateViewController(withIdentifier: "DefaultGroups") as! DefaultGroupsViewController
        AddGroup.delegate = self
        self.navigationController!.pushViewController(AddGroup, animated: true)
    }
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.row == 1{
            
            print(" Phone List")

            let contactPickerScene = EPContactsPicker(delegate: self, multiSelection:true, subtitleCellType: SubtitleCellValue.phoneNumber)
            if self.selectedContacts.count > 0 {
                contactPickerScene.selectedContacts = self.selectedContacts
            }
            let navigationController = UINavigationController(rootViewController: contactPickerScene)
            self.present(navigationController, animated: true, completion: nil)
//            self.importAllContacts()
        }
//        else if indexPath.row == 3{
//            
//            print("From Email Account")
////            showAlertWithTitle(title: "Under working", message: "", forTarget: self, buttonOK: "" , buttonCancel: "OK", alertOK: { (okTitle:String) in
////            }, alertCancel: { Void in })
////            return;
//            let AddGroup = self.storyboard!.instantiateViewController(withIdentifier: "MailContactsViewController") as! MailContactsViewController
//            AddGroup.updateSelectedGmailDelegate = self
//             self.navigationController!.pushViewController(AddGroup, animated: true)
//
//        }
        else if indexPath.row == 2 {
            let controller = CNContactViewController(forNewContact: nil)
            controller.delegate = self
            let navigationController = UINavigationController(rootViewController: controller)
            self.present(navigationController, animated: true)
        }
        else if indexPath.row == 3 {
            let AddGroup = self.storyboard!.instantiateViewController(withIdentifier: "SortingView") as! SortingViewController
            AddGroup.selectedSortingType = selectedSortingType
            AddGroup.delegate = self
            self.navigationController!.pushViewController(AddGroup, animated: true)
        }
        
    }
    func importAllContacts()  {
        
        getAllContacts( {(contacts, error) in
            if (error == nil) {
                DispatchQueue.main.async(execute: {
 
 
                    for cnContact in contacts
                    {
                        if self.selectedContacts.contains(where: { $0.contactId == cnContact.identifier })
                        {
                            // no need to add
                        }
                        else{
                            
                            let epConatct:EPContact = EPContact (contact: cnContact)
                            self.selectedContacts.append(epConatct)
                        }
                    }
                    self.refreshArrayList ()
                })
            }
        })

    }
    func updateNavigationButton(isRightBarButtonEnabled: Bool){
        if isRightBarButtonEnabled {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        else{
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    func checkGroupNameAvailableInDB(groupName:String) -> Bool {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Groups")
        fetchRequest.predicate = NSPredicate(format: "groupName == %@", groupName)

        do {
            let groups = try managedContext.fetch(fetchRequest) as! [Groups]
            if groups.count > 0 {
                return true
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        return false
    }
    func btnDoneAction()  {
        
        let indexPath = NSIndexPath(row: 0, section: 0)
        let cell:AddNewGroupCell = self.tblGroupDetails.cellForRow(at: indexPath as IndexPath) as! AddNewGroupCell
        if ((cell.txtfldGroupName.text?.characters.count)! < 1) {
            print("Please Enter Group Name")
        }
        else{
            
            if selectedGroup != nil {
                if selectedGroup.groupName != cell.txtfldGroupName.text {
                    if checkGroupNameAvailableInDB(groupName: cell.txtfldGroupName.text!) {
                        showAlertWithTitle(title: "", message: "Group Name already exists.", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
                        }, alertCancel: { Void in })
                        return;
                    }
                }
                selectedGroup.groupName = cell.txtfldGroupName.text
                selectedGroup.groupImage = String(format:"%d_%@",selectedGroup.groupID,selectedGroup.groupName!)
                selectedGroup.groupOrder = (selectedSortingType != nil) ? selectedSortingType : "Default"
                var selectedContactList:String = ""
                for contact in selectedContacts {
                    if selectedContactList.characters.count > 0{
                        selectedContactList = String(format:"%@,%@",selectedContactList,contact.contactId!)
                    }
                    else{
                        selectedContactList = String(format:"%@",contact.contactId!)
                    }
                }
                self.saveImageDocumentDirectory(withImageName: selectedGroup.groupImage!)

                selectedGroup.groupContacts = selectedContactList
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
                self.delegate?.updateContactInfo(selectedGroup: selectedGroup)
                
            }else{
                
                if checkGroupNameAvailableInDB(groupName: cell.txtfldGroupName.text!) {
                    showAlertWithTitle(title: "", message: "Group Name already exists.", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
                    }, alertCancel: { Void in })
                    return;
                }
                
                let groupInfo:Groups!
                if #available(iOS 10.0, *) {
                    groupInfo = Groups(context: managedContext)
                } else {
                    // Fallback on earlier versions
                    
                    let entity =  NSEntityDescription.entity(forEntityName: "Groups",
                                                             in:managedContext)
                    
                    groupInfo = Groups(entity: entity!,
                                        insertInto: managedContext)

                }
                let groupIDCount = self.getMaxGroupId()
                groupInfo.groupID = (selectedGroup != nil) ? selectedGroup.groupID : groupIDCount+1
                groupInfo.groupName = cell.txtfldGroupName.text
                groupInfo.groupImage = String(format:"%d_%@",groupInfo.groupID,groupInfo.groupName!)
                groupInfo.groupOrder = (selectedSortingType != nil) ? selectedSortingType : "Default"
                
                let timestampAsString = String(format: "%f", NSDate.timeIntervalSinceReferenceDate)
                let timestampParts = timestampAsString.components(separatedBy: ".")
                groupInfo.createdDate =  timestampParts[0]
                
                var selectedContactList:String = ""
                for contact in selectedContacts {
                    if selectedContactList.characters.count > 0{
                        selectedContactList = String(format:"%@,%@",selectedContactList,contact.contactId!)
                    }
                    else{
                        selectedContactList = String(format:"%@",contact.contactId!)
                    }
                }
                groupInfo.groupContacts = selectedContactList
                
                self.saveImageDocumentDirectory(withImageName: groupInfo.groupImage!)
                selectedGroup = groupInfo
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }

            self.navigationController?.popViewController(animated: true)
        }
    }
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func saveImageDocumentDirectory(withImageName:String){
        
        if selectedgroupImage != nil {
            let fileManager = FileManager.default
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(withImageName)
            let image = selectedgroupImage
            print(paths)
            let imageData = UIImageJPEGRepresentation(image!, 0.5)
            fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
        }
    }

    
    func getMaxGroupId() -> Int {
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Groups")
        
        fetchRequest.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: "groupID", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let group = try managedContext.fetch(fetchRequest)
            print(group)
            if group.count == 0 {
                return 0
            }
            let max = group.first
            print(max?.value(forKey: "groupID") as! Int!)
            return (max?.value(forKey: "groupID") as! Int)
        } catch _ {
            
        }
        return 0
    }

    /// database methods
    func save(groupInfo: Groups) {
        
        let entity =
            NSEntityDescription.entity(forEntityName: "Groups",
                                       in: managedContext)!
        
        let group = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        // 4
        do {
            try managedContext.save()
            print("saved")
            groups.append(group)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
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
        selectedContacts = contacts
//        for contact in contacts {
//            
//            selectedContacts.add(contact)
//            print("\(contact.displayName())")
//        }
    }

    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact1: CNContact?) {
        viewController.navigationController?.dismiss(animated: true)
        
        if contact1 != nil
        {
            let contact: EPContact
            contact = EPContact(contact: contact1!)
            selectedContacts.append(contact)
        }

    }
    
    func updateSelectedGmailContacts(contactVal contactval:CNContact)  {
        let contact: EPContact
        contact = EPContact(contact: contactval)
        selectedContacts.append(contact)

    }
    
    // Update Image
    func UpdateGroupImage()  {
        
        let GroupImages = self.storyboard!.instantiateViewController(withIdentifier: "GroupImagesViewController") as! GroupImagesViewController
        GroupImages.groupImageDelegate = self
        let navigationController = UINavigationController(rootViewController: GroupImages)
        self.present(navigationController, animated: true, completion: nil)
        
    }
    func camera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = UIImagePickerControllerSourceType.camera
            
            self.present(myPickerController, animated: true, completion: nil)
        }
        
    }
    func photoLibrary()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(myPickerController, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let indexPath = NSIndexPath(row: 0, section: 0)
        let cell:AddNewGroupCell = self.tblGroupDetails.cellForRow(at: indexPath as IndexPath) as! AddNewGroupCell
        // Set photoImageView to display the selected image.
        cell.btnGroupImage.setImage(selectedImage, for: .normal)

        selectedgroupImage = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
    }
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }

    // get Contacts
    
    // MARK: - Contact Operations
    
    open func reloadContacts() {
        getContacts( {(contacts, error) in
            if (error == nil) {
                DispatchQueue.main.async(execute: {
                    
                    for cnContact in contacts
                    {
                        let epConatct:EPContact = EPContact (contact: cnContact)
                        self.selectedContacts.append(epConatct)
                    }
                    self.refreshArrayList ()
                })
            }
        })
    }
    
    func refreshArrayList()  {
        
//        if self.selectedContacts.count > 0 {
//            
//            self.selectedContacts = self.selectedContacts.uniq()
//
//            var str:String
//            if self.selectedContacts.count == 1 {
//                str = String(format:"%d Contact - Add More",self.selectedContacts.count)
//            }
//            else{
//                str = String(format:"%d Contacts - Add More",self.selectedContacts.count)
//            }
//            self.groupDetails = ["Select from Contact List","Create Contact","Sort Order"]
//        }
//        else{
//            self.groupDetails = ["Select from Contact List","Create Contact","Sort Order"]
//        }
        self.groupDetails = ["Select from Contact List","Create Contact","Sort Order"]

        self.tblGroupDetails.reloadData()

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
                    contactsArray.append(contact)
                    
                })
                completion(contactsArray  , nil)
                
                
                
            }
                //Catching exception as enumerateContactsWithFetchRequest can throw errors
            catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
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
                    if self.selectedGroup != nil {
                        if (self.selectedGroup.groupContacts?.characters.count)! > 0
                        {
                            let arrCIdentifiers = self.selectedGroup.groupContacts?.components(separatedBy: ",")
                            
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

    func updateGroupImage(image:UIImage)
    {
        let indexPath = NSIndexPath(row: 0, section: 0)
        let cell:AddNewGroupCell = self.tblGroupDetails.cellForRow(at: indexPath as IndexPath) as! AddNewGroupCell
        // Set photoImageView to display the selected image.
        cell.btnGroupImage.setImage(image, for: .normal)
        selectedgroupImage = image
    }
}
