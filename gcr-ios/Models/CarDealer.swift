//
//  CarDealer.swift
//  gcr-ios
//
//  Created by Alex on 8/24/17.
//  Copyright © 2017 leboprojects. All rights reserved.
//

import Foundation

class CarDealer {
    public var dealerID                 : String
    public var dealerImage              : URL
    public var dealerName               : String
    public var dealerWorkingHours       : String
    public var dealerReviewsID          : String
    public var messageNumber            : String
    public var callNumber               : String
    public var email                    : String
    public var dealerDescription        : String
    public var dealerLocationLatitude   : Double
    public var dealerLocationLongitude  : Double
    
    init () {
        self.dealerID                    = ""
        self.dealerImage                 = URL(string: "")!
        self.dealerName                  = ""
        self.dealerWorkingHours          = ""
        self.dealerReviewsID             = ""
        self.messageNumber               = ""
        self.callNumber                  = ""
        self.email                       = ""
        self.dealerDescription           = ""
        self.dealerLocationLatitude      = 0
        self.dealerLocationLongitude     = 0
    }
    
    init (id : String,
          image : URL,
          name : String,
          workingHours : String,
          reviewsID : String,
          messageNumber : String,
          callNumber : String,
          email : String,
          description : String,
          locationLatitude : Double,
          locationLongitude : Double) {
        self.dealerID                    = id
        self.dealerImage                 = image
        self.dealerName                  = name
        self.dealerWorkingHours          = workingHours
        self.dealerReviewsID             = reviewsID
        self.messageNumber               = messageNumber
        self.callNumber                  = callNumber
        self.email                       = email
        self.dealerDescription           = description
        self.dealerLocationLatitude      = locationLatitude
        self.dealerLocationLongitude     = locationLongitude
    }
}
