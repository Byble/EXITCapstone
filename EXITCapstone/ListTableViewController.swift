//
//  ListTableViewController.swift
//  EXITCapstone
//
//  Created by 김민국 on 2018. 7. 17..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {

    var APIData: [Place] = []{
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return APIData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "dest"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default, reuseIdentifier: id)
        cell.selectionStyle = .none

        let name = APIData[indexPath.row]
        cell.textLabel?.text = name.name
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 11)
        cell.textLabel?.textAlignment = .right
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reveal = self.revealViewController()
        let front = reveal?.frontViewController as! MapViewController
        front.selectedInx = indexPath.row
        self.revealViewController()?.revealToggle(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
