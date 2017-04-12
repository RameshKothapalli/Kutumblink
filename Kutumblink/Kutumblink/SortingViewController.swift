//
//  SortingViewController.swift
//  Kutumblink
//
//  Created by Apple on 07/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

protocol  SortingViewControllerDelegate{
    func updateSortingType(actionType: String)
}
class SortingViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tblSortOptions: UITableView!
    var delegate: SortingViewControllerDelegate?

    
    let arrSortingOptions:NSMutableArray = ["Default","By First Name","By Last Name"]
    var selectedSortingType:String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tblSortOptions.delegate = self
        tblSortOptions.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSortingOptions.count
    }
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SortingCell", for: indexPath) as UITableViewCell
        cell.accessoryType = .none
        cell.selectionStyle = .none
        cell.textLabel?.text = arrSortingOptions.object(at: indexPath.row) as? String
        cell.accessoryType = UITableViewCellAccessoryType.none
        let selectedIndex = arrSortingOptions.index(of: selectedSortingType)
        if selectedIndex == indexPath.row
        {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.delegate?.updateSortingType(actionType: (arrSortingOptions.object(at: indexPath.row) as? String)!)
        self.navigationController?.popViewController(animated: true)
    }

}
