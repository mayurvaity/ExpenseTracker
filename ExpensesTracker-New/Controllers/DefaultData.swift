//
//  DefaultData.swift
//  ExpensesTracker-New
//
//  Created by Mayur Vaity on 31/05/24.
//

import Foundation
import RealmSwift

class DefaultData {
    
    //creating new realm
    let realm = try! Realm()
    
    //array to store all category objects
    var categoryArray: Results<Category>?
    
    //array to store all account objects
    var accountArray: Results<Account>?
    
    
    //used to check if default entries are there and to add them
    func addDefaultEntries() {
        //loading categories data from realm db
        loadCategories()
        
        //chcking if there any categories, if not to add the default one
        if categoryArray?.count == 0 {
            print("No categories created yet. Adding 1st now...")
            addDefaultCategory()
        } else {
            print("Category count: \(categoryArray?.count)")
        }
        
        //loading accounts data from realm db
        loadAccounts()
        
        //checking if there are any pre-existing accounts
        if accountArray?.count == 0 {
            print("No acoounts created yet. Adding 1st now...")
            addDefaultAccount()
        } else {
            print("Account count: \(accountArray?.count)")
        }
    }
    
    
    //MARK: - Category - Model Manipulation Methods 
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
    
    //to fetch categories from realm db
    func loadCategories() {
        categoryArray = realm.objects(Category.self)
    }
    
    //to add "other" default category
    func addDefaultCategory() {
        //creating a category object to be passed in array
        let newCategoryN = Category()
        newCategoryN.title = "other"
        
        //to save category array to realm
        self.save(category: newCategoryN)
    }
    
    //MARK: - Account - Model Manipulation Methods
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
    
    //to fetch accounts from realm db
    func loadAccounts() {
        accountArray = realm.objects(Account.self)
    }
    
    //to add "cash" default account
    func addDefaultAccount() {
        //creating a category object to be passed in array
        let newAccountN = Account()
        newAccountN.name = "cash"
        
        //to save category array to realm
        self.saveAccount(account: newAccountN)
    }
}
