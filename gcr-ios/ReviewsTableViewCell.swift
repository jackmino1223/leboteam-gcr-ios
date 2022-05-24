//
//  ReviewsTableViewCell.swift
//  gcr-ios
//
//  Created by iOS Developer on 7/21/17.
//  Copyright © 2017 leboprojects. All rights reserved.
//

import UIKit
import Cosmos

class ReviewsTableViewCell: UITableViewCell {
    @IBOutlet weak var usernameOfReview: UILabel!
    @IBOutlet weak var starsOfReview: CosmosView!
    @IBOutlet weak var descriptionOfReview: UILabel!

    func prepare(data: ReviewCard) {
        self.backgroundColor = AppColors.background
        usernameOfReview.textColor = AppColors.carTitle
        descriptionOfReview.textColor = AppColors.detailsText
        
        usernameOfReview.text = data.getReviewName()
        starsOfReview.rating = Double(data.getReviewStars())
        descriptionOfReview.text = data.getReviewDescription()
    }

}
