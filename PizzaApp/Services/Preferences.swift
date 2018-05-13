//
//  Preferences.swift
//  PizzaApp
//
//  Created by mac on 5/9/18.
//  Copyright © 2018 mobileappscompany. All rights reserved.
//

import Foundation


class Preferences {
    
    struct Keys {
        static let pizzaCount = "pizzaCount"
        static let favorite = "Favorite"
        static let theme = "theme"
        static let ctmToppings = "ctmToppings"
    }

    // read pizza count from User Defaults
    // if no count is present, use the default (20)
    static var pizzaCount: Int {
        let count = UserDefaults.standard.value(forKey: Keys.pizzaCount)
        return (count as? Int) ?? 20
    }
    
    // update the pizza count by saving to user defaults
    class func setPizzaCount(to count: Int) {
        UserDefaults.standard.set(count, forKey: Keys.pizzaCount)
    }
    
    static var ctmToppings: [String]? {
        guard let newToppings = UserDefaults.standard.value(forKey: Keys.ctmToppings)
            else {return [String]()}
        
        return newToppings as? [String]
    }
    
    class func addCtmTopping(_ newTopping: String) {
        var newToppings = [String]()
        if ctmToppings != nil{
           newToppings = ctmToppings!
           newToppings.append(newTopping)
        } else {
           newToppings.append(newTopping)
        }
         UserDefaults.standard.set(newToppings, forKey: Keys.ctmToppings)
    }
    
    
}
