//
//  Preferences.swift
//  PizzaApp
//
//  Created by mac on 5/9/18.
//  Copyright © 2018 mobileappscompany. All rights reserved.
//

import Foundation
import Firebase

typealias toppings = ([String])->Void

class Preferences {
    
    struct Keys {
        static let pizzaCount = "pizzaCount"
        static let favorite = "favorite"
        static let theme = "theme"
        static let toppings = "toppings"
    }
    static let toppingsRef = Database.database().reference(withPath: Keys.toppings)

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
    
    
    class func getToppings (completion: @escaping toppings){
            Preferences.toppingsRef.observe(.value, with: { snapshot in
            if let value = snapshot.value as? [String]{
                completion(value)
            }
            })
    }
    
    
    class func addCtmTopping(_ newTopping: [String]) {
        
//        Preferences.getToppings(){ toppings in
//            var newToppings = [String]()
//            if toppings.count != 0 {
//                newToppings = toppings
//                newToppings.append(newTopping)
//            } else {
//                newToppings.append(newTopping)
//            }
//            Preferences.toppingsRef.setValue( newToppings)
//        }
    Preferences.toppingsRef.setValue(newTopping)
    }
}
