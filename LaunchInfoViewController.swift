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
import MapKit

class LaunchInfoViewController: UIViewController, SegmentedDataSource {
    
    var launchItem: Launch!
    let eventStore = EKEventStore()
    var image: UIImage?
    
    let dateFormatter = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy, HH:mm:ss"
        return dateFormatter
    }()
    
    let intervalFormatter = { () -> DateComponentsFormatter in
        let intervalFormatter = DateComponentsFormatter()
        intervalFormatter.allowedUnits = [.hour, .minute]
        intervalFormatter.unitsStyle = .positional
        intervalFormatter.zeroFormattingBehavior = .pad
        return intervalFormatter
    }()
    
    //////@IBOutlet weak var missionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var rocketLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    //////@IBOutlet weak var windowLabel: UILabel!
    
    @IBOutlet var segmentedViews: [UIView]!
    
    private var missionDescription: String?
    private var missionType: String?
    
    // These two properties are queried from the internet and therefore need a property observer to update them
    private var rocketInfo: String? { didSet{ updateSegmentedViews() }}
    private var rocketImage: UIImage? { didSet{ updateSegmentedViews() }}
    
    private let sentenceCap: Int = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the rocket image if there is any
        if let imageURL = launchItem.rocket?.imageURL {
            rocketImage(fromURL: imageURL) { image in
                self.rocketImage = image
            }
        }
        
        // Get article text form wiki info manager
        WikiInfoManager.getArticleText(articleURL: (launchItem.rocket?.wikiURL)!) { [weak self] articleText in
            
            if let text = articleText {
                
                //var sentences = text.components(separatedBy: ". ")
                
                //sentences.removeSubrange((self?.sentenceCap)!..<sentences.count)
                self?.rocketInfo = text
            }
            
        }
        
        // Do any additional setup after loading the view.
        launchItemSet()
        updateSegmentedViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func launchItemSet() {
        
        // Sort the outlet collection by tag order
        segmentedViews.sort(by: { $0.tag < $1.tag })
        
        title = launchItem.rocketName
        //////missionLabel.text = launchItem.missionName
        missionDescription = launchItem.missions?.first?.description
        missionType = launchItem.missions?.first?.typeName
        locationLabel.text = launchItem.location?.pads?.first?.name
        timeRemainingLabel.text = "T- " + (intervalFormatter.string(from: launchItem.date.timeIntervalSinceNow) ?? "Error")
        
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
    
    @IBAction func switchView(_ sender: UISegmentedControl) {
        animateViewSwitch(withDuration: 0.5, showView: sender.selectedSegmentIndex)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "embedSegmented":
                if let destinationVC = segue.destination as? SegmentedViewController {
                    destinationVC.dataSource = self
                }
            default:
                return
            }
        }
    }
    
    private func updateSegmentedViews() {
        for child in children {
            if let childVC = child as? SegmentedViewController {
                childVC.viewWillAppear(true)
            }
        }
    }
    
    private func animateViewSwitch(withDuration duration: TimeInterval, showView: Int) {
        
        UIView.animate(withDuration: duration, animations: {
            for i in 0..<self.segmentedViews.count {
                if (showView == i) {
                    self.segmentedViews[i].alpha = 1
                } else {
                    self.segmentedViews[i].alpha = 0
                }
            }
        })
    }
    
    private func rocketImage(fromURL URL: URL, completion: @escaping (Image) -> Void){
        Alamofire.request(URL).responseImage() { response in
            
            if let image = response.result.value {
                completion(image)
            }
        }
    }
    
    // MARK: Data source methods
    
    func missionData(missionType: UILabel!, missionDescription: UILabel!) {
        missionType.text = self.missionType
        missionDescription.text = self.missionDescription
    }
    
    func rocketData(rocketInfo: UILabel!, rocketImage: UIImageView!) {
        rocketInfo.text = self.rocketInfo
        rocketImage.image = self.rocketImage
    }
    
    func locationData(locationView: MKMapView!) {
        return
    }
    
}

