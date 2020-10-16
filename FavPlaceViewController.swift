//
//  FavPlaceViewController.swift
//  varmeets
//
//  Created by 持田侑菜 on 2020/10/15.
//

import UIKit
import MapKit

class FavPlaceViewController: UIViewController, MKMapViewDelegate {
    
    var place: String?
    var lat: Double?
    var lon: Double?
    
    var annotation = MKPointAnnotation()
    
    let geocoder = CLGeocoder()

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self

        initMap()
        
        if let placeName = place {
            
            self.navigationItem.title = placeName
            
            if let lat = self.lat, let lon = self.lon {
                
                // ピンに緯度と経度をセット
                let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                annotation.coordinate = center
                // ピンをMKMapViewの中心にする
                mapView.centerCoordinate = center
                // ピンを立てる
                mapView.addAnnotation(annotation)
                // ピンを最初から選択状態にする
                mapView.selectAnnotation(annotation, animated: true)
                // ピンのタイトルに場所の名前を表示
                annotation.title = placeName
                
                // 緯度と経度から住所を特定
                let location = CLLocation(latitude: lat, longitude: lon)
                
                geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
                    
                    if let error = error {
                        print("住所取得エラー: \(error)")
                        return
                    }
                    
                    if let placemark = placemarks?.first,
                       let administrativeArea = placemark.administrativeArea, //県
                       let locality = placemark.locality, // 市区町村
                       let throughfare = placemark.thoroughfare, // 丁目を含む地名
                       let subThoroughfare = placemark.subThoroughfare { // 番地
                        
                        // サブタイトルに住所を表示
                        self.annotation.subtitle = administrativeArea + locality + throughfare + subThoroughfare
                    }
                })
            }
        }
    }
    
    func initMap() {
        // 縮尺
        var region = mapView.region
        region.span.latitudeDelta = 0.02
        region.span.longitudeDelta = 0.02
        mapView.setRegion(region, animated: true)
    }
    
    // ピンの詳細設定
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        
        // 吹き出しを表示
        annotationView.canShowCallout = true
        
        return annotationView
    }
}
