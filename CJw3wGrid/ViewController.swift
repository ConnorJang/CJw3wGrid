//
//  ViewController.swift
//  CJw3wGrid
//
//  Created by iMac03 on 2017-10-12.
//  Copyright © 2017 iMac03. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import SwiftyJSON
import MapKit

class ViewController: UIViewController {
    @IBOutlet weak var gridText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var locManager = CLLocationManager()
    
    @IBOutlet weak var gridButton: UIButton!
    @IBAction func gridAction(_ sender: UIButton) {
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse)
        {
            var lat, long : Double
            // Rounding Lat/Long to 6 decimal places
            //lat = Double(round(1000000*(locManager.location?.coordinate.latitude ?? -1))/1000000)
            //long = Double(round(1000000*(locManager.location?.coordinate.longitude ?? -1))/1000000)
            lat = Double(locManager.location?.coordinate.latitude ?? -1)
            long = Double(locManager.location?.coordinate.longitude ?? -1)
            print("Latitude---> \(lat) ")
            print("Longitude--> \(long) ")
            
            
            // Variable for the grid nw=NorthWest se=SouthEast
            // 0.000027 = about 3m
            let nwLat = lat + (5*0.00003)
            let nwLong = long - (5*0.00003)
            let seLat = lat - (5*0.00003)
            let seLong = long + (5*0.00003)
            
            gridText.text = "Latitude = \(lat) Longitude = \(long)\nGrid Bounding Box:\n  NW corner:\n    lat = \(nwLat) \n    long = \(nwLong)\n  SE corner: \n    lat = \(seLat)\n    long = \(seLong)\n"
            
            //Sample URL for the api call: https://api.what3words.com/v2/grid?bbox=52.208867,0.117540,52.207988,0.116126&format=json&key=BJEVPZLZ
            // Subbing in the calucalted bounding 
            let url = URL(string: "https://api.what3words.com/v2/grid?bbox=\(nwLat),\(nwLong),\(seLat),\(seLong)&format=json&key=BJEVPZLZ")
            
            
            let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                
                if let data = data {
                    do {
                        // Convert the data to JSON
                        let json = try JSON(data: data)
                        print(json["lines"])
                        let lineObject = json["lines"]
                        
                        var lats = Set<Double>()
                        var longs = Set<Double>();
                        var points = [CLLocationCoordinate2D]();
                        for i in 0...lineObject.count-1 {
                            lats.insert(lineObject[i]["start"]["lat"].double!)
                            lats.insert(lineObject[i]["start"]["lat"].double!)
                            longs.insert(lineObject[i]["start"]["lng"].double!)
                            longs.insert(lineObject[i]["start"]["lng"].double!)
                        }
                        
                        // Sorting so that first element in 'points' is top-left, last element is bottom-right.
                        // In other words, 'points' goes left to right, top to bottom.
                        let sortedLats = lats.sorted(by: >)
                        let sortedLongs = longs.sorted()
                        
                        for latitude in sortedLats {
                            for longitude in sortedLongs {
                                let point = CLLocationCoordinate2D(latitude : latitude, longitude : longitude);
                                points += [point]
                            }
                        }
                        
                        for point in points {
                            print("\(point.latitude), \(point.longitude)")
                        }
  
                    }  catch let error as NSError {
                        print(error.localizedDescription)
                    }
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            task.resume()
            
            // Infinitely run the main loop to wait for our request.
            // Only necessary if you are testing in the command line.
            //RunLoop.main.run()
        }
    }
}
