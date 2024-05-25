//
//  Category.swift
//  ExpensesTracker-New
//
//  Created by Mayur Vaity on 25/05/24.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var title: String = ""
//    @objc dynamic var done: Bool = false 
    
    //forward relationship (dimenson to fact) 
    let expenses = List<Expense>()
    
}
