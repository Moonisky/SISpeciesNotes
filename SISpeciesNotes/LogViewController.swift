//
//  LogViewController.swift
//  SISpeciesNotes
//
//  Created by 星夜暮晨 on 2015-04-29.
//  Copyright (c) 2015 益行人. All rights reserved.
//

import UIKit
import MapKit
import Realm

class LogViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    // MARK: - 属性
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    /// 物种
    var species: RLMResults!
    /// 搜索结果
    var searchResults = SpeciesModel.allObjects()
    
    var searchController: UISearchController!
    
    // MARK: - 控制器生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        species = SpeciesModel.allObjects().sortedResultsUsingProperty("name", ascending: true)
        
        initSearchController()  // 初始化搜索控制器
        definesPresentationContext = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - SearchBar Delegate
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text

        let searchResultController = searchController.searchResultsController as! UITableViewController
        searchResultController.tableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            if searchResults != nil {
                return Int(searchResults.count)
            }else {
                return 0
            }
        }else {
            return Int(species.count)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("LogCell", forIndexPath: indexPath) as? LogCell
        var speciesModel = species[UInt(indexPath.row)] as! SpeciesModel
        
        if searchController.active {
            speciesModel = searchResults[UInt(indexPath.row)] as! SpeciesModel
        }else {
            speciesModel = species[UInt(indexPath.row)] as! SpeciesModel
        }
        
        cell!.titleLabel.text = speciesModel.name
        cell!.subtitleLabel.text = speciesModel.category.name
        cell!.iconImageView.image = getImageOfSpecies(speciesModel.category.name)
        
        if speciesModel.distance < 0 {
            cell!.distanceLabel.text = "N/A"
        }else {
            cell!.distanceLabel.text = String(format: "%.2fkm", speciesModel.distance / 1000)
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteRowAtIndexPath(indexPath)
        }
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Edit" {
            let controller = segue.destinationViewController as! AddNewEntryController
            var selectedSpecies: SpeciesModel!
            let indexPath = tableView.indexPathForSelectedRow()
            
            if searchController.active {
                let searchResultsController = searchController.searchResultsController as! UITableViewController
                let indexPathSearch = searchResultsController.tableView.indexPathForSelectedRow()
                selectedSpecies = searchResults[UInt(indexPathSearch!.row)] as! SpeciesModel
            }else{
                selectedSpecies = species[UInt(indexPath!.row)] as! SpeciesModel
            }
            
            controller.species = selectedSpecies
        }
    }
    
    // MARK: - Actions
    
    @IBAction func scopeChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            species = SpeciesModel.allObjects().sortedResultsUsingProperty("name", ascending: true)
        case 1:
            species = SpeciesModel.allObjects().sortedResultsUsingProperty("distance", ascending: true)
        case 2:
            species = SpeciesModel.allObjects().sortedResultsUsingProperty("created", ascending: true)
        default:
            species = SpeciesModel.allObjects().sortedResultsUsingProperty("name", ascending: true)
        }
        tableView.reloadData()
    }
    
    func deleteRowAtIndexPath(indexPath: NSIndexPath) {
        let realm = RLMRealm.defaultRealm()
        let objectToDelete = species[UInt(indexPath.row)] as! SpeciesModel
        realm.beginWriteTransaction()
        realm.deleteObject(objectToDelete)
        realm.commitWriteTransaction()
        
        species = SpeciesModel.allObjects().sortedResultsUsingProperty("name", ascending: true)
        
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
    
    func filterResultsWithSearchString(searchString: String) {
        if searchResults == nil {
            searchResults = SpeciesModel.allObjects()
        }else {
            let predicate = "name BEGINSWITH [c]'\(searchString)'"
            let scopeIndex = searchController.searchBar.selectedScopeButtonIndex
            searchResults = SpeciesModel.objectsWhere(predicate)
            println(searchResults)
            switch scopeIndex {
            case 0:
                searchResults = searchResults.sortedResultsUsingProperty("name", ascending: true)
            case 1:
                searchResults = searchResults.sortedResultsUsingProperty("distance", ascending: true)
            case 2:
                searchResults = searchResults.sortedResultsUsingProperty("created", ascending: true)
            default:
                return
            }
        }
    }
    
    // MARK: - Setter & Getter
    
    func initSearchController() {
        var searchResultsController = UITableViewController(style: .Plain) as UITableViewController
        searchResultsController.tableView.delegate = self
        searchResultsController.tableView.dataSource = self
        searchResultsController.tableView.rowHeight = 63
        searchResultsController.tableView.registerClass(LogCell.self, forCellReuseIdentifier: "LogCell")
        
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.tintColor = UIColor.whiteColor()
        searchController.searchBar.delegate = self
        searchController.searchBar.barTintColor = UIColor(red: 0, green: 104.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        tableView.tableHeaderView?.addSubview(searchController.searchBar)
    }
}
