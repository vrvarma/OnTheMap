//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Vikas Varma on 8/16/15.
//  Copyright (c) 2015 Vikas Varma. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet var refresh: UIBarButtonItem!
    @IBOutlet var post: UIBarButtonItem!
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(true)
        refreshData()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(true)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItems = [refresh, post]
        
    }
    
    func refreshData(){
        
        OTMClient.sharedInstance().getStudentLocationData() {success, errorString in
            if success{
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.tableView.reloadData()
                }
            }else {
                dispatch_async(dispatch_get_main_queue()) {
                    OTMClient.alertDialog(self, errorTitle: "Error Retrieving data", action: "OK", errorMsg: errorString!)
                }
            }
        }
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        
        OTMClient.sharedInstance().resetDataModel()
        refreshData()
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return OTMClient.sharedInstance().students.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TableViewCell") as! UITableViewCell
        //get the info
        let student = OTMClient.sharedInstance().students[indexPath.row]
        //Populate the cell graphic
        cell.imageView!.image = UIImage(named: "pin")
        //Student name
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        cell.detailTextLabel!.text = "\(student.mapString)"
        return cell
    }
    
    //The user selected a cell
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //get the info
        let student = OTMClient.sharedInstance().students[indexPath.row]
        let app = UIApplication.sharedApplication()
        var mapString = student.mediaURL
        if !mapString.hasPrefix("http") {
            
            mapString = "http://"+mapString
        }
        //Show the user's weblink
        app.openURL(NSURL(string: mapString)!)
        
    }
    
    @IBAction func logout(sender: UIBarButtonItem) {
        
        OTMClient.sharedInstance().logoutFromUdacity() {success, errorString in
            
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
    
    @IBAction func postPosition(sender: UIBarButtonItem) {
        retrieveUserLocation()
    }
    
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
    
    func showInfoPositionView(){
        dispatch_async(dispatch_get_main_queue()) {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InfoPositionViewController") as! InfoPositionViewController
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
}