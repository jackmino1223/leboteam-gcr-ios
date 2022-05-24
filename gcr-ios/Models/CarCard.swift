//
//  MainViewCard.swift
//  gcr-ios
//
//  Created by iOS Developer on 7/14/17.
//  Copyright © 2017 leboprojects. All rights reserved.
//

import UIKit

class CarCard {
    private var carID    : String
    private var carName  : String
    private var carPrice : String
    private var carImage : URL
    
    init(ID: String, name: String, price: String, image: String) {
        carID    = ID
        carName  = name
        carPrice = price
        carImage = URL(string: image)!
    }
    
    public func getCarID() -> String       { return carID }
    public func getCarName() -> String     { return carName }
    public func getCarPrice() -> String    { return "\(carPrice)$" }
    public func getCarImage() -> URL       { return carImage }
}
