//
//  EventsViewController.swift
//  Kutumblink
//
//  Created by Apple on 07/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import CoreData

class EventsViewController: BaseViewController ,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tblEvents: UITableView!
    var arrEvents:NSMutableArray! = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Events"
        self.navigationController?.navigationBar.barTintColor = navigationBarColor

//        let rightButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action:   #selector(EventsViewController.btnAddNewEventAction))
//        self.navigationItem.rightBarButtonItem = rightButtonItem

        var imagelogo = UIImage(named: "applogo")
        imagelogo = imagelogo?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imagelogo, style: UIBarButtonItemStyle.plain, target: self, action:nil)
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        
        var imagemenu = UIImage(named: "menu.png")
        imagemenu = imagemenu?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: imagemenu, style: UIBarButtonItemStyle.plain, target: self, action:    #selector(EventsViewController.btnMenuAction))

        
        // Do any additional setup after loading the view.
        self.tblEvents.delegate = self
        self.tblEvents.dataSource = self
        self.tblEvents.estimatedRowHeight = 100
        self.tblEvents.rowHeight = UITableViewAutomaticDimension
        NotificationCenter.default.addObserver(self, selector: #selector(EventsViewController.refreshList), name: NSNotification.Name(rawValue: "KutumblinkShouldRefresh"), object: nil)
        
        // show ads
      //  self.showFullScreenAds()

    }
    override func viewWillDisappear(_ animated: Bool) {
        self.interstitial?.delegate = nil
    }
    func btnMenuAction()  {
        
        let AddGroup = self.storyboard!.instantiateViewController(withIdentifier: "InfoViewController") as! InfoViewController
        self.navigationController!.pushViewController(AddGroup, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // show ads
       // self.showFullScreenAds()

        self.tblEvents.backgroundView = nil
        self.getEvents()
    }
    func refreshList() {
        self.tblEvents.reloadData()
        
    }

    func getEvents()  {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Events")
        do {
            let events = try managedContext.fetch(fetchRequest) as! [Events]
            if arrEvents.count > 0 {
                arrEvents.removeAllObjects()
            }
            for event in events {
                debugPrint(event.eventId)
                arrEvents.add(event)
            }
            debugPrint(arrEvents)
            tblEvents.reloadData()
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    func btnAddNewEventAction()  {
        let AddGroup = self.storyboard!.instantiateViewController(withIdentifier: "AddNewEvent") as! AddNewEventViewController
        self.navigationController!.pushViewController(AddGroup, animated: true)
    }
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        if arrEvents.count == 0 {
//            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
//            emptyLabel.text = "No events available in this group. Please add event."
//            emptyLabel.numberOfLines = 0
//            emptyLabel.textAlignment = .center
//            self.tblEvents.backgroundView = emptyLabel
//            self.tblEvents.separatorStyle = UITableViewCellSeparatorStyle.none
//        }
//        else{
//            self.tblEvents.backgroundView = nil
//        }
        return arrEvents.count + 1
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell:GroupCell = tableView.dequeueReusableCell(withIdentifier: "GroupCell") as! GroupCell
            return cell
        }
        let cell:EventCell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventCell
        let currentEvent = arrEvents.object(at: indexPath.row-1) as! Events
        
        cell.lblEventTitle.text = currentEvent.eventTitle
        cell.lblEventDescription.text = currentEvent.eventDescription
 
        let todoItem = TodoItem(deadline: currentEvent.eventDate as! Date, title: currentEvent.eventTitle!, UUID: "",description:currentEvent.eventDescription!,contacts:currentEvent.contacts!)
        if (todoItem.isOverdue) { // the current time is later than the to-do item's deadline
            cell.lblEventDate?.textColor = UIColor.red
        } else {
            cell.lblEventDate?.textColor = UIColor.black // we need to reset this because a cell with red subtitle may be returned by dequeueReusableCellWithIdentifier:indexPath:
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd yyyy h:mm a" // example: "Due Jan 01 at 12:00 PM"
        cell.lblEventDate?.text = dateFormatter.string(from: todoItem.deadline as Date)
        cell.lblEventDate?.adjustsFontSizeToFitWidth = true
        
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.row == 0 {
            return false
        }
        return true
    }


   func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
   //     let cell:EventCell = self.tblEvents.cellForRow(at: editActionsForRowAt as IndexPath) as! EventCell

        let edit = UITableViewRowAction(style: .normal, title: "       ") { action, index in
            print("Edit button tapped")
            
            let AddGroup = self.storyboard!.instantiateViewController(withIdentifier: "AddNewEvent") as! AddNewEventViewController
            AddGroup.selectedEvent = self.arrEvents.object(at: editActionsForRowAt.row-1) as! Events
            self.navigationController!.pushViewController(AddGroup, animated: true)
        }
        edit.backgroundColor = UIColor(patternImage: UIImage(named: "edit")!)
        

        let delete = UITableViewRowAction(style: .normal, title: "       ") { action, index in
            print("Delete button tapped")
            
            showAlertWithTitle(title: "Delete Event", message: "Are you sure?", forTarget: self, buttonOK: "OK" , buttonCancel: "Cancel", alertOK: { (okTitle:String) in

                let selectedEvent = self.arrEvents.object(at: editActionsForRowAt.row-1) as! Events
                self.arrEvents.removeObject(at: editActionsForRowAt.row-1)
                self.tblEvents.reloadData()

                let todoItem = TodoItem(deadline: selectedEvent.eventDate as! Date, title: selectedEvent.eventTitle!, UUID: "",description:selectedEvent.eventDescription!,contacts:selectedEvent.contacts!)

                TodoList.sharedInstance.removeItem(todoItem)
                managedContext.delete(selectedEvent)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
            }, alertCancel: { Void in
                
            })
            return;
        }
    delete.backgroundColor = UIColor(patternImage:UIImage(named: "delete")!)
    
        return [ delete, edit]
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 64.0;//Choose your custom row height
    }

    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let AddGroup = self.storyboard!.instantiateViewController(withIdentifier: "AddNewEvent") as! AddNewEventViewController
            self.navigationController!.pushViewController(AddGroup, animated: true)
            
        }
        else{
            let currentEvent = arrEvents.object(at: indexPath.row-1) as! Events
            
            let AddGroup = self.storyboard!.instantiateViewController(withIdentifier: "EventDetailsViewController") as! EventDetailsViewController
            AddGroup.selectedEvent = currentEvent
            self.navigationController!.pushViewController(AddGroup, animated: true)
        }
    }

}
