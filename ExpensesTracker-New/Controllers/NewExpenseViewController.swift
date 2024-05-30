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
    
    //array to store accounts
    let accounts = ["cash", "UPI", "card"]
    
    @IBOutlet weak var expenseDescription: UITextField!
    
    @IBOutlet weak var expenseAmount: UITextField!
    @IBOutlet weak var expenseCategory: UITextField!
    @IBOutlet weak var expenseDate: UITextField!
    
    @IBOutlet weak var expenseAccount: UITextField!
    @IBOutlet weak var amountError: UILabel!
    
    @IBOutlet weak var submitButton: UIButton!
    
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
        
        //loading categories from Realm db
        loadCategories()
        
        //assigning delegate and data source
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerViewAccounts.delegate = self
        pickerViewAccounts.dataSource = self
        
        //assigning view to tf
        expenseCategory.inputView = pickerView
        expenseAccount.inputView = pickerViewAccounts
        
        //default value for tf
        expenseCategory.text = categoryArray?[0].title 
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
    
    //to enable/ disable submit based on input received in amount field
    func checkForValidForm() {
        if amountError.isHidden {
            submitButton.isEnabled = true
        } else {
            submitButton.isEnabled = false
        }
    }
    
    //MARK: - Button Action Method
    
    @IBAction func addNewExpenseTapped(_ sender: UIButton) {
        print("Add new expense button tapped")
        
        //to dismiss the modal View
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: - Data Load Methods
    func loadCategories() {
        
        categoryArray = realm.objects(Category.self)
        
        //to refresh data in the tableView
        //        tableView.reloadData()
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
