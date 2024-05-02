//
//  ExpensesViewController.swift
//  ExpensesTracker-New
//
//  Created by Mayur Vaity on 02/05/24.
//

import UIKit
import CoreData

class ExpensesViewController: UITableViewController {
    
    var expensesArray = [Expenses]()
    
    //optional variable, so until it has been initialized its value would be nil
    var selectedCategory : Category? {
        //we r calling load exp method here bc we need selectedCategory value everytime this VC gets loaded
        didSet {
            loadExpenses()
        }
    }
    
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
        //db file path
        print(dataFilePath)
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expensesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //creating a cell to pass at tableview
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpensesCell", for: indexPath)
        
        //getting a value for that position from categoryarray
        let expense = expensesArray[indexPath.row]
        
        //setting this value to text label of the cell
        cell.textLabel?.text = expense.title
        
        return cell
    }
    
    //MARK: - Data Manipulation Methods
    //used to save data to coredata
    func saveExpenses() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
        
        //to refresh data in the tableView
        tableView.reloadData()
    }
    
    
    func loadExpenses(with request : NSFetchRequest<Expenses> = Expenses.fetchRequest(), searchPredicate: NSPredicate? = nil) {
        
        var categoryPredicate = NSPredicate(format: "parentCategory.title MATCHES %@", self.selectedCategory!.title!)
        
        if let additionalPredicate = searchPredicate {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
            request.predicate = compoundPredicate
        } else {
            request.predicate = categoryPredicate
        }
        
        //using above created request fetching data from
        do {
            expensesArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        //to refresh data in the tableView
        tableView.reloadData()
    }
    
    //MARK: - Add new Expenses
    
    @IBAction func addExpensesButtonClicked(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        var amountTextField = UITextField()
        
        //for the pop-up alert, to add new category
        let alert = UIAlertController(title: "Add New Expense", message: "", preferredStyle: .alert)
        
        //for the button in above created pop-up, and actions of that button
        let action = UIAlertAction(title: "Add Expense", style: .default) { action in
            
            //creating a category object to be passed in array
            var expense = Expenses(context: self.context)
            expense.title = textField.text!
            expense.amount = 0.0
            expense.parentCategory = self.selectedCategory 
            print("Amount: ", amountTextField.text)
            
            self.expensesArray.append(expense)
            
            //setting above created array to user defaults local data storage, to the key specified as below
            //            self.defaults.set(self.categoryArray, forKey: "CategoryListArray")
            
            //to save category array to our(custom) plist
            self.saveExpenses()
        }
        
        //to add textfield to above alert
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Enter new expense"
            textField = alertTextField
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Amount"
            amountTextField = alertTextField
        }
        
        //adding action to this alert
        alert.addAction(action)
        
        //to show pop-up present method is used
        present(alert, animated: true, completion: nil)
        
    }

}

extension ExpensesViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //query
        var request: NSFetchRequest<Expenses> = Expenses.fetchRequest()
        
        print(searchBar.text!)
        //creating a predicate i.e., where condition
        var predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        //adding predicate to the request i.e., adding where condition to query
        //will passs above predicate as a parameter
//        request.predicate = predicate
        
        //to sort, i.e., adding order by to our query
        //creating a sortDescriptor (create as many u need)
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        //adding this sortDescriptor to the request (below is an array so can add many)
        request.sortDescriptors = [sortDescriptor]
        
        //fetching request and reloading data i.e., running the query and getting O/P
        loadExpenses(with: request, searchPredicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            //relaoding all data as searchBar is empty
            loadExpenses()
            
            //to resign search bar as first responder i.e., deselect search bar and close the keyboard
            //need to call this within a dispacthqueue main async to keep UI unfrozen
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
