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
import EventKit

class LaunchInfoViewController: UIViewController {
    
    var launchItem: Launch!
    let eventStore = EKEventStore()
    var image: UIImage?
    
    let dateFormatter = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy, HH:mm:ss"
        return dateFormatter
    }()
    
    @IBOutlet weak var rocketImage: UIImageView!
    //////@IBOutlet weak var missionLabel: UILabel!
    @IBOutlet weak var missionDescriptionLabel: UILabel!
    @IBOutlet weak var missionTypeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var rocketLabel: UILabel!
    //////@IBOutlet weak var windowLabel: UILabel!
    @IBOutlet weak var rocketInfoLabel: UILabel!
    
    @IBOutlet weak var sectionParentView: UIView!
    @IBOutlet var missionView: UIView!
    @IBOutlet var rocketView: UIView!
    @IBOutlet var locationView: UIView!
    
    
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
        
        // Instantiate the info cells nib file
        let nib = UINib(nibName: "InfoCells", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        
        sectionParentView.addSubview(missionView)
        sectionParentView.addSubview(rocketView)
        sectionParentView.addSubview(locationView)
        
        rocketView.isHidden = true
        locationView.isHidden = true
        
        var constraint = NSLayoutConstraint(item: missionView, attribute: .top, relatedBy: .equal, toItem: sectionParentView, attribute: .top, multiplier: 1, constant: 0)
        sectionParentView.addConstraint(constraint)
        constraint = NSLayoutConstraint(item: missionView, attribute: .right, relatedBy: .equal, toItem: sectionParentView, attribute: .right, multiplier: 1, constant: 0)
        sectionParentView.addConstraint(constraint)
        constraint = NSLayoutConstraint(item: missionView, attribute: .bottom, relatedBy: .equal, toItem: sectionParentView, attribute: .bottom, multiplier: 1, constant: 0)
        sectionParentView.addConstraint(constraint)
        constraint = NSLayoutConstraint(item: missionView, attribute: .left, relatedBy: .equal, toItem: sectionParentView, attribute: .left, multiplier: 1, constant: 0)
        sectionParentView.addConstraint(constraint)
        
        
        
        // Do any additional setup after loading the view.
        launchItemSet()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func launchItemSet() {
        
        title = launchItem.rocketName
        //////missionLabel.text = launchItem.missionName
        missionDescriptionLabel.text = launchItem.missions?.first?.description
        missionTypeLabel.text = launchItem.missions?.first?.typeName
        locationLabel.text = launchItem.location?.pads?.first?.name
        
        rocketLabel.text = launchItem.rocket?.name
        
        
        var windowText = dateFormatter.string(from: launchItem.windowstart)
        
        if launchItem.windowstart != launchItem.windowend {
            windowText.append(" - \(dateFormatter.string(from: launchItem.windowend))")
        }
        
        //////windowLabel.text = windowText
        view.setNeedsLayout()
    }
    
    @IBAction func notificationClicked(_ sender: UIButton) {
        eventStore.requestAccess(to: .event) { [weak self] (granted, error) in
            guard let strongSelf = self else {
                return
            }
            
            if (granted && error == nil) {
                debugPrint("Granted")
                let event = EKEvent(eventStore: strongSelf.eventStore)
                event.title = strongSelf.launchItem.rocketName + " launch"
                event.startDate = strongSelf.launchItem.date
                event.endDate = strongSelf.launchItem.date
                event.notes = strongSelf.launchItem.missions?.first?.description
                event.calendar = strongSelf.eventStore.defaultCalendarForNewEvents
                
                // This might crash (but shouldnt)
                let alarm = EKAlarm(relativeOffset: TimeInterval(exactly: -3600)!)
                event.addAlarm(alarm)
                do {
                    try strongSelf.eventStore.save(event, span: .thisEvent)
                } catch let error {
                    debugPrint("Failed to save event with error : \(error)")
                }
                
                debugPrint("Saved successfully!")
            } else {
                debugPrint("Failed to save event with error : \(String(describing: error)) or access not granted")
                
            }
        }
    }
    
    @IBAction func switchView(_ sender: Any) {
        
        
        
    }
    
    private func rocketImage(fromURL URL: URL, completion: @escaping (Image) -> Void){
        Alamofire.request(URL).responseImage() { response in
            
            if let image = response.result.value {
                completion(image)
            }
        }
    }
    
}

