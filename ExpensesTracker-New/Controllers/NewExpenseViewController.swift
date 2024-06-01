//
//  NewExpenseViewController.swift
//  ExpensesTracker-New
//
//  Created by Mayur Vaity on 26/05/24.
//

import UIKit
import RealmSwift

//protocol created (for reloading data on main VC)
protocol NewExpenseViewControllerDelegate: AnyObject {
    //this method in main VC will do the reloading of data
    func newExpenseViewControllerWillDisapear(_ modal: NewExpenseViewController)
}

class NewExpenseViewController: UIViewController {
    
    //creating new realm
    let realm = try! Realm()
    
    //array to store all category objects
    var categoryArray: Results<Category>?
    var expenses: Results<Expense>?
    
    //array to store all category objects
    var accountArray: Results<Account>?
    
    var selectedCategory: Category?
    var selectedAccount: Account? 
    
    //array to store accounts
//    let accounts = ["cash", "UPI", "card"]
    
    @IBOutlet weak var expenseDescription: UITextField!
    
    @IBOutlet weak var expenseAmount: UITextField!
    @IBOutlet weak var expenseCategory: UITextField!
    @IBOutlet weak var expenseDate: UITextField!
    
    @IBOutlet weak var expenseAccount: UITextField!
    @IBOutlet weak var amountError: UILabel!
    
    @IBOutlet weak var descriptionError: UILabel!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    //delegate to be created to use protocol by main VC
    weak var delegate: NewExpenseViewControllerDelegate?
    
    //picker vw obj
    let pickerView = UIPickerView()
    let pickerViewAccounts = UIPickerView()
    
    //viewWillDisappear on this VC (to call delegate method from main VC)
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //to call delegate method from main VC
        delegate?.newExpenseViewControllerWillDisapear(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton.isEnabled = false
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact 
        
        //loading categories from Realm db
        loadCategories()
        
        //setting default category for selected category
        selectedCategory = categoryArray?[0]
        
        //loading accounts data from realm db
        loadAccounts()
        
        //setting default account for selecte account
        selectedAccount = accountArray?[0]
        
        //assigning delegate and data source
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerViewAccounts.delegate = self
        pickerViewAccounts.dataSource = self
        
        //assigning view to tf
        expenseCategory.inputView = pickerView
        expenseAccount.inputView = pickerViewAccounts
        
        //default value for tf (category)
        if let categories = categoryArray {
            if categories.count > 0 {
                expenseCategory.text = categoryArray?[0].title
            } else {
                expenseCategory.text = "default"
            }
        } else {
            expenseCategory.text = "default"
        }
        //default value for TF (account)
        if let accounts = accountArray {
            if accounts.count > 0 {
                expenseAccount.text = accountArray?[0].name
            } else {
                expenseAccount.text = "default"
            }
        } else {
            expenseAccount.text = "default"
        }
    }
    
    //MARK: - New category and accounts

