//
//  PizzaService.swift
//  PizzaApp
//
//  Created by mac on 5/8/18.
//  Copyright © 2018 mobileappscompany. All rights reserved.
//

import UIKit
import CoreData

typealias PizzaHandler = ([(Pizza, Int)])->Void
typealias OrderHandler = ([Order]) -> Void

class PizzaService {
    
    static var persistentContainer: NSPersistentContainer = {
        return UIApplication.appDelegate.persistentContainer
    }()

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
    
            let context = persistentContainer
                .newBackgroundContext()
            
            // create request for orders
            let fetchRequest: NSFetchRequest
                <NSFetchRequestResult> =
                NSFetchRequest(entityName: Entity.Names.pizza.rawValue)
            
            // grab the specific order
            let key = Entity.Keys.Pizza.date.rawValue
            let fetchPredicate = NSPredicate(
                format: "\(key)=%@",
                argumentArray: [order.date])
            
            // apply the predicate
            fetchRequest.predicate = fetchPredicate
            
            var results: [Any]!
            do {
                results = try context.fetch(fetchRequest)
            }
            catch { return }
            
            guard let orders = results as? [NSManagedObject],
                let storedOrder = orders.first else {
                    return
            }
            
            // update properties
            storedOrder.setValue(order.favorite,
                forKey: Entity.Keys.Pizza
                    .favorite.rawValue)
            
            storedOrder.setValue(order.toppings,
                forKey: Entity.Keys.Pizza
                    .toppings.rawValue)
            
            do { try context.save() }
            catch { print("could not save changes")}
        }
    }
    
    class func saveOrder(toppings: [String]){
        
        DispatchQueue.global().async {
            let context = persistentContainer.newBackgroundContext()
            
            guard let entity = NSEntityDescription.entity(forEntityName: Entity.Names.pizza.rawValue, in: context) else {
                print("Invalid Entity name")
                return
            }
            
            let order = NSManagedObject(entity: entity, insertInto: context)
            
            // set entity properties
            order.setValue(false, forKey: Entity.Keys.Pizza.favorite.rawValue)
            order.setValue(Date(), forKey: Entity.Keys.Pizza.date.rawValue)
            order.setValue(toppings, forKey: Entity.Keys.Pizza.toppings.rawValue)
            
            // commit changes and save
            do {
                try context.save()

                NotificationCenter
                    .default
                    .post(
                        name: .orderCreated,
                        object: nil,
                        userInfo: nil)
                
                print("Order saved")
            }catch {
                print("Could not save order")
            }
        }
    }
    
    class func getOrders(completion: @escaping OrderHandler){
        
        DispatchQueue.global(qos:
            .userInitiated).async {
                
            let context = persistentContainer
                .newBackgroundContext()
                
            // create request for orders
            let fetchRequest: NSFetchRequest
                <NSFetchRequestResult> =
                NSFetchRequest(entityName: Entity.Names.pizza.rawValue)
            
            // sort by date
            let sortDescriptors = [NSSortDescriptor(key: Entity.Keys.Pizza.date.rawValue,
                ascending: true)]
                
            // apply sorting to request
            fetchRequest.sortDescriptors = sortDescriptors

            var results: [Any]!
            do {
                results = try context.fetch(fetchRequest)
            }
            catch {
                completion([])
                return
            }
            
            let orders = (results as? [NSManagedObject]) ?? []
                
            let allOrders = orders.compactMap{ Order(entity: $0)}
            completion(allOrders)
        }
    }
    
    class func deleteOrder(_ order: Order){
        DispatchQueue.global(qos: .utility).async {
            
            let context = persistentContainer
                .newBackgroundContext()
            
            // create request for orders
            let fetchRequest: NSFetchRequest
                <NSFetchRequestResult> =
                NSFetchRequest(entityName: Entity.Names.pizza.rawValue)
            
            // grab the specific order
            let key = Entity.Keys.Pizza.date.rawValue
            let fetchPredicate = NSPredicate(
                format: "\(key)=%@",
                argumentArray: [order.date])
            
            // apply the predicate
            fetchRequest.predicate = fetchPredicate
            guard let results = try! context.fetch(fetchRequest) as? [NSManagedObject]
                    else{ return }
            for object in results {
                    context.delete(object)
            }
            do { try context.save() }
            catch { print("could not save changes")}
 
        }
    }
}

    

