//
//  CurrentUser+CoreDataProperties.swift
//  TopJam
//
//  Created by Sam Langon on 11/18/15.
//  Copyright © 2015 TopJam. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CurrentUser {

    @NSManaged var username: String?
    @NSManaged var email: String?
    @NSManaged var password: String?

}
