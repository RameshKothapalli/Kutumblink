//
//  InfoViewController.swift
//  Kutumblink
//
//  Created by Apple on 15/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import CoreData
import Contacts
import ContactsUI
import CloudKit
import PKHUD


class InfoViewController: BaseViewController ,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tblOptions: UITableView!
    let arrOptions:NSMutableArray = ["Share KutumbLink","Rate KutumbLink","Contact","FAQs","Kutumblink App Screen"]
    
    var updatedCount:Int = 0
    var totalCount:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Settings"
        self.navigationController?.navigationBar.barTintColor = navigationBarColor

        tblOptions.delegate = self
        tblOptions.dataSource = self
        let cellNib = UINib(nibName: "ActionCell", bundle: nil)
        tblOptions.register(cellNib, forCellReuseIdentifier: "ActionCell")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOptions.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ActionCell = tableView.dequeueReusableCell(withIdentifier: "ActionCell") as! ActionCell
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        cell.lblActionType.text = arrOptions.object(at: indexPath.row) as? String
        cell.lblActionType.textColor = UIColor.black
        
        return cell
        
    }
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            // Share the app
            
            let appID = "1218648204"
            let urlStr = "https://itunes.apple.com/app/id\(appID)" // (Option 1) Open App Page
 
            
            if let name = NSURL(string: urlStr) {
                let objectsToShare = [name]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
            }
            else
            {
                // show alert for not available
            }
        }
        else if indexPath.row == 1{
            // Rate us
            let appID = "1218648204"
//            let urlStr = "itms-apps://itunes.apple.com/app/id\(appID)" // (Option 1) Open App Page
            let urlStr = "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(appID)" // (Option 2) Open App Review Tab
 
            let url = URL(string: urlStr)!

            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        else if indexPath.row == 2
        {
            // Contact us
            let contactUs = self.storyboard!.instantiateViewController(withIdentifier: "ContactUSViewController") as! ContactUSViewController
            self.navigationController!.pushViewController(contactUs, animated: true)
        }
        else if indexPath.row == 3{
            //FAQ
            let contactUs = self.storyboard!.instantiateViewController(withIdentifier: "FAQViewController") as! FAQViewController
            self.navigationController!.pushViewController(contactUs, animated: true)

        }
        else if indexPath.row == 4
        {
            let AddGroup = self.storyboard!.instantiateViewController(withIdentifier: "LaunchImageViewController") as! LaunchImageViewController
            self.navigationController!.pushViewController(AddGroup, animated: true)
        }

        else if indexPath.row == 5{
            //Backup
            showAlertWithTitle(title: "Backup Groups", message: "Are you sure?", forTarget: self, buttonOK: "OK" , buttonCancel: "Cancel", alertOK: { (okTitle:String) in
                self.backupGroups()
            }, alertCancel: { Void in })
            return;

        }
        else if indexPath.row == 6{
            //Restore
            
            showAlertWithTitle(title: "Restore Groups", message: "Are you sure?", forTarget: self, buttonOK: "OK" , buttonCancel: "Cancel", alertOK: { (okTitle:String) in
                self.fetchrecords()
            }, alertCancel: { Void in })
            return;

        }

    }
    
    func saveContactsToiCloud(contact:String)  {
    
        getSelectedContacts(selctedContacts:contact, {(contacts, error) in
            if (error == nil) {
                DispatchQueue.main.async(execute: {
                    
                    HUD.hide()
                })
            }
        })

    }
    
    func getSelectedContacts(selctedContacts:String, _ completion:  @escaping ContactsHandler1) {
        
        var contactsStore: CNContactStore?

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
                    self.getSelectedContacts(selctedContacts:selctedContacts,completion)
                }
            })
            
        case  CNAuthorizationStatus.authorized:
            //Authorization granted by user for this app.
            
            let contactFetchRequest = CNContactFetchRequest(keysToFetch: allowedContactKeys())
            
            do {
                let arrCIdentifiers = selctedContacts.components(separatedBy: ",")
                let arrGroups:NSMutableArray = []
                let contactIdentifires:NSMutableArray = []
                // Remove duplication of vcard files
                for str in arrCIdentifiers {
                    if (contactIdentifires.contains(str))
                    {// no need to add
                    }
                    else{
                        contactIdentifires.add(str)
                    }
                }

                var contactsArray = [CNContact]()
                
                try contactsStore?.enumerateContacts(with: contactFetchRequest, usingBlock: { (contact, stop) -> Void in
                    //Ordering contacts based on alphabets in firstname
                    if (contactIdentifires.contains(contact.identifier))
                    {
                        let container = CKContainer.default()
                        let publicDatabase = container.privateCloudDatabase;

                        let epContact:EPContact = EPContact(contact:contact)
                        self.uploadContact(publicDatabase, contact: epContact)
//                        contactsArray.append(contact)
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

    func backupGroups()  {
         // Fetch Groups from coredata
        self.updatedCount = 0

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Groups")
        do {
            var allcontactidentifires:String = ""

            let groups = try managedContext.fetch(fetchRequest) as! [Groups]
            if groups.count > 0 {
                
                DispatchQueue.main.async(execute: {
                    HUD.show(.rotatingImage(UIImage.init(named: "progress_circular")))
                })

                for group in groups {
                    debugPrint(group.groupID)
                    
                    totalCount = groups.count
                    let imageName:String = group.groupImage!
                    let imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent(imageName)
                    let container = CKContainer.default()
                    let publicDatabase = container.privateCloudDatabase
                    
                    if (group.groupContacts?.characters.count)! > 0
                    {
                        if allcontactidentifires.characters.count > 0 {
                            allcontactidentifires = String(format:"%@,%@",allcontactidentifires,group.groupContacts!)
                        }
                        else{
                            allcontactidentifires = String(format:"%@",group.groupContacts!)
                        }
                    }
                    
                    // upload group Information to icloud except contacts, bcz same contact may have two groups to avoid duplicates save contacts separately
                    self.uploadGroup(publicDatabase, groupImage: group.groupImage!, groupName: group.groupName!, groupOrder: group.groupOrder!, groupContacts: group.groupContacts!, groupImagePath: imagePAth, createdDate:group.createdDate!)
                    
                }
                // upload contacts to DB
//                if allcontactidentifires.characters.count > 0 {
//                    [self.saveContactsToiCloud(contact:allcontactidentifires)];
//                }

            }
            else{
                showAlertWithTitle(title: "Backup", message: "Groups not available to save.", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
                }, alertCancel: { Void in })
                return;
            }


        }
        catch let error as NSError {
            HUD.hide()
            print("Could not fetch. \(error), \(error.userInfo)")
        }

    }

    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    
    func uploadGroup(_ db: CKDatabase,
                groupImage: String,
                groupName: String,
                groupOrder:  String,
                groupContacts: String,
                groupImagePath: String,
                createdDate: String){
        
        let noteID = CKRecordID(recordName : createdDate)
        let group = CKRecord(recordType: "Groups",recordID :noteID)

        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: groupImagePath){
            let imURL = NSURL.fileURL(withPath: groupImagePath)
            let coverPhoto = CKAsset(fileURL: imURL)
            group.setObject(coverPhoto, forKey: "CoverPhoto")
        }
        group.setObject(groupName as CKRecordValue?, forKey: "groupName")
        group.setObject(groupOrder as CKRecordValue?, forKey: "groupOrder")
        group.setObject(groupImage as CKRecordValue?, forKey: "groupImage")
        group.setObject(groupContacts as CKRecordValue?, forKey: "groupContacts")
        group.setObject(createdDate as CKRecordValue?, forKey: "createdDate")

     
        db.fetch(withRecordID: noteID, completionHandler: { record, error in
            if let fetchError = error {
                db.save(group, completionHandler: { record, error in
                    guard error == nil else {
                        HUD.hide()
                        print("error setting up record \(error)")
                        showAlertWithTitle(title: "Backup Groups", message: String(format:"%@",(error?.localizedDescription)!), forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
                        }, alertCancel: { Void in })
                        return;

                    }
                    self.updatedCount = self.updatedCount+1
                    print("saved: \(record)")
                    if self.updatedCount ==  self.totalCount{
                        DispatchQueue.main.async(execute: {
                            HUD.hide()
                            showAlertWithTitle(title: "", message: "Groups back up completed, file stored in cloud account linked to your phone", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
                            }, alertCancel: { Void in })
                            return;

                        })
                    }
                })


            } else {

                // Modify the record
                db.delete(withRecordID: noteID, completionHandler: { record, error in
                    guard error == nil else {
                        print("error setting up record \(error)")
                        
                        return
                    }
                    print("deleted: \(record)")
                    db.save(group, completionHandler: { record, error in
                        guard error == nil else {
                            print("error setting up record \(error)")
                            
                            return
                        }
                        self.updatedCount = self.updatedCount+1
                        print("updated: \(record)")
                        if self.updatedCount ==  self.totalCount{
                            DispatchQueue.main.async(execute: {
                                HUD.hide()
                                showAlertWithTitle(title: "", message: "Groups back up completed, file stored in cloud account linked to your phone", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
                                }, alertCancel: { Void in })
                                return;
                            })
                        }
                    })
                })
            }
        })


     }
    
    func uploadContact(_ db: CKDatabase,
                       contact :EPContact){
    
        let noteID = CKRecordID(recordName : contact.contactId!)
        let group = CKRecord(recordType: "Contacts",recordID :noteID)
        
        let fileManager = FileManager.default
        
        group.setObject(contact.firstName as CKRecordValue?, forKey: "firstName")
        group.setObject(contact.lastName as CKRecordValue?, forKey: "lastName")
        group.setObject(contact.company as CKRecordValue?, forKey: "company")
        group.setObject(contact.birthday as CKRecordValue?, forKey: "birthday")
        group.setObject(contact.birthdayString as CKRecordValue?, forKey: "birthdayString")
        group.setObject(contact.contactId as CKRecordValue?, forKey: "contactId")
        
        let phoneNumbers:NSMutableArray = []
        for phoneNumber in contact.phoneNumbers {
            let phone = phoneNumber.phoneNumber
            phoneNumbers.add(phone)
        }
        if phoneNumbers.count > 0 {
            group.setObject(phoneNumbers as CKRecordValue?, forKey: "phoneNumbers")
        }
        
        let emails:NSMutableArray = []
        for email in contact.emails {
            let email = email.email
            emails.add(email)
        }
        if emails.count > 0 {
            group.setObject(emails as CKRecordValue?, forKey: "emails")
        }

        db.save(group, completionHandler: { record, error in
            guard error == nil else {
                print("error setting up record \(error)")
                
                return
            }
            print("saved: \(record)")
            
        })
    }

    
    func fetchrecords()  {
        
        HUD.show(.rotatingImage(UIImage.init(named: "progress_circular")))

        let arrGroups:NSMutableArray = []
        
        let container = CKContainer.default()
        let publicDB = container.privateCloudDatabase;
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Groups", predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { [unowned self] results, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    HUD.hide()

          
                     print("Cloud Query Error - Refresh: \(error)")
                    showAlertWithTitle(title: "Restore Groups", message: String(format:"%@",(error?.localizedDescription)!), forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
                    }, alertCancel: { Void in })
                    return;

                }
                return
            }
            
            for record in results! {
                
                print(record["createdDate"] as! String)
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Groups")
                fetchRequest.predicate = NSPredicate(format: "createdDate == %@", record["createdDate"] as! String)

                do {
                    let groups = try managedContext.fetch(fetchRequest) as! [Groups]
                    if groups.count > 0
                    {
                        for group in groups {
                            print("update Record")
                            
                            group.groupName = record["groupName"] as? String
                            group.groupOrder = record["groupOrder"] as? String
                            group.groupContacts = record["groupContacts"] as? String
                            group.groupImage = record["groupImage"] as? String
                            group.createdDate = record["createdDate"] as? String
                            (UIApplication.shared.delegate as! AppDelegate).saveContext()
                            
                            self.loadCoverPhoto(record: record) { image in
                                DispatchQueue.main.async {
                                    if image != nil{
                                        self.saveImageDocumentDirectory(image:image!, withImageName: group.groupImage!)
                                    }
                                }
                            }
                            arrGroups.add(group)
                            
                        }
                    }
                    else{
                        print("no records found")
                        // No records Found
                        let group:Groups!
                        if #available(iOS 10.0, *) {
                            group = Groups(context: managedContext)
                        } else {
                            // Fallback on earlier versions
                            
                            let entity =  NSEntityDescription.entity(forEntityName: "Groups",
                                                                     in:managedContext)
                            
                            group = Groups(entity: entity!,
                                           insertInto: managedContext)
                            
                        }
                        
                        group.groupName = record["groupName"] as? String
                        group.groupOrder = record["groupOrder"] as? String
                        group.groupContacts = record["groupContacts"] as? String
                        group.groupImage = record["groupImage"] as? String
                        group.createdDate = record["createdDate"] as? String
                        (UIApplication.shared.delegate as! AppDelegate).saveContext()
                        
                        self.loadCoverPhoto(record: record) { image in
                            DispatchQueue.main.async {
                                if image != nil{
                                    self.saveImageDocumentDirectory(image:image!, withImageName: group.groupImage!)
                                }
                            }
                        }
                        arrGroups.add(group)
                        
                    }
                }catch{
                    
                }
            }
            
            DispatchQueue.main.async {
                
                print("arrGroups: \(arrGroups)")
                HUD.hide()
                if arrGroups.count > 0
                {
                    showAlertWithTitle(title: "Restore Groups", message: "Completed", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
                    }, alertCancel: { Void in })
                    return;
                }
                else{
                    
                    showAlertWithTitle(title: "Restore Groups", message: "Groups not available to restore in cloud account linked to your phone", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
                    }, alertCancel: { Void in })
                    return;

                }
            }
        }
        
    }
    func getContactsFromCloud() {
        
        let container = CKContainer.default()
        let publicDB = container.privateCloudDatabase;
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Contacts", predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { [unowned self] results, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    HUD.hide()
                    
                    print("Cloud Query Error - Refresh: \(error)")
                }
                return
            }
            
            for record in results! {
                
                let contact:Data = (record["Contacts"] as? Data)!
              
                let vcardFromContacts:NSArray
                do {
                    try vcardFromContacts = CNContactVCardSerialization.contacts(with:contact) as NSArray
                } catch {
                    print("vcardFromContacts \(error)")
                }

             }
            
            DispatchQueue.main.async {
                
                HUD.hide()
            }
        }

    }
    func saveImageDocumentDirectory(image:UIImage ,withImageName:String){
        
        if image != nil {
            let fileManager = FileManager.default
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(withImageName)
            print(paths)
            let imageData = UIImageJPEGRepresentation(image, 0.5)
            fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
        }
    }

    func loadCoverPhoto(record:CKRecord, completion:@escaping (_ photo: UIImage?) -> ()) {
        // 1
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            var image: UIImage!
            defer {
                completion(image)
            }
            // 2
            guard let asset = record["CoverPhoto"] as? CKAsset else {
                return
            }
            
            let imageData: Data
            do {
                imageData = try Data(contentsOf: asset.fileURL)
            } catch {
                return
            }
            image = UIImage(data: imageData)
        }
    }
}
