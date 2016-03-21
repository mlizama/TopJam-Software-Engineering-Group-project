//
//  PersistentLobby.swift
//  TopJam
//
//  Created by Matt Messa on 11/30/15.
//  Copyright © 2015 TopJam. All rights reserved.
//

import Foundation

class PersistentLobby : NSObject
{
	init(returnedJSON: JSON)
	{
        NSUserDefaults.standardUserDefaults().setObject(returnedJSON[0]["owner"].stringValue, forKey: "owner")
		NSUserDefaults.standardUserDefaults().setObject(returnedJSON[0]["lobby_name"].stringValue, forKey: "lobby_name")
		NSUserDefaults.standardUserDefaults().setObject(returnedJSON[0]["lobby_password"].stringValue, forKey: "lobby_password")
	}
	
	override init()
	{}
	
	func lobbyName() -> String
	{
		return NSUserDefaults.standardUserDefaults().objectForKey("lobby_name")! as! String
	}
	
	func lobbyPassword() -> String
	{
		return NSUserDefaults.standardUserDefaults().objectForKey("lobby_password")! as! String
	}
	
	
	
}