//
//  Trip.swift
//  gofa
//
//  Created by Andrew Grant on 2/3/15.
//  Copyright (c) 2015 gprod. All rights reserved.
//

import Foundation

class Trip
{
    let user: FAuthData
    let location: String!
    let arrivalTime: Int!
    var typePublic: Bool = false
    var customers = Array<FAuthData>()
    var destination: String?
    
    init(userInfo: FAuthData, locationInfo: String!, arrivalTimeInfo: Int!, typePublicInfo: Bool, destinationInfo: String?)
    {
        user = userInfo
        location = locationInfo
        arrivalTime = arrivalTimeInfo
        typePublic = typePublicInfo
        destination = destinationInfo
        
        
        var tripIdentifier = userInfo.uid + "_\(arrivalTimeInfo)"
        println(tripIdentifier)
        var tripInfo = ["user": userInfo.uid, "location": locationInfo, "toa": arrivalTimeInfo,
            "typePublic": typePublicInfo]
        var tripRef =  Firebase(url:"https://gofa.firebaseio.com/trips")
        // enter user provider and email into Firebase
        tripRef.childByAppendingPath(tripIdentifier).setValue(tripInfo)
        var userRef = Firebase(url:"https://gofa.firebaseio.com/users/" + userInfo.uid)
        userRef.childByAppendingPath("trips").updateChildValues([tripIdentifier: arrivalTimeInfo])
        var locationRef = Firebase(url:"https://gofa.firebaseio.com/locations/" + locationInfo)
        locationRef.childByAppendingPath("trips").updateChildValues([tripIdentifier: arrivalTimeInfo])
        
        println("In Trip Model!")
        println(location)
        println(user.uid)
        println("\(arrivalTime)")
    }
    
    
    // userInfo has requested a delivery
    func customerRequest(userInfo: FAuthData)
    {
    
    }
    
    // the trip "owner" accepts userInfo's request
    func requestAccepted(userInfo: FAuthData)
    {
        //new transaction
    }
    
    
    func notifyTripOwner()// type of notifcation
    {
    
    }
    
    
}