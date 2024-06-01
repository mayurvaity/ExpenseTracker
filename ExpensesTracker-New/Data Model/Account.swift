//
//  Account.swift
//  ExpensesTracker-New
//
//  Created by Mayur Vaity on 01/06/24.
//

import Foundation
import RealmSwift

class Account: Object {
    @objc dynamic var name: String = ""
//    @objc dynamic var done: Bool = false
    
    //forward relationship (dimenson to fact)
    let expensesAccount = List<Expense>()
    
}

