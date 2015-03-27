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

    // register regions nearest to the users current location
    func registerRegions() {
        self.locManager = CLLocationManager()
        locManager.delegate = self
        locManager.requestAlwaysAuthorization()
        locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        //registerRegions()
        
        // temporary, dtr: array that updates with closest 20 stores to user
        //firestone
        // 40.349148, -74.657742
        //music building
        //40.347404, -74.655639
        // ustore
        //40.347130, -74.661525
        // down the hall
        // 40.345985, -74.660765
        var latitude:CLLocationDegrees = 40.345985
        var longitude:CLLocationDegrees = -74.660765
        var center:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        var radius:CLLocationDistance = CLLocationDistance(5.0)
        var identifier:String = "downthehall"
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
        self.locManager.startMonitoringForRegion(geoRegion)
        locManager.startUpdatingLocation()
        /*var monitoredRegions = self.locManager.monitoredRegions
        for region in monitoredRegions {
            var name = (region as CLRegion).identifier
            if (name == "mendell") {
                println("mendell")
                var region2 = region as CLCircularRegion
                println(region.notifyOnEntry)
                self.centerLoc = CLLocation(latitude: region2.center.latitude, longitude: region2.center.longitude)
                self.dillsbury2 = region2
                //self.locManager.startUpdatingLocation()
                self.locManager.requestStateForRegion(region as CLRegion)
            }
        } */

        if UIApplication.sharedApplication().backgroundRefreshStatus == UIBackgroundRefreshStatus.Available {
            println("all good")
        }
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways
        {
            println("all good again")
        }
        println(self.locManager.monitoredRegions)
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
        /*if region.containsCoordinate(manager.location.coordinate) {
            println("i'm in firestone. crap.")
        } else {
            println("there's hope")
        }
        //var fromLoc = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        //var distance = manager.location.distanceFromLocation(fromLoc)
        // println(distance)*/
        if (state == CLRegionState.Inside) {
            println("I'm down the hall")
        } else {
            println("keep trying")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
        self.locManager.requestStateForRegion(region as CLRegion)
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        NSNotificationCenter.defaultCenter().postNotificationName("regionEntered", object: nil)
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        NSNotificationCenter.defaultCenter().postNotificationName("regionExited", object: nil)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as CLLocation
        //println(location)
        //var dist = location.distanceFromLocation(self.centerLoc)
        //println(location.coordinate.latitude, location.coordinate.longitude)
        //println(dist)
       /* if self.dillsbury2.containsCoordinate(location.coordinate) {
            // alert user
            NSNotificationCenter.defaultCenter().postNotificationName("regionEntered", object: nil)
        }*/
    
    }


}