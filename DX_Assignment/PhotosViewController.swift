//
//  PhotosViewController.swift
//  DX_Assignment
//
//  Created by Usha Chawla on 11/11/19.
//  Copyright © 2019 Usha Chawla. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let photosTableView = UITableView()
    let webServiceShared = WebServiceManager.webServiceManagerSharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Assignment"
        getJsonDataFromApi()
        self.view.addSubview(photosTableView)
        photosTableView.translatesAutoresizingMaskIntoConstraints = false
        setTableViewLayout()
        
        photosTableView.dataSource = self
        photosTableView.register(UITableViewCell.self, forCellReuseIdentifier: "photoCell")
    }
    
    func setTableViewLayout() {
        photosTableView.topAnchor.constraint(equalTo:view.safeAreaLayoutGuide.topAnchor).isActive = true
        photosTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        photosTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        photosTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    func getJsonDataFromApi() {
        webServiceShared.getJsonData { (error, jsonResponseData) in
            guard error == nil else{
                print(error!)
                return
            }
            print(jsonResponseData)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath)
        cell.textLabel?.text = "Test"
        cell.detailTextLabel?.text = "Detailed test"
        return cell
    }
    
}

