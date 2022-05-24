//
//  DealerViewController.swift
//  gcr-ios
//
//  Created by iOS Developer on 7/20/17.
//  Copyright © 2017 leboprojects. All rights reserved.
//

import UIKit
import AlamofireImage
import GoogleMaps
import Cosmos
import PKHUD
import MessageUI

class DealerViewController: UITableViewController {
    var dealerID = ""
    var doneLoading = false
    var reviewsDoneLoading = false
    var dealerDetails : CarDealer? = nil
    
    @IBOutlet var textLabels: [UILabel]!
    
    @IBOutlet weak var dealerLogo: UIImageView!
    @IBOutlet weak var dealerName: UILabel!
    @IBOutlet weak var dealerWorkingHours: UILabel!
    @IBOutlet weak var reviewerName: UILabel!
    @IBOutlet weak var reviewerComment: UILabel!
    @IBOutlet weak var reviewStars: CosmosView!
    @IBOutlet weak var reviewAllReviews: UILabel!
    @IBOutlet weak var dealerDescription: UILabel!
    @IBOutlet weak var dealerLocation: GMSMapView!
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        if(MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Hi! I'm interested in you car deals, can you give me more information about your cars ?"
            controller.recipients = [(dealerDetails?.messageNumber)!]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }

    }
    
    @IBAction func callButtonPressed(_ sender: Any) {
        guard let number = URL(string: "tel://\(String(describing: (dealerDetails?.callNumber)!))") else { return }
        UIApplication.shared.open(number)
    }
    
    @IBAction func emailButtonPressed(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            
            mailComposerVC.setToRecipients([(dealerDetails?.email)!])
            mailComposerVC.setSubject("Car rental information")
            mailComposerVC.setMessageBody("Hi! I'm interested in you car deals, can you give me more information about your cars ?", isHTML: false)
            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            HUD.flash(.labeledError(title: "", subtitle: "Error!"), delay: 2.0)
        }
    }
    
    @IBAction func seeAllReviews(_ sender: Any) {
        performSegue(withIdentifier: "showReviews", sender: nil)
    }
    
    @IBAction func seeAllDealerCars(_ sender: Any) {
        performSegue(withIdentifier: "showDealerCars", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HUD.show(.progress)
        
        self.view.backgroundColor = AppColors.background
        self.navigationController?.navigationBar.tintColor = AppColors.carTitle
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : AppColors.carTitle]

        for label in textLabels {
            label.textColor = AppColors.detailsText
        }
        
        dealerLogo.layer.backgroundColor = UIColor.white.cgColor
        dealerLogo.layer.borderWidth = 3
        dealerLogo.layer.borderColor = AppColors.carTitle.cgColor
        dealerLogo.layer.cornerRadius = dealerLogo.frame.height/2
        
        APIClient.getCarDealer(id: dealerID, success: { (data) in
            self.dealerDetails = data
            
            self.dealerLogo.af_setImage(withURL: (self.dealerDetails?.dealerImage)!)
            
            self.dealerName.text = self.dealerDetails?.dealerName
            self.dealerWorkingHours.text = self.dealerDetails?.dealerWorkingHours
            self.dealerDescription.text = self.dealerDetails?.dealerDescription
            
            DispatchQueue.global(qos: .background).async {
                self.mapSetUp((self.dealerDetails?.dealerLocationLatitude)!, long: (self.dealerDetails?.dealerLocationLongitude)!)
            }
            self.doneLoading = true
            self.tableView.reloadData()
            HUD.hide()
            
            APIClient.getBasicReviewDetails(id: self.dealerID, success: { (data) in
                self.reviewerName.text = data.getReviewName()
                self.reviewerComment.text = data.getReviewDescription()
                self.reviewStars.rating = data.getReviewStars()
                self.reviewAllReviews.text = "(\(data.getReviewStars()))"
                self.reviewsDoneLoading = true
                self.tableView.reloadData()
            }, failure: { (data) in
                
            })
        }, failure: { (data) in
            print(data)
            HUD.flash(.labeledError(title: "", subtitle: data), delay: 2.0) { _ in
                self.navigationController?.popViewController(animated: true)
            }
        })
        navigationItem.title = "Dealer Information"
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = AppColors.background
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        switch indexPath.row {
        case 0:
            if doneLoading { return 190 }
            return 0
        case 1:
            if doneLoading { return 60 }
            return 0
        case 2:
            if doneLoading, reviewsDoneLoading { return 120 }
            return 0
        case 3:
            if doneLoading {
                return CGFloat(dealerDescription.numberOfVisibleLines * 15) + 60
            }
            return 0
        case 4:
            if doneLoading { return 50 }
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
        
        if segue.identifier == "showDealerCars" {
            let newVC : DealerCarListViewController = (segue.destination as? DealerCarListViewController)!
            newVC.dealerID = dealerID
        }
        if segue.identifier == "showReviews" {
            let newVC : ReviewsViewController = (segue.destination as? ReviewsViewController)!
            newVC.dealerID = dealerID
        }
    }
    
    func mapSetUp(_ lat:Double,long:Double) -> () {
        DispatchQueue.main.async(execute: { () -> Void in
            let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 17.0)
            self.dealerLocation.camera = camera
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
            marker.map = self.dealerLocation
        })
    }
}

extension DealerViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
        switch result.rawValue {
        case MessageComposeResult.cancelled.rawValue : HUD.flash(.labeledError(title: "", subtitle: "Canceled"), delay: 1.0)
        default: HUD.flash(.labeledSuccess(title: "", subtitle: "Sent"), delay: 2.0)
        }
    }
}

extension DealerViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        switch result.rawValue {
        case MessageComposeResult.cancelled.rawValue : HUD.flash(.labeledError(title: "", subtitle: "Canceled"), delay: 1.0)
        default: HUD.flash(.labeledSuccess(title: "", subtitle: "Sent"), delay: 2.0)
        }
    }
}

extension UILabel {
    var numberOfVisibleLines: Int {
        let textSize = CGSize(width: CGFloat(self.frame.size.width), height: CGFloat(MAXFLOAT))
        let rHeight: Int = lroundf(Float(self.sizeThatFits(textSize).height))
        let charSize: Int = lroundf(Float(self.font.pointSize))
        return rHeight / charSize
    }
}
