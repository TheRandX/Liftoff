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
    
    private let store: LaunchStore = LaunchStore()
    private var selectedLaunch: Launch?
    private let dateFormatter = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LaunchManager.getLaunches(mode: "verbose", options: nil) { [weak self] optLaunches in
            guard let strongSelf = self, let launches = optLaunches else { return }
            strongSelf.store.items = launches
            strongSelf.store.sortItems()
            strongSelf.tableView.reloadData()
        }
        
        // Get the height of the status bar
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        // Create insets so the status bar and table view dont clip
        let insets = UIEdgeInsets(top: statusBarHeight, left: 0, bottom: 0, right: 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
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
        
        // Set the date
        cell.date.text = dateFormatter.string(from: item.date)
        cell.rocketName.text = item.rocketName
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedLaunch = store.items[indexPath.row]
        performSegue(withIdentifier: "launchInfo", sender: self)
        selectedLaunch = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "launchInfo":
                if let dvc = segue.destination.contentViewController as? LaunchInfoViewController {
                    if let launch = selectedLaunch {
                        dvc.launchItem = launch
                    }
                }
            default:
                break
            }
        }
    }
    
}

extension UIViewController {
    var contentViewController: UIViewController {
        if let nvc = self as? UINavigationController {
            return nvc.visibleViewController ?? self
        }
        else {
            return self
        }
    }
}