    //new category
    @IBAction func newCategoryButtonPressed(_ sender: UIButton) {
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
    
    @IBAction func newAccountButtonPressed(_ sender: UIButton) {
        var textField = UITextField()
        
        //for the pop-up alert, to add new category
        let alert = UIAlertController(title: "Add New Account", message: "", preferredStyle: .alert)
        
        //for the button in above created pop-up, and actions of that button
        let action = UIAlertAction(title: "Add Account", style: .default) { action in
            
            //creating a category object to be passed in array
            let newAccountN = Account()
            newAccountN.name = textField.text!
            
            //to save category array to realm
            self.saveAccount(account: newAccountN)
        }
        
        //to add textfield to above alert
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new account"
            textField = alertTextField
        }
        
        //adding action to this alert
        alert.addAction(action)
        
        //to show pop-up present method is used
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Event monitoring on text fields
    //to validate amount field
    @IBAction func amountChanged(_ sender: Any) {
        if let amount = expenseAmount.text {
            //if field is left blank
            if amount == "" {
                amountError.text = "Required"
                amountError.isHidden = false
            } else {
                //if field has some value
                let amountDouble: Float? = Float(amount)
                if amountDouble == nil {
                    amountError.text = "Invalid Number"
                    amountError.isHidden = false
                } else {
                    amountError.isHidden = true
                }
            }
        }
        //to enable/ disable submit based on input received in amount field
        checkForValidForm()
    }
    
    //description changed
    @IBAction func descriptionChanged(_ sender: Any) {
        if let description = expenseDescription.text {
            //to check if tf contains other than whitespaces (i.e. it is not empty)
            if description.trimmingCharacters(in: .whitespaces).isEmpty {
                descriptionError.text = "Required"
                descriptionError.isHidden = false
            } else {
                descriptionError.isHidden = true
            }
        }
        //to enable/ disable submit based on input received in description field
        checkForValidForm()
    }
    
    
    //to enable/ disable submit based on input received in amount field
    func checkForValidForm() {
        if amountError.isHidden && descriptionError.isHidden {
            submitButton.isEnabled = true
        } else {
            submitButton.isEnabled = false
        }
    }
    
    //MARK: - Button Action Method
    
    @IBAction func addNewExpenseTapped(_ sender: UIButton) {
        print("Add new expense button tapped")
        
        //printing values
        print("Amount \(expenseAmount.text!)")
        print("account \(expenseAccount.text!)")
        print("category \(expenseCategory.text!)")
        print("date \(datePicker.date)")
        print("description: \(expenseDescription.text!)")
        
        do {
            try self.realm.write {
                //creating a category object to be passed in array
                let expense = Expense()
                expense.title = expenseDescription.text!
                guard let amount = Float(expenseAmount.text!) else {
                    fatalError("Invalid value")
                }
                expense.amount = amount
                expense.date = datePicker.date 
                
                //setting category to this expense
                self.selectedCategory?.expenses.append(expense)
                print("selected category: \(selectedCategory?.title)")
                
                //setting account to this expense
                self.selectedAccount?.expensesAccount.append(expense)
                print("Selected account: \(selectedAccount?.name)")
                
//                let thisAccount = accountArray?.filter("expensesAccount in %@", expense)
//                print("Expense ac: \(thisAccount?.count)")
            }
        } catch {
            print("Error saving new expense, \(error)")
        }
        
        //to dismiss the modal View
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: - Data Load Methods
    func loadCategories() {
        
        categoryArray = realm.objects(Category.self)
        
    }
    
    //used to save data to realm db
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving new category, \(error)")
        }
    }
    
    //to fetch accounts from realm db
    func loadAccounts() {
        accountArray = realm.objects(Account.self)
    }
    
    //used to save data to realm db
    func saveAccount(account: Account) {
        
        do {
            try realm.write {
                realm.add(account)
            }
        } catch {
            print("Error saving new account, \(error)")
        }
        
    }
}

//MARK: - Picker view methods
extension NewExpenseViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //no of rows in pickerview
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.pickerView {
            return categoryArray?.count ?? 1
        }
        if pickerView == pickerViewAccounts {
            return accountArray?.count ?? 1
        }
        return 1
    }
    
    //data in pickerview
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.pickerView {
            if let category = categoryArray?[row] {
                //setting selected category to variable for later use
                self.selectedCategory = category
                //returnig title from selected category for TF text
                return category.title
            } else {
                return "No categories added yet"
            }
        }
        if pickerView == pickerViewAccounts {
            if let account = accountArray?[row] {
                //setting selected account to variable for later use
                self.selectedAccount = account
                //returnig title from selected category for TF text
                return account.name
            } else {
                return "No accounts added yet"
            }
        }
        return "default"
    }
    
    //data selected from pickerview 
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //to assign selected value to TF
        if pickerView == self.pickerView {
            if let categories = categoryArray {
                expenseCategory.text = categories[row].title
            } else {
                expenseCategory.text = "No categories added yet"
            }
        }
        if pickerView == pickerViewAccounts {
            if let accounts = accountArray {
                expenseAccount.text = accounts[row].name
            } else {
                expenseAccount.text = "No accounts added yet"
            }
        }
        
        //to hide pickerview once a value is selected
        self.view.endEditing(true)
    }
}


