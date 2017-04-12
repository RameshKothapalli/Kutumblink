//
//  DefaultGroupsViewController.swift
//  Kutumblink
//
//  Created by Apple on 08/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

protocol  DefaultGroupsViewControllerDelegate{
    func updateGroupDetails(groupName: String)
}

class DefaultGroupsViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {

    var delegate: DefaultGroupsViewControllerDelegate?
    let arrGroups:NSMutableArray = ["Family","Extended Family","Cousins","All Relatives","Friends","Work Friends","Neighbors","Party Friends"]
    
    
    @IBOutlet weak var tblGroups: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Groups"
        self.navigationController?.navigationBar.barTintColor = navigationBarColor

        // Do any additional setup after loading the view.
        tblGroups.delegate = self
        tblGroups.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrGroups.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:GroupCell = tableView.dequeueReusableCell(withIdentifier: "GroupCell") as! GroupCell
        
        cell.lblGroupName.text = arrGroups.object(at: indexPath.row) as? String
        cell.imgvwGroup.image = UIImage (named: arrGroups.object(at: indexPath.row ) as! String)
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.delegate?.updateGroupDetails(groupName: arrGroups.object(at: indexPath.row) as! String)
        self.navigationController?.popViewController(animated: true)
    }

}
