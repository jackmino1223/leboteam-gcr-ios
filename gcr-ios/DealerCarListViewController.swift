//
//  DealerCarListViewController.swift
//  gcr-ios
//
//  Created by iOS Developer on 7/21/17.
//  Copyright © 2017 leboprojects. All rights reserved.
//

import UIKit
import PKHUD

class DealerCarListViewController: UITableViewController {
    var dealerID = ""
    var cars = [CarCard]()
    var currentPage = 0
    var maxCarsShowed = 0
    var requestedCarID = ""
    
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingSpinner.stopAnimating()
        HUD.show(.progress)

        self.view.backgroundColor = AppColors.background
        
        APIClient.getCarDealerCarList(dealerID: dealerID, page: currentPage, success: { (carsNr, data) in
            self.maxCarsShowed = carsNr
            self.cars = data
            self.tableView.reloadData()
            HUD.hide()
            self.loadingSpinner.startAnimating()
        }, failure: { (data) in
            HUD.flash(.labeledError(title: "", subtitle: data), delay: 2.0) { _ in
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dealerCarsCell", for: indexPath) as! DealerCarListTableViewCell
        if indexPath.row == cars.count-1, indexPath.row < maxCarsShowed - 1 {
            loadingSpinner.startAnimating()
            DispatchQueue.main.async {
                self.downloadData(page: (self.currentPage + 1), success: { (data) in
                    self.cars.append(contentsOf: data)
                    self.currentPage += 1
                    self.tableView.reloadData()
                }, failure: { (error) in
                    HUD.flash(.labeledError(title: "", subtitle: error), delay: 2.0)
                })
            }
        } else {
            loadingSpinner.stopAnimating()
        }
        
        cell.prepare(data: cars[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath as IndexPath)!
        requestedCarID = cars[indexPath.row].getCarID()
        performSegue(withIdentifier: "showDealerCarSegue", sender: selectedCell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = " "
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier == "showDealerCarSegue" {
            let newVC : CarDetailsViewController = (segue.destination as? CarDetailsViewController)!
            newVC.carID = requestedCarID
            newVC.goToCarCdealerActive = true
        }
    }
    
    func downloadData(page: Int, success: @escaping ([CarCard]) -> Void, failure: @escaping (String) -> Void) {
        APIClient.getCarDealerCarList(dealerID: dealerID, page: page, success: { (carsNr, data) in
            success(data)
        }, failure: { (error) in
            failure(error)
        })
    }
}
