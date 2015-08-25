//
//  CollectionViewController.swift
//  OnTheMap
//
//  Created by Vikas Varma on 8/24/15.
//  Copyright (c) 2015 Vikas Varma. All rights reserved.
//

import UIKit

class CollectionViewController : UICollectionViewController{
    
    
    @IBOutlet var refresh: UIBarButtonItem!
    @IBOutlet var post: UIBarButtonItem!
    
    var isRefreshData = false
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(true)
        refreshData()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(true)
        collectionView!.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItems = [refresh, post]
        
    }
    
    func refreshData(){
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        if isRefreshData {
            
            OTMClient.sharedInstance().resetDataModel()
        }
        OTMClient.sharedInstance().getStudentLocationData() {success, errorString in
            if success{
                dispatch_async(dispatch_get_main_queue()) {
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    self.collectionView?.reloadData()
                    
                }
            }else {
                dispatch_async(dispatch_get_main_queue()) {
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    OTMClient.alertDialog(self, errorTitle: "Error Retrieving data", action: "OK", errorMsg: errorString!)
                    
                }
            }
        }
        self.isRefreshData = false
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        
        isRefreshData = true
        refreshData()
    }
    
    //CollectionView Delegate Methods
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("OTMCollectionViewCell", forIndexPath: indexPath) as! OTMCollectionViewCell
        
        // Configure the cell
        let student = OTMClient.sharedInstance().students[indexPath.row]
        
        cell.fullNameLabel?.text = "\(student.firstName) \(student.lastName)"
        cell.urlLabel?.text = student.mediaURL
        cell.locationLabel?.text = student.mapString
        
        return cell
        
    }
    
    //To return the student count
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return OTMClient.sharedInstance().students.count
    }
    
    //Handle the cell selection code.
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let collectionCell = collectionView.cellForItemAtIndexPath(indexPath) {
            
            let cell = collectionCell as! OTMCollectionViewCell
            var mapString = cell.urlLabel!.text!
            if !mapString.hasPrefix("http") {
                
                mapString = "http://"+mapString
            }
            
            UIApplication.sharedApplication().openURL(NSURL(string: mapString)!)
        }
    }
    
    //Logout
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
    
    //create or update a new location in parse api
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