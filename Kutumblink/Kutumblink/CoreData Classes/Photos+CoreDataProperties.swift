//
//  Photos+CoreDataProperties.swift
//  
//
//  Created by Apple on 13/02/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Photos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photos> {
        return NSFetchRequest<Photos>(entityName: "Photos");
    }

    @NSManaged public var photoId: Int64
    @NSManaged public var photoTitle: String?
    @NSManaged public var photoUrl: String?

}
