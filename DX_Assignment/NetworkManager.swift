//
//  NetworkManager.swift
//  DX_Assignment
//
//  Created by Usha Chawla on 11/13/19.
//  Copyright © 2019 Usha Chawla. All rights reserved.
//

import UIKit
import Reachability

/// Protocol for listenig network status change
public protocol NetworkStatusListener: class {
    func networkStatusDidChange(status: Reachability.Connection)
}


class NetworkManager {
    
    static let sharedInstance = NetworkManager()
    private var reachability: Reachability!
    //Array of delegates which are interested to listen to network status change
    var listeners = [NetworkStatusListener]()
    
    /// Starts monitoring the network availability status
    func startMonitoring() {
        self.reachability = try! Reachability()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged(note:)),
                                               name: Notification.Name.reachabilityChanged,
                                               object: reachability)
        do {
            try reachability.startNotifier()
        } catch let error {
            print("Error occured while starting reachability notifications : \(error.localizedDescription)")
        }
    }
    
    /// Stops monitoring the network availability status
    func stopMonitoring() {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name.reachabilityChanged,
                                                  object: reachability)
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .cellular:
            online = true
            break
        case .wifi:
            online = true
            break
        case .none:
            online = false
            break
        case .unavailable:
            online = false
            break
        }
        
        // Sending message to each of the delegates
        for listener in listeners {
            listener.networkStatusDidChange(status: reachability.connection)
        }
    }
    
    
    /// Adds a new listener to the listeners arrayå
    func addListener(listener: NetworkStatusListener) {
        listeners.append(listener)
    }
    
    /// Removes a listener from listeners array
    func removeListener(listener: NetworkStatusListener) {
        listeners = listeners.filter { $0 !== listener}
    }
}

