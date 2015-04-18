//
//  LocationTestViewController.swift
//  gofa
//
//  Created by Andrew Grant on 4/16/15.
//  Copyright (c) 2015 gprod. All rights reserved.
//

import Foundation

class LocationTestViewController: UIViewController {

    var index = 0
    var regionLabels: [UILabel] = []
    
    override func viewDidLoad() {
        
        var testLabel = UILabel()
        testLabel.text = "TESTS"
        testLabel.sizeToFit()
        self.view.addSubview(testLabel)
        testLabel.center.x = self.view.center.x
        testLabel.center.y = CGFloat(50 + 10 * self.index)
        
        NSNotificationCenter.defaultCenter().addObserverForName("regionEntered", object: nil, queue: nil) { (notif) -> Void in
            println("got notif")
            var regionInfo = notif.userInfo as [String: String!]
            var regionName = regionInfo["region"] as String!
            var regionLabel = UILabel()
            regionLabel.text = regionName
            regionLabel.sizeToFit()
            self.view.addSubview(regionLabel)
            regionLabel.center.x = self.view.center.x
            regionLabel.center.y = CGFloat(100 + 10 * self.index)
            self.regionLabels.append(regionLabel)
            self.index = self.index + 1
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName("regionExited", object: nil, queue: nil, usingBlock: { (notif) -> Void in
        println("got notif")
        var regionInfo = notif.userInfo as [String: String!]
        var regionName = regionInfo["region"] as String!
        let alertController = UIAlertController(title: "Hello!", message: "You exited a marked region " + regionName, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
        })
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated:true, completion:nil)
        })

    }
  
    

}