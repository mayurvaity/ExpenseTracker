//
//  ViewController.swift
//  ExpensesTracker-New
//
//  Created by Mayur Vaity on 25/04/24.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    
    //to get directory path of documents directory for this app (inside sandbox), this is where coredata db file will be stored
    var dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    //to use context created in AppDelegate.swift, we have to access UIApplication.shared singleton, then cast its delegate to AppDelegate class, and access viewContext
    //UIApplication.shared this gets created for when app runs
    //shared is a singleton object of UIApplication class
    //UIApplication class gets created at run time of current class
    //this class is used as it and AppDelegate inherit UIApplicationDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        print(dataFilePath)
        
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
    //to mark done on click
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected cell: ", categoryArray[indexPath.row])
        
        categoryArray[indexPath.row].done = !categoryArray[indexPath.row].done
        
        //saving updated data in db and reload tableView
        saveCategories()
        
        //to deselect a cell after clicking on (makes it normal looking instead of keeping it look selected(grey))
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //to update on click
    //    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        print("Selected cell: ", categoryArray[indexPath.row])
    //
    //        //changing title to mark completed
    //        categoryArray[indexPath.row].title = "Completed"
    //
    //        //saving updated data in db and reload tableView
    //        saveCategories()
    //
    //        //to deselect a cell after clicking on (makes it normal looking instead of keeping it look selected(grey))
    //        tableView.deselectRow(at: indexPath, animated: true)
    //    }
    
    //to delete on click
    //    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        print("Selected cell: ", categoryArray[indexPath.row])
    //
    //        //to delete from context
    //        context.delete(categoryArray[indexPath.row])
    //
    //        //to delete from category array
    //        categoryArray.remove(at: indexPath.row)
    //
    //        //writing context with updated data to db and reloading tableView
    //        saveCategories()
    //
    //        //to deselect a cell after clicking on (makes it normal looking instead of keeping it look selected(grey))
    //        tableView.deselectRow(at: indexPath, animated: true)
    //    }
    
    //MARK: - Add New Categories
    @IBAction func addCategoryPressed(_ sender: Any) {
        
        var textField = UITextField()
        
        //for the pop-up alert, to add new category
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        //for the button in above created pop-up, and actions of that button
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            
            //creating a category object to be passed in array
            var newCategoryN = Category(context: self.context)
            newCategoryN.title = textField.text!
            newCategoryN.done = false
            
            
            self.categoryArray.append(newCategoryN)
            
            //setting above created array to user defaults local data storage, to the key specified as below
            //            self.defaults.set(self.categoryArray, forKey: "CategoryListArray")
            
            //to save category array to our(custom) plist
            self.saveCategories()
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
    
    //used to save data to coredata
    func saveCategories() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
        
        //to refresh data in the tableView
        tableView.reloadData()
    }
    
    
    func loadCategories(with request : NSFetchRequest<Category> = Category.fetchRequest()) {
        
        //using above created request fetching data from
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        //to refresh data in the tableView
        tableView.reloadData()
    }
    
}

//MARK: - Search Bar Methods
extension CategoryViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //query
        var request: NSFetchRequest<Category> = Category.fetchRequest()
        
        print(searchBar.text!)
        //creating a predicate i.e., where condition
        var predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        //adding predicate to the request i.e., adding where condition to query
        request.predicate = predicate
        
        //to sort, i.e., adding order by to our query
        //creating a sortDescriptor (create as many u need)
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        //adding this sortDescriptor to the request (below is an array so can add many)
        request.sortDescriptors = [sortDescriptor]
        
        //fetching request and reloading data i.e., running the query and getting O/P
        loadCategories(with: request)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            //relaoding all data as searchBar is empty
            loadCategories()
            
            //to resign search bar as first responder i.e., deselect search bar and close the keyboard
            //need to call this within a dispacthqueue main async to keep UI unfrozen 
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}
