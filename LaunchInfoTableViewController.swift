//
//  LaunchInfoViewController.swift
//  Liftoff
//
//  Created by Pavol Margitfalvi on 15/08/2017.
//  Copyright © 2017 Pavol Margitfalvi. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import ExpandableCell

class LaunchInfoTableViewController: UITableViewController, ExpandableDelegate {
    
    var launchItem: Launch!
    
    var image: UIImage?
    
    let dateFormatter = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy, HH:mm:ss"
        return dateFormatter
    }()
    
    @IBOutlet weak var rocketImage: UIImageView!
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
        
        // Get the rocket image if there is any
        if let imageURL = launchItem.rocket?.imageURL {
            rocketImage(fromURL: imageURL) { image in
                self.rocketImage.image = image
            }
        }
        
        // Get article text form wiki info manager
        WikiInfoManager.getArticleText(articleURL: (launchItem.rocket?.wikiURL)!) { [weak self] articleText in
            
            if let text = articleText {
                
                //var sentences = text.components(separatedBy: ". ")
                
                //sentences.removeSubrange((self?.sentenceCap)!..<sentences.count)
                
                self?.rocketInfoLabel.text = text
            }
            
        }
        
        if let expandableTableView = tableView as? ExpandableTableView {
            expandableTableView.expandableDelegate = self
        }
        
        // Do any additional setup after loading the view.
        launchItemSet()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func launchItemSet() {
        
        // Instantiate the info cells nib file
        let nib = UINib(nibName: "InfoCells", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        /*
         for cell in infoCells {
         cell.awakeFromNib()
         }*/
        
        
        title = launchItem.rocketName
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
        return headerCells[indexPath.section].frame.height
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, expandedCellsForRowAt indexPath: IndexPath) -> [UITableViewCell]? {
        for header in headerCells {
            header.close()
        }
        if let result = infoCells?[indexPath.section] {
            let arr: [UITableViewCell]? = [result]
            return arr
        } else {
            return nil
        }
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (headerCells.count > indexPath.section) {
            return headerCells[indexPath.section]
        } else {
            return headerCells[0]
        }
    }
    
    func numberOfSections(in expandableTableView: ExpandableTableView) -> Int {
        return headerCells.count
    }
    
    private func rocketImage(fromURL URL: URL, completion: @escaping (Image) -> Void){
        Alamofire.request(URL).responseImage() { response in
            
            if let image = response.result.value {
                completion(image)
            }
        }
    }
    
}

