//
//  AddNewEntryController.swift
//  SISpeciesNotes
//
//  Created by 星夜暮晨 on 2015-04-29.
//  Copyright (c) 2015 益行人. All rights reserved.
//

import UIKit
import Realm

class AddNewEntryController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - 属性
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    /// 当前所选中的标记信息
    var selectedAnnotation: SpeciesAnnotation!
    
    var selectedCategory: CategoryModel!
    
    var species: SpeciesModel!
    
    // MARK: - 控制器生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if species == nil {
            title = "添加新的物种"
        }else {
            title = "编辑\(species.name)"
            fillTextFields()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.performSegueWithIdentifier("Categories", sender: self)
    }
    
    // MARK: - 按钮动作
    
    @IBAction func unwindFromCategories(segue: UIStoryboardSegue) {
        let categoriesController = segue.sourceViewController as! CategoriesTableViewController
        
        selectedCategory = categoriesController.selectedCategories
        categoryTextField.text = selectedCategory.name
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if validateFields() {
            if species == nil {
                addNewSpecies()
            }else {
                updateSpecies()
            }
            return true
        } else {
            return false
        }
    }
    
    // MARK: - 文本栏输入验证
    
    func validateFields() -> Bool {
        if nameTextField.text.isEmpty || descriptionTextView.text.isEmpty || selectedCategory == nil {
            let alertController = UIAlertController(title: "验证错误", message: "所有的文本栏都不能为空", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "确认", style: .Destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return false
        }else {
            return true
        }
    }
    
    func addNewSpecies() {
        let realm = RLMRealm.defaultRealm()
        
        realm.beginWriteTransaction()
        let newSpecies = SpeciesModel()

        newSpecies.name = nameTextField.text
        newSpecies.category = selectedCategory
        newSpecies.speciesDescription = descriptionTextView.text
        newSpecies.latitude = selectedAnnotation.coordinate.latitude
        newSpecies.longitude = selectedAnnotation.coordinate.longitude
        
        realm.addObject(newSpecies)
        realm.commitWriteTransaction()
        
        self.species = newSpecies
    }
    
    func fillTextFields() {
        nameTextField.text = species.name
        categoryTextField.text = species.category.name
        descriptionTextView.text = species.speciesDescription
        
        selectedCategory = species.category
    }
    
    func updateSpecies() {
        let realm = RLMRealm.defaultRealm()
        realm.beginWriteTransaction()
        
        species.name = nameTextField.text
        species.category = selectedCategory
        species.speciesDescription = descriptionTextView.text
        
        realm.commitWriteTransaction()
    }
}
