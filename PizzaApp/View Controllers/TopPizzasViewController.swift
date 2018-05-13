//
//  ViewController.swift
//  PizzaApp
//
//  Created by mac on 5/8/18.
//  Copyright © 2018 mobileappscompany. All rights reserved.
//

import UIKit

class TopPizzasViewController: UIViewController, UISearchBarDelegate{
    
    @IBOutlet weak var pizzaTableView: UITableView!
   
    @IBOutlet weak var searchBar: UISearchBar!
    
    var pizzas: [(Pizza, Int)] = []
    var order = "Descending"
    var isSearching = false
    var start = true
    var allPizzas: [(Pizza, Int)] = []
    var searchText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PizzaService.getPizzas() { [unowned self] pizzas in
            self.allPizzas = pizzas
            self.fetchPizzas(count: Preferences.pizzaCount, order: self.order)
        }
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
    }
        
    @IBAction func orderChanged(_ sender: UISegmentedControl) {
        order = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        if isSearching {
            searchBar(searchBar, textDidChange: searchText)
        } else {
            fetchPizzas(count: Preferences.pizzaCount, order: order)
        }
    }
    
    func fetchPizzas(count: Int, order: String){
        switch order {
        case "Ascending":
            self.pizzas = self.allPizzas.sorted(by: { $1.1 > $0.1 })
        case "Descending":
            self.pizzas = self.allPizzas.sorted(by: { $0.1 > $1.1 })
        default:
            self.pizzas = self.allPizzas.sorted(by: { $0.0 < $1.0 })
        }
        let end = min(count, self.pizzas.count)
        self.pizzas = Array(self.pizzas[0..<end])
        
        DispatchQueue.main.async {
            self.pizzaTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchPizzas(count: Preferences.pizzaCount, order: order)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? SettingsViewController else {
            return
        }
        
        vc.delegate = self
    }
}

extension TopPizzasViewController: SettingsDelegate {
    
    func updatedPizzaCount(to count: Int) {
        fetchPizzas(count: count, order: order)
    }
}


extension TopPizzasViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pizzas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PizzaCell", for: indexPath)
        
        let pizza = pizzas[indexPath.row].0
        cell.textLabel?.text = pizza.toppings.joined(separator: ", ")
        let number = "\(pizzas[indexPath.row].1)"
        cell.detailTextLabel?.text = number

        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchText == "" {
            isSearching = false
            view.endEditing(true)
            fetchPizzas(count: Preferences.pizzaCount, order: order)
        } else {
            isSearching = true
            self.searchText = searchText
            fetchPizzas(count: allPizzas.count, order: order)
            pizzas = pizzas.filter({( pizza: Pizza, int: Int) -> Bool in return pizza.toppings.joined().lowercased().contains(searchText.lowercased())})
            let end = min(Preferences.pizzaCount, self.pizzas.count)
            pizzas = Array(pizzas[0..<end])
            pizzaTableView.reloadData()
        }
    }
}

