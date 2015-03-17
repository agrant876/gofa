//
//  TripViewController.swift
//  gofa
//
//  Created by Andrew Grant on 2/2/15.
//  Copyright (c) 2015 gprod. All rights reserved.
//

import Foundation
import UIKit

class TripViewController: UIViewController {

    var location: String!
    var locationDict = [String: AnyObject]()
    var locationName: String!
    var locationAddress: String!
    var publicTrip = false

    
    
    var authData: FAuthData!
    var curUserName: String!
    
    
    
    @IBOutlet weak var locationLabelName: UILabel!
    
    @IBOutlet weak var locationLabelAddress: UILabel!
  
    @IBOutlet weak var timeTillArrival: UITextField!
    
    @IBOutlet weak var privateButton: UIButton!
    @IBOutlet weak var publicButton: UIButton!
    
    // hack, come back later
    @IBOutlet weak var rightButton: OBShapedButton!
    @IBOutlet weak var leftButton: OBShapedButton!
    @IBOutlet weak var topButton: OBShapedButton!
    
    
    @IBAction func selectPrivate(sender: UIButton) {
        publicTrip = false
        
        publicButton.enabled = true
        privateButton.enabled = false
        privateButton.alpha = 0.25
        publicButton.alpha = 1
        
        
    }
    
    @IBAction func selectPublic(sender: UIButton) {
        publicTrip = true
        
        publicButton.enabled = false
        privateButton.enabled = true
        publicButton.alpha = 0.25
        privateButton.alpha = 1

    }
    
    @IBAction func stepperPressed(sender: UIStepper) {
        timeTillArrival.text = "\(Int(sender.value))"
    }
    
    
    @IBAction func postTrip(sender: UIButton) {
        let date = NSDate()
        let timestamp = date.timeIntervalSince1970
    
        // time till arrival in seconds
        var seconds = (timeTillArrival.text! as NSString).integerValue * 60

        var arrivalTime = Int(ceil(timestamp)) + seconds
        
 

        Trip(userInfo: authData, locationInfo: location, arrivalTimeInfo: arrivalTime, typePublicInfo: publicTrip, destinationInfo: nil)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        // Do any additional setup after loading the view, typically from a nib.
    }
    /*
    func setupFirebase(completion:(snapshot:FDataSnapshot!)->()) {
        
        let queue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue, {
            self.locationRef = Firebase(url:"https://gofa.firebaseio.com/locations/wawa")
            self.locationRef.observeEventType(.Value, withBlock: {
                snapshot in
                println(snapshot)
                completion(snapshot: snapshot)
                // self.address = snapshot.value["address"] as? String
            })
        })
    }*/

    
    func updateUI() {
    println(self.location)
        self.locationLabelName.text = self.locationDict["name"] as? String
        self.locationLabelName.sizeToFit()
        self.locationLabelAddress.text = self.locationDict["address"] as? String
        timeTillArrival.text = "0"
        privateButton.enabled = false
        privateButton.alpha = 0.25
        rightButton.enabled = false
        leftButton.enabled = false
        topButton.enabled = false
    }
}