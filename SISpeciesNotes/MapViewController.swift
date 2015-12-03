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

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    // MARK: - 属性
    
    /// 地图控件
    @IBOutlet weak private var mapView: MKMapView!
    /// 位置管理器
    private var locationManager = CLLocationManager()
    /// 最后一个标记点信息
    private var lastAnnotation: MKAnnotation!
    /// 标记用户是否定位
    private var isUserLocated = false
    
    // MARK: - 控制器生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "未能获取定位"
        
        initMapView()
        
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            print("请求授权")
        } else {
            locationManager.startUpdatingLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Realm相关方法
    
    // MARK: - CLLocationManager Delegate
    
    /// 改变授权状态信息时调用
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .NotDetermined {
            print("已禁止应用获取用户位置信息，请授权！")
        } else {
            mapView.showsUserLocation = true
        }
    }
    
    // MARK: - MKMapView Delegate
    
    /// 标记的视图定义
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        guard let currentAnnotation = annotation as? SpeciesAnnotation else { return nil }
        guard let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(currentAnnotation.subtitle!) else {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: currentAnnotation.subtitle!)
            
            annotationView.image = currentAnnotation.category.getImage()
            annotationView.enabled = true
            annotationView.canShowCallout = true
            annotationView.centerOffset = CGPointMake(0, -10)
            annotationView.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            if currentAnnotation.category == .Uncategorized {
                annotationView.draggable = true
            }
            return annotationView
        }
        return annotationView
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        for annotationView in views {
            if annotationView.annotation is SpeciesAnnotation {
                annotationView.transform = CGAffineTransformMakeTranslation(0, -500)
                UIView.animateWithDuration(0.5, delay: 0, options: .CurveLinear, animations: {
                    annotationView.transform = CGAffineTransformMakeTranslation(0, 0)
                }, completion: nil)
            }
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if view.annotation is SpeciesAnnotation {
            self.performSegueWithIdentifier("NewEntry", sender: view.annotation)
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == .Ending {
            view.dragState = .None
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
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
        }
    }
    
    @IBAction func unwindFromAddNewEntry(segue: UIStoryboardSegue) {
        
        let addNewEntryController = segue.sourceViewController as! AddNewEntryController
        
        if lastAnnotation != nil {
            mapView.removeAnnotation(lastAnnotation)
        } else {
            for annotation in mapView.annotations {
                
            }
        }
        
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
                (alert: UIAlertAction) -> Void in
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
            placemarks, error in
            if error != nil {
                print("获取当前的位置失败：\(error)")
                return
            }
            for placemark in placemarks! {
                print(placemark.addressDictionary)
                if let area = placemark.addressDictionary!["SubLocality"] as? String {
                    // 区
                    self.title = area
                    print(area)
                }else if let city = placemark.addressDictionary!["City"] as? String {
                    // 市
                    self.title = city
                    print(city)
                }else if let province = placemark.addressDictionary!["State"] as? String {
                    // 省
                    self.title = province
                    print(province)
                }
                else if let country = placemark.addressDictionary!["Country"] as? String {
                    // 国家
                    self.title = country
                    print(country)
                }else {
                    self.title = "未能获取定位"
                }
            }
        })
        
    }
    
    // MARK: - Setter & Getter

    func initMapView() {
        mapView.deleteAttributionLabel()
        mapView.deleteMapInfo()
    }
}

