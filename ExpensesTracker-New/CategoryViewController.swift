//
//  ViewController.swift
//  ExpensesTracker-New
//
//  Created by Mayur Vaity on 25/04/24.
//

import UIKit

class CategoryViewController: UITableViewController {
    
    var categoryArray = ["Travel", "Food", "Clothing"]
    
    //creating an object of UserDefaults interface to access this persistent local data storage
    var defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //to retrive data from plist (userdefaults) file, and use it in the array
        //for each data type there is a different defaults method, for arrays it is array 
        if let categories = defaults.array(forKey: "CategoryListArray") as? [String] {
            categoryArray = categories
        }
    }

    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //creating a cell to pass at tableview
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        //getting a value for that position from categoryarray
        let category = categoryArray[indexPath.row]
        
        //setting this value to text label of the cell
        cell.textLabel?.text = category
        
        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected cell: ", categoryArray[indexPath.row])
        
        //to add a check mark when selected
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark 
        }
        
        //to deselect a cell after clicking on (makes it normal looking instead of keeping it look selected(grey))
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Categories
    @IBAction func addCategoryPressed(_ sender: Any) {
        
        var textField = UITextField()
        
        //for the pop-up alert, to add new category
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        //for the button in above created pop-up, and actions of that button
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            //what will happen once we pressed this button
            self.categoryArray.append(textField.text!)
            
            //setting above created array to user defaults local data storage, to the key specified as below
            self.defaults.set(self.categoryArray, forKey: "CategoryListArray")
            
            //to refresh data in the tableView
            self.tableView.reloadData()
        }
        
        //to add textfield to above alert
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        //adding action to this alert
        alert.addAction(action)
        
        //to show pop-up present method is used
        present(alert, animated: true, completion: nil)
    }
    
}

