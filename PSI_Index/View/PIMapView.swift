//
//  ViewController.swift
//  PSI_Index
//
//  Created by javedmultani16 on 19/11/19.
//  Copyright © 2019 Javed Multani. All rights reserved.
//

import UIKit
import MapKit

class PIMapView: UIViewController {
    
    @IBOutlet var typeSegment: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    var psiData = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        getData()
        
    }
    //MARK: - API Call
    //This method is used for the getting data from API
    func getData() {
        APIHelper().getPSIData { (data) in
            self.psiData = data ?? [:]
            DispatchQueue.main.async(execute: {
                self.addPins()
            })
        }
    }
    //MARK: - adding pin
    //This method is used for adding pin on map
    func addPins() {
        if let regionMetadata = self.psiData["region_metadata"] as? [[String: Any]]{
            for regionData in regionMetadata {
                var lastCoordinate = CLLocationCoordinate2D()
                if let location = regionData["label_location"] as? [String: Double], let lat = location["latitude"], let long = location["longitude"]  {
                    let annotation = PSIAnnotation()
                    let centerCoordinate = CLLocationCoordinate2D(latitude: (lat) , longitude: (long))
                    lastCoordinate = centerCoordinate
                    annotation.coordinate = centerCoordinate
                    annotation.title = regionData["name"] as? String ?? ""
                    mapView.addAnnotation(annotation)
                }
                let center = lastCoordinate
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3))
                
                //set region on the map
                mapView.setRegion(region, animated: true)
            }
            print(regionMetadata)
        }
    }
    //MARK: - Segment Handler
    //This method is used for change map type using segment control
    @IBAction func typeSegmenthandler(_ sender: Any) {
        if self.typeSegment.selectedSegmentIndex == 0{
            self.mapView.mapType = .standard
        }else if self.typeSegment.selectedSegmentIndex == 1{
            self.mapView.mapType = .satellite
        }else{
            self.mapView.mapType = .hybrid
        }
        
    }
    
}

extension PIMapView: MKMapViewDelegate  {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print(view)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let identifier = "PSIAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            
            annotationView!.annotation = annotation
        }
        
        configureDetailView(annotationView: annotationView!)
        return annotationView
    }
    
    func configureDetailView(annotationView: MKAnnotationView) {
        guard let view = annotationView.annotation as? PSIAnnotation else {
            return
        }
        print("detect",view.title ?? "")
        let detailView = PSIDetailView.fromNib(xibName: "PSIDetailView") as! PSIDetailView
        var detailData = ""
        if let items = self.psiData["items"] as? [[String: Any]] {
            for item in items {
                if let reading = item["readings"] as? [String: Any] {
                    for (_,dict) in reading.enumerated() {
                        if let value = dict.value as? [String: Int] {
                            var calculateValues = 0
                            for (_, values) in value.enumerated() {
                                if values.key == view.title {
                                    calculateValues = calculateValues+values.value
                                    print(values.key)
                                    print(values.value)
                                }
                            }
                            detailData = detailData+"\(dict.key): \(calculateValues)\n"
                        }
                        print(detailData)
                    }
                }
            }
        }
        detailView.lblDetail.text = detailData
        annotationView.detailCalloutAccessoryView = detailView
    }
    
}

extension UIView {
    class func fromNib<T : UIView>(xibName: String) -> T {
        return Bundle.main.loadNibNamed(xibName, owner: nil, options: nil )![0] as! T
    }
}

