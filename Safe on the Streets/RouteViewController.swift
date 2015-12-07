//
//  RouteViewController.swift
//  Safe on the Streets
//
//  Created by Zach Jiroun on 12/6/15.
//  Copyright © 2015 Zach Jiroun. All rights reserved.
//

import UIKit
import MapKit

class RouteViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var routeMap: MKMapView!
    var destination: MKMapItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        routeMap.showsUserLocation = true
        routeMap.delegate = self
        self.getDirections()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonTouched(sender: UIBarButtonItem) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getDirections() {
        let request = MKDirectionsRequest()
        request.source = MKMapItem.mapItemForCurrentLocation()
        request.destination = destination!
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        
        directions.calculateDirectionsWithCompletionHandler({(response: MKDirectionsResponse?, error: NSError?) -> Void in
            if error != nil {
                let alert = UIAlertController(title: "No route found", message: "Please try a different location.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction!) -> Void in
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                self.showRoute(response!)
            }
        })
    }
    
    func showRoute(response: MKDirectionsResponse) {
        for route in response.routes {
            routeMap.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
            for step in route.steps {
                print(step.instructions)
            }
        }
        let userLocation = routeMap.userLocation
        let region = MKCoordinateRegionMakeWithDistance((userLocation.location?.coordinate)!, 2000, 2000)
        routeMap.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 5.0
        return renderer
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
