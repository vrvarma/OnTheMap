//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Vikas Varma on 8/2/15.
//  Copyright (c) 2015 Vikas Varma. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate{
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    var session: NSURLSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = NSURLSession.sharedSession()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        facebookLoginButton.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        if FBSDKAccessToken.currentAccessToken() != nil {
            
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
        }
        //Hide the nav bar on the login view
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        emailTextField.text = ""
        passwordTextField.text = ""
        //Make the email field the responder
        emailTextField.becomeFirstResponder()
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    //TextField delegate methods
    func textFieldShouldReturn(textField:UITextField)->Bool{
        
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func openUdacitySignUpPage(sender: UIButton) {
        
        UIApplication.sharedApplication().openURL(NSURL(string: OTMClient.Constants.UdacitySignUpURL)!)
        
    }
    
    @IBAction func loginPressed(sender: UIButton) {
        
        OTMClient.sharedInstance().doUdacityLogin(emailTextField.text, password:passwordTextField.text){ (success, errorString) in
            if success {
                
                //println(OTMClient.sharedInstance().sessionId!)
                self.completeLogin()
                
            } else {
                dispatch_async(dispatch_get_main_queue()){
                    
                    OTMClient.alertDialog(self, errorTitle: "Login Failed", action: "OK", errorMsg: errorString!)
                }
            }
        }
    }
    
    //Once user login successfully completes
    //Present the TabBarController
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapTabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    //Facebook Login
    //Delegate Methods.
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if error == nil {
            OTMClient.sharedInstance().facebookLogin(){ (success, errorString) in
                if success {
                    
                    print(OTMClient.sharedInstance().sessionId!)
                    self.completeLogin()
                    
                } else {
                    dispatch_async(dispatch_get_main_queue()){
                        
                        OTMClient.alertDialog(self, errorTitle: "Login Failed", action: "OK", errorMsg: "Facebook authorization cancelled")
                    }
                }
            }
        }else{
            dispatch_async(dispatch_get_main_queue()){
                
                OTMClient.alertDialog(self, errorTitle: "Login Failed", action: "OK", errorMsg: "Error Login using Facebook")
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        OTMClient.sharedInstance().logout {
            (success, errorString) -> Void in
            
            print("Logged out from facebook")
        }
    }
}

