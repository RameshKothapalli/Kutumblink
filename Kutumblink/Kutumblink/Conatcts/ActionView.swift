//
//  ActionView.swift
//  sampleContacts
//
//  Created by Apple on 06/02/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

protocol ActionViewDelegate {
    func ActionButton(actionType: String)
}
class ActionView: UIView ,UITableViewDelegate,UITableViewDataSource{

    var tblActions:UITableView!
    var delegate: ActionViewDelegate?
    var arrActions:NSMutableArray = []
    var arrActionImages:NSMutableArray = []

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    func designScreen(arrActions:NSMutableArray,arrActionImages:NSMutableArray)  {
        
        self.arrActions = arrActions
        self.arrActionImages = arrActionImages

        tblActions = UITableView (frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        tblActions.backgroundColor = UIColor.clear
        tblActions.isScrollEnabled = false
        tblActions.delegate = self
        tblActions.dataSource = self
        tblActions.separatorStyle = .singleLine
        self.addSubview(tblActions)
        tblActions.rowHeight = 40
        
        let cellNib = UINib(nibName: "ActionCell", bundle: nil)
        self.tblActions.register(cellNib, forCellReuseIdentifier: "ActionCell")

    }
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrActions.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ActionCell = tableView.dequeueReusableCell(withIdentifier: "ActionCell") as! ActionCell
        cell.accessoryType = .none
        cell.selectionStyle = .none
        cell.lblActionType.text = self.arrActions.object(at: indexPath.row) as? String
        cell.lblActionType.textColor = UIColor.black
        let imageName:String = self.arrActionImages.object(at: indexPath.row) as! String
        cell.imgvwType.image = UIImage(named:imageName)
        
        return cell

    }
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.delegate?.ActionButton(actionType: self.arrActions.object(at: indexPath.row) as! String)
    }

}
