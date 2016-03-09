//
//  AddNewEntryController.swift
//  SISpeciesNotes
//
//  Created by 星夜暮晨 on 2015-04-29.
//  Copyright (c) 2015 益行人. All rights reserved.
//

import UIKit

class AddNewEntryController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - 属性
    
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var categoryTextField: UITextField!
    @IBOutlet private weak var descriptionTextView: UITextView!
    
    /// 当前所选中的标记信息
    var selectedAnnotation: SpeciesAnnotation! {
        didSet {
            species = selectedAnnotation.species
        }
    }
    var selectedCategory: CategoryModel!
    var species: SpeciesModel!
    
    // MARK: - 控制器生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let species = self.species {
            title = "编辑\(species.name)"
            fillTextfields()
        } else {
            title = "添加新的物种"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.performSegueWithIdentifier("Categories", sender: self)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if validateFields() {
            species == nil ? addNewSpecies() : updateSpecies()
            return true
        }
        return false
    }
    
    // MARK: - 按钮动作
    
    @IBAction private func unwindFromCategories(segue: UIStoryboardSegue) {
        guard let categoriesController = segue.sourceViewController as? CategoriesTableViewController, category = categoriesController.selectedCategory else { return }
        selectedCategory = category
        categoryTextField.text = category.name
    }
    
    private func addNewSpecies() {
        try! realm.write {
            let newSpecies = SpeciesModel()
            newSpecies.name = self.nameTextField.text!
            newSpecies.category = self.selectedCategory
            newSpecies.speciesDescription = self.descriptionTextView.text
            newSpecies.latitude = self.selectedAnnotation.coordinate.latitude
            newSpecies.longitude = self.selectedAnnotation.coordinate.longitude
            self.species = newSpecies
            realm.add(newSpecies)
        }
    }
    
    private func fillTextfields() {
        if species == nil { return }
        nameTextField.text = species.name
        categoryTextField.text = species.category?.name
        descriptionTextView.text = species.speciesDescription
    }
    
    private func updateSpecies() {
        try! realm.write {
            self.species.name = nameTextField.text!
            self.species.category = selectedCategory
            self.species.speciesDescription = descriptionTextView.text
        }
    }
    
    // MARK: - 文本栏输入验证
    
    private func validateFields() -> Bool {
        if nameTextField.text!.isEmpty || descriptionTextView.text.isEmpty || selectedCategory == nil {
            let alertController = UIAlertController(title: "验证错误", message: "所有的文本栏都不能为空", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "确认", style: .Destructive) { alert in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            }
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            return false
        }
        return true
    }
}
