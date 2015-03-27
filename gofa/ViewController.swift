//
//  ViewController.swift
//  gofa
//
//  Created by Andrew Grant on 1/28/15.
//  Copyright (c) 2015 gprod. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
    
    var myRootRef: Firebase!
    var locationRef: Firebase!
    var myLocRef: Firebase!
    
    
    // node info 
    let urlstring = "http://localhost:3000/"
//    let urlping = "http://gofa-app.com/ping"
    let urlping = "http://localhost:3000/ping"
    let urlunseennotif = "http://localhost:3000/unseenNotif"
    var url: NSURL!
    
    // location manager
    var locManager: CLLocationManager!
    
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

    // transaction info (for segue to Notification VIew Controller)
    var transaction = [String: AnyObject]()
    
    @IBOutlet weak var testLocationLabel: UILabel!
    
    

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
    
    /// VENMO TESTS /////
    
    
    @IBAction func venmoMe(sender: UIButton) {
        Venmo.sharedInstance().sendPaymentTo("aggrant13@gmail.com", amount:4, note: "yup", audience: VENTransactionAudience.Private) { (transaction, success, error) -> Void in
            if (success) {
                println("success drew!")
            } else {
                println("venmo failed, error: " + error.localizedDescription)
            }
        }
    }
    
    
    
    /// NODE TESTS /////
 
    @IBOutlet weak var serverResponse: UILabel!
    
    @IBAction func pingServer(sender: UIButton) {
        
        // set up request data
        var requestInfo:NSDictionary = ["userid": self.curUser]
        println(NSJSONSerialization.isValidJSONObject(requestInfo))
        
        var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
       
        
        println(requestData)
        
    
        let url = NSURL(string: urlping)
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "POST"
        req.HTTPBody = requestData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        println(req.HTTPBody)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config);
        
        
        
        let pingTask = session.dataTaskWithRequest(req, { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                println("the data..")
                println(data)
                var feedback: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as NSDictionary
                //println(feedback)
                var status = feedback["status"] as String!
                if (status == "success") {
                    self.serverResponse.text = "successfully sent to Brian"
                    println("successfully sent to Brian")
                }
                //var resArray: NSDictionary! =  NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as NSDictionary
                //println(resArray)
                //var textResponse = resArray["text"] as String!
                //self.serverResponse.text = textResponse
                //println(resArray["text"] as String!)
                //println(response.description)
            } else {
                println(error)
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
    
    
    override func viewDidAppear(animated: Bool) {
      //  registerRegions()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserverForName("regionEntered", object: nil, queue: nil, usingBlock: { (ViewController) -> Void in
                println("got notif")
                let alertController = UIAlertController(title: "Hello!", message: "You entered a marked region", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                })
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated:true, completion:nil)
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName("regionExited", object: nil, queue: nil, usingBlock: { (ViewController) -> Void in
            println("got notif")
            let alertController = UIAlertController(title: "Hello!", message: "You exited a marked region", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            })
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated:true, completion:nil)
        })

        
        var myLocationManager = LocationManager.sharedInstance
        myLocationManager.registerRegions()
        
        //println(self.locManager)
        //if (self.locManager == nil) {
          //  self.initLocationManager()
        //}
        setupFirebase() //MOVED TO APP DELEGATE
        self.url = NSURL(string: urlstring)
        
        
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
                println("correct")
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
        if segue.identifier == "goto_notif" {
                var newNotifVC = NotificationViewController()
                newNotifVC = segue.destinationViewController as NotificationViewController
                newNotifVC.transaction = self.transaction
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
                self.checkForUnseenNotifs(self.curUser)
                
                // get name of current user
                var usernameURL = "https://gofa.firebaseio.com/users/" + self.curUser + "/username"
                var usernameref = Firebase(url: usernameURL)
                usernameref.observeEventType(.Value, withBlock: { snapshot in
                    self.curUserName = snapshot.value as? String
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
    
    // contacts server to check for any unseened notification, and if there are any, sets the
    // notification controller as the root view controller
    func checkForUnseenNotifs(curUser: String!) {
        
        var requestInfo:NSDictionary = ["userid": curUser]
        var requestData = NSJSONSerialization.dataWithJSONObject(requestInfo,
            options:NSJSONWritingOptions.allZeros, error: nil)
        let url = NSURL(string: urlunseennotif)
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "POST"
        req.HTTPBody = requestData
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config);
        
        let serverTask = session.dataTaskWithRequest(req, { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                var feedback: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as NSDictionary
                //println(feedback)
                var transaction: AnyObject? = feedback["transaction"] as AnyObject?
                if transaction != nil {
                    println(transaction)
                    self.transaction = transaction as Dictionary!
                    //there are unseen transactions, present notification view controller
                    self.performSegueWithIdentifier("goto_notif", sender:self)
                    //remoteNotif = remoteNotif as NSDictionary!
                    //notificationVC.notification = remoteNotif as NSDictionary
                }
            } else {
                println(error)
                println("nope")
            }
        })
        serverTask.resume()
    }


    /*
    func registerRegions() {
        // temporary, dtr: array that updates with closest 20 stores to user
        // dillsbury
        //18.030801, -76.771491
        // gate
       // 18.031568, -76.771533
        //gas station
        //18.031006, -76.773974
        //constant spring
        //18.040714, -76.795610
        
        var latitude:CLLocationDegrees = 18.040714
        var longitude:CLLocationDegrees = -76.795610
        var center:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        var radius:CLLocationDistance = CLLocationDistance(10.0)
        var identifier:String = "dillsbury"
        var overlay = MKCircle(centerCoordinate: center, radius: radius)
        registerRegionWithCircularOverlay(overlay, identifier: identifier)
    }
    
    func registerRegionWithCircularOverlay(overlay: MKCircle, identifier: String) {
        // If the overlay's radius is too large, registration fails automatically,
        // so clamp the radius to the max value.
        var radius = overlay.radius;
        if (radius > self.locManager.maximumRegionMonitoringDistance) {
            radius = self.locManager.maximumRegionMonitoringDistance;
        }
        // Create the geographic region to be monitored.
        var geoRegion = CLCircularRegion(center: overlay.coordinate, radius: radius, identifier: identifier)
        
        println(geoRegion)
        self.locManager.startMonitoringForRegion(geoRegion)
        self.locManager.requestStateForRegion(geoRegion)
        //println(self.locManager)
       // println("ok")
        println(self.locManager.monitoredRegions)
        if UIApplication.sharedApplication().backgroundRefreshStatus == UIBackgroundRefreshStatus.Available {
                println("all good")
        }
        //if CLAuthorizationStatue == CLAuthorizationStatus.AuthorizedAlways {
         //   println("all good again")
       // }
        
    }
    
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLCircularRegion!) {
        println("in did determine state!")
        println(region)
        println(manager.location)
        var fromLoc = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        var distance = manager.location.distanceFromLocation(fromLoc)
        println(distance)
        if (state == CLRegionState.Inside) {
            println("I'm home!")
        } else {
            println("keep trying")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println(locations)
    }

    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        println("you reach the bump")
        testLocationLabel.text = "you entered it man"
    }
    
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
        
    }
    
    // set up region boundaries
    
    func initLocationManager() {
        println("yup, view did load")
        self.locManager = CLLocationManager()
        locManager.delegate = self
        //locManager.locationServicesEnabled
        locManager.requestAlwaysAuthorization()
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        //locManager.startUpdatingLocation()
        registerRegions()
        //locManager.requestAlwaysAuthorization()
    }
*/
    
}

