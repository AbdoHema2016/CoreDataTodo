//
//  CategoryViewController.swift
//  CoreDataTodo
//
//  Created by Abdelrahman-Arw on 12/19/19.
//  Copyright © 2019 Abdelrahman-Arw. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import FirebaseDatabase


class CategoryViewController: SwipeTableViewController {

    //MARK: - Variables
    let realm = try! Realm()
    var ref: DatabaseReference!
    var categoryArray : Results<Category>?

    
    //Add new Categories
    @IBAction func barBtnAdd(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new todo item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // what will happen on tapping the action add button
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colour = UIColor.randomFlat.hexValue()
            
            self.ref.child("Categories").childByAutoId().setValue(["name": newCategory.name,"colour": newCategory.colour])
            
            self.save(category: newCategory)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Item"
            textField = alertTextField
            
        }
        alert.addAction(action)
        present(alert,animated: true,completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        loadCategories()
        
        
        tableView.separatorStyle = .none

    }

    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let categories =  categoryArray?[indexPath.row] {
            cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No categories added yet"
           guard let categoryColour = UIColor(hexString: categories.colour) else {fatalError()}
           cell.backgroundColor = categoryColour
           cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
        }
        
        return cell
    }
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.save(category: indexPath.row)
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    //MARK: - Model Manipulation Methods
    
    func save(category: Category) {
        do{
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error: \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func loadCategories() {
        
        categoryArray = realm.objects(Category.self)
        tableView.reloadData()
        ref.child("Categories").observeSingleEvent(of: .value, with: { (snapshot) in
           // Get user value
            
            for snap in snapshot.children {
                let userSnap = snap as! DataSnapshot
                let userDict = userSnap.value as! [String:AnyObject]
                let username = userDict["name"] as? String ?? ""
                let color = userDict["colour"] as? String ?? ""
                
                
                 let category = self.categoryArray?.filter("name CONTAINS[cd] %@",username).sorted(byKeyPath: "name")
                if username == category?.first?.name {
                     print("already saved")
                } else {
                    let newCategory = Category()
                    newCategory.name = username
                    newCategory.colour = color
                    self.save(category: newCategory)
                }
                
            }
            self.tableView.reloadData()
          
        
           
            
           // ...
       }) { (error) in
           print(error.localizedDescription)
       }
       
        
        
        
    }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let categoryForDeletion = self.categoryArray?[indexPath.row] {
            do{
                try self.realm.write{
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error: \(error)")
            }
            
        }
    }

    
  

}
