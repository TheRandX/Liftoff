//
//  LaunchInfoViewController.swift
//  Liftoff
//
//  Created by Pavol Margitfalvi on 15/08/2017.
//  Copyright © 2017 Pavol Margitfalvi. All rights reserved.
//

import UIKit
import Alamofire
import ExpandableCell

class LaunchInfoTableViewController: UITableViewController, ExpandableDelegate {
    
    var launchItem: Launch!
    
    let dateFormatter = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy, HH:mm:ss"
        return dateFormatter
    }()
    
    @IBOutlet weak var missionLabel: UILabel!
    @IBOutlet weak var missionDescriptionLabel: UILabel!
    @IBOutlet weak var missionTypeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var rocketLabel: UILabel!
    @IBOutlet weak var windowLabel: UILabel!
    @IBOutlet weak var rocketInfoLabel: UILabel!
    
    @IBOutlet var headerCells: [ExpandableCell]!
    @IBOutlet var infoCells: [UITableViewCell]!
    
    private let sentenceCap: Int = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get article text form wiki info manager
        WikiInfoManager.getArticleText(articleURL: (launchItem.rocket?.wikiURL)!) { [weak self] articleText in
            
            if let text = articleText {
                
                //var sentences = text.components(separatedBy: ". ")
                
                //sentences.removeSubrange((self?.sentenceCap)!..<sentences.count)
                
                self?.rocketInfoLabel.text = text
            }
            
        }
        
        // Do any additional setup after loading the view.
        launchItemSet()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func launchItemSet() {
        
        let nib = UINib(nibName: "InfoCells", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        
        for cell in infoCells {
            cell.awakeFromNib()
        }
        
        self.title = launchItem.rocketName
        missionLabel.text = launchItem.missionName
        missionDescriptionLabel.text = launchItem.missions?.first?.description
        missionTypeLabel.text = launchItem.missions?.first?.typeName
        locationLabel.text = launchItem.location?.pads?.first?.name
        
        rocketLabel.text = launchItem.rocket?.name
        
        
        var windowText = dateFormatter.string(from: launchItem.windowstart)
        
        if launchItem.windowstart != launchItem.windowend {
            windowText.append(" - \(dateFormatter.string(from: launchItem.windowend))")
        }
        
        windowLabel.text = windowText
        
        view.setNeedsLayout()
    }
    
    
    // Delegate methods
    func expandableTableView(_ expandableTableView: ExpandableTableView, heightsForExpandedRowAt indexPath: IndexPath) -> [CGFloat]? {
        return [CGFloat(300)]
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, expandedCellsForRowAt indexPath: IndexPath) -> [UITableViewCell]? {
        return [infoCells[indexPath.row]]
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (headerCells.count <= indexPath.row) {
            return headerCells[indexPath.row]
        } else {
            return headerCells[0]
        }
    }
    
}

