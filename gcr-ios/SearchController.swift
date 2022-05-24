//
//  SearchController.swift
//  gcr-ios
//
//  Created by iOS Developer on 7/17/17.
//  Copyright © 2017 leboprojects. All rights reserved.
//

import UIKit
import TBDropdownMenu
import PKHUD

class SearchController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    var cars = [CarCard]()
    var selectedFilter = 0
    var currentPage = 0
    var maxCarsShowed = 50
    var requestedCarID = ""
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchSomethingLabel: UILabel!
    @IBOutlet weak var foundCars: UILabel!
    @IBOutlet weak var searchSpinner: UIActivityIndicatorView!
    @IBOutlet weak var carsTableView: UITableView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    @IBAction func filterButtonPressed(_ sender: UIBarButtonItem) {
        let item1 = DropdownItem(title: "Recent")
        let item2 = DropdownItem(title: "Price: lowest first")
        let item3 = DropdownItem(title: "Price: highest first")
        
        let items = [item1, item2, item3]
        let menuView = DropdownMenu(navigationController: navigationController!, items: items, selectedRow: selectedFilter)
        menuView.textColor = AppColors.carTitle
        menuView.tableViewBackgroundColor = AppColors.background
        menuView.cellBackgroundColor = AppColors.background
        menuView.highlightColor = AppColors.carTitle
        menuView.delegate = self
        menuView.showMenu()
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        search()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = AppColors.background
        self.navigationController?.navigationBar.tintColor = AppColors.carTitle
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : AppColors.carTitle]
        
        searchField.becomeFirstResponder()
        searchField.delegate = self
        
        carsTableView.delegate = self
        carsTableView.dataSource = self
        carsTableView.backgroundColor = AppColors.background
        carsTableView.separatorInset = UIEdgeInsets.init(top: 0, left: 15, bottom: 0, right: 15)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        search()
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
        if indexPath.row == cars.count-1, indexPath.row < maxCarsShowed - 1  {
            loadingSpinner.startAnimating()
            DispatchQueue.main.async {
                self.downloadData(status: self.selectedFilter, page: (self.currentPage + 1), success: { (data) in
                    self.cars.append(contentsOf: data)
                    self.currentPage += 1
                    self.carsTableView.reloadData()
                }, failure: { (error) in
                    HUD.flash(.labeledError(title: "", subtitle: error), delay: 2.0)
                    self.loadingSpinner.stopAnimating()
                })
            }
        } else {
            loadingSpinner.stopAnimating()
        }
        
        cell.prepare(data: cars[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath as IndexPath)!
        requestedCarID = cars[indexPath.row].getCarID()
        performSegue(withIdentifier: "searchViewCarDetailsSegue", sender: selectedCell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = " "
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier == "searchViewCarDetailsSegue" {
            let newVC : CarDetailsViewController = (segue.destination as? CarDetailsViewController)!
            newVC.carID = requestedCarID
        }
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func downloadData(status: Int, page: Int, success: @escaping ([CarCard]) -> Void, failure: @escaping (String) -> Void) {
        switch(status) {
        case 0 :
//            maxCarsShowed = 50
            APIClient.getSearchRecentCarList(phrase: searchField.text!, page: page, success: { (carsNr, data) in
                self.maxCarsShowed = carsNr
                success(data)
            }, failure: { (error) in
                failure(error)
            })
            break;
        case 1:
//            maxCarsShowed = 200
            APIClient.getSearchAscendingCarList(phrase: searchField.text!, page: page, success: { (carsNr, data) in
                self.maxCarsShowed = carsNr
                success(data)
            }, failure: { (error) in
                failure(error)
            })
            break;
        case 2:
//            maxCarsShowed = 200
            APIClient.getSearchDescendingCarList(phrase: searchField.text!, page: page, success: { (carsNr, data) in
                self.maxCarsShowed = carsNr
                success(data)
            }, failure: { (error) in
                failure(error)
            })
            break;
        default:
            break;
        }
    }
    
    func search() {
        if !(searchField.text?.isEmpty)! {
            searchSpinner.startAnimating()
            searchSomethingLabel.isHidden = true
            
            downloadData(status: selectedFilter, page: 0, success: { (data) in
                self.cars.removeAll()
                self.carsTableView.reloadData()
                self.cars = data
                self.carsTableView.reloadData()
                self.currentPage = 0
                self.searchSpinner.stopAnimating()
                self.foundCars.text = "Found \(self.maxCarsShowed) cars"
                self.foundCars.isHidden = false
                self.carsTableView.isHidden = false
            }, failure: { (error) in
                self.searchSpinner.stopAnimating()
                HUD.flash(.labeledError(title: "", subtitle: error), delay: 2.0)
            })
            dismissKeyboard()
        }
    }
}

extension SearchController: DropdownMenuDelegate {
    func dropdownMenu(_ dropdownMenu: DropdownMenu, didSelectRowAt indexPath: IndexPath) {
        HUD.show(.progress)
        downloadData(status: indexPath.row, page: 0, success: { (data) in
            self.selectedFilter = indexPath.row
            self.cars.removeAll()
            self.carsTableView.reloadData()
            self.cars = data
            self.carsTableView.reloadData()
            self.currentPage = 0
            HUD.hide()
        }, failure: { (error) in
            HUD.flash(.labeledError(title: "", subtitle: error), delay: 2.0)
        })
    }
}
