//
//  MessagesViewController.swift
//  Kutumblink
//
//  Created by Apple on 09/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import CoreData

class MessagesViewController: BaseViewController ,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tblMessages: UITableView!
    var arrMessages:NSMutableArray! = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Message Links"
        self.navigationController?.navigationBar.barTintColor = navigationBarColor

        var imagelogo = UIImage(named: "applogo")
        imagelogo = imagelogo?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imagelogo, style: UIBarButtonItemStyle.plain, target: self, action:nil)
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        
//        var imagemenu = UIImage(named: "menu.png")
//        imagemenu = imagemenu?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: imagemenu, style: UIBarButtonItemStyle.plain, target: self, action:    #selector(MessagesViewController.btnMenuAction))

        let rightButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action:   #selector(PhotoLinksViewController.btnEditAction))
        self.navigationItem.rightBarButtonItem = rightButtonItem
        self.navigationItem.rightBarButtonItem?.isEnabled = false

        
        tblMessages.delegate = self
        tblMessages.dataSource = self
        self.tblMessages.estimatedRowHeight = 64
//        self.tblMessages.rowHeight = UITableViewAutomaticDimension


    }
    override func viewWillDisappear(_ animated: Bool) {
        self.interstitial?.delegate = nil
    }
    func btnEditAction()  {
        
        if(self.isEditing == true)
        {
            super.setEditing(false, animated: false)
            self.tblMessages.setEditing(false, animated: false)
            self.tblMessages.reloadData()
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        }
        else
        {
            super.setEditing(true, animated: true)
            self.tblMessages.setEditing(true, animated: true)
            self.tblMessages.reloadData()
            self.navigationItem.rightBarButtonItem?.title = "Done"
        }
    }

    func btnMenuAction()  {
        
        let AddGroup = self.storyboard!.instantiateViewController(withIdentifier: "InfoViewController") as! InfoViewController
        self.navigationController!.pushViewController(AddGroup, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        
        // show ads
//        self.showFullScreenAds()
        self.getMessages()
    }
  
    
    func getMessages()  {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Messages")
        do {
            let messages = try managedContext.fetch(fetchRequest) as! [Messages]
            if arrMessages.count > 0 {
                arrMessages.removeAllObjects()
            }
            for message in messages {
                arrMessages.add(message)
            }
            debugPrint(arrMessages)
            if arrMessages.count > 0 {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
            else{
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                super.setEditing(false, animated: false)
                self.tblMessages.setEditing(false, animated: false)
                self.navigationItem.rightBarButtonItem?.title = "Edit"
            }
            tblMessages.reloadData()
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrMessages.count + 1
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0
        {
            let cell:GroupCell = tableView.dequeueReusableCell(withIdentifier: "GroupCell") as! GroupCell
            return cell
        }
        
        let cell:MessageCell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageCell
        let message = self.arrMessages.object(at: indexPath.row-1) as! Messages
        
        cell.lblTitle.text = message.messageTitle
        
        return cell
    }
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tblMessages.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let AddGroup = self.storyboard!.instantiateViewController(withIdentifier: "AddMessage") as! AddMessageViewController
            AddGroup.selectedMessage = nil
            self.navigationController!.pushViewController(AddGroup, animated: true)
        }
        else{
            let message = self.arrMessages.object(at: indexPath.row-1) as! Messages

            if verifyUrl(urlString: message.messageUrl) {

                showAlertWithTitle(title: "", message: "Do you want to navigate to the message link?", forTarget: self, buttonOK: "OK" , buttonCancel: "Cancel", alertOK: { (okTitle:String) in
                    UIApplication.shared.openURL(NSURL(string: message.messageUrl!)! as URL)
                    
                }, alertCancel: { Void in
                    
                })
                return;

            }
            else{
                showAlertWithTitle(title: "", message: "Invalid url.", forTarget: self, buttonOK: "" , buttonCancel: "OK", alertOK: { (okTitle:String) in
                    }, alertCancel: { Void in
                        
                })
                return;
            }
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.row == 0 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let edit = UITableViewRowAction(style: .normal, title: "       ") { action, index in
            print("Edit button tapped")
            let message = self.arrMessages.object(at: editActionsForRowAt.row-1) as! Messages

            let AddGroup = self.storyboard!.instantiateViewController(withIdentifier: "AddMessage") as! AddMessageViewController
            AddGroup.selectedMessage = message

            self.navigationController!.pushViewController(AddGroup, animated: true)
        }
        edit.backgroundColor = UIColor(patternImage: UIImage(named: "edit")!)
        
        
        let delete = UITableViewRowAction(style: .normal, title: "       ") { action, index in
            print("Delete button tapped")
            showAlertWithTitle(title: "Delete Message Link", message: "Are you sure?", forTarget: self, buttonOK: "OK" , buttonCancel: "Cancel", alertOK: { (okTitle:String) in
                
                let currentGroup = self.arrMessages.object(at: editActionsForRowAt.row-1) as! Messages
                managedContext.delete(currentGroup)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                self.arrMessages.removeObject(at: editActionsForRowAt.row-1)
                
                if self.arrMessages.count > 0 {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    
                }
                else{
                     self.navigationItem.rightBarButtonItem?.isEnabled = false
                    super.setEditing(false, animated: false)
                    self.tblMessages.setEditing(false, animated: false)
                    self.navigationItem.rightBarButtonItem?.title = "Edit"
                }

                self.tblMessages.reloadData()
                
                
            }, alertCancel: { Void in
                
            })
            return;
        }
        delete.backgroundColor = UIColor(patternImage: UIImage(named: "delete")!)
        
        return [ delete, edit]
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
        }
    }


}
