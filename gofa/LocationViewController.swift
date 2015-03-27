//
//  LocationViewController.swift
//  gofa
//
//  Created by Andrew Grant on 2/6/15.
//  Copyright (c) 2015 gprod. All rights reserved.
//

import Foundation
import UIKit

class LocationViewController: UIViewController {

    var location: String!
    var locationDict = [String: AnyObject]()
    var locationName: String!
    var locationAddress:String!
    
    var authData: FAuthData!
    var curUserName: String!
    var curUser: String!
    
    var currentTrips: [String :Int]?
    var trips = [String]()
    
    // trip identifiers for buttons
    var tripOne: String!
    var tripTwo: String!
    var tripThree: String!
    
    
    
    let urlpinguser = "http://localhost:3000/pingUser"
    
    @IBOutlet weak var userOne: UILabel!
    @IBOutlet weak var userTwo: UILabel!
    @IBOutlet weak var userThree: UILabel!
    
    @IBOutlet weak var timeOne: UILabel!
    
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var pingResponse: UILabel!
    
    // USER INTERACTION
    
    // press button (ping user, basic)
    @IBAction func selectTrip(sender: OBShapedButton) {
        if sender.tag == 1 {
            var tripIdentifier = tripOne
            pingUser(tripIdentifier)
        }
    }
    
    func pingUser(tripid: String!) {

        // set up request
        var requestInfo:NSDictionary = ["userid": self.curUser, "tripid": tripid]
        //println(NSJSONSerialization.isValidJSONObject(requestInfo))
        
        var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        
        let url = NSURL(string: urlpinguser)
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "POST"
        req.HTTPBody = requestData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //println(req.HTTPBody)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config);
        
        let serverTask = session.dataTaskWithRequest(req, { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                var feedback: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as NSDictionary
                //println(feedback)
                var status = feedback["status"] as String!
                if (status == "success") {
                    self.pingResponse.text = "successfully sent"
                    println("successfully sent to Brian")
                }
            } else {
                println(error)
                println("nope")
            }
        })
        
        serverTask.resume()
    }
    
    func setupFirebase()
    {
        let locRef = Firebase(url: "https://gofa.firebaseio.com/locations/" + location)
        let locTripsRef = locRef.childByAppendingPath("trips")
        locTripsRef.observeEventType(.Value, withBlock: {
            snapshot in
            self.currentTrips = snapshot.value as? Dictionary
            if self.currentTrips == nil {
                self.updateUI()
            } else {
                var index = 0
                // for every trip at location
                for (tripIdentifier, toa) in self.currentTrips! {
                    let date = NSDate()
                    let timestamp = date.timeIntervalSince1970
                    println("\(timestamp)")
                    
                    // if the toa has passed, remove the trip
                    if (Int(timestamp) > toa) {
                        Firebase(url: "https://gofa.firebaseio.com/trips/\(tripIdentifier)").removeValue()
                        Firebase(url: "https://gofa.firebaseio.com/locations/\(self.location)/trips/\(tripIdentifier)").removeValue()
                    } else {
                        println("\(tripIdentifier)")
                        self.trips.append(tripIdentifier)
                        self.tripOne = tripIdentifier as String
                    }
                }
                self.updateUI()
            }
        })
    }
   
    func updateUI() {
        
        if currentTrips == nil {
            infoLabel.text = "Sorry, no trips right now!"
        } else {
            let tripRef = Firebase(url: "https://gofa.firebaseio.com/trips/" + trips[0])
            
            // display trip "owner"
            tripRef.childByAppendingPath("user").observeEventType(.Value, withBlock: {
                    snapshot in
                    var user = snapshot.value as String!
                    let userRef = Firebase(url: "https://gofa.firebaseio.com/users/" + user + "/username")
                    userRef.observeEventType(.Value, withBlock: {
                        snapshot in
                        var username = snapshot.value as String!
                        self.userOne.text = username
                    })
            })
        
            // display Time till Arrival (toa - current time)
            tripRef.childByAppendingPath("toa").observeEventType(.Value, withBlock: {
                snapshot in
                var toa = snapshot.value as Int!
                let date = NSDate()
                let timestamp = date.timeIntervalSince1970
                println("\(timestamp)")
                println("\(toa)")
                toa = (toa - Int(ceil(timestamp)))
                // display in minutes and round down
                toa = Int(floor(Double(toa) / 60.0))
                self.timeOne.text = "\(toa)"
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.curUser = self.authData.uid
        setupFirebase()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "goto_bag" {
            var newBagVC = BagViewController()
            newBagVC = segue.destinationViewController as BagViewController
            newBagVC.authData = self.authData
            newBagVC.curUserName = self.curUserName
            newBagVC.location = self.location
            newBagVC.locationName = self.locationDict["name"] as String!
            println(locationDict)
            //newBagVC.locationName = "Wawa"
        }
    }


}