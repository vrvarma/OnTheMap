//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Vikas Varma on 8/16/15.
//  Copyright (c) 2015 Vikas Varma. All rights reserved.
//

import Foundation

struct StudentInformation {
    
    var uniqueKey : String = ""
    var firstName : String = ""
    var lastName  : String = ""
    var mapString : String = ""
    var mediaURL  : String = ""
    var latitude  : Double  = 0
    var longitude : Double  = 0
    var objectId  : String = ""
    var updatedAt : String = ""
    
    init(dictionary: [String : AnyObject]) {
        
        self.uniqueKey = dictionary["uniqueKey"] as! String
        self.firstName = dictionary["firstName"] as! String
        self.lastName = dictionary["lastName"] as! String
        self.mediaURL = dictionary["mediaURL"] as! String
        self.mapString = dictionary["mapString"] as! String
        self.latitude = dictionary["latitude"] as! Double
        self.longitude = dictionary["longitude"] as! Double
        self.objectId = dictionary["objectId"] as! String
        self.updatedAt = dictionary["updatedAt"] as! String
        
    }
    
    static func studentInformationFromResults(results: [[String : AnyObject]]) -> [StudentInformation] {
        var students = [StudentInformation]()
        
        for result in results {
            students.append( StudentInformation(dictionary: result) )
        }
        
        return students
        
    }
}