//
//  ViewController.swift
//  gcr-ios
//
//  Created by iOS Developer on 7/11/17.
//  Copyright © 2017 leboprojects. All rights reserved.
//

import UIKit
import TBDropdownMenu
import PKHUD
import ReachabilitySwift
import GoogleMobileAds

class MainViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, GADInterstitialDelegate {
    var cars = [CarCard]()
    var selectedFilter = 0
    var currentPage = 0
    var maxCarsShowed = 50
    var requestedCarID = ""
    var reachability: Reachability?
    
    @IBOutlet weak var tableView: UITableView!
    
    var interstitial: GADInterstitial!
    var bannerView: GADBannerView!
    var refreshControl: UIRefreshControl!
    
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

    override func viewDidLoad() {
        
        super.viewDidLoad()
        HUD.show(.progress)
        
        self.view.backgroundColor = AppColors.background
        
        refreshControl = UIRefreshControl()
        let attributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 12)]
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing", attributes: attributes)

        tableView.addSubview(refreshControl)
        self.tableView.refreshControl?.addTarget(self, action: #selector(doRefresh(refreshControl:)), for: .valueChanged)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        setupReachabilityGetData(nil, useClosures: true)
        startNotifier()
        
        interstitial = createAndLoadInterstitial()
        _ = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.showInterstial), userInfo: nil, repeats: true)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.frame = CGRect(x: 0, y: self.view.frame.size.height - bannerView.frame.size.height, width: self.view.frame.size.width, height: bannerView.frame.size.height)
        self.view.addSubview(bannerView)
        bannerView.adUnitID = "ca-app-pub-3173930063697040/4726713424"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        self.tableView.frame = CGRect(x: 0, y:0, width:self.view.frame.width, height: self.view.frame.height - bannerView.frame.size.height)
    }
    
    @objc func showInterstial() {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-9105892500117278/1961158123")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
    
    func startDownloadingData() {
        APIClient.getRecentCarList(page: currentPage, success: { (data) in
            self.cars = data
            self.maxCarsShowed = data.count
            self.tableView.reloadData()
            HUD.hide()
        }, failure: { _ in
            HUD.flash(.labeledError(title: "", subtitle: "Error!"), delay: 2.0)
        })
    }
    
    func setupReachabilityGetData(_ hostName: String?, useClosures: Bool) {
        let reachability = hostName == nil ? Reachability() : Reachability(hostname: hostName!)
        self.reachability = reachability
        
        if useClosures {
            reachability?.whenReachable = { reachability in
                if(self.cars.isEmpty){
                   self.startDownloadingData()
                }
            }
            reachability?.whenUnreachable = { reachability in
                self.askToConnectInternet()
            }
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: reachability)
        }
    }
    
    func startNotifier() {
        do {
            try reachability?.startNotifier()
        } catch {
            return
        }
    }
    
    func stopNotifier() {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        reachability = nil
    }
    
    
    func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            if(self.cars.isEmpty){
                self.startDownloadingData()
            }
        }
    }
    
    deinit {
        stopNotifier()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainViewCell", for: indexPath) as! MainTableViewCell
        if indexPath.row == cars.count-1, indexPath.row < maxCarsShowed - 1 {
            loadingSpinner.startAnimating()
            DispatchQueue.main.async {
                self.downloadData(status: self.selectedFilter, page: (self.currentPage + 1), success: { (data) in
                    self.cars.append(contentsOf: data)
                    self.currentPage += 1
                    self.tableView.reloadData()
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
        performSegue(withIdentifier: "mainViewCarDetailsSegue", sender: selectedCell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = " "
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier == "mainViewCarDetailsSegue" {
            let newVC : CarDetailsViewController = (segue.destination as? CarDetailsViewController)!
            newVC.carID = requestedCarID
        }
    }
    
    func doRefresh(refreshControl: UIRefreshControl) {
        downloadData(status: self.selectedFilter, page: 0, success: { (data) in
            self.cars.removeAll()
            self.tableView.reloadData()
            self.cars = data
            self.tableView.reloadData()
            self.currentPage = 0
            self.tableView.refreshControl?.endRefreshing()
        }, failure: { (error) in
            self.tableView.refreshControl?.endRefreshing()
            HUD.flash(.labeledError(title: "", subtitle: error), delay: 2.0)
        })
    }
    
    func downloadData(status: Int, page: Int, success: @escaping ([CarCard]) -> Void, failure: @escaping (String) -> Void) {
        switch(status) {
        case 0 :
            maxCarsShowed = 50
            APIClient.getRecentCarList(page: page, success: { (data) in
                success(data)
                self.maxCarsShowed = data.count
            }, failure: { (error) in
                failure(error)
            })
            break;
        case 1:
            maxCarsShowed = 200
            APIClient.getAscendingCarList(page: page, success: { (data) in
                success(data)
                self.maxCarsShowed = data.count
            }, failure: { (error) in
                failure(error)
            })
            break;
        case 2:
            maxCarsShowed = 200
            APIClient.getDescendingCarList(page: page, success: { (data) in
                success(data)
                self.maxCarsShowed = data.count
            }, failure: { (error) in
                failure(error)
            })
            break;
        default:
            break;
        }
    }
    
    func askToConnectInternet(){
        HUD.hide()
        let alert = UIAlertController(title: "Cellular Data is Turned Off", message: "Turn on cellular data or use Wi-Fi to access data.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: openSettings))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openSettings(alert: UIAlertAction!) {
        UIApplication.shared.open(URL(string: "App-Prefs:root")!, options: [:], completionHandler: nil)
    }
    
}

extension MainViewController: DropdownMenuDelegate {
    func dropdownMenu(_ dropdownMenu: DropdownMenu, didSelectRowAt indexPath: IndexPath) {
        HUD.show(.progress)
        downloadData(status: indexPath.row, page: 0, success: { (data) in
            self.selectedFilter = indexPath.row
            self.cars.removeAll()
            self.tableView.reloadData()
            self.cars = data
            self.tableView.reloadData()
            self.currentPage = 0
            HUD.hide()
        }, failure: { (error) in
            HUD.flash(.labeledError(title: "", subtitle: error), delay: 2.0)
        })
    }
}
