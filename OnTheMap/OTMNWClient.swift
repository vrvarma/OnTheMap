//
//  OTMNWClient.swift
//  OnTheMap
//
//  Created by Vikas Varma on 8/21/15.
//  Copyright (c) 2015 Vikas Varma. All rights reserved.
//

import Foundation


extension OTMClient{

    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            //println(parsedResult)
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    //Implement GET Method
    func taskForGETMethod(urlString: String, parameters: [String : AnyObject],headers:[String:String],completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = parameters
        
        /* 2/3. Build the URL and configure the request */
        let urlString = urlString + OTMClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        if !headers.isEmpty {
            for (key,value) in headers{
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        println(request)
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                completionHandler(result:nil,  error:downloadError)
            } else {
                completionHandler(result: data,  error:nil)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    func taskForPUTMethod(urlString: String, parameters: [String : AnyObject], headers:[String:String], jsonBody: AnyObject, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = parameters
        
        /* 2/3. Build the URL and configure the request */
        let url = NSURL(string: urlString + OTMClient.escapedParameters(mutableParameters))!
        
        let request = NSMutableURLRequest(URL: url)
        //var jsonifyError: NSError? = nil
        request.HTTPMethod = "PUT"
        
        if !headers.isEmpty{
            for (key,value) in headers{
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        //println(jsonBody)
        request.HTTPBody = jsonBody as? NSData
        
        println(request)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                
                completionHandler(result: nil, error: downloadError)
            } else {
                
                completionHandler(result:data, error:nil)
            }
        }
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    
    func taskForPOSTMethod(urlString: String, parameters: [String : AnyObject], headers:[String:String], jsonBody: AnyObject, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = parameters
        
        /* 2/3. Build the URL and configure the request */
        let url = NSURL(string: urlString + OTMClient.escapedParameters(mutableParameters))!
        
        let request = NSMutableURLRequest(URL: url)
        //var jsonifyError: NSError? = nil
        request.HTTPMethod = "POST"
        
        if !headers.isEmpty{
            for (key,value) in headers{
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        //println(jsonBody)
        request.HTTPBody = jsonBody as? NSData
        
        println(request)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                
                completionHandler(result: nil, error: downloadError)
            } else {
                
                completionHandler(result:data, error:nil)
            }
        }
        /* 7. Start the request */
        task.resume()
        
        return task
    }
}