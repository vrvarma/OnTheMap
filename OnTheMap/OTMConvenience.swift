//
//  OTMConvenience.swift
//  OnTheMap
//
//  Created by Vikas Varma on 8/12/15.
//  Copyright (c) 2015 Vikas Varma. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import FBSDKLoginKit

extension OTMClient{
    
    //Strip the first 5 characters out of the response
    //from Udacity
    func subdata(data: NSData) -> NSData{
        
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
        return newData
    }
    
    static func alertDialog(viewController:UIViewController, errorTitle: String, action: String, errorMsg:String) -> Void{
        
        let alertController = UIAlertController(title: errorTitle, message: errorMsg, preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(alertAction)
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    static func alertDialogWithHandler(viewController: UIViewController, errorTitle: String, action:String, errorMsg: String, handler: UIAlertAction! -> Void) {
        
        let alertController = UIAlertController(title: errorTitle, message: errorMsg, preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: action, style: UIAlertActionStyle.Cancel, handler: handler)
        alertController.addAction(alertAction)
        dispatch_async(dispatch_get_main_queue(), {
            viewController.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    func doUdacityLogin(email: String!, password: String!, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        
        if IJReachability.isConnectedToNetwork(){
            var parameters = [String : AnyObject] ()
            
            let body = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
            var headers : [String: String] = [
                "Accept": "application/json",
                "Content-Type": "application/json"]
            let task = taskForPOSTMethod(OTMClient.Constants.UdacitySessionURL, parameters: parameters,headers:headers, jsonBody: body.dataUsingEncoding(NSUTF8StringEncoding)!) { JSONResult, error in
                
                /* 3. Send the desired value(s) to completion handler */
                if error != nil {
                    
                    completionHandler(success: false, errorString: error!.localizedFailureReason!)
                } else {
                    
                    var userdata = self.subdata(JSONResult as! NSData)
                    OTMClient.parseJSONWithCompletionHandler(userdata) { (JSONData, parseError) in
                        //If we failed to parse the data return the reason why
                        if parseError != nil{
                            
                            completionHandler(success: false, errorString: parseError?.localizedDescription)
                        }else{
                            if let sessionData = JSONData["session"] as? NSDictionary{
                                println(sessionData)
                                //Save the session and user ids for future use
                                self.sessionId = sessionData["id"]
                                //We have to dig the user ID out of the account dictionary
                                if let accountData = JSONData["account"] as? NSDictionary{
                                    self.userId = accountData["key"] as? String
                                    //We saved the ids so go ahead and grab our user data for later
                                    self.getUdacityInfo({ (success, errorString) -> Void in
                                        if success{
                                            completionHandler(success: success
                                                , errorString: errorString)
                                        }else{
                                            completionHandler(success: success
                                                , errorString: errorString)
                                            
                                        }
                                    })
                                }else{
                                    //Failed to get the userID, so return a generic error
                                    completionHandler(success: false, errorString: "Unable to obtain UserID. Please re-try login.")
                                }
                            }else{
                                if let sessionError = JSONData["error"] as? String{
                                    println(JSONData)
                                    //We got an error, but Udacity sends some different messages. Let's pretty those up
                                    //Fromat the error if needed
                                    var formattedError = self.formatError(sessionError)
                                    //And then show it
                                    completionHandler(success: false, errorString: formattedError)
                                }else{
                                    //Failed to get the sessionID some other way, so return a generic error
                                    completionHandler(success: false, errorString: "Unable to obtain Session ID. Please re-try login.")
                                }
                            }
                        }
                    }
                    
                }
            }
        }else{
            
            completionHandler(success: false, errorString: "Unable to connect to Internet!.")
            
        }
        
    }
    
    func formatError(error: String) -> String{
        
        if error.rangeOfString(":") != nil{
            
            var errArray = error.componentsSeparatedByString(":")
            return errArray[1] as String
        }else{
            
            return error
        }
    }
    
    func facebookLogin(completionHandler: (success: Bool, errorString: String?) -> Void){
        
        if IJReachability.isConnectedToNetwork(){
            
            var headers : [String: String] = [
                "Accept": "application/json",
                "Content-Type": "application/json"]
            
            var parameters = [String : AnyObject] ()
            
            var jsonBody: [String: AnyObject]
            // facebook token
            if FBSDKAccessToken.currentAccessToken() != nil {
                
                // json body with Facebook access token
                let token = FBSDKAccessToken.currentAccessToken().tokenString
                var accessToken: [String: AnyObject] = ["access_token": token]
                jsonBody = ["facebook_mobile": accessToken]
                
            } else {
                
                completionHandler(success: false, errorString: "Facebook couldn't authorize the user")
                return
            }
            var jsonifyError: NSError? = nil
            
            let body = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
            
            let task = taskForPOSTMethod(OTMClient.Constants.UdacitySessionURL, parameters: parameters,headers:headers, jsonBody: body!) { JSONResult, error in
                
                /* 3. Send the desired value(s) to completion handler */
                if error != nil {
                    
                    completionHandler(success: false, errorString: error!.localizedFailureReason!)
                }
                else{
                    let newData = self.subdata(JSONResult as! NSData)
                    
                    OTMClient.parseJSONWithCompletionHandler(newData) { (JSONData, parseError) in
                        // println("JSON User Data: \(JSONData)")
                        
                        if parseError != nil{
                            
                            completionHandler(success: false, errorString: parseError?.localizedDescription)
                        }else{
                            
                            if let sessionData = JSONData["session"] as? NSDictionary{
                                println(sessionData)
                                //Save the session and user ids for future use
                                self.sessionId = sessionData["id"]
                                //save the userId from the account
                                if let accountData = JSONData["account"] as? NSDictionary{
                                    self.userId = accountData["key"] as? String
                                    //We saved the ids so go ahead and grab our user data for later
                                    self.getUdacityInfo({ (success, errorString) -> Void in
                                        if success{
                                            completionHandler(success: success
                                                , errorString: errorString)
                                        }else{
                                            completionHandler(success: success
                                                , errorString: errorString)
                                            
                                        }
                                    })
                                }else{
                                    //Failed to get the userID, so return a generic error
                                    completionHandler(success: false, errorString: "Unable to obtain UserID. Please re-try login.")
                                }
                            }else{
                                if let sessionError = JSONData["error"] as? String{
                                    
                                    //Format the error if needed
                                    var formattedError = self.formatError(sessionError)
                                    //And then show it
                                    completionHandler(success: false, errorString: formattedError)
                                }else{
                                    //Failed to get the sessionID some other way, so return a generic error
                                    completionHandler(success: false, errorString: "Unable to obtain Session ID. Please re-try login.")
                                }
                            }
                        }
                    }
                }
            }
        }else{
            
            completionHandler(success: false, errorString: "Unable to connect to Internet!.")
            
        }
        
    }
    
    func getUdacityInfo(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        if IJReachability.isConnectedToNetwork(){
            var parameters = [String : AnyObject] ()
            var headers = [String: String]()
            let task = taskForGETMethod(Constants.UdacityUserURL + self.userId!, parameters: parameters,headers:headers) { data, error in
                
                /* 3. Send the desired value(s) to completion handler */
                if error != nil {
                    
                    completionHandler(success: false, errorString: error!.localizedFailureReason!)
                }
                else{
                    //subset the data and save the id after checking for errors
                    var userdata = self.subdata(data as! NSData)
                    OTMClient.parseJSONWithCompletionHandler(userdata) { (JSONData, parseError) in
                        //println("JSON User Data: \(JSONData)")
                        
                        if parseError != nil{
                            
                            completionHandler(success: false, errorString: parseError!.localizedDescription)
                        }else{
                            
                            if let userData = JSONData["user"] as? NSDictionary{
                                
                                // println(userData)
                                self.udacityUser.firstName = userData["first_name"] as? String
                                self.udacityUser.lastName = userData["last_name"] as? String
                                self.udacityUser.userId = self.userId
                                self.udacityUser.weblink = userData["website_url"] as? String
                                
                                
                                if let emailData = userData["email"] as? NSDictionary{
                                    
                                    self.udacityUser.Email = emailData["address"] as? String
                                    println(self.udacityUser.Email!)
                                    completionHandler(success: true, errorString: nil)
                                }
                            }
                        }
                    }
                }
                
            }
        }else{
            
            completionHandler(success: false, errorString: "Unable to connect to Internet!.")
            
        }
    }
    
    //***************************************************
    func getStudentLocationData(completionHandler: (success: Bool, errorString: String?) -> Void){
        
        if IJReachability.isConnectedToNetwork(){
            
            getStudenLocationList(OTMClient.sharedInstance().limit,skip: OTMClient.sharedInstance().students.count,completionHandler:completionHandler)
        }else{
            
            completionHandler(success: false, errorString: "Unable to connect to Internet!.")
            
        }
    }
    
    func getStudenLocationList(limit:Int,skip:Int,completionHandler:(success:Bool,errorString: String?) ->Void){
        
        println("limit = \(limit) skip=\(skip) cached student count \(self.students.count)")
        //Set the headers
        var headers : [String: String] = [
            "X-Parse-Application-Id": Constants.ParseApplicationID,
            "X-Parse-REST-API-Key": Constants.RESTApiKey]
        //Set the parameters
        var parameters = ["skip":"\(skip)","limit":"\(limit)","order":"-updatedAt"]
        
        //Invoke the task
        let task = taskForGETMethod(Constants.ApiParseAPIURL, parameters: parameters,headers:headers) { data, error in
            
            /* Send the desired value(s) to completion handler */
            if  error != nil {
                
                completionHandler(success: false, errorString: error!.localizedFailureReason!)
            }else{
                OTMClient.parseJSONWithCompletionHandler(data as! NSData) { (JSONData, parseError) in
                    //If we failed to parse the data return the reason why
                    if parseError != nil{
                        completionHandler(success: false, errorString: parseError!.localizedDescription)
                        //We seem to have gotten the info, so extract and save it
                    }else{
                        
                        var results = JSONData["results"] as! [[String : AnyObject]]
                        //Populate the students array by converting the JSON objects
                        //to StudentInformation objects
                        self.students = self.students + StudentInformation.studentInformationFromResults(results)
                        completionHandler(success: true, errorString: nil)
                    }
                }
            }
        }
    }
    //
    // Post our location to parse ApI
    //
    func postMyLocation( completionHandler: (success: Bool, errorString: String?) -> Void){
        
        if IJReachability.isConnectedToNetwork(){
            // extract the lat and long from the location annotation
            var headers : [String: String] = [
                "X-Parse-Application-Id": Constants.ParseApplicationID,
                "X-Parse-REST-API-Key": Constants.RESTApiKey,
                "Content-Type":"application/json"]
            
            var parameters = [String : AnyObject]()
            //Create the string for posting
            var jsonBody: [String: AnyObject]
            jsonBody = ["uniqueKey": self.udacityUser.userId! as String,"firstName":self.udacityUser.firstName! as String,
                "lastName": self.udacityUser.lastName! as String,
                "mapString":self.udacityUser.mapString! as String,
                "mediaURL":self.udacityUser.weblink! as String,
                "latitude":self.udacityUser.latitude! as Double,
                "longitude":self.udacityUser.longitude! as Double
            ]
            
            if let objectid = self.udacityUser.objectId {
                
                updateParseApiLocation(parameters, headers: headers, jsonBody: jsonBody,completionHandler:completionHandler)
            }else{
                
                createNewLocation(parameters, headers: headers, jsonBody: jsonBody,completionHandler:completionHandler)
            }
        }else{
            
            completionHandler(success: false, errorString: "Unable to connect to Internet!.")
            
        }
    }
    
    //Update the User entry in the ParseApiLocation
    private func updateParseApiLocation(parameters:[String:AnyObject!],headers:[String:String],jsonBody:[String: AnyObject],completionHandler: (success:Bool, errorString:String?) -> Void){
        
        //Update the database.
        var jsonifyError: NSError? = nil
        let body = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        let task = taskForPUTMethod(Constants.ApiParseAPIURL+self.udacityUser.objectId!, parameters: parameters,headers:headers, jsonBody: body!) { data, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if error != nil  {
                
                completionHandler(success: false, errorString: error!.localizedFailureReason!)
            }else{
                
                OTMClient.parseJSONWithCompletionHandler(data as! NSData) { (JSONData, parseError) in
                    //If we failed to parse the data return the reason why
                    if parseError != nil{
                        completionHandler(success: false, errorString: parseError!.localizedDescription)
                    }else{
                        
                        if let sessionError = JSONData["error"] as? String{
                            
                            completionHandler(success: false, errorString: sessionError)
                        }else{
                            
                            completionHandler(success: true, errorString: nil)
                        }
                    }
                }
            }
        }
    }
    
    //
    //Insert a new entry in the ParseApiLocation database.
    //
    private func createNewLocation(parameters:[String:AnyObject!],headers:[String:String],jsonBody:[String: AnyObject],completionHandler: (success:Bool, errorString:String?) -> Void){
        var jsonifyError: NSError? = nil
        let body = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        let task = taskForPOSTMethod(Constants.ApiParseAPIURL, parameters: parameters,headers:headers, jsonBody: body!) { data, error in
            
            /* Send the desired value(s) to completion handler */
            if error != nil {
                
                completionHandler(success: false, errorString: error!.localizedFailureReason!)
            }else{
                
                OTMClient.parseJSONWithCompletionHandler(data as! NSData) { (JSONData, parseError) in
                    //If we failed to parse the data return the reason why
                    if parseError != nil{
                        completionHandler(success: false, errorString: parseError!.localizedDescription)
                    }else{
                        
                        if let sessionError = JSONData["error"] as? String{
                            
                            completionHandler(success: false, errorString: sessionError)
                        }else{
                            
                            completionHandler(success: true, errorString: nil)
                        }
                    }
                }
            }
        }
        
    }
    
    //
    // Get the current users location info from parse ApI
    //
    func retrieveMyLocation( completionHandler: (success: Bool, errorString: String?) -> Void){
        // extract the lat and long from the location annotation
        var headers : [String: String] = [
            "X-Parse-Application-Id": Constants.ParseApplicationID,
            "X-Parse-REST-API-Key": Constants.RESTApiKey,
            "Content-Type":"application/json"]
        
        var parameters = ["where":"{\"uniqueKey\":\"\(self.udacityUser.userId!)\"}"]
        
        //Make the request
        let task = taskForGETMethod(Constants.ApiParseAPIURL, parameters: parameters,headers:headers) { data, error in
            
            /* Send the desired value(s) to completion handler */
            if error != nil {
                
                completionHandler(success: false, errorString: error!.localizedFailureReason!)
            }else{
                
                OTMClient.parseJSONWithCompletionHandler(data as! NSData) { (JSONData, parseError) in
                    //If we failed to parse the data return the reason why
                    if parseError != nil{
                        completionHandler(success: false, errorString: parseError!.localizedDescription)
                    }else{
                        
                        // println(JSONData)
                        var results = JSONData["results"] as! [[String : AnyObject]]
                        if results.count == 0 {
                            completionHandler(success: false, errorString: "User hasn't posted data")
                            return
                        }
                        //Assuming that we will be able to post one
                        //location per user.
                        var result = results.first
                        if let result = result{
                            
                            OTMClient.sharedInstance().udacityUser.objectId = result["objectId"] as? String
                            completionHandler(success: true, errorString: nil)
                        }
                    }
                }
            }
        }
    }
    
    //
    // Logout from application
    // Logout out from facebook, if facebook authentication was used.
    // Else logout from udacity.
    //
    func logout(completionHandler:(success:Bool,errorString:String?)->Void){
        
        if IJReachability.isConnectedToNetwork(){
            if FBSDKAccessToken.currentAccessToken() != nil {
                // clear facebook token
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
                //FBSDKAccessToken.setCurrentAccessToken(nil)
                // and clear session
                self.clearSession()
                //println("Facebook: logged out, token cleared")
                completionHandler(success: true,errorString:nil)
            }else{
                
                //Log out from Udacity
                
                let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
                request.HTTPMethod = "DELETE"
                var xsrfCookie: NSHTTPCookie? = nil
                let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
                for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
                    if cookie.name == "XSRF-TOKEN" {
                        xsrfCookie = cookie
                    }
                }
                if let xsrfCookie = xsrfCookie {
                    request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
                }
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(request) { data, response, error in
                    
                    if error != nil {
                        // Handle error…
                        completionHandler(success: false,errorString: error!.localizedDescription)
                        
                    }
                    else{
                        // and clear session
                        self.clearSession()
                                                completionHandler(success: true,errorString: nil)
                    }
                }
                task.resume()
            }
        } else{
            
            completionHandler(success: false, errorString: "Unable to connect to Internet!.")
            
        }
    }
}
