//
//  SignUpViewController.swift
//  TopJam
//
//  Created by Sam Langon on 9/20/15.
//  Copyright (c) 2015 TopJam. All rights reserved.
//

//http://www.briangrinstead.com/blog/ios-uicolor-picker
//color picker^

import Foundation
import UIKit
import MediaPlayer
import CoreData


class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var confirmPassField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var alreadyUserButton: UIButton!
    
    @IBOutlet weak var line4: UIView!
    @IBOutlet weak var line3: UIView!
    @IBOutlet weak var line2: UIView!
    @IBOutlet weak var line1: UIView!
    
    @IBOutlet weak var usernameImage: UIImageView!
    @IBOutlet weak var emailImage: UIImageView!
    
    @IBOutlet weak var password2Image: UIImageView!
    @IBOutlet weak var passwordImage: UIImageView!
    var moviePlayer : MPMoviePlayerController?
    var users = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        registerButton.layer.cornerRadius = 5
        registerButton.layer.borderWidth = 1
        
        alreadyUserButton.layer.cornerRadius = 5
        alreadyUserButton.layer.borderWidth = 1
        
        let usernamePlaceHolder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        userNameField.attributedPlaceholder = usernamePlaceHolder
        
        let emailPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        emailField.attributedPlaceholder = emailPlaceholder
        
        let passwordPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        passField.attributedPlaceholder = passwordPlaceholder
        
        let passwordPlaceholder2 = NSAttributedString(string: "Confirm Password", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        confirmPassField.attributedPlaceholder = passwordPlaceholder2
        
        self.playVideo()
        self.view.addSubview(userNameField!)
        self.view.addSubview(emailField!)
        self.view.addSubview(passField!)
        self.view.addSubview(confirmPassField!)
        self.view.addSubview(line1!)
        self.view.addSubview(line2!)
        self.view.addSubview(line3!)
        self.view.addSubview(line4!)
        self.view.addSubview(registerButton!)
        self.view.addSubview(alreadyUserButton!)
        self.view.addSubview(usernameImage!)
        self.view.addSubview(emailImage!)
        self.view.addSubview(passwordImage!)
        self.view.addSubview(password2Image!)
        
        //disable register button till fields are filled
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
        registerButton.enabled = false
        registerButton.alpha = 0.5;
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func textChanged(sender: NSNotification) {
        if userNameField.hasText() && emailField.hasText() && passField.hasText() && confirmPassField.hasText() {
            registerButton.enabled = true
            registerButton.alpha = 1.0;
        }
        else {
            registerButton.enabled = false
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
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
        if textField == userNameField
        {
            emailField.becomeFirstResponder()
        }
        else if textField == emailField
        {
            passField.becomeFirstResponder()
        }
        else if textField == passField
        {
            confirmPassField.becomeFirstResponder()
        }
        else if textField == confirmPassField
        {
            userNameField.resignFirstResponder()
            self.view.endEditing(true)
        }
        return true
    }
    
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(candidate)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerClicked(sender: AnyObject)
    {
        if userNameField.text!.isEmpty || emailField.text!.isEmpty || passField.text!.isEmpty || confirmPassField.text!.isEmpty
        {
            let alert = UIAlertView()
            alert.title = "Invalid"
            alert.message = "Please fill in all fields"
            alert.addButtonWithTitle("Okay!")
            alert.show()
        }
        else if passField.text! != confirmPassField.text!
        {
            let alert = UIAlertView()
            alert.title = "Invalid"
            alert.message = "Passwords do not match!"
            alert.addButtonWithTitle("Okay!")
            alert.show()
        }
        else if !validateEmail(emailField.text!)
        {
            let alert = UIAlertView()
            alert.title = "Invalid"
            alert.message = "Please enter in a valid email!"
            alert.addButtonWithTitle("Okay!")
            alert.show()
        }
        else
        {
            let urlToCall = "http://52.27.209.129/create_user.php"
            let params = ["username":userNameField.text!, "email":emailField.text!, "password":passField.text!] as Dictionary<String, String>
            
            MyRestAPI.sharedInstance.makeHTTPPostRequest(urlToCall, queryItems: params){ (succeeded: Bool, returnedJSON: JSON) -> () in
                if(succeeded == false) {
                    print("error")
                    let alert = UIAlertView()
                    alert.title = "Please try again"
                    alert.message = "There was an error signing up"
                    alert.addButtonWithTitle("Okay!")
                    alert.show()
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        NSLog("Error")
                    })
                    
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        //create current user to pass through the app
                        let myUser = PersistentUser(returnedJSON: returnedJSON)
                        print(myUser.username())
                        self.saveUser(self.userNameField.text!, email: self.emailField.text!, pass: self.passField.text!)

                        //segue once completed
                        self.performSegueWithIdentifier("signup_segue", sender: nil)
                        NSLog("sign up segue completed")
                    })
                }
            }
        }
    }
    
    func saveUser(name:String, email:String, pass:String) {
        //1
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let entity =  NSEntityDescription.entityForName("CurrentUser", inManagedObjectContext:managedContext)
        
        let person = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        //3
        person.setValue(name, forKey: "username")
        person.setValue(email, forKey: "email")
        person.setValue(pass, forKey: "password")
        
        //4
        do {
            try managedContext.save()
            //5
            users.append(person)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }

}
