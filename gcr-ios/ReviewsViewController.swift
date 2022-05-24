//
//  ReviewsViewController.swift
//  gcr-ios
//
//  Created by iOS Developer on 7/20/17.
//  Copyright © 2017 leboprojects. All rights reserved.
//

import UIKit
import PKHUD

class ReviewsViewController: UITableViewController {
    var dealerID = ""
    var placeID = ""
    var reviews = [ReviewCard]()
    
    @IBAction func addReviewClicked(_ sender: Any) {
        UIApplication.shared.open(URL(string: URLAdress.getWriteReviewLink(placeID: placeID))! , options: [:], completionHandler: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        HUD.show(.progress)
        
        self.title = "Reviews"
        
        self.view.backgroundColor = AppColors.background
        self.navigationController?.navigationBar.tintColor = AppColors.carTitle
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : AppColors.carTitle]
        
        APIClient.getReviewList(id: dealerID, success: { (id, data) in
            self.placeID = id
            self.reviews = data
            self.tableView.reloadData()
            HUD.hide()
        }, failure: { (error) in
            HUD.flash(.labeledError(title: "", subtitle: error), delay: 2.0) { _ in
                self.navigationController?.popViewController(animated: true)
            }
        })
        
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewsTableViewCell
    
        cell.prepare(data: reviews[indexPath.row])
        return cell
    }
}
