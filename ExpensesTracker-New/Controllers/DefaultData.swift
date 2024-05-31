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
    
}
