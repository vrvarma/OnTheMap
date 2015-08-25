//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Vikas Varma on 8/16/15.
//  Copyright (c) 2015 Vikas Varma. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class MapViewController: UIViewController ,MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet var post: UIBarButtonItem!
    @IBOutlet var refresh: UIBarButtonItem!
    
    var isRefreshData = false
    
    var annotations = [MKPointAnnotation]()
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(true)
        refreshData()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(true)
        mapView.showAnnotations(mapView.annotations, animated: true)
        dispatch_async(dispatch_get_main_queue(), {
            let center = self.mapView.centerCoordinate
            self.mapView.centerCoordinate = center
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up mapViewDelegate.
        mapView.delegate = self
        navigationItem.rightBarButtonItems = [refresh, post]
        activityIndicatorView.hidesWhenStopped = true
    }
    
    @IBAction func logout(sender: UIBarButtonItem) {
        
        OTMClient.sharedInstance().logout() {success, errorString in
            
            if success{
                
                dispatch_async(dispatch_get_main_queue()){
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                
                dispatch_async(dispatch_get_main_queue()){
                    
                    OTMClient.alertDialog(self, errorTitle: "Error Logging Out", action: "OK", errorMsg: errorString!)
                }
            }
        }
    }
    
    //UIMapView Delegate Methods
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        dispatch_async(dispatch_get_main_queue()){
            
            var mapString = view.annotation.subtitle!
            if !mapString.hasPrefix("http") {
                mapString = "http://"+mapString
            }
            UIApplication.sharedApplication().openURL(NSURL(string: mapString)!)
        }
    }
    
    //Method to retrieve the data
    private func refreshData(){
        
        if isRefreshData {
            OTMClient.sharedInstance().resetDataModel()
        }
        
        activityIndicatorView.startAnimating()
        OTMClient.sharedInstance().getStudentLocationData() {success, errorString in
            
            if success{
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    var annotations = [AnyObject]()
                    for student in OTMClient.sharedInstance().students{
                        
                        var annotation: AnyObject! = self.buildAnnotationFromStudent(student) as AnyObject
                        annotations.append(annotation)
                    }
                    self.mapView.addAnnotations(annotations)
                    self.activityIndicatorView.stopAnimating()
                }
            } else {
                self.activityIndicatorView.stopAnimating()
                OTMClient.alertDialog(self, errorTitle: "Error Retrieving data", action: "OK", errorMsg: errorString!)
            }
        }
        isRefreshData = false
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        
        //Get a fresh set of data
        isRefreshData = true
        refreshData()
    }

    //Method to build the MKPoint annotation from StudentInformation struct
    func buildAnnotationFromStudent(student :StudentInformation)-> MKPointAnnotation{
        
        var annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
        annotation.title = "\(student.firstName) \(student.lastName)"
        annotation.subtitle = student.mediaURL
        return annotation
    }
    
    @IBAction func postPosition(sender: UIBarButtonItem) {
        retrieveUserLocation()
    }
    
    //Method to check whether the user already exists in the 
    //Parse API database.
    func retrieveUserLocation(){
        OTMClient.sharedInstance().retrieveMyLocation(){ (success, errorString) in
            if success {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    let alertController = self.buildAlertDialog()
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }else{
                //User doesn't exist in parse database
                self.showInfoPositionView()
            }
        }
    }
    
    //Alert dialog to confirm with the user that he/she wants to overwrite the data
    func buildAlertDialog() -> UIAlertController{
        
        var confirm = UIAlertController(title: "You have already posted a location", message: "Do you want to overwrite the current location?", preferredStyle: UIAlertControllerStyle.Alert)
        
        //Overwrite button just closes the dialog
        confirm.addAction(UIAlertAction(title: "Overwrite",style: UIAlertActionStyle.Default, handler: {
            action in
            self.showInfoPositionView()
        }))
        
        //Cancel button
        var alertCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel,handler: nil)
        confirm.addAction(alertCancel)
        return confirm
    }
    
    //Method to show the InfoPositonViewController
    func showInfoPositionView(){
        dispatch_async(dispatch_get_main_queue()) {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InfoPositionViewController") as! InfoPositionViewController
            self.presentViewController(controller, animated: true, completion: {
                self.isRefreshData = true
            })
        }
    }
}