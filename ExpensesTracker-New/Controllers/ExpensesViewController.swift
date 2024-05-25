//
//  ExpensesViewController.swift
//  ExpensesTracker-New
//
//  Created by Mayur Vaity on 02/05/24.
//

import UIKit
import RealmSwift

class ExpensesViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var expenses: Results<Expense>?
    
    //optional variable, so until it has been initialized its value would be nil
    var selectedCategory : Category? {
        //we r calling load exp method here bc we need selectedCategory value everytime this VC gets loaded
        didSet {
            loadExpenses()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //creating a cell to pass at tableview
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpensesCell", for: indexPath)
        
        //setting this value to text label of the cell
        cell.textLabel?.text = expenses?[indexPath.row].title ?? "No expense in this category yet."
        
        return cell
    }
    
    //MARK: - Data Manipulation Methods
    //used to save data to coredata
    func save(expense: Expense) {
        
        do {
            try realm.write {
                realm.add(expense)
            }
        } catch {
            print("Error saving context, \(error)")
        }
        
        //to refresh data in the tableView
        tableView.reloadData()
    }
    
    
    func loadExpenses() {
        
        expenses = selectedCategory?.expenses.sorted(byKeyPath: "title", ascending: true)

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
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        //creating a category object to be passed in array
                        let expense = Expense()
                        expense.title = textField.text!
                        guard let amount = Float(amountTextField.text!) else {
                            fatalError("Invalid value")
                        }
                        expense.amount = amount
                        //setting category to this expense
                        self.selectedCategory?.expenses.append(expense)
                        
                        //to save (cannot add it here as changing in above array will automatically gets added in the realm db)
//                        self.save(expense: expense)
                    }
                } catch {
                    print("Error saving new expense, \(error)")
                }
            }
            
            self.tableView.reloadData()
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

//extension ExpensesViewController: UISearchBarDelegate {
//    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        //query
//        var request: NSFetchRequest<Expenses> = Expenses.fetchRequest()
//        
//        print(searchBar.text!)
//        //creating a predicate i.e., where condition
//        var predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//        
//        //adding predicate to the request i.e., adding where condition to query
//        //will passs above predicate as a parameter
////        request.predicate = predicate
//        
//        //to sort, i.e., adding order by to our query
//        //creating a sortDescriptor (create as many u need)
//        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
//        //adding this sortDescriptor to the request (below is an array so can add many)
//        request.sortDescriptors = [sortDescriptor]
//        
//        //fetching request and reloading data i.e., running the query and getting O/P
//        loadExpenses(with: request, searchPredicate: predicate)
//    }
//    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text?.count == 0 {
//            //relaoding all data as searchBar is empty
//            loadExpenses()
//            
//            //to resign search bar as first responder i.e., deselect search bar and close the keyboard
//            //need to call this within a dispacthqueue main async to keep UI unfrozen
//            DispatchQueue.main.async {
//                searchBar.resignFirstResponder()
//            }
//        }
//    }
//}
