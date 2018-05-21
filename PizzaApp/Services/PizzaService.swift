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
    
//    static var persistentContainer: NSPersistentContainer = {
//        return UIApplication.appDelegate.persistentContainer
//    }()

    class func getPizzas(completion: @escaping PizzaHandler){
        DispatchQueue.global(qos: .userInitiated).async {
            guard let path = Bundle.main.path(
                forResource: "pizzas",
                ofType: "json") else {
                return
            }
            let fileURL = URL(fileURLWithPath: path)
            
            var pizzas: [Pizza]
            do {
                let data = try Data(contentsOf: fileURL)
                pizzas = try JSONDecoder().decode([Pizza].self, from: data)
            } catch  {
                print(error.localizedDescription)
                return
            }
            
            let counts = pizzas.reduce(into: [Pizza: Int]()){ $0[$1, default: 0] += 1}
             let topPizzas = counts.sorted(by: { $0.value > $1.value })
            // return the top N pizzas
            completion(Array(topPizzas))
        }
    }
    
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

    

