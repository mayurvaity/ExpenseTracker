//
//  ViewController.swift
//  ExpensesTracker-New
//
//  Created by Mayur Vaity on 25/04/24.
//

import UIKit

class CategoryViewController: UITableViewController {
    
    var categoryArray = ["Travel", "Food", "Clothing"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
    
}

