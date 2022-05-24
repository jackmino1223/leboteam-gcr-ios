//
//  BasicReviewDetail.swift
//  gcr-ios
//
//  Created by Alex on 8/29/17.
//  Copyright © 2017 leboprojects. All rights reserved.
//

import Foundation

class BasicReviewDetails {
    private var reviewName          : String
    private var reviewDescription   : String
    private var reviewStars         : Double
        
    init(name: String, description: String, stars: Double) {
        reviewName          = name
        reviewDescription   = description
        reviewStars         = stars
    }
    
    public func getReviewName() -> String           { return reviewName }
    public func getReviewDescription() -> String    { return reviewDescription }
    public func getReviewStars() -> Double          { return reviewStars }
}
