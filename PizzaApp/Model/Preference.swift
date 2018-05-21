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
