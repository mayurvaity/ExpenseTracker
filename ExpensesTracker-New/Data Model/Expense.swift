//
//  Expenses.swift
//  ExpensesTracker-New
//
//  Created by Mayur Vaity on 25/05/24.
//

import Foundation
import RealmSwift

class Expense: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var amount: Float = 0.0
    
    //backward relationship (fact to dimension)
    var parentCategory = LinkingObjects(fromType: Category.self, property: "expenses")
}
