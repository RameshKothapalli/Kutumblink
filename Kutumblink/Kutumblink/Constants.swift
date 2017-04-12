//
//  Constants.swift
//  Teacher
//
//  Created by Chinna Addepally on 4/27/16.
//  Copyright © 2016 iFlyTechSoft. All rights reserved.
//

import Foundation
import UIKit

//User Defaults
let AVAILABLE_LANGUAGES:String = "AvailableLanguages"

let navigationBarColor:UIColor! = UIColor.init(red: 255.0/255.0, green: 192.0/255.0, blue: 1.0/255.0, alpha: 1)

let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
let managedContext = appDelegate.databaseContext

var menuItems:NSMutableArray = []
var profileDictionary:NSDictionary!
var selectedLanguage:String = ""
var selectedBranch:String = ""
var selectedBranchImage:UIImage! = UIImage.init(named: "")



class Constants {
 
    //MARK: Singleton Instance
    static let sharedInstance = Constants()
}

func verifyUrl (urlString: String?) -> Bool {
    //Check for nil
    if let urlString = urlString {
        // create NSURL instance
        if let url = NSURL(string: urlString) {
            // check if your application can open the NSURL instance
            return UIApplication.shared.canOpenURL(url as URL)
        }
    }
    return false
}

extension Array where Element: Equatable {
    
    public func uniq() -> [Element] {
        var arrayCopy = self
        arrayCopy.uniqInPlace()
        return arrayCopy
    }
    
    mutating public func uniqInPlace() {
        var seen = [Element]()
        var index = 0
        for element in self {
            if seen.contains(element) {
                remove(at: index)
            } else {
                seen.append(element)
                index += 1
            }
        }
    }
}
