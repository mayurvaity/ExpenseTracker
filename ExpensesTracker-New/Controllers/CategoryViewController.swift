//
//  ViewController.swift
//  ExpensesTracker-New
//
//  Created by Mayur Vaity on 25/04/24.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    //creating new realm
    let realm = try! Realm()
    
    //array to store all category objects
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create a nib for custom cell
        let nib = UINib.init(nibName: "CategoryTableViewCell", bundle: nil)
        //register that nib with tableview
        tableView.register(nib, forCellReuseIdentifier: "categoryCell")
        
        //to get data from realm
        loadCategories()
    }
    
    //to reload the data when back button on navigation bar is pressed
    override func viewWillAppear(_ animated: Bool) {
        
        print("viewWillAppear CategoryVC")
        //create a nib for custom cell
        let nib = UINib.init(nibName: "CategoryTableViewCell", bundle: nil)
        //register that nib with tableview
        tableView.register(nib, forCellReuseIdentifier: "categoryCell")
        
        //to get data from realm
        loadCategories()
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //creating a cell to pass at tableview
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? CategoryTableViewCell
        
        //getting a value for that position from categoryarray
        if let category = categoryArray?[indexPath.row] {
            
            cell?.categoryLabel.text = category.title
            
            //getting total of category expenses
            let total: Float = category.expenses.sum(ofProperty: "amount")
            print("total \(total)")
            
            cell?.categoryTotalLabel.text = String(total)
            
        }
        
        //        //setting this value to text label of the cell
        //        cell.textLabel?.text = category?.title ?? "No categories added yet."
        //
        //        //setting accessorytype to >
        //        cell.accessoryType = .disclosureIndicator
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToExpenses", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToExpenses" {
            let destinationVC = segue.destination as! ExpensesViewController
            
            //getting selected row details
            if let indexPath = tableView.indexPathForSelectedRow {
                //to get category name to be used in expensesVC
                destinationVC.selectedCategory = categoryArray?[indexPath.row]
            }
        }
        
        //for going to new expense VC and setting its delegate to this VC 
        switch (segue.identifier, segue.destination) {
            // Check that the segue identifer matches and destination controller is a ModalViewController
        case ("goToNewExpense", let destination as NewExpenseViewController):
            print("going through segue...")
            destination.delegate = self
        case _:
            break
        }
    }
    
    
    //MARK: - Add New Categories
    @IBAction func addCategoryPressed(_ sender: Any) {
        
        var textField = UITextField()
        
        //for the pop-up alert, to add new category
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        //for the button in above created pop-up, and actions of that button
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            
            //creating a category object to be passed in array
            let newCategoryN = Category()
            newCategoryN.title = textField.text!
            
            //to save category array to realm
            self.save(category: newCategoryN)
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
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving new category, \(error)")
        }
        
        //to refresh data in the tableView
        tableView.reloadData()
    }
    
    
    func loadCategories() {
        
        categoryArray = realm.objects(Category.self)
        
        //        //using above created request fetching data from
        //        do {
        //            categoryArray = try context.fetch(request)
        //        } catch {
        //            print("Error fetching data from context \(error)")
        //        }
        //to refresh data in the tableView
        tableView.reloadData()
    }
    
    
    
}

//MARK: - Search Bar Methods
//extension CategoryViewController : UISearchBarDelegate {
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        //query
//        var request: NSFetchRequest<Category> = Category.fetchRequest()
//
//        print(searchBar.text!)
//        //creating a predicate i.e., where condition
//        var predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        //adding predicate to the request i.e., adding where condition to query
//        request.predicate = predicate
//
//        //to sort, i.e., adding order by to our query
//        //creating a sortDescriptor (create as many u need)
//        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
//        //adding this sortDescriptor to the request (below is an array so can add many)
//        request.sortDescriptors = [sortDescriptor]
//
//        //fetching request and reloading data i.e., running the query and getting O/P
//        loadCategories(with: request)
//    }
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text?.count == 0 {
//            //relaoding all data as searchBar is empty
//            loadCategories()
//
//            //to resign search bar as first responder i.e., deselect search bar and close the keyboard
//            //need to call this within a dispacthqueue main async to keep UI unfrozen
//            DispatchQueue.main.async {
//                searchBar.resignFirstResponder()
//            }
//        }
//    }
//
//}


extension CategoryViewController: NewExpenseViewControllerDelegate {
    func newExpenseViewControllerWillDisapear(_ modal: NewExpenseViewController) {
        print("newExpenseViewControllerWillDisapear CategoryVC")
        //create a nib for custom cell
        let nib = UINib.init(nibName: "CategoryTableViewCell", bundle: nil)
        //register that nib with tableview
        tableView.register(nib, forCellReuseIdentifier: "categoryCell")
        
        //to get data from realm
        loadCategories()
    }
    
}

