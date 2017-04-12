//
//  PhotoLinksViewController.swift
//  Kutumblink
//
//  Created by Apple on 09/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import CoreData

class PhotoLinksViewController: BaseViewController ,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tblPhotoLinks: UITableView!
    var arrPhotoLinks:NSMutableArray! = []

    var isEditModeOn:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
 
        self.navigationItem.title = "Photo Links"
        self.navigationController?.navigationBar.barTintColor = navigationBarColor
     
        var imagelogo = UIImage(named: "applogo")
        imagelogo = imagelogo?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imagelogo, style: UIBarButtonItemStyle.plain, target: self, action:nil)
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        
//        var imagemenu = UIImage(named: "menu.png")
//        imagemenu = imagemenu?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: imagemenu, style: UIBarButtonItemStyle.plain, target: self, action:    #selector(PhotoLinksViewController.btnMenuAction))

        let rightButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action:   #selector(PhotoLinksViewController.btnEditAction))
        self.navigationItem.rightBarButtonItem = rightButtonItem

//        self.navigationItem.rightBarButtonItem = self.editButtonItem

        tblPhotoLinks.delegate = self
        tblPhotoLinks.dataSource = self
        self.tblPhotoLinks.estimatedRowHeight = 64
//        self.tblPhotoLinks.rowHeight = UITableViewAutomaticDimension
//        self.tblPhotoLinks.allowsSelectionDuringEditing = true;


    }
    override func viewWillDisappear(_ animated: Bool) {
        self.interstitial?.delegate = nil
    }
    func btnEditAction()  {
        
        if(self.isEditing == true)
        {
            super.setEditing(false, animated: false)
            self.tblPhotoLinks.setEditing(false, animated: false)
            self.tblPhotoLinks.reloadData()
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        }
        else
        {
            super.setEditing(true, animated: true)
            self.tblPhotoLinks.setEditing(true, animated: true)
            self.tblPhotoLinks.reloadData()
            self.navigationItem.rightBarButtonItem?.title = "Done"
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        
        self.getPhotos()
        // show ads
       // self.showFullScreenAds()
    }
    
    
    func getPhotos()  {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Photos")
        do {
            let photolinks = try managedContext.fetch(fetchRequest) as! [Photos]
            if arrPhotoLinks.count > 0 {
                arrPhotoLinks.removeAllObjects()
            }
            for photolink in photolinks {
                arrPhotoLinks.add(photolink)
            }
            
            if arrPhotoLinks.count > 0 {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
            else{
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                super.setEditing(false, animated: false)
                self.tblPhotoLinks.setEditing(false, animated: false)
                self.navigationItem.rightBarButtonItem?.title = "Edit"
            }

            
            debugPrint(arrPhotoLinks)
            tblPhotoLinks.reloadData()
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
 
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrPhotoLinks.count + 1
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell:GroupCell = tableView.dequeueReusableCell(withIdentifier: "GroupCell") as! GroupCell
            return cell
 
        }
        let cell:MessageCell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageCell
            let photolink = self.arrPhotoLinks.object(at: indexPath.row-1) as! Photos
            
            cell.lblTitle.text = photolink.photoTitle
        

        
        return cell
    }
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tblPhotoLinks.deselectRow(at: indexPath, animated: true)

        if indexPath.row == 0 {
            let AddGroup = self.storyboard!.instantiateViewController(withIdentifier: "AddPhoto") as! AddPhotoViewController
            AddGroup.selectedphoto = nil
            self.navigationController!.pushViewController(AddGroup, animated: true)
        }
        else{
            let message = self.arrPhotoLinks.object(at: indexPath.row-1) as! Photos
            if verifyUrl(urlString: message.photoUrl) {
                
                showAlertWithTitle(title: "", message: "Do you want to navigate to the photo link?", forTarget: self, buttonOK: "OK" , buttonCancel: "Cancel", alertOK: { (okTitle:String) in
                    UIApplication.shared.openURL(NSURL(string: message.photoUrl!)! as URL)

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
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
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
            let message = self.arrPhotoLinks.object(at: editActionsForRowAt.row-1) as! Photos
            
            let AddGroup = self.storyboard!.instantiateViewController(withIdentifier: "AddPhoto") as! AddPhotoViewController
            AddGroup.selectedphoto = message
            
            self.navigationController!.pushViewController(AddGroup, animated: true)
        }
        edit.backgroundColor = UIColor(patternImage: UIImage(named: "edit")!)
        
        
        let delete = UITableViewRowAction(style: .normal, title: "       ") { action, index in
            print("Delete button tapped")
            showAlertWithTitle(title: "Delete Photo Link", message: "Are you sure?", forTarget: self, buttonOK: "OK" , buttonCancel: "Cancel", alertOK: { (okTitle:String) in
                
                let currentGroup = self.arrPhotoLinks.object(at: editActionsForRowAt.row-1) as! Photos
                managedContext.delete(currentGroup)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                self.arrPhotoLinks.removeObject(at: editActionsForRowAt.row-1)
                
                if self.arrPhotoLinks.count > 0 {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                }
                else{
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                    super.setEditing(false, animated: false)
                    self.tblPhotoLinks.setEditing(false, animated: false)
                    self.navigationItem.rightBarButtonItem?.title = "Edit"
                }

                self.tblPhotoLinks.reloadData()
                
                
            }, alertCancel: { Void in
                
            })
            return;
        }
        delete.backgroundColor = UIColor(patternImage: UIImage(named: "delete")!)
        
        return [ delete, edit]
    }
    

}
