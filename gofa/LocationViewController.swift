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

    var locationid: String!
    var locationDict = [String: AnyObject]()
    
    var authData: FAuthData!
    var curUserName: String!
    var curUser: String!
    
    var bagContents: String!
    
    var locTrips: [String :Int]?
    var trips = Array<NSDictionary>() //active trips' id's
    var tripInfo = Array<NSDictionary>() //trip dictionaries
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var noTripsLabel: UILabel!
    
    // is button displaying trip? anticlockwise
    var buttontrip1 = false
    var buttontrip2 = false
    var buttontrip3 = false

    let urlkind = "gofa-app.com"
    var urlremovetrip: String!
    var urlgettrips: String!
    var urlgettripinfo: String!
    var urlgetbag: String!
    
    @IBOutlet weak var user1: UILabel!
    @IBOutlet weak var user2: UILabel!
    @IBOutlet weak var user3: UILabel!
    
    @IBOutlet weak var time1: UILabel!
    @IBOutlet weak var time2: UILabel!
    @IBOutlet weak var time3: UILabel!
    
    @IBOutlet weak var min1: UILabel!
    @IBOutlet weak var min2: UILabel!
    @IBOutlet weak var min3: UILabel!
    
    @IBOutlet weak var topButton: OBShapedButton!
    @IBOutlet weak var leftButton: OBShapedButton!
    @IBOutlet weak var rightButton: OBShapedButton!
    
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var pingResponse: UILabel!
    
    // USER INTERACTION
    
    @IBOutlet weak var confirmationView: UIImageView!

    // press button (ping user, basic)
    @IBAction func selectTrip(sender: OBShapedButton) {
        let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
        let confirmVC:ConfirmationViewController = storyboard.instantiateViewControllerWithIdentifier("confirm") as ConfirmationViewController
        confirmVC.curUser = self.curUser
        confirmVC.curUserName = self.curUserName
        confirmVC.locationid = self.locationid
        confirmVC.locationName = self.locationDict["name"] as String!
        confirmVC.locationDict = self.locationDict
        
        if sender.tag == 1 {
            if (buttontrip1) {
                println(buttontrip1)
                var trip = trips[0] as NSDictionary
                confirmVC.tripid = trip["tripid"] as String
                confirmVC.tripInfo = tripInfo[0]
                self.presentViewController(confirmVC, animated: false, completion: nil)
            }
        }
        if sender.tag == 2 {
            if (buttontrip2) {
                var trip = trips[1] as NSDictionary
                confirmVC.tripid = trip["tripid"] as String
                confirmVC.tripInfo = tripInfo[1]
                self.presentViewController(confirmVC, animated: false, completion: nil)
            }
        }
        if sender.tag == 3 {
            if (buttontrip3) {
                var trip = trips[2] as NSDictionary
                confirmVC.tripid = trip["tripid"] as String
                confirmVC.tripInfo = tripInfo[2]
                self.presentViewController(confirmVC, animated: false, completion: nil)
            }
        }
        
    }
    
    @IBAction func viewBag(sender: OBShapedButton) {
        let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
        let bagVC:BagViewController = storyboard.instantiateViewControllerWithIdentifier("bag") as BagViewController
        bagVC.curUser = self.curUser
        bagVC.curUserName = self.curUserName
        bagVC.location = self.locationid
        bagVC.locationName = self.locationDict["name"] as String!
        bagVC.locationDict = self.locationDict

        self.presentViewController(bagVC, animated: false, completion: nil)
    }
    
    @IBAction func home(sender: UIButton) {
        let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
        let VC:ViewController = storyboard.instantiateViewControllerWithIdentifier("home") as ViewController
        self.presentViewController(VC, animated: false, completion: nil)
    }
    
    //remove trip and associated PENDING transactions
    func removeTrip(tripid: String!) {
        var requestInfo:NSDictionary = ["tripid": tripid]
        var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urlremovetrip)
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
                    println("successfully deleted trips and pending transactions")
                }
            } else {
                println(error)
                println("nope")
            }
        })
        
        serverTask.resume()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var locName = self.locationDict["name"] as String!
        locName.replaceRange(locName.startIndex...locName.startIndex, with: String(locName[locName.startIndex]).capitalizedString)
        self.locationLabel.text = locName
   
        self.urlremovetrip = "http://" + urlkind + "/removeTrip"
        self.urlgettrips = "http://" + urlkind + "/getTrips"
        self.urlgettripinfo = "http://" + urlkind + "/getTripInfo"
        self.urlgetbag = "http://" + urlkind + "/getbag"
        getBagContents()
        getTrips()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goto_bag" {
            var newBagVC = BagViewController()
            newBagVC = segue.destinationViewController as BagViewController
            newBagVC.authData = self.authData
            newBagVC.curUserName = self.curUserName
            newBagVC.location = self.locationid
            newBagVC.locationName = self.locationDict["name"] as String!
            println(locationDict)
            //newBagVC.locationName = "Wawa"
        }
    }
    
    func getBagContents() {
        println(self.locationid)
        var bagInfo = ["userid": self.curUser, "locationid": self.locationid]
        var bagData = NSJSONSerialization.dataWithJSONObject(bagInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urlgetbag)
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "POST"
        req.HTTPBody = bagData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config);
        let serverTask = session.dataTaskWithRequest(req, { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                var feedback: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as NSDictionary
                self.bagContents = feedback["contents"] as? String
                println("successfully got bag")
            } else {
                println(error)
                println("nope")
            }
        })
        serverTask.resume()
    }
    
    func getTrips() {
        var requestInfo:NSDictionary = ["locationid": self.locationid]
        var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urlgettrips)
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "POST"
        req.HTTPBody = requestData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        println(req.HTTPBody)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config);
        let serverTask = session.dataTaskWithRequest(req, { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                var feedback: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as NSDictionary
                var status = feedback["status"] as String!
                if (status == "success") {
                    println("successfully retrieved trips")
                    println(feedback["trips"])
                    self.trips = feedback["trips"] as Array
                    if self.trips.count > 0 {
                        //display trips
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.displayTrips()
                        })
                    } else {
                        //display no trips
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.noTripsLabel.hidden = false
                        })
                    }
                }
            } else {
                println(error)
                println("nope")
            }
        })
        
        serverTask.resume()
    }
    
    func displayTrips() {
        // sort trip array according to time of arrival
        self.trips = sorted(self.trips, soonest)
        // get info for all the trips in location (D.T.R: limit how many are loaded)
        for (var i = 0; i < self.trips.count; i++) {
            var trip = self.trips[i] as NSDictionary
            println(trip)
            var tripid = trip["tripid"] as String
            var toa = trip["toa"] as Int
            var requestInfo:NSDictionary = ["tripid": tripid, "toa": toa]
            var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
                options:NSJSONWritingOptions.allZeros, error: nil)
            let url = NSURL(string: urlgettripinfo)
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
                        self.tripInfo.append(feedback["tripInfo"] as NSDictionary)
                        println("successfully got transaction info")
                        if (self.buttontrip1 == false) {
                            //update top button
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.updateButton(1, tripInfo: feedback["tripInfo"] as NSDictionary)
                            })
                        }
                        else if (self.buttontrip2 == false) {
                            //update left button
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.updateButton(2, tripInfo: feedback["tripInfo"] as NSDictionary)
                            })
                        }
                        else if (self.buttontrip3 == false) {
                            //update right button 
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.updateButton(3, tripInfo: feedback["tripInfo"] as NSDictionary)
                            })
                        }
                    }
                } else {
                    println(error)
                    println("nope")
                }
            })
            
            serverTask.resume()
        }
    }

    func updateButton(tag: Int!, tripInfo: NSDictionary) {
        println(tripInfo)
        var toa = tripInfo["toa"] as Int
        let date = NSDate()
        let timestamp = date.timeIntervalSince1970
        toa = (toa - Int(ceil(timestamp)))
        // display in minutes and round down
        toa = Int(floor(Double(toa) / 60.0))
        if (tag == 1) {
            self.user1.text = tripInfo["userName"] as String!
            self.time1.text = "\(toa)"
            self.user1.sizeToFit()
            self.buttontrip1 = true
            self.user1.hidden = false
            self.time1.hidden = false
            self.min1.hidden = false
            var userid = tripInfo["user"] as String //trip owner
            // if trip owner is not current user, enable button
            if (self.curUser == userid) {
                println("***")
                println(userid)
                self.topButton.enabled = false
            }
        }
        if (tag == 2) {
            self.user2.text = tripInfo["userName"] as String!
            self.time2.text = "\(toa)"
            self.user2.sizeToFit()
            self.buttontrip2 = true
            self.user2.hidden = false
            self.time2.hidden = false
            self.min2.hidden = false
            var userid = tripInfo["user"] as String //trip owner
            if (self.curUser != userid) {
                println("****")
                println(userid)
                self.leftButton.enabled = true
            }
        }
        if (tag == 3) {
            self.user3.text = tripInfo["userName"] as String!
            self.time3.text = "\(toa)"
            self.user3.sizeToFit()
            self.buttontrip3 = true
            self.user3.hidden = false
            self.time3.hidden = false
            self.min3.hidden = false
            var userid = tripInfo["user"] as String //trip owner
            if (self.curUser != userid) {
                self.rightButton.enabled = true
            }
        }
    }
    
    func soonest(trip1: NSDictionary, trip2: NSDictionary) -> Bool {
        println(trip1)
        println(trip1[0])
        var toa1 = trip1["toa"] as Int
        var toa2 = trip2["toa"] as Int
        return toa1 < toa2
    }
    
}