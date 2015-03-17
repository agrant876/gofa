//
//  ViewController.swift
//  gofa
//
//  Created by Andrew Grant on 1/28/15.
//  Copyright (c) 2015 gprod. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    var myRootRef: Firebase!
    var locationRef: Firebase!
    var myLocRef: Firebase!
    
    
    // node info 
    let urlstring = "http://localhost:3000/"
    let urlping = "http://gofa-app.com/ping"
    var url: NSURL!
    
    
    // location info 
    var topLocKey: String!
    var topLocDict = [String: AnyObject]()
    var rightLocKey: String!
    var rightLocDict = [String: AnyObject]()
    var leftLocKey: String!
    var leftLocSnap: FDataSnapshot!
    
    // user info
    var authData: FAuthData!
    var curUser: String!
    var curUserName: String!
    var tripMode = false


    @IBOutlet weak var topLoc: UILabel!
    @IBOutlet weak var rightLoc: UILabel!
    @IBOutlet weak var leftLoc: UILabel!
    
    @IBOutlet weak var postTripLabel: UILabel!
    @IBOutlet weak var postTripButton: UIButton!
    
    
    @IBOutlet weak var userName: UIButton!
    
    @IBAction func activateTripMode(sender: UIButton) {
        postTripLabel.text = "Where are you going?"
        postTripButton.setTitle("", forState: .Normal)
        postTripButton.enabled = false
        tripMode = true
    }
    
    /// NODE TESTS /////
 
    @IBOutlet weak var serverResponse: UILabel!
    
    @IBAction func pingServer(sender: UIButton) {
        let url = NSURL(string: urlping)
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "GET"
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config);
        
        let pingTask = session.dataTaskWithRequest(req, { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                println("yes, success")
                //var resArray: NSDictionary! =  NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as NSDictionary
                //println(resArray)
                //var textResponse = resArray["text"] as String!
                //self.serverResponse.text = textResponse
                //println(resArray["text"] as String!)
                //println(response.description)
            } else {
                println("nope")
            }
        })
        
        pingTask.resume()
        
    }
    
  
    
    
    //////////////////
    
    @IBAction func touchLocButton(sender: OBShapedButton) {
        if tripMode == true {
            performSegueWithIdentifier("goto_trip", sender: sender)
        } else {
            performSegueWithIdentifier("goto_location", sender: sender)
        }
    }
   
  /*  @IBAction func topbutton(sender: UIButton) {
            let location = sender.titleLabel?.text
            locationRef = myRootRef.childByAppendingPath("locations/"+location!)
            locationRef.observeEventType(.Value, withBlock: {
                snapshot in
                self.locationSnapshot = snapshot
                println(snapshot)
                self.performSegueWithIdentifier("showLocation", sender:self)
            })
        
    }*/
    
    @IBAction func logout(sender: UIButton) {
        myRootRef.unauth()
        performSegueWithIdentifier("goto_login", sender: self)
    }
    
    
    
    func setupFirebase() {
        myRootRef = Firebase(url:"https://gofa.firebaseio.com/")
        
        locationRef = myRootRef.childByAppendingPath("locations/p01")
        locationRef.observeEventType(.Value, withBlock: {
            snapshot in
            self.topLocKey = snapshot.key
            self.topLocDict = snapshot.value as Dictionary!
            //println(self.topLocSnap)
            //self.topLoc.text = self.topLocDict["name"] as? String
        })
        locationRef = myRootRef.childByAppendingPath("locations/p02")
        locationRef.observeEventType(.Value, withBlock: {
            snapshot in
            self.rightLocKey = snapshot.key
            self.rightLocDict = snapshot.value as Dictionary!
           // println(self.rightLocSnap)
            //self.rightLoc.text = self.rightLocDict["name"] as? String
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupFirebase()
        self.url = NSURL(string: urlstring)
        
       // var ref = Firebase(url:"https://gofa.firebaseio.com/trips/simplelogin:8_1423366867")
        var locTripRef = Firebase(url:"https://gofa.firebaseio.com/locations/p02/trips/simplelogin:8_1423366867")

        //ref.removeValue()
        locTripRef.removeValue()
        
        
        ////// RANDOM TEST /////
        
        let devTokenString = "this is fake device token"
        let devToken = devTokenString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        print(devToken)
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "POST"
       // req.setValue(String(devToken.length), forHTTPHeaderField: "Content-Length")
        req.HTTPBody = devToken!
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config);
        
        let postDevToken = session.dataTaskWithRequest(req, { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                println("Succesfully saved device token")
            } else {
                println("Error saving device token")
            }
        })
        
        postDevToken.resume()

        
        
        
        
        ///////////////////
        updateUI()
        
       
       /* myLocRef = Firebase(url:"https://gofa.firebaseio.com/locations/wawa")
        myLocRef.observeEventType(.Value, withBlock: {
            snapshot in
            println(snapshot)
            self.address = snapshot.value["address"] as? String
        })
*/

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI() {
       // println(self.curUserName)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
        if segue.identifier == "goto_trip" {
            var newTripVC = TripViewController()
            newTripVC = segue.destinationViewController as TripViewController
            newTripVC.authData = self.authData
            newTripVC.curUserName = self.curUserName
            
            var button = sender as OBShapedButton
            if button.tag == 0 {
                newTripVC.location = self.topLocKey
                newTripVC.locationDict = self.topLocDict
            } else if button.tag == 1 {
                newTripVC.location = self.rightLocKey
                newTripVC.locationDict = self.rightLocDict
            }
        }
        if segue.identifier == "goto_location" {
            var newLocVC = LocationViewController()
            newLocVC = segue.destinationViewController as LocationViewController
            newLocVC.authData = self.authData
            newLocVC.curUserName = self.curUserName
        
            var button = sender as OBShapedButton
            if button.tag == 0 {
                newLocVC.location = self.topLocKey
                newLocVC.locationDict = self.topLocDict
            } else if button.tag == 1 {
                newLocVC.location = self.rightLocKey
                newLocVC.locationDict = self.rightLocDict
            }
            /*
            var locTripsRef = Firebase(url: "https://gofa.firebaseio.com/locations/\(newLocVC.location)/trips")
            locTripsRef.observeEventType(.Value, withBlock: {
                snapshot in
                var curTrips = snapshot.value as Dictionary?
                
            })*/
        }
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        //let ref = Firebase(url:"https://gofa.firebaseio.com/")
        
        myRootRef.observeAuthEventWithBlock({ authData in
            if authData != nil {
                // user authenticated with Firebase
                self.authData = authData
                self.curUser = authData.uid
                println(self.curUser)
                println(authData)
                
                // get name of current user
                var usernameURL = "https://gofa.firebaseio.com/users/" + self.curUser + "/username"
                var usernameref = Firebase(url: usernameURL)
                usernameref.observeEventType(.Value, withBlock: { snapshot in
                    self.curUserName = snapshot.value as? String
                    println(self.curUserName)
                    self.userName.setTitle(self.curUserName, forState: .Normal)
                    },
                    withCancelBlock: { error in
                        println(error.description)
                })
            } else {
                // No user is logged in
                println("nouser")
                self.performSegueWithIdentifier("goto_login", sender:self)
            }
        })
    }
    
}

