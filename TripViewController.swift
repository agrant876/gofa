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

    var locationid: String!
    var locationDict = [String: AnyObject]()
    var locationName: String!
    var locationAddress: String!
    var publicTrip = false

    var authData: FAuthData!
    var curUser: String!
    var curUserName: String!
    
    let urlposttrip = "http://localhost:3000/postTrip"
    
    
    @IBOutlet weak var locationLabelName: UILabel!
    
    @IBOutlet weak var locationLabelAddress: UILabel!
  
    @IBOutlet weak var timeTillArrival: UITextField!
    
    
    @IBOutlet weak var posteditButton: UIButton!
    @IBOutlet weak var tripPostedLabel: UILabel!
    
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
        
        
        var requestInfo:NSDictionary = ["userid": self.curUser, "locationid": self.locationid, "toa": arrivalTime, "public": false]
        var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urlposttrip)
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "POST"
        req.HTTPBody = requestData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config);
        let serverTask = session.dataTaskWithRequest(req, { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                var feedback: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as NSDictionary
                var status = feedback["status"] as String!
                if (status == "success") {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tripPosted()
                    })
                }
            } else {
                println(error)
                println("nope")
            }
        })
        serverTask.resume()

        // Trip(userInfo: authData, locationInfo: location, arrivalTimeInfo: arrivalTime, typePublicInfo: publicTrip, destinationInfo: nil)
    }
    
    @IBAction func backToHome(sender: UIButton) {
        let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
        let VC:ViewController = storyboard.instantiateViewControllerWithIdentifier("home") as ViewController
        self.presentViewController(VC, animated: false, completion: nil)
    }

    // this function is called when a trip was successfully posted. It does the necessary updates to the UI.
    func tripPosted() {
        self.posteditButton.titleLabel?.text = "EDIT"
        self.tripPostedLabel.hidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func updateUI() {
        self.locationLabelName.text = self.locationDict["name"] as? String
        self.locationLabelName.sizeToFit()
        self.locationLabelAddress.text = self.locationDict["address"] as? String
        timeTillArrival.text = "0"
        /*privateButton.enabled = false
        privateButton.alpha = 0.25
        rightButton.enabled = false
        leftButton.enabled = false
        topButton.enabled = false
        */
    }
}