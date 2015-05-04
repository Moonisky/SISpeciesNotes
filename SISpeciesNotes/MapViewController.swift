//
//  ViewController.swift
//  SISpeciesNotes
//
//  Created by 星夜暮晨 on 2015-04-29.
//  Copyright (c) 2015 益行人. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Realm

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    // MARK: - 属性
    
    /// 地图控件
    @IBOutlet weak var mapView: MKMapView!
    /// 位置管理器
    var locationManager = CLLocationManager()
    /// 最后一个标记点信息
    var lastAnnotation: MKAnnotation!
    
    /// 标记用户是否定位
    var isUserLocated = false
    
    var results: RLMResults?
    
    // MARK: - 控制器生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "未能获取定位"
        
        initMapView()
        
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            println("请求授权")
        } else {
            locationManager.startUpdatingLocation()
        }
        
        populateMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Realm相关方法
    
    // MARK: - CLLocationManager Delegate
    
    /// 改变授权状态信息时调用
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .NotDetermined {
            println("已禁止应用获取用户位置信息，请授权！")
        }else {
            mapView.showsUserLocation = true
        }
    }
    
    // MARK: - MKMapView Delegate
    
    /// 标记的视图定义
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is SpeciesAnnotation {
            let currentAnnotation = annotation as! SpeciesAnnotation
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(currentAnnotation.subtitle)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: currentAnnotation.subtitle)
                annotationView.image = getImageOfSpecies(currentAnnotation.subtitle)
                annotationView.enabled = true
                annotationView.canShowCallout = true
                annotationView.centerOffset = CGPointMake(0, -10)
                
                var detailDisclosure = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
                annotationView.rightCalloutAccessoryView = detailDisclosure
            
                if currentAnnotation.title == "新物种" {
                    annotationView.draggable = true
                }
            }
            return annotationView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!) {
        for annotationView in views as! [MKAnnotationView] {
            if annotationView.annotation is SpeciesAnnotation {
                annotationView.transform = CGAffineTransformMakeTranslation(0, -500)
                UIView.animateWithDuration(0.5, delay: 0, options: .CurveLinear, animations: {
                    annotationView.transform = CGAffineTransformMakeTranslation(0, 0)
                }, completion: nil)
            }
        }
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if view.annotation is SpeciesAnnotation {
            self.performSegueWithIdentifier("NewEntry", sender: view.annotation)
        }
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == .Ending {
            view.dragState = .None
        }
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        getCurrentGeoInfo()
    }
    
    // MARK: - 按钮动作
    
    @IBAction func addNewEntryTapped(sender: UIBarButtonItem) {
        addNewAnnotation()
    }
    
    @IBAction func centerToUserLocationTapped(sender: UIBarButtonItem) {
        centerToUsersLocation()
    }
    
    /// 界面跳转
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NewEntry" {
            let controller = segue.destinationViewController as! AddNewEntryController
            let speciesAnnotation = sender as! SpeciesAnnotation
            controller.selectedAnnotation = speciesAnnotation
        }else if segue.identifier == "Log" {
            updateLocationDistance()
        }
    }
    
    @IBAction func unwindFromAddNewEntry(segue: UIStoryboardSegue) {
        
        let addNewEntryController = segue.sourceViewController as! AddNewEntryController
        let addedSpecies = addNewEntryController.species
        let addedSpeciesCoordinate = CLLocationCoordinate2DMake(addedSpecies.latitude, addedSpecies.longitude)
        
        if lastAnnotation != nil {
            mapView.removeAnnotation(lastAnnotation)
        } else {
            for annotation in mapView.annotations {
                let currentAnnotation = annotation as! SpeciesAnnotation
                if currentAnnotation.coordinate.latitude == addedSpeciesCoordinate.latitude && currentAnnotation.coordinate.longitude == addedSpeciesCoordinate.longitude {
                    mapView.removeAnnotation(currentAnnotation)
                    break
                }
            }
        }
        
        let annotation = SpeciesAnnotation(coordinate: addedSpeciesCoordinate, title: addedSpecies.name, sub: Categories(rawValue: addedSpecies.category.name)!, species: addedSpecies)
        
        mapView.addAnnotation(annotation)
        
        lastAnnotation = nil
    }
    
    // MARK: - 私有的简易方法
    
    /// 将地图中心重定位到当前用户位置
    private func centerToUsersLocation() {
        let userLocation = mapView.userLocation.coordinate
        mapView.setCenterCoordinate(userLocation, zoomLevel: 5, animated: true)
    }
    
    /// 添加新的标记点
    private func addNewAnnotation() {
        if lastAnnotation == nil {

            let species = SpeciesAnnotation(coordinate: mapView.centerCoordinate, title: "新物种", sub: .Uncategorized)
            
            mapView.addAnnotation(species)
            lastAnnotation = species
            
        }else {
            let alertController = UIAlertController(title: "这个位置已被标记", message: "当前位置已经标记过了，如果需要更改这个标记的位置，请将其拖动到其他位置！", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "确定", style: .Destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                    alertController.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // 获取当前地理位置信息
    private func getCurrentGeoInfo() {
        var geocoder = CLGeocoder()
        var location = CLLocation(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
        geocoder.reverseGeocodeLocation(location, completionHandler: {
            (array: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                println("获取当前的位置失败：\(error)")
                return
            }
            var placemarks = array as! [CLPlacemark]
            for placemark in placemarks {
                println(placemark.addressDictionary)
                if let area = placemark.addressDictionary["SubLocality"] as? String {
                    // 区
                    self.title = area
                    println(area)
                }else if let city = placemark.addressDictionary["City"] as? String {
                    // 市
                    self.title = city
                    println(city)
                }else if let province = placemark.addressDictionary["State"] as? String {
                    // 省
                    self.title = province
                    println(province)
                }
                else if let country = placemark.addressDictionary["Country"] as? String {
                    // 国家
                    self.title = country
                    println(country)
                }else {
                    self.title = "未能获取定位"
                }
            }
        })
    }
    
    func populateMap() {
        mapView.removeAnnotations(mapView.annotations)
        
        if let results = SpeciesModel.allObjects() {
            self.results = results
            for result in results {
                let species = result as! SpeciesModel
                let coordinate = CLLocationCoordinate2DMake(species.latitude, species.longitude)
                let speciesAnnotation = SpeciesAnnotation(coordinate: coordinate, title: species.name, sub: Categories(rawValue: species.category.name)!, species: species)
                mapView.addAnnotation(speciesAnnotation)
            }
        }
    }
    
    func updateLocationDistance() {
        let realm = RLMRealm.defaultRealm()
        
        if results != nil {
            for result in results! {
                let currentSpecies = result as! SpeciesModel
                let currentLocation = CLLocation(latitude: currentSpecies.latitude, longitude: currentSpecies.longitude)
                let distance = currentLocation.distanceFromLocation(mapView.userLocation.location)
                realm.beginWriteTransaction()
                currentSpecies.distance = Double(distance)
                realm.commitWriteTransaction()
            }
        }
    }
    
    // MARK: - Setter & Getter

    func initMapView() {
        mapView.deleteAttributionLabel()
        mapView.deleteMapInfo()
    }
}

