//
//  CategoriesTableViewController.swift
//  SISpeciesNotes
//
//  Created by 星夜暮晨 on 2015-04-30.
//  Copyright (c) 2015 益行人. All rights reserved.
//

import UIKit
import Realm

class CategoriesTableViewController: UITableViewController {

    // MARK: - 属性
    
    var results: RLMResults!
    
    var selectedCategories: CategoryModel!
    
    // MARK: - 控制器生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateDefaultCategories()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(results.count)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = (results[UInt(indexPath.row)] as! CategoryModel).name
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        selectedCategories = self.results[UInt(indexPath.row)] as! CategoryModel
        return indexPath
    }
    
    // MARK: - 私有方法
    
    private func populateDefaultCategories() {
        results = CategoryModel.allObjects()
        
        if results.count == 0 {
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            
            let defaultCategories = Categories.allValues
            for category in defaultCategories {
                let newCategory = CategoryModel()
                newCategory.name = category
                realm.addObject(newCategory)
            }
    
            realm.commitWriteTransaction()
            results = CategoryModel.allObjects()
        }
    }
}
