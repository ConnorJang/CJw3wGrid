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

class ViewController: UIViewController {

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
            lat = Double(round(1000000*(locManager.location?.coordinate.latitude ?? -1))/1000000)
            long = Double(round(1000000*(locManager.location?.coordinate.longitude ?? -1))/1000000)
            print("Latitude---> \(lat) ")
            print("Longitude--> \(long) ")
            
            
            // Variable for the grid nw=NorthWest se=SouthEast
            // 0.000027 = about 3m
            let nwLat = lat + (2*0.000027)
            let nwLong = long - (2*0.000027)
            let seLat = lat - (2*0.000027)
            let seLong = long + (2*0.000027)
            
            //Sample URL for the api call: https://api.what3words.com/v2/grid?bbox=52.208867,0.117540,52.207988,0.116126&format=json&key=BJEVPZLZ
            // Subbing in the calucalted bounding 
            let url = URL(string: "https://api.what3words.com/v2/grid?bbox=\(nwLat),\(nwLong),\(seLat),\(seLong)&format=json&key=BJEVPZLZ")
            
            
            let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                
                if let data = data {
                    do {
                        // Convert the data to JSON
                        let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                        
                        // Sets the json values recieved to variables
                        //     ex:  let url = json["url"], let explanation = json["explanation"]
                        if let json = jsonSerialized, let status = json["status"], let lines = json["lines"] {
                            print(status)
                            print(lines)
                            //for line in (lines) {
                            //    //print("line = \(line)")
                            //    print(line)
                            //}
                            
                            
                            //for (key, value) in json {
                            //    print(key)
                            //    print(value)
                            //}
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