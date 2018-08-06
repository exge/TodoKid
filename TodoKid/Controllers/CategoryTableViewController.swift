//
//  CategoryTableViewController.swift
//  TodoKids
//
//  Created by Khoa Vo on 8/6/18.
//  Copyright © 2018 Expert-Generalist. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        loadCategories()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        guard let category = categories?[indexPath.row] else {
            fatalError("RETRIVE CATEGORY ERROR")
        }
        
        cell.textLabel?.text = category.name
        if let backgroundColor = UIColor(hexString: category.color) {
            cell.backgroundColor = backgroundColor
            cell.textLabel?.textColor = ContrastColorOf(backgroundColor, returnFlat: true)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! ItemTableViewController
        
        guard let category = categories?[(tableView.indexPathForSelectedRow?.row)!] else {
            fatalError("RETRIVE CATEGORY ERROR")
        }
        
        destinationViewController.selectedCategory = category
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add New Category", message: nil, preferredStyle: .alert)
        
        var textField: UITextField?
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "type new category name"
            
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { (alertAction) in
            if let name = textField?.text, name.count > 0 {
                let category = Category()
                category.name = name
                category.color = RandomFlatColorWithShade(.light).hexValue()
                
                do {
                    try self.realm.write {
                        self.realm.add(category)
                    }
                } catch {
                    print("ADD CATEGORY ERROR: \(error)")
                }
                
                self.tableView.reloadData()
            }
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(categoryForDeletion.childrenItems)
                    realm.delete(categoryForDeletion)
                }
            } catch {
                print("DELETE CATEGORY ERROR: \(error)")
            }
        }
    }
    
}
