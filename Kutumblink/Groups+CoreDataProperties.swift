//
//  Groups+CoreDataProperties.swift
//  
//
//  Created by Apple on 02/03/17.
//
//

import Foundation
import CoreData


extension Groups {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Groups> {
        return NSFetchRequest<Groups>(entityName: "Groups");
    }

    @NSManaged public var createdDate: String?
    @NSManaged public var groupContacts: String?
    @NSManaged public var groupID: Int64
    @NSManaged public var groupImage: String?
    @NSManaged public var groupName: String?
    @NSManaged public var groupOrder: String?

}
