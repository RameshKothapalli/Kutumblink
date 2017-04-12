//
//  SideMenuView.swift
//  Kutumblink
//
//  Created by Apple on 13/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class SideMenuView: UIView ,UITableViewDelegate,UITableViewDataSource{

    var arrActions:NSMutableArray = []

    func screenDesign()  {
        
        arrActions = ["Send SMS","Send E-mail","Add to Group","Remove from Group","Add Event","E-mail Contacts Info"]

        let tableView:UITableView!

        tableView = UITableView (frame: CGRect (x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        tableView.backgroundColor = UIColor.red
        self.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        let cellNib = UINib(nibName: "ActionCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "ActionCell")

    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrActions.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ActionCell = tableView.dequeueReusableCell(withIdentifier: "ActionCell") as! ActionCell
        cell.accessoryType = .none
        cell.selectionStyle = .none
        cell.lblActionType.text = arrActions.object(at: indexPath.row) as? String
        cell.lblActionType.textColor = UIColor.black
        
        return cell
        
    }
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }


}
