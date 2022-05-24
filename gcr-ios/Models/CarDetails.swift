//
//  CarDetails.swift
//  gcr-ios
//
//  Created by Alex on 8/24/17.
//  Copyright © 2017 leboprojects. All rights reserved.
//

import Foundation

class CarDetails {
    public var carID                    : String
    public var carName                  : String
    public var carPrice                 : String
    public var carRentLink              : String
    public var carImages                : [String]
    public var messageNumber            : String
    public var callNumber               : String
    public var email                    : String
    public var carDescription           : String
    public var carDetailsBrand          : String
    public var carDetailsModel          : String
    public var carDetailsYear           : String
    public var carDetailsWheels         : String
    public var carDetailsColor          : String
    public var carDetailsDistance       : String
    public var carDetailsSpecs          : String
    public var carDetailsGearBox        : String
    public var carDetailsSeats          : String
    public var carDetailsCylinders      : String
    public var carDetailsInterior       : String
    public var carDetailsCondition      : String
    public var carDealerImage           : URL
    public var carDealerName            : String
    public var carDealerID              : String
    public var carLocationLatitude      : Double
    public var carLocationLongitude     : Double
    
    init() {
        self.carID                  = ""
        self.carName                = ""
        self.carPrice               = ""
        self.carRentLink            = ""
        self.carImages              = [""]
        self.messageNumber          = ""
        self.callNumber             = ""
        self.email                  = ""
        self.carDescription         = ""
        self.carDetailsBrand        = ""
        self.carDetailsModel        = ""
        self.carDetailsYear         = ""
        self.carDetailsWheels       = ""
        self.carDetailsColor        = ""
        self.carDetailsDistance     = ""
        self.carDetailsSpecs        = ""
        self.carDetailsGearBox      = ""
        self.carDetailsSeats        = ""
        self.carDetailsCylinders    = ""
        self.carDetailsInterior     = ""
        self.carDetailsCondition    = ""
        self.carDealerImage         = URL(string: "")!
        self.carDealerName          = ""
        self.carDealerID            = ""
        self.carLocationLatitude    = 0
        self.carLocationLongitude   = 0
    }
    
    init(id:                    String,
         name:                  String,
         price:                 String,
         rentLink:              String,
         images:                [String],
         messageNumber:         String,
         callNumber:            String,
         email:                 String,
         description:           String,
         detailsBrand:          String,
         detailsModel:          String,
         detailsYear:           String,
         detailsWheels:         String,
         detailsColor:          String,
         detailsDistance:       String,
         detailsSpecs:          String,
         detailsGearBox:        String,
         detailsSeats:          String,
         detailsCylinders:      String,
         detailsInterior:       String,
         detailsCondition:      String,
         dealerImage:           URL,
         dealerName:            String,
         dealerID:              String,
         locationLatitude:      Double,
         locationLongitude:     Double) {
        self.carID                  = id
        self.carName                = name
        self.carPrice               = "\(price)$"
        self.carRentLink            = rentLink
        self.carImages              = images
        self.messageNumber          = messageNumber
        self.callNumber             = callNumber
        self.email                  = email
        self.carDescription         = description
        self.carDetailsBrand        = detailsBrand
        self.carDetailsModel        = detailsModel
        self.carDetailsYear         = detailsYear
        self.carDetailsWheels       = detailsWheels
        self.carDetailsColor        = detailsColor
        self.carDetailsDistance     = detailsDistance
        self.carDetailsSpecs        = detailsSpecs
        self.carDetailsGearBox      = detailsGearBox
        self.carDetailsSeats        = detailsSeats
        self.carDetailsCylinders    = detailsCylinders
        self.carDetailsInterior     = detailsInterior
        self.carDetailsCondition    = detailsCondition
        self.carDealerImage         = dealerImage
        self.carDealerName          = dealerName
        self.carDealerID            = dealerID
        self.carLocationLatitude    = locationLatitude
        self.carLocationLongitude   = locationLongitude
    }
}
