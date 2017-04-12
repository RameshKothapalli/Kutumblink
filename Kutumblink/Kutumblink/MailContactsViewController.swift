//
//  MailContactsViewController.swift
//  Kutumblink
//
//  Created by Apple on 28/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import PKHUD
import Contacts
import ContactsUI

protocol  MailContactsViewControllerDelegate{
    func updateSelectedGmailContacts(contactVal:CNContact)
    
}



class MailContactsViewController: BaseViewController ,GIDSignInDelegate,GIDSignInUIDelegate,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var btngmail: UIButton!
    @IBOutlet weak var tblContacts: UITableView!
    var arrContacts:NSMutableArray = []
    var selectedContacts:NSMutableArray = []
    var updateSelectedGmailDelegate: MailContactsViewControllerDelegate?

    class contacts:NSMutableDictionary{
        var name:String = ""
        let arrEmails:NSMutableArray = []
        let arrPhoneNumbers:NSMutableArray = []
        var isSeleted:Bool = false
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = navigationBarColor
        self.navigationItem.title = "Email Contacts"

        let rightButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action:   #selector(MailContactsViewController.btnImportAction))
        self.navigationItem.rightBarButtonItem = rightButtonItem

        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.login")
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.me")
        GIDSignIn.sharedInstance().scopes.append("https://www.google.com/m8/feeds/")
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/contacts.readonly")

        // Do any additional setup after loading the view.
        tblContacts.isHidden = true
        tblContacts.estimatedRowHeight = 64
        btngmail.isHidden = false

        tblContacts.delegate = self
        tblContacts.dataSource = self
    }
    
    func btnImportAction()  {
        
        for index in 0...self.arrContacts.count-1 {
            let contact:contacts = self.arrContacts.object(at: index) as! MailContactsViewController.contacts
            
            if contact.isSeleted == true {
                let newContact = CNMutableContact()
                
                newContact.givenName = contact.name
                if contact.arrEmails.count >  0{
                    let homeEmail = CNLabeledValue(label: CNLabelHome, value: contact.arrEmails.object(at: 0) as! NSString)
                    
                    newContact.emailAddresses = [homeEmail]
                }
                if contact.arrPhoneNumbers.count >  0 {
                    
                    newContact.phoneNumbers = [CNLabeledValue(
                        label:CNLabelPhoneNumberiPhone,
                        value:CNPhoneNumber(stringValue:(contact.arrPhoneNumbers.object(at: 0) as! NSString) as String))]

                }
                // Saving the newly created contact
                let store = CNContactStore()
                let saveRequest = CNSaveRequest()
                saveRequest.add(newContact, toContainerWithIdentifier:nil)
                try! store.execute(saveRequest)

                print(newContact.identifier)
                self.updateSelectedGmailDelegate?.updateSelectedGmailContacts(contactVal: newContact)
            }
        }
   
        self.navigationController?.popViewController(animated: true)
    }
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrContacts.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:EmailContactCell = tableView.dequeueReusableCell(withIdentifier: "EmailContactCell") as! EmailContactCell
        
        let contact:contacts = self.arrContacts.object(at: indexPath.row) as! MailContactsViewController.contacts
        cell.lblName.text = contact.name
        cell.accessoryType = UITableViewCellAccessoryType.none

        if contact.isSeleted == true {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact:contacts = self.arrContacts.object(at: indexPath.row) as! MailContactsViewController.contacts
        if contact.isSeleted == true {
            contact.isSeleted = false
        }else{
            contact.isSeleted = true
        }
        self.tblContacts.reloadRows(at: [indexPath], with: .none)
    }
    
    @IBAction func signInGmailClicked(_ sender: Any) {
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()

    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
//            let userId = user.userID
//            let idToken = user.authentication.idToken // Safe to send to the server
//            let fullName = user.profile.name
//            let givenName = user.profile.givenName
//            let familyName = user.profile.familyName
//            let email = user.profile.email
//            
//            print(userId,idToken,fullName,familyName,givenName,email,user.profile.imageURL(withDimension: 100),user.profile.hasImage)
            
            self.getcontsctList(user: user)
            
            
        } else {
            let nserr = error as NSError
            //            if nserr.code == errorCodeCancelled (-5 for google) {
            //                // Cancelled task
            //
            //            } else {
            //                //handle error other than cancelling
            //                print(nserr)
            //            }
        }
    }
    
    func getcontsctList(user:GIDGoogleUser)
    {
        
        HUD.show(.rotatingImage(UIImage.init(named: "progress_circular")))
        
        let urlString = String(format:"https://www.google.com/m8/feeds/contacts/default/full?alt=json&access_token=%@&max-results=5000&v=3.0",user.authentication.accessToken)
        
        GIDSignIn.sharedInstance().signOut()

        let url = URL(string: urlString)
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            if error != nil {
                print(error)
            } else {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                    print(parsedData)
                    
                    let feed = parsedData["feed"] as! [String:Any]
                    let entry = feed["entry"] as! NSArray
                    print(entry)
                    
                    for index in 0...entry.count-1 {
                        let dict = entry.object(at: index) as! Dictionary<String, Any>
                        
                        print(dict)
                        let contactData:contacts = contacts()

                        
                        if dict["title"] != nil {
                            
                            let title = dict["title"] as! Dictionary<String, Any>
                            // name
                            if title["$t"] != nil {
                                contactData.name = title["$t"] as! String
                            }
                        }
                        // phone numbers
                        
                        if dict["gd$phoneNumber"] != nil {
                            let Numbers:NSArray = dict["gd$phoneNumber"] as! NSArray
                            for phoneindex in 0...Numbers.count-1 {
                                let phNumber = Numbers.object(at: phoneindex) as! Dictionary<String, Any>
                                
                                if phNumber["$t"] != nil {
                                    contactData.arrPhoneNumbers.add(phNumber["$t"] as! String)
                                }
                            }
                        }
                        
                        if dict["gd$email"] != nil {
                            
                            let email:NSArray = dict["gd$email"] as! NSArray
                            for emailIndex in 0...email.count-1 {
                                let emailDict = email.object(at: emailIndex) as! Dictionary<String, Any>
                                
                                if emailDict["address"] != nil {
                                    contactData.arrEmails.add(emailDict["address"] as! String)
                                }
                            }
                            
                        } else {
                            print("key is not present in dict")
                        }
                        
                        // email address
                        print(contactData.name)
                        if contactData.name.characters.count > 1
                        {
                            self.arrContacts.add(contactData)
                        }
                        //                        print("\(index) times 5 is \(index * 5)")
                    }
                    DispatchQueue.main.async(){
                        //code 
                        HUD.hide()
                        if self.arrContacts.count > 0
                        {
                            self.btngmail.isHidden = true
                            self.tblContacts.isHidden = false
                            self.tblContacts.reloadData()
                        }

                    }

                    
                    
                } catch let error as NSError {
                    print(error)
                }            }
            
            }.resume()
        
        
    }
    
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
        //myActivityIndicator.stopAnimating()
    }
    
    // Present a view that prompts the user to sign in with Google
    func signIn(signIn: GIDSignIn!,
                presentViewController viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
        
        print("Sign in presented")
        
    }
    
    // Dismiss the "Sign in with Google" view
    func signIn(signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
        
        print("Sign in dismissed")
    }
    
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        //        myActivityIndicator.stopAnimating()
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true, completion: nil)
    }


}
