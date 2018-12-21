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
import EventKit
import MapKit
import MarqueeLabel

class LaunchInfoViewController: UIViewController, UIViewControllerTransitioningDelegate, SegmentedDataSource, SegmentedDelegate {
    
    var launchItem: Launch!
    private let eventStore = EKEventStore()
    private var image: UIImage?
    
    private let timeUnits: Set<Calendar.Component> = [.day, .hour, .minute, .second]
    
    private let dateFormatter = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy, HH:mm:ss"
        return dateFormatter
    }()
    
    private let intervalFormatter = { () -> DateComponentsFormatter in
        let intervalFormatter = DateComponentsFormatter()
        intervalFormatter.allowedUnits = [.hour, .minute]
        intervalFormatter.unitsStyle = .positional
        intervalFormatter.zeroFormattingBehavior = .pad
        return intervalFormatter
    }()
    
    @IBOutlet weak var locationLabel: MarqueeLabel!
    @IBOutlet weak var rocketLabel: UILabel!
    @IBOutlet weak var countdownView: TimeCellView!
    @IBOutlet weak var notificationButton: UIButton!
    
    @IBOutlet var segmentedViews: [UIView]!
    
    private var missionDescription: String?
    private var missionType: String?
    
    // These two properties are queried from the internet and therefore need a property observer to update them
    private var rocketInfo: String? { didSet{ updateSegmentedViews() }}
    private var rocketImage: UIImage? { didSet{ updateSegmentedViews() }}
    
    
    // MARK: Constants
    private let notificationIconName = "notification_bell"
    private let triggeredNotificationIconName = "notification_bell_triggered"
    private let labelScrollRate: CGFloat = 40
    private let sentenceCap: Int = 3
    private let buttonImageWidth: CGFloat = 30
    
    // MARK: Primitive variables
    private var activeView: Int = 0
    private var notificationSet = false
    private var launchEventIdentifier: String!
    
    
    // MARK: Life-cycle methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        runTimer()
    }
    
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
    
    // MARK: IB actions
    @IBAction func notificationClicked(_ sender: UIButton) {
        var savedSuccessfuly = false
        if !notificationSet {
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
                    strongSelf.launchEventIdentifier = event.eventIdentifier
                    savedSuccessfuly = true
                    strongSelf.notificationSet = true
                    DispatchQueue.main.async {
                        strongSelf.updateButton(triggered: true)
                    }
                } else {
                    debugPrint("Failed to save event with error : \(String(describing: error)) or access not granted")
                    
                }
            }
        } else {
            // Here is the method to delete the event
            notificationSet = false
            eventStore.requestAccess(to: .event) { [weak self] (granted, error) in
                guard let strongSelf = self else { return }
                
                if granted && error == nil {
                    debugPrint("Granted")
                    
                    if let eventToDelete = strongSelf.eventStore.event(withIdentifier: strongSelf.launchEventIdentifier) {
                        
                        do {
                            try strongSelf.eventStore.remove(eventToDelete, span: .thisEvent)
                        } catch let error {
                            debugPrint("Failed to delete event with error : \(String(describing: error)) or access not granted.")
                        }
                        
                        DispatchQueue.main.async {
                            strongSelf.updateButton(triggered: false)
                        }
                        
                    }
                    
                }
                
            }
            
        }
    }
    
    @IBAction func switchView(_ sender: UISegmentedControl) {
        animateViewSwitch(withDuration: 0.5, showView: sender.selectedSegmentIndex)
    }
    
    @IBAction func tapRecognized(_ sender: UITapGestureRecognizer) {
        if segmentedViews[activeView].bounds.contains(sender.location(in: segmentedViews[activeView])) {
            var segue = "presentMission"
            switch activeView {
            case 0:
                break
            case 1:
                segue = "presentRocket"
            case 2:
                segue = "presentLocation"
            default:
                return
            }
            performSegue(withIdentifier: segue, sender: nil)
        }
    }
    
    // MARK: Overriden methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "embedSegmented", "presentMission", "presentRocket", "presentLocation":
                if let destinationVC = segue.destination as? SegmentedViewController {
                    destinationVC.dataSource = self
                    destinationVC.delegate = self
                }
                switch identifier {
                case "presentMission", "presentRocket", "presentLocation":
                    let vc = segue.destination
                    
                    // Retrieve the content view (tag set in IB to 255)
                    if let _ = vc.view.viewWithTag(255) {
                        if let vc = vc as? SegmentedViewController {
                            vc.view.backgroundColor = UIColor(red:0.33, green:0.33, blue:0.33, alpha:0.33)
                            vc.blurViewHeight.constant = rocketLabel.bounds.maxY + (navigationController?.navigationBar.bounds.maxY ?? 0) + 30
                            vc.tapRecognizer.isEnabled = true
                        }
                    }
                default:
                    return
                }
            default:
                return
            }
        }
    }
    
    // MARK: Private methods
    private func launchItemSet() {
        
        // Sort the outlet collection by tag order
        segmentedViews.sort(by: { $0.tag < $1.tag })
        
        title = launchItem.rocketName
        //////missionLabel.text = launchItem.missionName
        missionDescription = launchItem.missions?.first?.description
        missionType = launchItem.missions?.first?.typeName
        
        // Run the timer that initialises and updates the countdown view
        runTimer()
        
        // Set up the scrolling location label
        locationLabel.animationCurve = .linear
        locationLabel.type = .continuous
        locationLabel.speed = .rate(labelScrollRate)
        locationLabel.text = launchItem.location?.pads?.first?.name
        
        let bellIcon = UIImage(named: notificationIconName)
        notificationButton.setTitle(nil, for: .normal)
        notificationButton.setImage(bellIcon?.renderResizedImage(newWidth: buttonImageWidth), for: .normal)
        
        
        rocketLabel.text = launchItem.rocket?.name
        
        var windowText = dateFormatter.string(from: launchItem.windowstart)
        
        if launchItem.windowstart != launchItem.windowend {
            windowText.append(" - \(dateFormatter.string(from: launchItem.windowend))")
        }
        
        view.setNeedsLayout()
    }
    
    private func updateButton(triggered: Bool) {
        var icon: UIImage? = nil
        if triggered {
            icon = UIImage(named: triggeredNotificationIconName)
        } else {
            icon = UIImage(named: notificationIconName)
        }
        notificationButton.setImage(icon?.renderResizedImage(newWidth: buttonImageWidth), for: .normal)
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
        
        for i in 0..<segmentedViews.count {
            if (showView == i) {
                segmentedViews[i].isHidden = false
            } else {
                segmentedViews[i].isHidden = true
            }
        }
        
        activeView = showView
    }
    
    private func rocketImage(fromURL URL: URL, completion: @escaping (Image) -> Void){
        Alamofire.request(URL).responseImage() { response in
            
            if let image = response.result.value {
                completion(image)
            }
        }
    }
    
    private func runTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
            
            guard let strongSelf = self else { return }
            
            var timeRemaining = NSCalendar.current.dateComponents(strongSelf.timeUnits, from: Date(), to: strongSelf.launchItem.date)
            timeRemaining.timeZone = TimeZone.current
            if let day = timeRemaining.day, let hour = timeRemaining.hour, let minute = timeRemaining.minute, let second = timeRemaining.second {
                
                strongSelf.countdownView.days.text = String(day)
                strongSelf.countdownView.hours.text = String(hour)
                strongSelf.countdownView.minutes.text = String(minute)
                strongSelf.countdownView.seconds.text = String(second)
            }
        }
    }
    
    // MARK: Transitioning controller delegate methods
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return VariableVerticalPresentationController(presentedViewController: presented, presenting: presentingViewController)
    }
    
    // MARK: Segmented delegate methods
    func readyToDismiss() {
        dismiss(animated: true, completion: nil)
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

extension UIImage {
    func renderResizedImage (newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        let image = renderer.image { (context) in
            self.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        }
        return image
    }
}

