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
    
    @IBAction func goHomeButtonPressed(sender: UIButton) {
        let defaults = NSUserDefaults.standardUserDefaults()
        guard let address = defaults.stringForKey(Tags.HomeAddress) else {
            let alert = UIAlertController(title: "Home Address Not Set", message: "Please set a home address in Settings", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
    }
    
    @IBAction func enterDestinationButtonPressed(sender: AnyObject) {
        let backItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        mapView.centerCoordinate = (userLocation.location?.coordinate)!
    }
}

