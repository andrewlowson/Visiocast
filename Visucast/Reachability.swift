//
//  Reachability.swift
//  Visiocast
//
//  Created by Andrew Lowson on 11/08/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//
//  Code taken from stackoverflow result: 
//  http://stackoverflow.com/questions/25398664/check-for-internet-connection-availability-in-swift

import Foundation
import SystemConfiguration


// Class to check if device is attached to a network.
public class Reachability {
    
    class func isConnectedToNetwork() throws -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        return (isReachable && !needsConnection)//


    }
}