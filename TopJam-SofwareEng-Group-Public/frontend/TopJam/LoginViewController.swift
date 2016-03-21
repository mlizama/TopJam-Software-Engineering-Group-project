
//
//  LoginViewController.swift
//  TopJam
//
//  Created by Sam Langon on 9/20/15.
//  Copyright (c) 2015 TopJam. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import CoreData

var moviePlayer : MPMoviePlayerController?

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var line2: UIView!
    @IBOutlet weak var line1: UIView!
    @IBOutlet weak var usernameImage: UIImageView!
    @IBOutlet weak var passwordImage: UIImageView!
    @IBOutlet weak var splashImageView: UIImageView!
    
    var users = [NSManagedObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //setting a bunch of the UI here and checking for previous user sessions
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        
        registerButton.layer.cornerRadius = 5
        registerButton.layer.borderWidth = 1
        
        let usernamePlaceHolder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        usernameField.attributedPlaceholder = usernamePlaceHolder
        
        let passwordPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        passwordField.attributedPlaceholder = passwordPlaceholder
        
        self.playVideo()
        self.view.addSubview(usernameField!)
        self.view.addSubview(passwordField!)
        self.view.addSubview(line1!)
        self.view.addSubview(line2!)
        
        self.view.addSubview(registerButton!)
        self.view.addSubview(loginButton!)
        self.view.addSubview(usernameImage!)
        self.view.addSubview(passwordImage!)
        self.splashImageView.backgroundColor = UIColor.blackColor()
        self.view.bringSubviewToFront(splashImageView)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "CurrentUser")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            users = results as! [NSManagedObject]
            if results.count > 0 {
                let match = results[0] as! NSManagedObject
                
                usernameField.text = (match.valueForKey("username") as! String)
                passwordField.text = (match.valueForKey("password") as! String)
                let urlToCall = "http://52.27.209.129/get_user.php"
                let params = ["username":usernameField.text!, "password":passwordField.text!] as Dictionary<String, String>
                
                MyRestAPI.sharedInstance.makeHTTPPostRequest(urlToCall, queryItems: params){ (succeeded: Bool, returnedJSON: JSON) -> () in
                    if(succeeded == false) {
                        print("error")
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            NSLog("Error")
                        })
                        
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            if (returnedJSON.isEmpty)
                            {
                                let alert = UIAlertView()
                                alert.title = "Error"
                                alert.message = "Username and Password do not match!"
                                alert.addButtonWithTitle("Okay!")
                                alert.show()
                            }
                            else if (self.usernameField.text!.isEmpty || self.passwordField.text!.isEmpty)
                            {
                                let alert = UIAlertView()
                                alert.title = "Error"
                                alert.message = "Please enter in all fields!"
                                alert.addButtonWithTitle("Okay!")
                                alert.show()
                            }
                            else
                            {
                                let myUser = PersistentUser(returnedJSON: returnedJSON)
                                print(myUser.username())
                                let myUser2 = PersistentUser()
                                print(myUser2.username())
                                
                                //Store username and email to autologin and then preform segue
                                self.saveUser(self.usernameField.text!, pass: self.passwordField.text!)
                                
                                self.performSegueWithIdentifier("login_segue", sender: nil)
                                NSLog("segue for login completed")
                            }
                        })
                    }
                }
            } else {
                self.view.viewWithTag(4)?.hidden = true //hiding the image/splash screen so the user can see the view
                print("no user stored")
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
    func playVideo() ->Bool
    {
        
        let path = NSBundle.mainBundle().pathForResource("concert", ofType:"mov")
        let url = NSURL.fileURLWithPath(path!)
        moviePlayer = MPMoviePlayerController(contentURL: url)
        
        if let player = moviePlayer
        {
            player.view.frame = self.view.bounds
            player.controlStyle = MPMovieControlStyle.None
            player.prepareToPlay()
            player.repeatMode = .One
            player.scalingMode = .AspectFill
            self.view.addSubview(player.view)
            
            return true
            
        }
        return false
    }

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameField
        {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField
        {
            passwordField.resignFirstResponder()
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func loginUser(sender: AnyObject) {
        if usernameField.text!.isEmpty || passwordField.text!.isEmpty {
            let alert = UIAlertView()
            alert.title = "Invalid"
            alert.message = "Please fill in all fields"
            alert.addButtonWithTitle("Working!!")
            alert.show()
        }
        else
        {
            let urlToCall = "http://52.27.209.129/get_user.php"
            let params = ["username":usernameField.text!, "password":passwordField.text!] as Dictionary<String, String>
            
            MyRestAPI.sharedInstance.makeHTTPPostRequest(urlToCall, queryItems: params){ (succeeded: Bool, returnedJSON: JSON) -> () in
                if(succeeded == false) {
                    print("error")
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        NSLog("Error")
                    })
                    
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        if (returnedJSON.isEmpty)
                        {
                            let alert = UIAlertView()
                            alert.title = "Error"
                            alert.message = "Username and Password do not match!"
                            alert.addButtonWithTitle("Okay!")
                            alert.show()
                        }
                        else if (self.usernameField.text!.isEmpty || self.passwordField.text!.isEmpty)
                        {
                            let alert = UIAlertView()
                            alert.title = "Error"
                            alert.message = "Please enter in all fields!"
                            alert.addButtonWithTitle("Okay!")
                            alert.show()
                        }
                        else
                        {
                            let myUser = PersistentUser(returnedJSON: returnedJSON)
							print(myUser.username())
							let myUser2 = PersistentUser()
							print(myUser2.username())
                            
                            //Store username and email to autologin
                            self.saveUser(self.usernameField.text!, pass: self.passwordField.text!)
                            
                            self.performSegueWithIdentifier("login_segue", sender: nil)
                            NSLog("segue for login completed")
                        }
                    })
                }
            }
        }
    }
    
    func saveUser(name:String, pass:String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate        
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("CurrentUser", inManagedObjectContext:managedContext)
        let person = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        person.setValue(name, forKey: "username")
        person.setValue("email", forKey: "email")
        person.setValue(pass, forKey: "password")
        
        
        do {
            try managedContext.save()
            users.append(person)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }

}
