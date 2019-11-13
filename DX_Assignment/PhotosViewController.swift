//
//  PhotosViewController.swift
//  DX_Assignment
//
//  Created by Usha Chawla on 11/11/19.
//  Copyright © 2019 Usha Chawla. All rights reserved.
//

import UIKit
import Reachability

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let photosTableView = UITableView()
    let webServiceShared = WebServiceManager.webServiceManagerSharedInstance
    var screenTitle : String?
    var rowsArray =  [[String : Any]]()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(photosTableView)
        photosTableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        setTableViewLayout()
        
        photosTableView.delegate = self
        photosTableView.dataSource = self
        photosTableView.register(PhotosTableViewCell.self, forCellReuseIdentifier: "photoCell")
        
        //API call to get data
        getJsonDataFromApi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        networkManager.addListener(listener: self as NetworkStatusListener)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        networkManager.removeListener(listener: self as NetworkStatusListener)
    }
    
    //This method sets constraints for tableview
    func setTableViewLayout() {
        photosTableView.translatesAutoresizingMaskIntoConstraints = false
        
        photosTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        photosTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        photosTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        photosTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    //This method makes call to web API and receives the reponse
    func getJsonDataFromApi() {
        if online{
            webServiceShared.getJsonData { (error, responseData) in
                guard error == nil else{
                    let alert = UIAlertController.init(title: errorTitle, message: error?.localizedDescription, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                    })
                    alert.addAction(ok)
                    DispatchQueue.main.async{
                        self.present(alert, animated: true)
                    }
                    return
                }
                print(responseData)
                self.parseJsonResponse(jsonData: responseData)
            }
        }
        else
        {
            let alert = UIAlertController.init(title: noInternetTitle, message: noInternetMessage, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
            })
            alert.addAction(ok)
            DispatchQueue.main.async{
                self.present(alert, animated: true)
            }
        }
    }
    
    //This method parses the JSON response received from API
    func parseJsonResponse(jsonData : [String : Any]) {
        screenTitle = jsonData["title"] as? String
        rowsArray = jsonData["rows"] as! [[String : Any]]
        
        DispatchQueue.main.async {
            self.navigationItem.title = self.screenTitle
            self.photosTableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    //This method is called when user pulls the screen to refresh the screen
    @objc private func refreshData(_ sender: Any) {
        //Fetch API Data
        if online{
            getJsonDataFromApi()
        }
        else
        {
            let alert = UIAlertController.init(title: noInternetTitle, message: noInternetMessage, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
            })
            alert.addAction(ok)
            DispatchQueue.main.async{
                self.present(alert, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PhotosTableViewCell = PhotosTableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "photoCell")
        
        let rowDictionary = rowsArray[indexPath.row]
        if !(rowDictionary["title"] is NSNull){
            cell.titleLabel.text = rowDictionary["title"] as? String
        }
        if !(rowDictionary["description"] is NSNull) {
            let detailString = rowDictionary["description"] as! String
            cell.descriptionLabel.text = detailString
        }
        if !(rowDictionary["imageHref"] is NSNull) {
            webServiceShared.getImageFromUrl(urlString: (rowDictionary["imageHref"] as! String)) { (error, imageData) in
                guard error == nil else {
                    print(error!)
                    return
                }
                DispatchQueue.main.async {
                    if let rowImage = UIImage.init(data: imageData!){
                        cell.photoImageView.image = rowImage
                    } else {
                        cell.photoImageView.image = UIImage(named: "no-image")
                    }
                    cell.setNeedsLayout()
                }
            }
        }
        else
        {
            DispatchQueue.main.async {
                cell.photoImageView.image = UIImage(named: "no-image")
                cell.setNeedsLayout()
            }
        }
        return cell
    }
}
extension PhotosViewController: NetworkStatusListener {
    //Detects network status change and performs action based on network status
    func networkStatusDidChange(status: Reachability.Connection) {
        DispatchQueue.main.async {
            if online {
                self.getJsonDataFromApi()
            } else {
                self.navigationItem.title = ""
                self.rowsArray = []
                self.photosTableView.reloadData()
                let alert = UIAlertController.init(title: noInternetTitle, message: noInternetMessage, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                })
                alert.addAction(ok)
                DispatchQueue.main.async{
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
