//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Vikas Varma on 8/2/15.
//  Copyright (c) 2015 Vikas Varma. All rights reserved.
//

import Foundation

import Foundation
import FBSDKLoginKit

class OTMClient : NSObject {
    
    /* Shared session */
    var session: NSURLSession
    
    var sessionId:AnyObject?
    var userId: String!
    var students: [StudentInformation] = [StudentInformation]()
    
    //The information of the user thats login in.
    var udacityUser =  UdacityUserInfo()
    
    let limit = 100
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    //Shared Instance
    class func sharedInstance() -> OTMClient {
        
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        
        return Singleton.sharedInstance
    }
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    //Reset the data thats being cached
    func resetDataModel() {
        
        //println("Reset data ")
        students.removeAll()
        students = [StudentInformation]()
        
    }
    
    func clearSession() {
        
        self.sessionId = nil
        self.userId = nil
        self.udacityUser.objectId = nil
        resetDataModel()
        FBSDKAccessToken.setCurrentAccessToken(nil)
    }
    
    
}