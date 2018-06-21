//
//  Message+CoreDataProperties.swift
//  Messenger
//
//  Created by nguyen van cong linh on 21/06/2018.
//  Copyright © 2018 nguyen van cong linh. All rights reserved.
//
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var text: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var friend: Friend?

}
