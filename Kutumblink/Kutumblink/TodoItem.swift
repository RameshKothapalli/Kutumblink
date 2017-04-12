//
//  TodoItem.swift
//  TodoNotificationsTutorial
//
//  Created by Jason Newell on 1/28/15.
//  Copyright (c) 2015 Jason Newell. All rights reserved.
//

import Foundation

struct TodoItem {
    var title: String
    var deadline: Date
    var UUID: String
    var description: String
    var contacts: String

    init(deadline: Date, title: String, UUID: String,description:String,contacts:String)  {
        self.deadline = deadline
        self.title = title
        self.UUID = ""
        self.description = description
        self.contacts = contacts

    }
    
    var isOverdue: Bool {
        return (Date().compare(self.deadline) == ComparisonResult.orderedDescending) // deadline is earlier than current date
    }
}
