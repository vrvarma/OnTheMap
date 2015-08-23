//
//  InfoPositionViewController.swift
//  OnTheMap
//
//  Created by Vikas Varma on 8/17/15.
//  Copyright (c) 2015 Vikas Varma. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class InfoPositionViewController : UIViewController, UITextFieldDelegate,UIWebViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var locationTextField: UITextField!
    
    
    @IBOutlet weak var whereRULabel: UILabel!
    
    @IBOutlet weak var urlTextField: UITextField!
    
    @IBOutlet weak var findOnMapButton: UIButton!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var showBrowserButton: UIButton!
    
    @IBAction func cancelDialog(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlTextField.delegate = self
        locationTextField.delegate = self
        activityIndicatorView.hidesWhenStopped = true
        webView.delegate = self
        initialState()
    }
    
    
    func initialState(){
        
        mapView.hidden = true
        webView.hidden = true
        urlTextField.hidden = true
        showBrowserButton.hidden = true
        submitButton.hidden=true
        submitButton.enabled = false
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(true)
    }
    
    @IBAction func findOnMapPressed(sender: UIButton) {
        
        if locationTextField.text.isEmpty{
            
            OTMClient.alertDialog(self, errorTitle: "Invalid Location", action: "OK", errorMsg: "Please type in the location ")
        }
        else{
            
            activityIndicatorView.startAnimating()
            
            getLocationFromString(locationTextField.text, withCompletion: { (location, error) -> () in
                
                if let error = error {
                    
                    println("getLocationFromString error \(error)")
                    self.activityIndicatorView.stopAnimating()
                    OTMClient.alertDialogWithHandler(self, errorTitle: "Invalid Location", action: "OK", errorMsg: "Cannot get the location",handler:{
                        
                        (alertActionOK) -> Void in
                        self.findOnMapButton.hidden = false
                    })
                } else {
                    
                    println("location coordinates \(location)")
                    
                    dispatch_async(dispatch_get_main_queue()){
                        
                        var span = MKCoordinateSpanMake(0.2, 0.2)
                        var region = MKCoordinateRegion(center: location!.coordinate, span: span)
                        
                        self.mapView.setRegion(region, animated: true)
                        
                        var annotation = MKPointAnnotation()
                        annotation.coordinate = location!.coordinate
                        annotation.title = "\(OTMClient.sharedInstance().udacityUser.firstName!) \(OTMClient.sharedInstance().udacityUser.lastName!)"
                        annotation.subtitle = OTMClient.sharedInstance().udacityUser.weblink
                        
                        self.urlTextField.text = OTMClient.sharedInstance().udacityUser.weblink
                        
                        self.mapView.hidden=false
                        self.urlTextField.hidden = false
                        self.submitButton.hidden=false
                        self.showBrowserButton.hidden=false
                        
                        self.locationTextField.hidden=true
                        self.findOnMapButton.hidden = true
                        self.whereRULabel.hidden = true
                        
                        self.mapView.addAnnotation(annotation)
                        self.activityIndicatorView.stopAnimating()
                        
                        self.updateSubmitButtonState(false)
                    }
                    
                }
            })
            
        }
    }
    
    //Update the SubmitButton state
    private func updateSubmitButtonState(enabled:Bool){
        
        isUrlValid = enabled
        submitButton.enabled = enabled
        submitButton.alpha = enabled ? 1.0:0.2
    }
    
    //Method to get the longitude and latitude
    //from the geocode address string
    func getLocationFromString(geoCodeString: String, withCompletion completion: (location: CLLocation?, error: NSError?) -> ()) {
        
        CLGeocoder().geocodeAddressString(geoCodeString) { (location: [AnyObject]!, error: NSError!) -> Void in
            //            println("geocode \(location)")
            if error != nil {
                
                println("error geocoding in function \(error)")
                completion(location: nil, error: error)
                
            } else {
                
                let placemark = location.first as! CLPlacemark
                let coordinates = placemark.location
                // set the string and coordinates
                OTMClient.sharedInstance().udacityUser.mapString = geoCodeString
                OTMClient.sharedInstance().udacityUser.longitude = coordinates.coordinate.longitude
                OTMClient.sharedInstance().udacityUser.latitude = coordinates.coordinate.latitude
                
                completion(location: coordinates, error: nil)
            }
        }
    }
    
    //textfield delegate methods
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool {
            if textField == urlTextField {
                //If text field is modified, disable submit button
                updateSubmitButtonState(false)
                return true
            }
            return true
    }
    
    var isUrlValid = false
    
    //UIWebview delegate methods
    func webViewDidFinishLoad(webView: UIWebView) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        if let currentURL = self.webView.request?.URL?.absoluteString {
            if currentURL != "about:blank" {
                
                urlTextField.text = currentURL
                updateSubmitButtonState(true)
            } else {
                
                urlTextField.enabled = true
                updateSubmitButtonState(false)
            }
        } else {
            
            updateSubmitButtonState(false)
        }
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        
        println("webview errorCode \(error.code)")
        //Not sure why webview returns when the backend forwards the page
        //hack to let the webview proceed.
        if(error.code == -999){
            return
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        let requestObj = NSURLRequest(URL: NSURL(string: "about:blank")!)
        self.webView.loadRequest(requestObj)
        
        OTMClient.alertDialog(self, errorTitle: "Error loading the URL", action: "OK", errorMsg: "\(error.localizedDescription) \(error.code)")
    }
    
    private func updateShowBrowserState(show: Bool){
        
        if(show){
            
            showBrowserButton.setTitle("Show Map", forState: .Normal)
            mapView.hidden = true
            webView.hidden = false
        }
        else{
            
            showBrowserButton.setTitle("Show Browser", forState: .Normal)
            mapView.hidden = false
            webView.hidden = true
        }
    }
    
    @IBAction func showInBrowser(sender: UIButton) {
        
        if showBrowserButton.currentTitle == "Show Map" {
            
            updateShowBrowserState(false)
        } else {
            
            updateShowBrowserState(true)
        }
        
        //println(isUrlValid)
        
        if !isUrlValid && urlTextField.text != ""{
            
            if let components = NSURLComponents(string: urlTextField.text) {
                
                if components.scheme == nil {
                    
                    components.scheme = "http"
                }
                if let url = components.URL {
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                    let requestObj = NSMutableURLRequest(URL: url)
                    requestObj.timeoutInterval = 30
                    self.webView.loadRequest(requestObj)
                    urlTextField.resignFirstResponder()
                    //urlTextField.enabled = false
                }
                
            } else {
                
                OTMClient.alertDialogWithHandler(self, errorTitle: "URL Invalid", action: "OK", errorMsg: "This doesn't look like a valid URL", handler:{
                    (alertActionOK) -> Void in
                    
                    self.urlTextField.enabled = true
                    self.isUrlValid = false
                    self.submitButton.enabled = false
                    self.showBrowserButton.setTitle("Show Browser", forState: .Normal)
                    self.mapView.hidden = false
                    self.webView.hidden = true
                })
            }
        }
    }
    
    @IBAction func submitPressed(sender: UIButton) {
        
        if urlTextField.text.isEmpty{
            
            OTMClient.alertDialog(self, errorTitle: "Invalid URL", action: "OK", errorMsg: "Please input your URL")
        }else{
            
            activityIndicatorView.startAnimating()
            
            OTMClient.sharedInstance().udacityUser.weblink = urlTextField.text
            
            OTMClient.sharedInstance().postMyLocation(){ (success, errorString) in
                if success {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        // stop the activity indicator
                        self.activityIndicatorView.stopAnimating()
                        OTMClient.alertDialogWithHandler(self, errorTitle: "Success", action: "OK", errorMsg: "WebLink Posted",handler: { (alertActionOK) -> Void in
                            // then dismiss view
                            self.dismissViewControllerAnimated(true, completion: nil)
                        })
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue()){
                        self.activityIndicatorView.stopAnimating()
                        OTMClient.alertDialog(self, errorTitle: "WebLink Post Failed", action: "OK", errorMsg: errorString!)
                    }
                }
            }
        }
    }
}