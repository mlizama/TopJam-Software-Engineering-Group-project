//
//  PersistentUser.swift
//  TopJam
//
//  Created by Matt Messa on 11/16/15.
//  Copyright © 2015 TopJam. All rights reserved.
//

import Foundation

class PersistentUser : NSObject
{
	init(returnedJSON: JSON)
	{
		NSUserDefaults.standardUserDefaults().setObject(returnedJSON[0]["username"].stringValue, forKey: "name")
		NSUserDefaults.standardUserDefaults().setObject(returnedJSON[0]["email"].stringValue, forKey: "email")
		NSUserDefaults.standardUserDefaults().setObject(returnedJSON[0]["password"].stringValue, forKey: "password")
	}
	
	override init()
	{}
	
	func username() -> String
	{
		 return NSUserDefaults.standardUserDefaults().objectForKey("name")! as! String
	}
	
	func email() -> String
	{
		return NSUserDefaults.standardUserDefaults().objectForKey("email")! as! String
	}
	
	func password() -> String
	{
		return NSUserDefaults.standardUserDefaults().objectForKey("password")! as! String
	}
	
}