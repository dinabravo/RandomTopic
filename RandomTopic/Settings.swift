//
//  Settings.swift
//  RandomTopic
//
//  Created by Dina Bravo Stojakovic on 07/10/2017.
//  Copyright © 2017 stojakovic. All rights reserved.
//

import UIKit



final class Settings
{
    public var changed: Bool = false
    private var categories: [CategorySetting] = []
    
    private init()
    {
        load()
    }
    
    static let instance = Settings()
    
    func getCategories() -> [CategorySetting]
    {
        return categories
    }
    
    func addCategory(name: String)
    {
       if categories.first(where: { $0.name == name }) == nil
        {
            let cat: CategorySetting = CategorySetting(name: name, active: true)
            categories.append(cat)
            
            save()
        }
    }
    
   
    func setCategoryActive(name: String, active: Bool)
    {
        if let cat: CategorySetting = categories.first(where: { $0.name == name })
        {
            cat.active = active
            save()
            self.changed = true
        }
    }
    
    func getActiveCategories() -> [CategorySetting]
    {
        return categories.filter{$0.active == true}
    }
    
    func save()
    {
        let data = NSKeyedArchiver.archivedData(withRootObject: categories)
        UserDefaults.standard.set(data, forKey: "categories")
    }
    
    func load()
    {
        if let data = UserDefaults.standard.object(forKey: "categories") as? Data
        {
            categories = NSKeyedUnarchiver.unarchiveObject(with: data) as! [CategorySetting]
        }
    }
}
