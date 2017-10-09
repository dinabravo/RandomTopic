//
//  CategoryItem.swift
//  RandomTopic
//
//  Created by Igor Stojakovic on 28/09/2017.
//  Copyright © 2017 stojakovic. All rights reserved.
//

import Foundation

class CategorySetting : NSObject, NSCoding
{
    var name: String
    var active: Bool
    init(name: String, active: Bool)
    {
        self.name = name
        self.active = active
    }
    
    required init(coder aDecoder: NSCoder)
    {
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.active = aDecoder.decodeBool(forKey: "active")
    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.active, forKey: "active")
    }
}
