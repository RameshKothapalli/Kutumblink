//
//  Messages+CoreDataProperties.swift
//  
//
//  Created by Apple on 13/02/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Messages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Messages> {
        return NSFetchRequest<Messages>(entityName: "Messages");
    }

    @NSManaged public var messageId: Int64
    @NSManaged public var messageTitle: String?
    @NSManaged public var messageUrl: String?

}
