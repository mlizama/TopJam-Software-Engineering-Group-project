//
//  ProfileViewController.swift
//  TopJam
//
//  Created by Sam Langon on 9/20/15.
//  Copyright (c) 2015 TopJam. All rights reserved.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController {
    
	@IBOutlet weak var userName: UILabel!
	
	let user = PersistentUser()
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
		userName.text = user.username()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
