//
//  LocationManager.swift
//  gofa
//
//  Created by Andrew Grant on 3/20/15.
//  Copyright (c) 2015 gprod. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

private let _LocationManagerSharedInstance = LocationManager()

class LocationManager: NSObject, CLLocationManagerDelegate {
    class var sharedInstance: LocationManager {
        return _LocationManagerSharedInstance
    }
    
    var locManager: CLLocationManager!
    var gateRegion: CLCircularRegion!
    var dillsbury2: CLCircularRegion!
    var centerLoc: CLLocation!
    var myRegion: CLCircularRegion!
    
    // register regions nearest to the users current location
    func registerRegions() {
        self.locManager = CLLocationManager()
        locManager.delegate = self
        locManager.requestAlwaysAuthorization()
        locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        // temporary, dtr: array that updates with closest 20 stores to user
        //firestone
        // 40.349148, -74.657742
        //music building
        //40.347404, -74.655639
        // ustore
        //40.347130, -74.661525
        // down the hall
        // 40.345985, -74.660765
        // southeast of frist
        //40.346454, -74.654140
        // dillon west
        //40.345620, -74.659138
        // spellman
        // 40.345044, -74.659073
        var latitude:CLLocationDegrees = 40.345044
        var longitude:CLLocationDegrees = -74.659073
        var center:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        var radius:CLLocationDistance = CLLocationDistance(5.0)
        var identifier:String = "spellman"
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
        
        //print(self.locManager)
        //println(geoRegion)
        geoRegion.notifyOnEntry = true
        geoRegion.notifyOnExit = true
        println("---------")
        println(geoRegion)
        println(geoRegion.notifyOnEntry)
        println(geoRegion.notifyOnExit)
        println("---------")
        self.centerLoc = CLLocation(latitude: geoRegion.center.latitude, longitude: geoRegion.center.longitude)
        self.myRegion = geoRegion

        locManager.startUpdatingLocation()
        locManager.startMonitoringForRegion(geoRegion)
        //self.locManager.requestStateForRegion(geoRegion)
        //var monitoredRegions = self.locManager.monitoredRegions
        /*for region in monitoredRegions {
            var name = (region as CLRegion).identifier
            if (name == "mendell") {
                println("mendell")
                var region2 = region as CLCircularRegion
                println(region2)
                println(region2.notifyOnEntry)
                self.centerLoc = CLLocation(latitude: region2.center.latitude, longitude: region2.center.longitude)
                //self.locManager.startUpdatingLocation()
                //self.locManager.requestStateForRegion(region as CLRegion)
            }
        }
        */

        if UIApplication.sharedApplication().backgroundRefreshStatus == UIBackgroundRefreshStatus.Available {
            println("all good")
        }
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways
        {
            println("all good again")
        }
        //println(self.locManager.monitoredRegions)
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }
    
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        println("in did determine state!")
        println(region.notifyOnEntry)
        println(region)
        println(manager.location)
        println(manager.desiredAccuracy)
        var region = region as CLCircularRegion
        var regionLoc = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        //var dist = manager.location.distanceFromLocation(regionLoc)
        println("!!!!!!!!!!!!!!!!!")
       //println(dist)
        /*if region.containsCoordinate(manager.location.coordinate) {
            println("i'm in firestone. crap.")
        } else {
            println("there's hope")
        }
        //var fromLoc = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        //var distance = manager.location.distanceFromLocation(fromLoc)
        // println(distance)*/
        if (state == CLRegionState.Inside) {
            println("I'm in dillon west region")
        } else {
            println("keep trying")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
        self.locManager.requestStateForRegion(region as CLRegion)
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        println("entered region")
        var regionInfo = ["region": region.identifier]
        NSNotificationCenter.defaultCenter().postNotificationName("regionEntered", object: nil, userInfo: regionInfo)
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        println("exited region")
        var regionInfo = ["region": region.identifier]
        NSNotificationCenter.defaultCenter().postNotificationName("regionExited", object: nil, userInfo: regionInfo)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as CLLocation
        //println(location)
        var dist = location.distanceFromLocation(self.centerLoc)
        //println(location.coordinate.latitude, location.coordinate.longitude)
        println(dist)
       /* if self.dillsbury2.containsCoordinate(location.coordinate) {
            // alert user
            NSNotificationCenter.defaultCenter().postNotificationName("regionEntered", object: nil)
        }*/
      //  self.locManager.requestStateForRegion(myRegion)
    }


}