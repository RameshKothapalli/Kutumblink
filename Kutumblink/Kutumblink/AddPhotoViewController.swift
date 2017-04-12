//
//  AddPhotoViewController.swift
//  Kutumblink
//
//  Created by Apple on 09/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import CoreData

class AddPhotoViewController: BaseViewController {

    @IBOutlet weak var txtfldTitle: UITextField!
    @IBOutlet weak var txtvwLink: UITextView!
    var selectedphoto:Photos!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Add Photo Link"
        self.navigationController?.navigationBar.barTintColor = navigationBarColor

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
        
        if (selectedphoto != nil)  {
            txtfldTitle.text = selectedphoto.photoTitle
            txtvwLink.text = selectedphoto.photoUrl
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
        if selectedphoto == nil{
            
            if checkPhotoTitleAvailableInDB(photoTitle: self.txtfldTitle.text!) {
                showAlertWithTitle(title: "", message: "Photo title already exists.", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
                }, alertCancel: { Void in })
                return;
            }
            
            let photoInfo:Photos!
            if #available(iOS 10.0, *) {
                photoInfo = Photos(context: managedContext)
            } else {
                // Fallback on earlier versions
                
                let entity =  NSEntityDescription.entity(forEntityName: "Photos",
                                                         in:managedContext)
                
                photoInfo = Photos(entity: entity!,
                                   insertInto: managedContext)
                
            }
            let messageIDCount = self.getMaxEventId()
            photoInfo.photoId = messageIDCount+1
            photoInfo.photoTitle = self.txtfldTitle.text
            photoInfo.photoUrl = self.txtvwLink.text
            selectedphoto = photoInfo
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        else{
            
            if selectedphoto.photoTitle != self.txtfldTitle.text {
                if checkPhotoTitleAvailableInDB(photoTitle: self.txtfldTitle.text!) {
                    showAlertWithTitle(title: "", message: "Photo title already exists.", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
                    }, alertCancel: { Void in })
                    return;
                }
            }

            selectedphoto.photoId = selectedphoto.photoId
            selectedphoto.photoTitle = self.txtfldTitle.text
            selectedphoto.photoUrl = self.txtvwLink.text
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        showAlertWithTitle(title: "Photo Link is saved.", message: "", forTarget: self, buttonOK: "OK" , buttonCancel: "", alertOK: { (okTitle:String) in
            
            self.navigationController?.popViewController(animated: true)
            }, alertCancel: { Void in })

    }
    func checkPhotoTitleAvailableInDB(photoTitle:String) -> Bool {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Photos")
        fetchRequest.predicate = NSPredicate(format: "photoTitle == %@", photoTitle)

        do {
            let photolinks = try managedContext.fetch(fetchRequest) as! [Photos]
            if photolinks.count > 0 {
                return true
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return false
    }

    func getMaxEventId() -> Int {
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Photos")
        
        fetchRequest.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: "photoId", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let group = try managedContext.fetch(fetchRequest)
            print(group)
            if group.count == 0 {
                return 0
            }
            let max = group.first
            print(max?.value(forKey: "photoId") as! Int!)
            return (max?.value(forKey: "photoId") as! Int)
        } catch _ {
            
        }
        return 0
    }
    

}
