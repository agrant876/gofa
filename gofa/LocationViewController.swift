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
    
    var currentTrips: [String :Int]?
    var trips = [String]()
    
    @IBOutlet weak var userOne: UILabel!
    @IBOutlet weak var userTwo: UILabel!
    @IBOutlet weak var userThree: UILabel!
    
    @IBOutlet weak var timeOne: UILabel!
    
    
    @IBOutlet weak var infoLabel: UILabel!
    
    
    func setupFirebase()
    {
       // self.trips = [String]()
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
                    }
                }
                self.updateUI()
            }
        })
    }
    /*
    func updateTrips() {
            var numberOfTrips = trips.count
            for int
    }
    
                    
                    
                    var tripRef = Firebase(url: "https://gofa.firebaseio.com/trips/\(tripIdentifier)")
                    // check to see if toa has passed
                    tripRef.childByAppendingPath("toa").observeEventType(.Value, withBlock: {
                        snapshot in
                            println(tripRef)
                            println(snapshot.value)
                            var toa = snapshot.value as Int!
                            println("\(toa)")
                            let date = NSDate()
                            let timestamp = date.timeIntervalSince1970
                            println("\(timestamp)")
                        
                            // if the toa has passed, remove the trip
                            if (Int(timestamp) > toa) {
                                Firebase(url: "https://gofa.firebaseio.com/trips/\(tripIdentifier)").removeValueWithCompletionBlock() {
                                        error, firebase in
                                    if (error == nil) {
                                        Firebase(url: "https://gofa.firebaseio.com/locations/\(self.location)/trips/\(tripIdentifier)").removeValueWithCompletionBlock() {
                                            error, firebase in
                                            if (error == nil) {
                                                break
                                            } else { println(error)}
                                        }
                                    } else { println(error)}
                                }
                            } else {
                                self.trips.append(tripIdentifier)
                            }
                    })
                }
                println(self.trips)
               // self.updateUI()
        })
    }
*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFirebase()
     //   updateUI()
    }
    
    func updateUI() {
        
        if currentTrips == nil {
            infoLabel.text = "Sorry, no trips right now!"
        } /*else {
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
        }*/
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "goto_bag" {
            var newBagVC = BagViewController()
            newBagVC = segue.destinationViewController as BagViewController
            newBagVC.authData = self.authData
            newBagVC.curUserName = self.curUserName
            newBagVC.location = self.location
            newBagVC.locationName = "Wawa"
        }
    }


}