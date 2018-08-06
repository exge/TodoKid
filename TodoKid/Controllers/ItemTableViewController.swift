//
//  ItemTableViewController.swift
//  TodoKids
//
//  Created by Khoa Vo on 8/6/18.
//  Copyright © 2018 Expert-Generalist. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ItemTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    var items: Results<Item>?
    
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = selectedCategory?.name
        
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateNavBar(withHexCode: (selectedCategory?.color)!)
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        updateNavBar(withHexCode: "#FFFFFF")
    }
    
    func updateNavBar(withHexCode colourHexCode: String){
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
        
        guard let navBarColour = UIColor(hexString: colourHexCode) else { fatalError()}
        
        navBar.barTintColor = navBarColour
        
        navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true)]
        
        searchBar.barTintColor = navBarColour
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        guard let item = items?[indexPath.row] else {
            fatalError("RETRIVE ITEM ERROR")
        }
        
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        
        if let backgroundColor = UIColor(hexString: (selectedCategory?.color)!)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat((items?.count)!)) {
            cell.backgroundColor = backgroundColor
            cell.textLabel?.textColor = ContrastColorOf(backgroundColor, returnFlat: true)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do {
            try realm.write {
                self.items![indexPath.row].done = !self.items![indexPath.row].done
            }
        } catch {
            print("CHANGE ITEM STATUS ERROR: \(error)")
        }
        
        tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Item", message: nil, preferredStyle: .alert)
        
        var textField: UITextField?
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "type new item name"
            
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { (alertAction) in
            if let name = textField?.text, name.count > 0 {
                let item = Item()
                item.title = name
                item.date = Date()
                
                do {
                    try self.realm.write {
                        self.selectedCategory?.childrenItems.append(item)
                    }
                } catch {
                    print("ADD ITEM ERROR: \(error)")
                }
                
                self.tableView.reloadData()
            }
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems() {
        items = selectedCategory?.childrenItems.sorted(byKeyPath: "date", ascending: true)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.selectedCategory?.childrenItems[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(itemForDeletion)
                }
            } catch {
                print("DELETE ITEM ERROR: \(error)")
            }
        }
    }
}

extension ItemTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        loadItems()
        
        if searchBar.text?.count == 0 {
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            items = items?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "date", ascending: true)
        }
        
        tableView.reloadData()
    }
    
}
