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
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    /// 当前所选中的标记信息
    var selectedAnnotation: SpeciesAnnotation!
    
    // MARK: - 控制器生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
    
    // MARK: - 文本栏输入验证
    
    private func validateFields() -> Bool {
        if nameTextField.text!.isEmpty || descriptionTextView.text.isEmpty {
            let alertController = UIAlertController(title: "验证错误", message: "所有的文本栏都不能为空", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "确认", style: .Destructive, handler: {
                (alert: UIAlertAction) -> Void in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return false
        }else {
            return true
        }
    }
}
