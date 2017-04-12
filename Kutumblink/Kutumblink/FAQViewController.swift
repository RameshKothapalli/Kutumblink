//
//  FAQViewController.swift
//  Kutumblink
//
//  Created by Admin on 27/02/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class FAQViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tblFAQ: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "FAQs"
        self.navigationController?.navigationBar.barTintColor = navigationBarColor

        // Do any additional setup after loading the view.
        self.tblFAQ.delegate = self
        self.tblFAQ.dataSource = self
        
        self.tblFAQ.estimatedRowHeight = 100
        self.tblFAQ.rowHeight = UITableViewAutomaticDimension

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 5
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:FAQCell = tableView.dequeueReusableCell(withIdentifier: "FAQCell") as! FAQCell
        
        if indexPath.row == 0 {
            cell.lblQuestion.text = "1) Why are contacts not visible?"
            cell.lblAnswer.text = "Go to your phone’s settings – privacy – contacts and give access."

        }
        else if (indexPath.row == 1){
            cell.lblQuestion.text = "2) Why do I see advertisements?"
            cell.lblAnswer.text = "KutumbLink free App has advertisements and KutumbLink premium App has no advertisements."
        }
        else if (indexPath.row == 2){
            cell.lblQuestion.text = "3) How can I edit or delete a Group or an Event?"
            cell.lblAnswer.text = "Swipe left on Group/Event name or click on Group/Event name and select Edit button at top right."
        }
        else if (indexPath.row == 3){
            cell.lblQuestion.text = "4) What happens to data entered in the App?"
            cell.lblAnswer.text = "All Contacts, Groups, Events, Message Links and Photo Links input in the App stay on your phone only."
        }
        else if (indexPath.row == 4){
            cell.lblQuestion.text = "4) How can I send text or email to Group or Event contacts?"
            cell.lblAnswer.text = "Select Group contacts and click on Action dropdown and select action. Click on Action dropdown in Event Details screen and select action."
        }
 
        
        return cell
    }
}
