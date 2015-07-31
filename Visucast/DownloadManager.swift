//
//  DownloadManager.swift
//  Visiocast
//
//  Created by Andrew Lowson on 31/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class DownloadManager {
    
    var fileName: String?
    var finalPath: NSURL?
    
    func initiateDownload(downloadURL: NSURL) {
        println("I'm going to start downloading something now")
//        Alamofire.download(.GET, downloadURL, { (temporaryURL, response) in
//            
//            if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
//                
//                fileName = response.suggestedFilename!
//                finalPath = directoryURL.URLByAppendingPathComponent(fileName!)
//                return finalPath!
//            }
//            
//            return temporaryURL
//        }).response { (request, response, data, error) in
//                
//                if error != nil {
//                    println("REQUEST: \(request)")
//                    println("RESPONSE: \(response)")
//                } 
//                
//                if finalPath != nil {
//                    doSomethingWithTheFile(finalPath!, fileName: fileName!)
//                }
//        }
    }
    
}