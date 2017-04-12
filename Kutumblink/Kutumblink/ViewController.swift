//
//  ViewController.swift
//  Kutumblink
//
//  Created by Admin on 04/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import CoreData


class ViewController: BaseViewController ,UITableViewDelegate,UITableViewDataSource,KLSelectedContactsPickerDelegate,UITabBarControllerDelegate{

    let groupCellIdentifier = "Groupcell"
    @IBOutlet weak var tblGroups: UITableView!
    var arrGroups:NSMutableArray! = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.


        self.navigationItem.title = "Groups"
        self.navigationController?.navigationBar.barTintColor = navigationBarColor

        var imagelogo = UIImage(named: "applogo")
        imagelogo = imagelogo?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imagelogo, style: UIBarButtonItemStyle.plain, target: self, action:nil)
        self.navigationItem.leftBarButtonItem?.isEnabled = false

        var imagemenu = UIImage(named: "menu.png")
        imagemenu = imagemenu?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: imagemenu, style: UIBarButtonItemStyle.plain, target: self, action:    #selector(ViewController.btnMenuAction))

        
        self.tblGroups.delegate = self
        self.tblGroups.dataSource = self
        
        print("database path =%@ ",applicationDirectoryPath())
        
        self.tabBarController?.delegate = self

    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)
    {
        if tabBarController.selectedIndex == 0 {
            print("0")
        }
        else if tabBarController.selectedIndex == 1 {
            self.showFullScreenAds()
            print("1")
        }
        else if tabBarController.selectedIndex == 2 {
            self.showFullScreenAds()
            print("2")
        }
        else if tabBarController.selectedIndex == 3 {
            self.showFullScreenAds()
            print("3")
        }
    }

    func btnMenuAction()  {
        
        let AddGroup = self.storyboard!.instantiateViewController(withIdentifier: "InfoViewController") as! InfoViewController
        self.navigationController!.pushViewController(AddGroup, animated: true)
    }
    
    func applicationDirectoryPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        
        self.getGroups()
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
            tblGroups.reloadData()
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (arrGroups != nil) ? arrGroups.count+1 : 1
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:GroupCell = tableView.dequeueReusableCell(withIdentifier: "GroupCell") as! GroupCell

        if indexPath.row == 0 {
            cell.lblGroupName.text = "Add Group"
            cell.imgvwGroup.image = UIImage (named:"addnewgroup")
            cell.imgvwGroup.contentMode = .scaleAspectFit
            cell.lblContactCount?.isHidden = true
        }
        else{

            let currentGroup = arrGroups.object(at: indexPath.row-1) as! Groups
            cell.lblGroupName?.text = currentGroup.groupName
            cell.lblContactCount?.isHidden = true
            if (currentGroup.groupContacts?.characters.count)! > 0
            {
                cell.lblContactCount?.isHidden = false
                let arrCIdentifiers = currentGroup.groupContacts?.components(separatedBy: ",")
                let str:String = String(format:"%i",arrCIdentifiers!.count)
                cell.lblContactCount?.text = str
            }
            let fileManager = FileManager.default
            var Image:UIImage? = nil
            let imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent(currentGroup.groupImage!)
            if fileManager.fileExists(atPath: imagePAth){
                Image = UIImage(contentsOfFile: imagePAth)!
                cell.imgvwGroup.image = Image
            }else{
                print("No Image")
                cell.imgvwGroup.contentMode = .scaleAspectFit
                cell.imgvwGroup.image = UIImage (named:"defaultgroup")
            }
        }
        return cell
    }
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let AddGroup = self.storyboard!.instantiateViewController(withIdentifier: "AddNewGroup") as! AddNewGroupViewController
            AddGroup.selectedGroup = nil
            self.navigationController!.pushViewController(AddGroup, animated: true)
        }
        else{
            let selectedGroup = self.arrGroups.object(at: indexPath.row-1) as! Groups
            let contactPickerScene = KLSelectedContactPicker(delegate: self, multiSelection:true, subtitleCellType: SubtitleCellValue.phoneNumber, SelectedGroup:selectedGroup)
            //let navigationController = UINavigationController(rootViewController: contactPickerScene)
            //self.present(navigationController, animated: true, completion: nil)
            self.navigationController?.pushViewController(contactPickerScene, animated: true)
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
            
            let AddGroup = self.storyboard!.instantiateViewController(withIdentifier: "AddNewGroup") as! AddNewGroupViewController
            AddGroup.selectedGroup = self.arrGroups.object(at: editActionsForRowAt.row-1) as! Groups
            self.navigationController!.pushViewController(AddGroup, animated: true)
        }
 
        edit.backgroundColor = UIColor(patternImage: UIImage(named: "edit")! )

        let delete = UITableViewRowAction(style: .normal, title: "       ") { action, index in
            print("Delete button tapped")
            
            showAlertWithTitle(title: "Delete Group", message: "Are you sure?", forTarget: self, buttonOK: "OK" , buttonCancel: "Cancel", alertOK: { (okTitle:String) in
                
                let currentGroup = self.arrGroups.object(at: editActionsForRowAt.row-1) as! Groups
                self.removeImage(withImageName: currentGroup.groupImage!)

                managedContext.delete(currentGroup)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
                self.arrGroups.removeObject(at: editActionsForRowAt.row-1)
                self.tblGroups.reloadData()
                
                
            }, alertCancel: { Void in
                
            })
            return;

        }
        delete.backgroundColor = UIColor(patternImage: UIImage(named: "delete")!)
 

        return [ delete, edit]
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
}

