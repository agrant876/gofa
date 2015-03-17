//
//  Location.swift
//  gofa
//
//  Created by Andrew Grant on 2/3/15.
//  Copyright (c) 2015 gprod. All rights reserved.
//

import Foundation

class Location {

    var name: String!
    var address: String!
    var trips = [Trip]()
    var transactions = [Transaction]()
    var totalTransactions: Int!
   /* var closed: Bool = false
    var closingTime....
    */
    
    init(locationName: String)
    {
        name = locationName
        
    }
    
    

}