//
//  CategoryModel.swift
//  SISpeciesNotes
//
//  Created by Semper_Idem on 15/12/3.
//  Copyright © 2015年 益行人. All rights reserved.
//

import UIKit
import RealmSwift

/// 种类模型
class CategoryModel: Object {
    /// 名称
    dynamic var name = Categories.Uncategorized.rawValue
}
