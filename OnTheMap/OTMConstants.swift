//
//  OTMConstants.swift
//  OnTheMap
//
//  Created by Vikas Varma on 8/2/15.
//  Copyright (c) 2015 Vikas Varma. All rights reserved.
//

import Foundation
import MapKit

extension OTMClient {
    
    // Constants
    struct Constants {
        
        //API and ID Keys
        static let ParseApplicationID: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RESTApiKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        //***************************************************
        //URLS
        //***************************************************
        
        //Udacity API
        static let UdacitySignUpURL: String = "https://www.udacity.com/account/auth#!/signup"
        static let UdacitySessionURL: String = "https://www.udacity.com/api/session"
        static let UdacityUserURL: String = "https://www.udacity.com/api/users/"
        
        
        //Parse API
        static let ApiParseAPIURL = "https://api.parse.com/1/classes/StudentLocation/"
        
    }
    
    struct UdacityUserInfo{
        var firstName: String? = ""
        var lastName: String? = ""
        var userId: String? = ""
        var objectId:String?=nil
        var Email: String? = ""
        var mapString:String?=""
        var weblink : String? = ""
        var longitude: Double?
        var latitude:Double?
    }

    
    
}