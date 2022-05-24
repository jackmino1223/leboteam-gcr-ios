//
//  ReviewCard.swift
//  gcr-ios
//
//  Created by iOS Developer on 7/20/17.
//  Copyright © 2017 leboprojects. All rights reserved.
//

class ReviewCard {
    private var reviewName          : String
    private var reviewDescription   : String
    private var reviewStars         : Int

    init(name: String, description: String, stars: Int) {
        reviewName          = name
        reviewDescription   = description
        reviewStars         = stars
    }
    
    public func getReviewName() -> String           { return reviewName }
    public func getReviewDescription() -> String    { return reviewDescription }
    public func getReviewStars() -> Int             { return reviewStars }
}
