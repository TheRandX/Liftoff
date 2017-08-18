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

class LaunchInfoViewController: UIViewController {
    
    var launchItem: Launch!
    
    @IBOutlet weak var rocketLabel: UILabel!
    @IBOutlet weak var missionLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var rocketImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get article text form wiki info manager
        WikiInfoManager.getArticleText(articleURL: (launchItem.rocket?.wikiURL)!) { [weak self] articleText in
            
            self?.infoTextView.text = articleText
            
        }
        
        // Get the image from the rocket object url
        Alamofire.request(launchItem.rocket!.imageURL!).responseImage() { [weak self] response in
            
            debugPrint(response)
            
            print(response.request)
            print(response.response)
            debugPrint(response.result)
            
            if let image = response.result.value {
                self?.rocketImageView.image = image
            }
            
        }

        
        // Configure info text view
        infoTextView.isScrollEnabled = false
        infoTextView.isEditable = false
        
        // Do any additional setup after loading the view.
        launchItemSet()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func launchItemSet() {
        
        rocketLabel.text = launchItem.rocketName
        missionLabel.text = launchItem.missionName
        
        view.setNeedsLayout()
    }
    
}
