//
//  LogViewController.swift
//  SISpeciesNotes
//
//  Created by 星夜暮晨 on 2015-04-29.
//  Copyright (c) 2015 益行人. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class LogViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    // MARK: 属性
    
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    
    /// 所有物种
    var species: Results<SpeciesModel>!
    /// 搜索结果
    private var searchResults: Results<SpeciesModel>!
    
    private var searchController: UISearchController!
    
    // MARK: 控制器生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.species = realm.objects(SpeciesModel).sorted("name", ascending: true)
        initSearchController()  // 初始化搜索控制器
        definesPresentationContext = true
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
            return searchResults != nil ? searchResults.count : 0
        }else {
            return species.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LogCell") as! LogCell
        let speciesModel: SpeciesModel
        if searchController.active {
            speciesModel = self.searchResults[indexPath.row]
        } else {
            speciesModel = self.species[indexPath.row]
        }
        cell.titleLabel.text = speciesModel.name
        cell.subtitleLabel.text = speciesModel.category?.name
        cell.iconImageView.image = Categories(rawValue: speciesModel.category!.name)!.annotationImage
   
        if speciesModel.distance < 0 {
            cell.distanceLabel.text = "N/A"
        } else {
            cell.distanceLabel.text = String(format: "%.2f km", speciesModel.distance / 1000)
        }
        
        return cell
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
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            if let searchResultsController = searchController.searchResultsController as? UITableViewController where searchController.active {
                if let indexPathSearch = searchResultsController.tableView.indexPathForSelectedRow {
                    selectedSpecies = searchResults[indexPathSearch.row]
                }
            } else {
                selectedSpecies = species[indexPath.row]
            }
            controller.species = selectedSpecies
        }
    }
    
    // MARK: - Actions
    
    private func deleteRowAtIndexPath(indexPath: NSIndexPath) {
        let objectToDelete = species[indexPath.row]
        try! realm.write {
            realm.delete(objectToDelete)
            self.species = realm.objects(SpeciesModel).sorted("name", ascending: true)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    private func filterResultsWithSearchString(searchString: String) {
        let results = realm.objects(SpeciesModel).filter("name BEGINSWITH [c]'\(searchString)'")
        let scopeIndex = searchController.searchBar.selectedScopeButtonIndex
        switch scopeIndex {
        case 0:
            searchResults = results.sorted("name", ascending: true)
        case 1:
            searchResults = results.sorted("distance", ascending: true)
        case 2:
            searchResults = results.sorted("created", ascending: true)
        default:
            searchResults = results
        }
        tableView.reloadData()
    }
    
    @IBAction private func scopeChanged(sender: AnyObject) {
        let species = realm.objects(SpeciesModel)
        switch sender.selectedSegmentIndex {
        case 0:
            self.species = species.sorted("name", ascending: true)
        case 1:
            self.species = species.sorted("distance", ascending: true)
        case 2:
            self.species = species.sorted("created", ascending: true)
        default:
            self.species = species
        }
        tableView.reloadData()
    }
    
    // MARK: - Setter & Getter
    
    private func initSearchController() {
        let searchResultsController = UITableViewController(style: .Plain)
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
