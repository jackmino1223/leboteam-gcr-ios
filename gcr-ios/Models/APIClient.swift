//
//  APIClient.swift
//  gcr-ios
//
//  Created by Alex on 8/4/17.
//  Copyright © 2017 leboprojects. All rights reserved.
//
import UIKit
import ReachabilitySwift
import Alamofire
import AlamofireImage
import SwiftyJSON

class APIClient {
    public static func getRecentCarList(page : Int,
                                        success: @escaping (_ data: [CarCard]) -> Void,
                                        failure: @escaping (_ error: String) -> Void) {
        getCarList(url: URLAdress.carList, page: page, success: { (data) in
            success(data)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    public static func getAscendingCarList(page : Int,
                                           success: @escaping (_ data: [CarCard]) -> Void,
                                           failure: @escaping (_ error: String) -> Void) {
        getCarList(url: "\(URLAdress.carList)?order=price&by=ASC", page: page, success: { (data) in
            success(data)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    public static func getDescendingCarList(page : Int,
                                            success: @escaping (_ data: [CarCard]) -> Void,
                                            failure: @escaping (_ error: String) -> Void) {
        getCarList(url: "\(URLAdress.carList)?order=price&by=DESC", page: page, success: { (data) in
            success(data)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    public static func getSearchRecentCarList(phrase: String,
                                              page : Int,
                                              success: @escaping (_ cars: Int, _ data: [CarCard]) -> Void,
                                              failure: @escaping (_ error: String) -> Void) {
        getCarList(url: URLAdress.getSearchCarList(search: phrase), page: page, success: { (data) in
            success(data.count, data)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    public static func getSearchAscendingCarList(phrase: String,
                                                 page : Int,
                                                 success: @escaping (_ cars: Int, _ data: [CarCard]) -> Void,
                                                 failure: @escaping (_ error: String) -> Void) {
        getCarList(url: "\(URLAdress.getSearchCarList(search: phrase))&order=price&by=ASC", page: page, success: { (data) in
            success(data.count, data)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    public static func getSearchDescendingCarList(phrase: String,
                                                  page : Int,
                                                  success: @escaping (_ cars: Int, _ data: [CarCard]) -> Void,
                                                  failure: @escaping (_ error: String) -> Void) {
        getCarList(url: "\(URLAdress.getSearchCarList(search: phrase))&order=price&by=DESC", page: page, success: { (data) in
            success(data.count, data)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    public static func getCarDealerCarList(dealerID : String,
                                           page : Int,
                                           success: @escaping (_ cars: Int, _ data: [CarCard]) -> Void,
                                           failure: @escaping (_ error: String) -> Void) {
        getCarDealerList(url: URLAdress.getCompanyCarList(company: dealerID), page: page, success: { (cars, data) in
            success(cars, data)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    private static func getCarList(url: String,
                                   page : Int,
                                   success: @escaping (_ data: [CarCard]) -> Void,
                                   failure: @escaping (_ error: String) -> Void) {
        Alamofire.request(url).responseJSON { (response) in
            if(response.result.isSuccess) {
                if((response.response?.statusCode)! == 200) {
                    var cars = [CarCard]()
                    let data = JSON(data: response.data!)
                    if data.count != 0 {
                        for i in 0...data.count-1 {
                            let car = CarCard(ID: data[i]["slug"].stringValue,
                                              name: data[i]["offer"].stringValue,
                                              price: data[i]["price"].stringValue,
                                              image: URLAdress.getImageURL(image: data[i]["carImages"][0]["name"].stringValue))
                            cars.append(car)
                        }
                    }
                    success(cars)
                } else {
                    failure("Data not found!")
                }
            } else {
                failure("Connection error!")
            }
        }
    }
    
    private static func getCarDealerList(url: String,
                                         page : Int,
                                         success: @escaping (_ cars : Int, _ data: [CarCard]) -> Void,
                                         failure: @escaping (_ error: String) -> Void) {
        Alamofire.request(url).responseJSON { (response) in
            if(response.result.isSuccess) {
                if((response.response?.statusCode)! == 200) {
                    var cars = [CarCard]()
                    let data = JSON(data: response.data!)
                    if data.count != 0 {
                        for i in 0...data.count-1 {
                            let car = CarCard(ID: data[i]["slug"].stringValue,
                                              name: data[i]["offer"].stringValue,
                                              price: data[i]["price"].stringValue,
                                              image: URLAdress.getImageURL(image: data[i]["carImages"][0]["name"].stringValue))
                            cars.append(car)
                        }
                    }
                    success(data.count, cars)
                } else {
                    failure("Data not found!")
                }
            } else {
                failure("Connection error!")
            }
        }
    }
    
    public static func getCarDetails(id : String,
                                     success: @escaping (_ data: CarDetails) -> Void,
                                     failure: @escaping (_ error: String) -> Void) {
        Alamofire.request(URLAdress.getCarDetails(car: id)).responseJSON { (response) in
            if(response.result.isSuccess) {
                if((response.response?.statusCode)! == 200) {
                    let data = JSON(data: response.data!)
                    var carImages = [String]()
                    let jsonArr = data["carImages"].arrayValue
                    for image in jsonArr {
                        carImages.append(URLAdress.getImageURL(image: image["name"].stringValue))
                    }
                    let carDetails = CarDetails(id: data["slug"].stringValue,
                                                name: data["offer"].stringValue,
                                                price: data["price"].stringValue,
                                                rentLink: URLAdress.getRentLink(carID: data["slug"].stringValue),
                                                images: carImages,
                                                messageNumber: data["company.phone"].stringValue,
                                                callNumber: data["company.phone"].stringValue,
                                                email: data["company.users.email"].stringValue,
                                                description: data["description"].stringValue,
                                                detailsBrand: data["brand.name"].stringValue,
                                                detailsModel: data["model"].stringValue,
                                                detailsYear: data["year"].stringValue,
                                                detailsWheels: data["tireSize"].stringValue,
                                                detailsColor: data["color"].stringValue,
                                                detailsDistance: data["kilometrage"].stringValue,
                                                detailsSpecs: data["specs"].stringValue,
                                                detailsGearBox: data["transmission"].stringValue,
                                                detailsSeats: data["seats"].stringValue,
                                                detailsCylinders: data["cylinders"].stringValue,
                                                detailsInterior: data["interior"].stringValue,
                                                detailsCondition: data["condition"].stringValue,
                                                dealerImage: URL(string: URLAdress.getCompanyImageURL(image: data["company.companyLogo"].stringValue))!,
                                                dealerName: data["company.name"].stringValue,
                                                dealerID: data["company.slug"].stringValue,
                                                locationLatitude: data["latitude"].doubleValue,
                                                locationLongitude: data["longitude"].doubleValue)
                    
                        success(carDetails)
                } else {
                    failure("Data not found!")
                }
            } else {
                failure("Connection error!")
            }
        }

    }
    
    public static func getCarDealer(id : String,
                                     success: @escaping (_ data: CarDealer) -> Void,
                                     failure: @escaping (_ error: String) -> Void) {
        Alamofire.request(URLAdress.getCompanyDetails(company: id)).responseJSON { (response) in
            if(response.result.isSuccess) {
                if((response.response?.statusCode)! == 200) {
                    let data = JSON(data: response.data!)
                    let dealerDetails = CarDealer(id: data["slug"].stringValue,
                                                  image: URL(string: URLAdress.getCompanyImageURL(image: data["companyLogo"].stringValue))!,
                                                  name: data["name"].stringValue,
                                                  workingHours: "\(data["openingHour"].stringValue) - \(data["closingHour"].stringValue)",
                                                  reviewsID: data["placeID"].stringValue,
                                                  messageNumber: data["phone"].stringValue,
                                                  callNumber: data["phone"].stringValue,
                                                  email: data["users.email"].stringValue,
                                                  description: data["address"].stringValue,
                                                  locationLatitude: data["latitude"].doubleValue,
                                                  locationLongitude: data["longitude"].doubleValue)
                    
                    success(dealerDetails)
                } else {
                    failure("Data not found!")
                }
            } else {
                failure("Connection error!")
            }
        }

    }
    
    public static func getBasicReviewDetails(id : String,
                                      success: @escaping (_ data: BasicReviewDetails) -> Void,
                                      failure: @escaping (_ error: String) -> Void) {
        Alamofire.request(URLAdress.getCompanyReviews(company: id)).responseJSON { (response) in
            if(response.result.isSuccess) {
                if((response.response?.statusCode)! == 200) {
                    let data = JSON(data: response.data!)
                    if !data["error_message"].stringValue.isEmpty {
                        failure("Data nor found!")
                    } else {
                        if data["rating"].stringValue == "no rating" {
                            failure("No reviews")
                        } else {
                            let basicReview = BasicReviewDetails(name: data["review"][0]["author_name"].stringValue,
                                                                 description: data["review"][0]["text"].stringValue,
                                                                 stars: data["rating"].doubleValue)
                            success(basicReview)
                        }
                    }
                } else {
                    failure("Data not found!")
                }
            } else {
                failure("Connection error!")
            }
        }
    }
    
    public static func getReviewList(id : String,
                                     success: @escaping (_ id: String,_ data: [ReviewCard]) -> Void,
                                     failure: @escaping (_ error: String) -> Void) {
        Alamofire.request(URLAdress.getCompanyReviews(company: id)).responseJSON { (response) in
            if(response.result.isSuccess) {
                if((response.response?.statusCode)! == 200) {
                    let data = JSON(data: response.data!)
                    var reviews = [ReviewCard]()
                    for i in 0...4 {
                        let review = ReviewCard(name: data["review"][i]["author_name"].stringValue,
                                                      description: data["review"][i]["text"].stringValue,
                                                      stars: data["review"][i]["rating"].intValue)
                        reviews.append(review)
                    }
                    
                    success(data["placeId"].stringValue, reviews)
                } else {
                    failure("Data not found!")
                }
            } else {
                failure("Connection error!")
            }
        }
    }
    
}
