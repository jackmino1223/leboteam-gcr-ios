//
//  CarDetailsViewController.swift
//  gcr-ios
//
//  Created by iOS Developer on 7/18/17.
//  Copyright © 2017 leboprojects. All rights reserved.
//

import UIKit
import AlamofireImage
import ImageSlideshow
import GoogleMaps
import Cosmos
import MessageUI
import PKHUD

class CarDetailsViewController: UITableViewController {
    var carID = ""
    var goToCarCdealerActive = false
    var doneLoading = false
    
    var carDetails : CarDetails? = nil
    
    @IBOutlet var textLabels: [UILabel]!
    @IBOutlet var imageSlideshow: ImageSlideshow!
    @IBOutlet weak var carPrice: UILabel!
    @IBOutlet weak var carMapView: GMSMapView!
    @IBOutlet weak var carDescription: UILabel!
    
    @IBOutlet weak var carMark: UILabel!
    @IBOutlet weak var carModel: UILabel!
    @IBOutlet weak var carYear: UILabel!
    @IBOutlet weak var carWheels: UILabel!
    @IBOutlet weak var carColor: UILabel!
    @IBOutlet weak var carDistance: UILabel!
    @IBOutlet weak var carSpecs: UILabel!
    @IBOutlet weak var carGearBox: UILabel!
    @IBOutlet weak var carSeats: UILabel!
    @IBOutlet weak var carCylinders: UILabel!
    @IBOutlet weak var carInterior: UILabel!
    @IBOutlet weak var carCondition: UILabel!
    
    @IBOutlet weak var dealerLogo: UIImageView!
    @IBOutlet weak var dealerName: UILabel!
    @IBOutlet weak var goToCarDealerButton: UIButton!
    @IBOutlet weak var goToCarDealerArrow: UIImageView!
    
