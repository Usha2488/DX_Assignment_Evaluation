//
//  WebServiceManager.swift
//  DX_Assignment
//
//  Created by Usha Chawla on 11/11/19.
//  Copyright © 2019 Usha Chawla. All rights reserved.
//

import UIKit

class WebServiceManager: NSObject {
    
    static let webServiceManagerSharedInstance = WebServiceManager()
    
    func getJsonData(completionHandler: @escaping(_ error: Error?, _ dataModel: [String:Any])-> Void) {
        let requestUrl = URL(string: "https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json")!
        
        var dataRequest = URLRequest(url: requestUrl)
        dataRequest.httpMethod = "GET"
        
        let session = URLSession.shared
        let task = session.dataTask(with: dataRequest) { (data, response, error) in
            guard error == nil else {
                completionHandler(error, [:])
                return
            }
            guard let responseData = data else {
                completionHandler(error, [:])
                return
            }
            let utf8Data = String(decoding: responseData, as: UTF8.self).data(using: .utf8)
            guard let jsonResponse = (try? JSONSerialization.jsonObject(with: utf8Data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
                print("Error occurred while json serialization")
                completionHandler(error, [:])
                return
            }
            print(jsonResponse)
            completionHandler(nil, jsonResponse)
            return
        }
        task.resume()
    }
  
  func getImageFromUrl(urlString: String, completionHandler: @escaping(_ error: Error?, _ dataModel: Data?)-> Void) {
    let requestUrl = URL(string: urlString)!
    
    let dataRequest = URLRequest(url: requestUrl)
    
    let session = URLSession.shared
    let task = session.dataTask(with: dataRequest) { (data, response, error) in
      guard error == nil else {
        completionHandler(error, nil)
        return
      }
      guard let responseData = data else {
        completionHandler(error, nil)
        return
      }
      completionHandler(nil, responseData)
      return
    }
    task.resume()
  }
    
}
