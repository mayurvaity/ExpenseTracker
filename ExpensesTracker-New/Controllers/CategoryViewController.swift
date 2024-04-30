//
//  ViewController.swift
//  ExpensesTracker-New
//
//  Created by Mayur Vaity on 25/04/24.
//

import UIKit

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    
    //creating an object of UserDefaults interface to access this persistent local data storage
//    var defaults = UserDefaults.standard
    
    //to get directory path of documents directory for this app (inside sandbox)
//        var dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    var dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Categories.plist")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print(dataFilePath)
        
//        let newCategory = Category()
//        newCategory.title = "Travel"
//        categoryArray.append(newCategory)
//        
//        let newCategory2 = Category()
//        newCategory2.title = "Food"
//        categoryArray.append(newCategory2)
//        
//        let newCategory3 = Category()
//        newCategory3.title = "Grossaries"
//        categoryArray.append(newCategory3)
        
        
        //to retrive data from plist (userdefaults) file, and use it in the array
        //for each data type there is a different defaults method, for arrays it is array 
//        if let categories = defaults.array(forKey: "CategoryListArray") as? [Category] {
//            categoryArray = categories
//        }
        
        //to get data from plist into categoriesArray 
        loadCategories()
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
        cell.textLabel?.text = category.title
        
        //setting value for tick mark
        cell.accessoryType = category.done ? .checkmark : .none
        //other way of doing the same
//        if category.done == true {
//            cell.accessoryType = .checkmark
//        } else {
//            cell.accessoryType = .none
//        }
        
        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected cell: ", categoryArray[indexPath.row])
        
        categoryArray[indexPath.row].done = !categoryArray[indexPath.row].done
        
//        if categoryArray[indexPath.row].done == false {
//            categoryArray[indexPath.row].done = true
//        } else {
//            categoryArray[indexPath.row].done = false
//        }
        
        //getting rid of below code as when this method gets triggered it will refresh tableView as well subsequently calling 2 tableView datasource methods, by calling relaoddata method
        //to add a check mark when selected
//        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
//            tableView.cellForRow(at: indexPath)?.accessoryType = .none
//        } else {
//            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//        }
        
        //saving updated check mark to plist file
        saveCategories()
        
        //reload tableview cells
        tableView.reloadData()
        
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
            
            //creating a category object to be passed in array
            var newCategoryN = Category()
            newCategoryN.title = textField.text!
            
            //what will happen once we pressed this button
            self.categoryArray.append(newCategoryN)
            
            //setting above created array to user defaults local data storage, to the key specified as below
//            self.defaults.set(self.categoryArray, forKey: "CategoryListArray")
            
            //to save category array to our(custom) plist
            self.saveCategories()
            
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
    
    //MARK: - Model Manipulation Methods
    
    //used to save data to plist from array
    func saveCategories() {
        
        //encoding and then writing this array to above created plist file
        var encoder = PropertyListEncoder()
        do {
            //encoding
            let data = try encoder.encode(categoryArray)
            //writing data to plist file
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding category array \(error)")
        }
        
    }
    
    func loadCategories() {
        //getting content of plist file into data variable
        if let data = try? Data(contentsOf: dataFilePath!) {
            //preparing decoder to decode data from variable data
            let decoder = PropertyListDecoder()
            do {
                self.categoryArray = try decoder.decode([Category].self, from: data)
            } catch {
                print("Error decoding plist data \(error)")
            }
            
        }
    }
    
}

