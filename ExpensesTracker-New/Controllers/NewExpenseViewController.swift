//
//  NewExpenseViewController.swift
//  ExpensesTracker-New
//
//  Created by Mayur Vaity on 26/05/24.
//

import UIKit

//protocol created (for reloading data on main VC)
protocol NewExpenseViewControllerDelegate: class {
    //this method in main VC will do the reloading of data
    func newExpenseViewControllerWillDisapear(_ modal: NewExpenseViewController)
}

class NewExpenseViewController: UIViewController {
    
    
    @IBOutlet weak var expenseDescription: UITextField!
    
    @IBOutlet weak var expenseAmount: UITextField!
    @IBOutlet weak var expenseAccount: UITextField!
    @IBOutlet weak var expenseDate: UITextField!
    
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

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addNewExpenseTapped(_ sender: UIButton) {
        print("Add new expense button tapped")
        
        //to dismiss the modal View 
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)

    }
    
    

}
