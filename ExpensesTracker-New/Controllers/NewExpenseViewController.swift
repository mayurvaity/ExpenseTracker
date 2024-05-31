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
    
    var selectedCategory: Category?
    
    //array to store accounts
    let accounts = ["cash", "UPI", "card"]
    
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
        
        //assigning delegate and data source
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerViewAccounts.delegate = self
        pickerViewAccounts.dataSource = self
        
        //assigning view to tf
        expenseCategory.inputView = pickerView
        expenseAccount.inputView = pickerViewAccounts
        
        //default value for tf
        if let categories = categoryArray {
            if categories.count > 0 {
                expenseCategory.text = categoryArray?[0].title
            } else {
                expenseCategory.text = "default"
            }
        } else {
            expenseCategory.text = "default"
        }
        
        expenseAccount.text = accounts[0]
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
        print("Amount \(expenseAmount.text)")
        print("account \(expenseAccount.text)")
        print("category \(expenseCategory.text)")
        print("date \(datePicker.date)")
        print("description: \(expenseDescription.text)")
        
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
            return accounts.count
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
            return accounts[row]
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
            expenseAccount.text = accounts[row]
        }
        
        //to hide pickerview once a value is selected
        self.view.endEditing(true)
    }
}
