//
//  SegmentedViewController.swift
//  Liftoff
//
//  Created by Pavol Margitfalvi on 19/12/2018.
//  Copyright © 2018 Pavol Margitfalvi. All rights reserved.
//

import UIKit

class SegmentedViewController: UIViewController {

    @IBOutlet weak var blurViewHeight: NSLayoutConstraint!
    
    var dataSource: SegmentedDataSource?
    var delegate: SegmentedDelegate?
    
    var tapRecognizer: UITapGestureRecognizer!
    
    ///////////////////////////////
    // Only for testing purposes//
    //////////////////////////////
    var longPressRecognizer: UILongPressGestureRecognizer!
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let childvc = self as? MissionViewController {
            childvc.viewWillAppear(animated)
        } else if let childvc = self as? RocketViewController {
            childvc.viewWillAppear(animated)
        } else if let childvc = self as? LocationViewController {
            childvc.viewWillAppear(animated)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapRecognized(sender: )))
        view.addGestureRecognizer(tapRecognizer)
        tapRecognizer.isEnabled = false
    }
    
    @objc func tapRecognized(sender: UITapGestureRecognizer) {
        guard let contentView = view.viewWithTag(255) else { return }
        if !contentView.frame.contains(sender.location(in: contentView)) {
            delegate?.readyToDismiss()
            tapRecognizer.isEnabled = false
        }
    }
}
