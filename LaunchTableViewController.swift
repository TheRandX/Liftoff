//
//  LaunchesTableView.swift
//  Liftoff
//
//  Created by Pavol Margitfalvi on 12/08/2017.
//  Copyright © 2017 Pavol Margitfalvi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LaunchTableViewController: UITableViewController {
    
    let store = LaunchStore()
    static let launchManager = LaunchManager()
    let dateFormatter = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the height of the status bar
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        // Create insets so the status bar and table view dont clip
        let insets = UIEdgeInsets(top: statusBarHeight, left: 0, bottom: 0, right: 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LaunchManager.getLaunches(mode: "verbose", options: nil) { [weak self] optLaunches in
            if let launches = optLaunches {
                self?.store.items = launches
                self?.tableView.reloadData()
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Dequeue a cell and cast it to Launch Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "launchCell", for: indexPath) as! LaunchCell
        
        // Retrieve the item from the item store
        let item = store.items[indexPath.row]
        
        // Set the date, if date is nil, set it to N/A
        if let date = item.date {
            cell.date.text = dateFormatter.string(from: date)
        } else {
            cell.date.text = "TBD"
        }
        cell.missionName.text = item.missionName
        cell.rocketName.text = item.rocketName
        
        return cell
        
        
        
    }
    
}
