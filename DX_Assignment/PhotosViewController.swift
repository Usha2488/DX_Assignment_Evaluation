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
  var screenTitle : String?
  var rowsArray =  [[String : Any]]()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    getJsonDataFromApi()
    self.view.addSubview(photosTableView)
    photosTableView.translatesAutoresizingMaskIntoConstraints = false
    setTableViewLayout()
    
    photosTableView.delegate = self
    photosTableView.dataSource = self
    photosTableView.register(UITableViewCell.self, forCellReuseIdentifier: "photoCell")
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.navigationItem.title = screenTitle
    
  }
  
  func setTableViewLayout() {
    photosTableView.topAnchor.constraint(equalTo:view.safeAreaLayoutGuide.topAnchor).isActive = true
    photosTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
    photosTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    photosTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
  }
  
  func getJsonDataFromApi() {
    webServiceShared.getJsonData { (error, responseData) in
      guard error == nil else{
        print(error!)
        return
      }
      print(responseData)
      self.parseJsonResponse(jsonData: responseData)
    }
  }
  
  func parseJsonResponse(jsonData : [String : Any]) {
    screenTitle = jsonData["title"] as? String
    rowsArray = jsonData["rows"] as! [[String : Any]]
    
    DispatchQueue.main.async {
      self.photosTableView.reloadData()
    }
  }
  
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return rowsArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath)
    let rowDictionary = rowsArray[indexPath.row]
    if rowDictionary["title"] != nil{
      cell.textLabel?.text = rowDictionary["title"] as? String
    }
    
    if rowDictionary["description"] != nil  {
      cell.detailTextLabel?.text = rowDictionary["description"] as? String
    }
    
    if !(rowDictionary["imageHref"] is NSNull) {
      webServiceShared.getImageFromUrl(urlString: (rowDictionary["imageHref"] as! String)) { (error, imageData) in
        guard error == nil else
        {
          print(error!)
          return
        }
        DispatchQueue.main.async {
          cell.imageView?.image = UIImage.init(data: imageData!)
          cell.setNeedsLayout()
        }
      }
    }
    return cell
  }
  
}