    @IBAction func rentButtonPressed(_ sender: UIBarButtonItem) {
        UIApplication.shared.open(URL(string: (carDetails?.carRentLink)!)! , options: [:], completionHandler: nil)
    }
    @IBAction func callButtonPressed(_ sender: UIButton) {
        guard let number = URL(string: "tel://\(String(describing: (carDetails?.callNumber)!))") else { return }
        UIApplication.shared.open(number)
    }
    @IBAction func smsButtonPressed(_ sender: UIButton) {
        if(MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Hi! I'm interested in your \(String(describing: (carDetails?.carName)!)) car, can I get more details about this car?"
            controller.recipients = [(carDetails?.messageNumber)!]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    @IBAction func emailButtonPressed(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            
            mailComposerVC.setToRecipients([(carDetails?.email)!])
            mailComposerVC.setSubject("Car rent - \(String(describing: (carDetails?.carName)!))")
            mailComposerVC.setMessageBody("Hi! I'm interested in your \((carDetails?.carName)!) car, can I get more details about this car?", isHTML: false)
            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            HUD.flash(.labeledError(title: "", subtitle: "Error!"), delay: 2.0)
        }
    }
    @IBAction func showCarDealerInfo(_ sender: Any) {
        performSegue(withIdentifier: "showDealerInformation", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HUD.show(.progress)
        
        self.view.backgroundColor = AppColors.background
        self.navigationController?.navigationBar.tintColor = AppColors.carTitle
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : AppColors.carTitle]
        
        for text in textLabels {
            text.textColor = AppColors.detailsText
        }
        
        imageSlideshow.backgroundColor = AppColors.background
        imageSlideshow.slideshowInterval = 5.0
        imageSlideshow.pageControlPosition = PageControlPosition.insideScrollView
        imageSlideshow.pageControl.currentPageIndicatorTintColor = AppColors.navigationBar
        imageSlideshow.pageControl.pageIndicatorTintColor = UIColor.white
        imageSlideshow.contentScaleMode = UIViewContentMode.scaleAspectFill
        
        carPrice.backgroundColor = AppColors.priceColor
        carPrice.textColor = AppColors.carTitle
        carPrice.layer.cornerRadius = 10
        
        dealerLogo.layer.backgroundColor = UIColor.white.cgColor
        dealerLogo.layer.borderWidth = 1
        dealerLogo.layer.borderColor = AppColors.carTitle.cgColor
        dealerLogo.layer.cornerRadius = dealerLogo.frame.height/2
        
        if goToCarCdealerActive {
            goToCarDealerArrow.isHidden = true
            goToCarDealerButton.isEnabled = false
        }
        
        APIClient.getCarDetails(id: carID,
                                success: { (data) in
                                    self.carDetails = data
                                    
                                    self.title = self.carDetails?.carName
                                    
                                    var imageImputs = [InputSource]()
                                    for image in (self.carDetails?.carImages)! {
                                        imageImputs.append(AlamofireSource(urlString: image)!)
                                    }
                                    
                                    self.imageSlideshow.setImageInputs(imageImputs)
                                    self.carPrice.text = self.carDetails?.carPrice
                                    self.carDescription.text = self.carDetails?.carDescription
                                    
                                    self.carMark.text = self.carDetails?.carDetailsBrand
                                    self.carModel.text = self.carDetails?.carDetailsModel
                                    self.carYear.text = self.carDetails?.carDetailsYear
                                    self.carWheels.text = self.carDetails?.carDetailsWheels
                                    self.carColor.text = self.carDetails?.carDetailsColor
                                    self.carDistance.text = self.carDetails?.carDetailsDistance
                                    self.carSpecs.text = self.carDetails?.carDetailsSpecs
                                    self.carGearBox.text = self.carDetails?.carDetailsGearBox
                                    self.carSeats.text = self.carDetails?.carDetailsSeats
                                    self.carCylinders.text = self.carDetails?.carDetailsCylinders
                                    self.carInterior.text = self.carDetails?.carDetailsInterior
                                    self.carCondition.text = self.carDetails?.carDetailsCondition
                                    
                                    self.dealerLogo.af_setImage(withURL: (self.carDetails?.carDealerImage)!)
                                    self.dealerName.text = self.carDetails?.carDealerName
                                    DispatchQueue.global(qos: .background).async {
                                        self.mapSetUp((self.carDetails?.carLocationLatitude)!, long: (self.carDetails?.carLocationLongitude)!)
                                    }
                                    self.doneLoading = true
                                    self.tableView.reloadData()
                                    HUD.hide()
                                },
                                failure: { (data) in
                                    HUD.flash(.labeledError(title: "", subtitle: data), delay: 2.0) { _ in
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                })
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = AppColors.background
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        switch indexPath.row {
        case 0:
            if doneLoading { return 175 }
            return 0
        case 1:
            if doneLoading { return 60 }
            return 0
        case 2:
            if doneLoading {
                return CGFloat(carDescription.numberOfVisibleLines * 15) + 60
            }
            return 0
        case 3:
            if doneLoading { return 365 }
            return 0
        case 4:
            if doneLoading { return 70 }
            return 0
        case 5:
            if doneLoading { return 240 }
            return 0
        default : return UITableViewAutomaticDimension
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = " "
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier == "showDealerInformation" {
            let nextVC : DealerViewController = (segue.destination as? DealerViewController)!
            nextVC.dealerID = (carDetails?.carDealerID)!
        }
    }
    
    func mapSetUp(_ lat:Double,long:Double) -> () {
        DispatchQueue.main.async(execute: { () -> Void in
            let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 17.0)
            self.carMapView.camera = camera
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
            marker.map = self.carMapView
        })
    }
}

extension CarDetailsViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
        switch result.rawValue {
        case MessageComposeResult.cancelled.rawValue : HUD.flash(.labeledError(title: "", subtitle: "Canceled"), delay: 1.0)
        default: HUD.flash(.labeledSuccess(title: "", subtitle: "Sent"), delay: 2.0)
        }
    }
}

extension CarDetailsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        switch result.rawValue {
        case MessageComposeResult.cancelled.rawValue : HUD.flash(.labeledError(title: "", subtitle: "Canceled"), delay: 1.0)
        default: HUD.flash(.labeledSuccess(title: "", subtitle: "Sent"), delay: 2.0)
        }
    }
}
