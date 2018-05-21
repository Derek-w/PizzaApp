//
//  PizzaService.swift
//  PizzaApp
//
//  Created by mac on 5/8/18.
//  Copyright © 2018 mobileappscompany. All rights reserved.
//

import UIKit
import CoreData
import Firebase

typealias PizzaHandler = ([(Pizza, Int)])->Void
typealias OrderHandler = ([Order]) -> Void


class PizzaService {
    
    struct Keys {
        static let pizzaToppings = "pizzaToppings"
        static let orders = "orders"
    }
    
    static let pizzaTopRef = Database.database().reference(withPath: Keys.pizzaToppings)
    static let ordersRef = Database.database().reference(withPath: Keys.orders)
    


    class func getPizzas(completion: @escaping PizzaHandler){
        PizzaService.pizzaTopRef.observe(.value, with: { snapshot in
            var pizzas = [Pizza: Int]()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let pizza = Pizza(snapshot: snapshot) {
                        print(pizza.toppings)
                    pizzas[pizza] = pizza.numOfOrders
                }
            }
            
            let topPizzas = pizzas.sorted(by: { $0.value > $1.value })
            completion(Array(topPizzas))
        })
    }
    
//    class func uploadJson(topPizzas: [Pizza: Int]){
//            for topPizza in topPizzas {
//                let pizza: Any = ["toppings": topPizza.key.toppings.sorted(),"price": topPizza.key.price ?? 0,"numOforders": topPizza.value]
//                let pizzaReference = PizzaService.pizzaTopRef.child(topPizza.key.toppingString)
//                pizzaReference.setValue(pizza)
//            }
//        }
    
    
    class func updateOrder(_ order: Order){
        DispatchQueue.global(qos: .utility).async {
            order.ref?.updateChildValues(["favorite": order.favorite])
        }
    }
    
    class func saveOrder(toppings: [String]){
        
        DispatchQueue.global().async {
            
            let order = Order(toppings: toppings,
                                          date: Date(),
                                          favorite: false)
            let orderRef = self.ordersRef.child(order.date)
              orderRef.setValue(order.toAnyObject())
            
                NotificationCenter
                    .default
                    .post(
                        name: .orderCreated,
                        object: nil,
                        userInfo: nil)
                
                print("Order saved")
            
        }
    }
    
    class func getOrders(completion: @escaping OrderHandler){
                ordersRef.observe(.value, with: { snapshot in
                    var allOrders = [Order]()
                    for child in snapshot.children {
                        if let snapshot = child as? DataSnapshot,
                            let order = Order(snapshot: snapshot) {
                            allOrders.append(order)
                        }
                    }
                    completion(allOrders.reversed())
                })
    }
    
    class func deleteOrder(_ order: Order){
        DispatchQueue.global(qos: .utility).async {
            order.ref?.removeValue()
        }
    }
}

    

