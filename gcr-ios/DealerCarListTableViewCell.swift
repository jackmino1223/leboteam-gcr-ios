//
//  DealerCarListTableViewCell.swift
//  gcr-ios
//
//  Created by iOS Developer on 7/21/17.
//  Copyright © 2017 leboprojects. All rights reserved.
//

import UIKit
import AlamofireImage

class DealerCarListTableViewCell: UITableViewCell {
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var carName: UILabel!
    @IBOutlet weak var carPrice: UILabel!

    func prepare(data: CarCard) {
        self.backgroundColor = AppColors.background
        carPrice.backgroundColor = AppColors.priceColor
        carPrice.textColor = AppColors.carTitle
        carPrice.layer.cornerRadius = 10
        carName.textColor = AppColors.carTitle
        
        carName.text    = data.getCarName()
        carPrice.text   = data.getCarPrice()
        carImage.af_setImage(withURL: data.getCarImage())
    }
}
