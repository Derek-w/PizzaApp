//
//  ToppingsViewController.swift
//  PizzaApp
//
//  Created by mac on 5/10/18.
//  Copyright © 2018 mobileappscompany. All rights reserved.
//

import UIKit
import Firebase

class ToppingsViewController: UIViewController {
    
    @IBOutlet weak var toppingsTableView: UITableView!
    @IBOutlet weak var toppingsPickerView: UIPickerView!
        
    @IBAction func addNewTopping(_ sender: Any) {
        let alert = UIAlertController(title: "Customise", message:.none , preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter your own favorite topping:"
        })
        alert.addAction(UIAlertAction(title: "Add",
                                      style: UIAlertActionStyle.default,
                                      handler: { [weak alert] (_) in
                                        guard let textField = alert!.textFields?[0]
                                            else { return }
                                        if textField.text != "" {
                                            
                                            self.toppings.insert(textField.text!, at: 0)
                                            Preferences.addCtmTopping(self.toppings)
                                            self.toppingsPickerView.reloadAllComponents()
                                        }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    let cellIdentifier = "ToppingCell"
    
    var toppings = [String]()
    
    
    var selectedToppings: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let top = ["Pepperoni", "Ham", "Pineapple"]//, "Olives", "Peppers", "Bacon", "Chicken", "Spinach"]
        Preferences.toppingsRef.setValue(top)
        Preferences.getToppings(){[weak self] toppings in
            self?.toppings = toppings
        }
        toppings = toppings.sorted()
    }
    
    @IBAction func toppingAdded(_ sender: Any) {
        guard !toppings.isEmpty else { return }
        
        let row = toppingsPickerView.selectedRow(inComponent: 0)
        
        let selectedTopping = toppings[row]
        
        print("Selected \(selectedTopping)")
        toppings.remove(at: row)
        toppings = toppings.sorted()
        toppingsPickerView.reloadAllComponents()
     
        addTopping(selectedTopping)
    }
    
    func addTopping(_ topping: String){
        
        // add to the array of selected toppings
        selectedToppings.append(topping)
        
        // get the index path of the new row
        let ip = IndexPath(row: selectedToppings.count-1, section: 0)
        
        // update table view
        toppingsTableView.insertRows(at: [ip], with: .automatic)
    }
    
    @IBAction func pizzaOrdered(_ sender: Any) {
        if selectedToppings.count == 0 {
            return
        }
        PizzaService.saveOrder(toppings: selectedToppings)
        
        toppings = (toppings + selectedToppings).sorted()
        selectedToppings.removeAll()
        
        toppingsPickerView.reloadAllComponents()
        toppingsTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        Preferences.getToppings(){[weak self] toppings in
            self?.toppings = toppings.sorted()
            self?.toppingsPickerView.reloadAllComponents()
        }
        
    }
}

extension ToppingsViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return toppings.count
    }
}

extension ToppingsViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return toppings[row]
    }
}

extension ToppingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedToppings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        cell.textLabel?.text = selectedToppings[indexPath.row]
        return cell
    }
}

extension ToppingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard editingStyle == .delete else { return }

        let removedTopping = selectedToppings.remove(at: indexPath.row)
        
        // update table view
        toppingsTableView.deleteRows(at: [indexPath], with: .automatic)
        
        toppings.append(removedTopping)
        toppings = toppings.sorted()
        
        toppingsPickerView.reloadAllComponents()
    }
}
