//
//  URL.swift
//  gcr-ios
//
//  Created by Alex on 8/4/17.
//  Copyright © 2017 leboprojects. All rights reserved.
//

class URLAdress {
    private static let host = "http://gulfcarsae.com"
    private static let hostAPI = "\(host)/api"
    
    public static let carList = "\(hostAPI)/cars"
    
    public static func getSearchCarList(search: String) -> String {
        return "\(hostAPI)/search?q=\(search.trimmingCharacters(in: .whitespaces))"
    }
    public static func getImageURL(image: String) -> String {
        return "\(host)/images/cars/\(image)"
    }
    public static func getCompanyImageURL(image: String) -> String {
        return "\(host)/images/companies/\(image)"
    }
    public static func getCarDetails(car: String) -> String {
        return "\(hostAPI)/cars/\(car)"
    }
    public static func getCompanyDetails(company: String) -> String {
        return "\(hostAPI)/company/\(company)"
    }
    public static func getCompanyReviews(company: String) -> String {
        return "\(hostAPI)/company/\(company)/reviews"
    }
    public static func getCompanyCarList(company: String) -> String {
        return "\(hostAPI)/company/\(company)/cars"
    }
    public static func getWriteReviewLink(placeID: String) -> String {
        return "https://search.google.com/local/writereview?placeid=\(placeID)"
    }
    public static func getRentLink(carID: String) -> String {
        return "\(host)/cars/\(carID)#rentCarModal"
    }
}
