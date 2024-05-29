//
//  NewExpenseViewController.swift
//  ExpensesTracker-New
//
//  Created by Mayur Vaity on 26/05/24.
//

import UIKit

//protocol created (for reloading data on main VC)
protocol NewExpenseViewControllerDelegate: AnyObject {
    //this method in main VC will do the reloading of data
    func newExpenseViewControllerWillDisapear(_ modal: NewExpenseViewController)
}

class NewExpenseViewController: UIViewController {
    
    
    @IBOutlet weak var expenseDescription: UITextField!
    
    @IBOutlet weak var expenseAmount: UITextField!
    @IBOutlet weak var expenseAccount: UITextField!
    @IBOutlet weak var expenseDate: UITextField!
    
    @IBOutlet weak var amountError: UILabel!
    
    @IBOutlet weak var submitButton: UIButton!
    
    //delegate to be created to use protocol by main VC
    weak var delegate: NewExpenseViewControllerDelegate?
    
    //viewWillDisappear on this VC (to call delegate method from main VC)
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //to call delegate method from main VC
        delegate?.newExpenseViewControllerWillDisapear(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton.isEnabled = false
        // Do any additional setup after loading the view.
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
    
    
    
}
