//
//  LobbyLinkerViewController.swift
//  TopJam
//
//  Created by Sam Langon on 11/3/15.
//  Copyright © 2015 TopJam. All rights reserved.
//

import Foundation
import UIKit

class LobbyLinkerViewController: UIViewController {
    
    var myLinker = LobbyLinker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myLinker.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showLinker(sender: AnyObject) {
        self.presentViewController(self.myLinker.browser, animated: true, completion: nil)
    }
}

extension LobbyLinkerViewController : LobbyLinkerDelegate {
    
    func connectedDevicesChanged(manager: LobbyLinker, connectedDevices: [String]) {
        
    }
    
    func colorChanged(manager: LobbyLinker, colorString: String) {
        
        
    }
}

