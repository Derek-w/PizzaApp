//
//  Order.swift
//  PizzaApp
//
//  Created by mac on 5/11/18.
//  Copyright © 2018 mobileappscompany. All rights reserved.
//


import Foundation
import CoreData
import Firebase



struct Order {
    
    
    let ref: DatabaseReference?
    let key: String
    let toppings: [String]
    let date: String 
    var favorite: Bool = false
    
    var toppingString: String {
        return toppings.joined(separator: ", ")
    }

    
//    init?(entity: NSManagedObject){
//        guard
//            let date = entity.value(forKey: Entity.Keys.Pizza.date.rawValue) as? Date,
//            let favorite = entity.value(forKey: Entity.Keys.Pizza.favorite.rawValue) as? Bool,
//            let toppings = entity.value(forKey: Entity.Keys.Pizza.toppings.rawValue) as? [String]
//            else {
//                return nil
//        }
//
//        self.date = date
//        self.favorite = favorite
//        self.toppings = toppings
//
//    }
    init(toppings: [String], date: Date, favorite: Bool, key: String = "") {
        self.ref = nil
        self.key = key
        self.toppings = toppings
        self.date = date.toString()
        self.favorite = favorite
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let toppings = value["toppings"] as? [String],
            let date = value["date"] as? String,
            let favorite = value["favorite"] as? Bool else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.toppings = toppings
        self.date = date
        self.favorite = favorite
    }
    
    func toAnyObject() -> Any {
        return [
            "toppings": toppings,
            "favorite": favorite,
            "date": date
        ]
    }
}

extension Date
{
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd H:m:ss +SSSS"
        return dateFormatter.string(from: self)
    }
}
