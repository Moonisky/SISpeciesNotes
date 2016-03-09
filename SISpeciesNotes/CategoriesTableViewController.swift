//
//  CategoriesTableViewController.swift
//  SISpeciesNotes
//
//  Created by 星夜暮晨 on 2015-04-30.
//  Copyright (c) 2015 益行人. All rights reserved.
//

import UIKit
import RealmSwift

class CategoriesTableViewController: UITableViewController {

    // MARK: - 属性
    
    private var categories: Results<CategoryModel>!
    var selectedCategory: CategoryModel!
    
    // MARK: - 控制器生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.populateDefaultCategories()
        self.tableView.tableFooterView = nil
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .Plain, target: self, action: "cancel")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath)
        if let currentCategory = Categories(rawValue: categories[indexPath.row].name) {
            cell.imageView?.image = currentCategory.annotationImage
            cell.textLabel?.text = currentCategory.rawValue
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        selectedCategory = self.categories[indexPath.row]
        return indexPath
    }
    
    @objc private func cancel() {
        self.performSegueWithIdentifier("categoryUnwind", sender: self)
    }
    
    // MARK: - Helper Methods
    
    private func populateDefaultCategories() {
        let fetchResults = realm.objects(CategoryModel)
        self.categories = fetchResults
        
        if categories.count != 0 { return }
        try! realm.write {
            for category in Categories.allValues {
                let newCategory = CategoryModel()
                newCategory.name = category.rawValue
                realm.add(newCategory)
            }
        }
    }
}
