////
////  Pizza.swift
////  PizzaApp
////
////  Created by mac on 5/8/18.
////  Copyright © 2018 mobileappscompany. All rights reserved.
////
//import Foundation
//import Firebase
//
//
//
//struct Pizza {
//
//    let ref: DatabaseReference?
//    let key: String
//    let toppings: [String]
//    let price: Int?
//
//    init(toppings: [String], price: Int, completed: Bool, key: String = "") {
//        self.ref = nil
//        self.key = key
//        self.toppings = toppings
//        self.price = price
//
//    }
//
//    init?(snapshot: DataSnapshot) {
//        guard
//            let value = snapshot.value as? [String: AnyObject],
//            let toppings = value["topings"] as? [String],
//            let price = value["price"] as? Int
//            else {
//                return nil
//        }
//
//        self.ref = snapshot.ref
//        self.key = snapshot.key
//        self.toppings = toppings
//        self.price = price
//    }
//
//    func toAnyObject() -> Any {
//        return [
//            "toppings": toppings,
//            "price": price ?? 0
//        ]
//    }
//}




import Foundation
import Firebase

struct Pizza {
    
    var toppings: [String]
    var price: Int
    var numOfOrders: Int = 0
    var toppingString: String {
        return toppings.joined(separator: ", ")
    }
    
    init(toppings: [String], price: Int = 0) {
        self.toppings = toppings
        self.price = price
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let toppings = value["toppings"] as? [String],
            let price = value["price"] as? Int,
            let numOfOrders = value["numOforders"] as? Int else {
                return nil
        }
        
        self.toppings = toppings.sorted()
        self.price = price
        self.numOfOrders = numOfOrders
    }
}


extension Pizza: Equatable {
    
    static func ==(lhs: Pizza, rhs: Pizza) -> Bool {
        return lhs.toppings.sorted() == rhs.toppings.sorted()
    }
}

extension Pizza: Comparable {
    static func < (lhs: Pizza, rhs: Pizza) -> Bool {
        let m = min(lhs.toppings.count,rhs.toppings.count)
        for i in 0...m {
            if lhs.toppings[i] < rhs.toppings[i] {
                return true
            } else {
                return false
            }
        }
        return lhs.toppings.count == m
    }
}

extension Pizza: Hashable {
    
    var hashValue: Int {
        return toppingString.hashValue
    }
}
