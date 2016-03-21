//
//  LobbyViewController.swift
//  TopJam
//
//  Created by Sam Langon on 9/20/15.
//  Copyright (c) 2015 TopJam. All rights reserved.
//

import UIKit

class LobbyViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var createLobby: UIButton!
    @IBOutlet weak var joinLobby: UIButton!
    @IBOutlet weak var navBar: UINavigationItem!
    
    @IBOutlet weak var lobbyName: UITextField!
    @IBOutlet weak var lobbyPassword: UITextField!
    let user = PersistentUser()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //myLinker.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        let namePlaceholder = NSAttributedString(string: "Lobby Name", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        lobbyName.attributedPlaceholder = namePlaceholder
        
        let passwordPlaceholder = NSAttributedString(string: "Lobby Password", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        lobbyPassword.attributedPlaceholder = passwordPlaceholder
        
//        createLobby.layer.cornerRadius = 5
//        createLobby.layer.borderWidth = 1
//        
//        joinLobby.layer.cornerRadius = 5
//        joinLobby.layer.borderWidth = 1
//        
        // Do any additional setup after loading the view, typically from a nib.
        //UINavigationBar.appearance().barTintColor = UIColor(red: 0.22, green: 0.67, blue: 0.96, alpha: 1.0)
        //UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        //UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == lobbyName
        {
            lobbyPassword.becomeFirstResponder()
        }
        else if textField == lobbyPassword
        {
            lobbyPassword.resignFirstResponder()
        }
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func createLobbyButton(sender: AnyObject) {
        
        am_host = true
        
        if lobbyName.text!.isEmpty || lobbyPassword.text!.isEmpty
        {
            let alert = UIAlertView()
            alert.title = "Invalid"
            alert.message = "Please fill in all fields"
            alert.addButtonWithTitle("Okay!")
            alert.show()
        }
        else
        {
            let urlToCall = "http://52.27.209.129/build_room.php"
            let params = ["owner":user.username(), "lobby_name":lobbyName.text!, "lobby_password":lobbyPassword.text!] as Dictionary<String, String>
            
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
                        global_lobby = self.lobbyName.text!
                        print(global_lobby)
                        
                        //segue once completed
                        self.performSegueWithIdentifier("lobby_success", sender: nil)
                        NSLog("segue for login completed")
                    })
                }
            }
        }
        
    }

    @IBAction func joinLobby(sender: AnyObject) {
        
        am_host = false

        
        if lobbyName.text!.isEmpty || lobbyPassword.text!.isEmpty
        {
            let alert = UIAlertView()
            alert.title = "Invalid"
            alert.message = "Please fill in all fields"
            alert.addButtonWithTitle("Okay!")
            alert.show()
        }
        else
        {
            let urlToCall = "http://52.27.209.129/get_lobby.php"
            let params = ["lobby_name":lobbyName.text!, "lobby_password":lobbyPassword.text!] as Dictionary<String, String>
            
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
                        print(returnedJSON)
                        if (returnedJSON.isEmpty)
                        {
                            let alert = UIAlertView()
                            alert.title = "Error"
                            alert.message = "Lobby name and password do not match!"
                            alert.addButtonWithTitle("Okay!")
                            alert.show()
                        }
                        else
                        {
                            //create current user to pass through the app
                            global_lobby = self.lobbyName.text!
                            print(global_lobby)
                            
                            //segue once completed
                            self.performSegueWithIdentifier("lobby_success", sender: nil)
                            NSLog("segue for login completed")
                            
                        }
                        
                    })
                }
            }
        }
        
    }
}
extension LobbyViewController : LobbyLinkerDelegate {
    
    func connectedDevicesChanged(manager: LobbyLinker, connectedDevices: [String]) {
        
    }
    
    func colorChanged(manager: LobbyLinker, colorString: String) {
        
        
    }
}