//
//  FirstViewController.swift
//  Safe on the Streets
//
//  Created by Zach Jiroun on 11/30/15.
//  Copyright © 2015 Zach Jiroun. All rights reserved.
//

import UIKit
import MapKit

class LaunchTrackerViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var goHomeView: UIView!
    @IBOutlet weak var enterDestinationView: UIView!
    
    @IBOutlet weak var searchTextField: UITextField!
    var matchingItems: [MKMapItem] = [MKMapItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        mapView.delegate = self
        self.navigationController?.navigationBar.topItem?.title = "Safe on the Streets"
        let userLocation = mapView.userLocation
        mapView.region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setupViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupViews() {
        goHomeView.layer.masksToBounds = false
        goHomeView.layer.shadowOffset = CGSizeMake(0, 1)
        goHomeView.layer.shadowRadius = 4
        goHomeView.layer.shadowOpacity = 0.5
        goHomeView.layer.shadowPath = UIBezierPath(rect: goHomeView.bounds).CGPath
        
        enterDestinationView.layer.masksToBounds = false
        enterDestinationView.layer.shadowOffset = CGSizeMake(0, 1)
        enterDestinationView.layer.shadowRadius = 4
        enterDestinationView.layer.shadowOpacity = 0.5
        enterDestinationView.layer.shadowPath = UIBezierPath(rect: enterDestinationView.bounds).CGPath
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController as! ResultsTableViewController
        destination.mapItems = self.matchingItems
    }
    
    @IBAction func zoomIn(sender: UIBarButtonItem) {
        let userLocation = mapView.userLocation
        
        let region = MKCoordinateRegionMakeWithDistance((userLocation.location?.coordinate)!, 2000, 2000)
        
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func goHomeButtonPressed(sender: UIButton) {
        print("go home")
    }
    
    @IBAction func enterDestinationButtonPressed(sender: AnyObject) {
        print("enter destination")
    }
    
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        mapView.centerCoordinate = (userLocation.location?.coordinate)!
    }
    
    @IBAction func textFieldReturn(sender: UITextField) {
        sender.resignFirstResponder()
        mapView.removeAnnotations(mapView.annotations)
        self.performSearch()
    }
    
    func performSearch() {
        
        matchingItems.removeAll()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchTextField.text
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler { (response: MKLocalSearchResponse?, error: NSError?) -> Void in
            if error != nil {
                print("Error occured in search: \(error!.localizedDescription)")
            } else if response!.mapItems.count == 0 {
                print("No matches found")
            } else {
                print("Matches found")
                
                for item in response!.mapItems {
                    print("Name = \(item.name)")
                    print("Phone = \(item.phoneNumber)")
                    
                    self.matchingItems.append(item as MKMapItem)
                    print("Matching items = \(self.matchingItems.count)")
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    self.mapView.addAnnotation(annotation)
                }
            }

        }
    }
}

