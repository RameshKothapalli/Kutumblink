//
//  Events+CoreDataProperties.swift
//  
//
//  Created by Apple on 08/03/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Events {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Events> {
        return NSFetchRequest<Events>(entityName: "Events");
    }

    @NSManaged public var contacts: String?
    @NSManaged public var eventDate: NSDate?
    @NSManaged public var eventDescription: String?
    @NSManaged public var eventId: Int64
    @NSManaged public var eventTitle: String?
    @NSManaged public var sortOrder: String?

}
