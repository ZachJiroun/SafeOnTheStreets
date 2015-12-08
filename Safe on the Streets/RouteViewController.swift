//
//  RouteViewController.swift
//  Safe on the Streets
//
//  Created by Zach Jiroun on 12/6/15.
//  Copyright © 2015 Zach Jiroun. All rights reserved.
//

import UIKit
import MapKit
import PasscodeLock

class RouteViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var routeMap: MKMapView!
    var destination: MKMapItem?
    let locationManager = CLLocationManager()
    var region: MKCoordinateRegion?
    var timer = NSTimer()
    var secondsRemaining = 300
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var checkInCountdownView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // The background shadow will pop in if setupViews() is not called in viewDidLoad because we're using a modal segue to this view controller
        setupViews()

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        routeMap.showsUserLocation = true
        routeMap.delegate = self
        self.getDirections()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        getStartingTime()
        startTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonTouched(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Safe!", message: "We've alerted your contact that you got home safely.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction!) -> Void in
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func emergencyButtonTouched(sender: UIButton) {
        let alert = UIAlertController(title: "Emergency Contact Alerted", message: "Your location has been sent to your emergency contact. Help will arrive shortly", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK - View Setup
    
    func setupViews() {
        checkInCountdownView.layer.masksToBounds = false
        checkInCountdownView.layer.shadowOffset = CGSizeMake(0, 1)
        checkInCountdownView.layer.shadowRadius = 4
        checkInCountdownView.layer.shadowOpacity = 0.5
        // Can't convert to a bezier path because the view's bounds wont' be established until viewDidAppear
        //checkInCountdownView.layer.shadowPath = UIBezierPath(rect: checkInCountdownView.bounds).CGPath
    }
    
    // MARK - Timer
    
    func getStartingTime() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let time = defaults.stringForKey(Tags.CheckInTime) {
            secondsRemaining = Int(time)! * 60
        } else {
            secondsRemaining = 300
        }
        let startTime: Int = secondsRemaining / 60
        timerLabel.text = String.localizedStringWithFormat("%02d:00 %@", startTime, "Until Next Check In")
    }
    
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("countdown"), userInfo: nil, repeats: true)
    }
    
    func countdown() {
        secondsRemaining--
        let minutes: Int = (secondsRemaining%3600)/60
        let seconds: Int = (secondsRemaining%3600)%60
        timerLabel.text = String.localizedStringWithFormat("%02d:%02d %@", minutes, seconds, "Until Next Check In")
        if secondsRemaining == 0 {
            self.timer.invalidate()
            let repository = UserDefaultsPasscodeRepository()
            let configuration = PasscodeLockConfiguration(repository: repository)
            let passcodeVC = PasscodeLockViewController(state: .EnterPasscode, configuration: configuration)
            presentViewController(passcodeVC, animated: true, completion: nil)
        }
    }
    
    // MARK - MapKit
    func getDirections() {
        let request = MKDirectionsRequest()
        request.source = MKMapItem.mapItemForCurrentLocation()
        request.destination = destination!
        request.requestsAlternateRoutes = false
        request.transportType = .Walking
        
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
        //let userLocation = routeMap.userLocation
        routeMap.setRegion(self.region!, animated: true)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 5.0
        return renderer
    }
    
    // MARK: - Location Delegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegionMakeWithDistance(center, 2000.0, 2000.0)
        self.region = region
        
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Error: " + error.localizedDescription)
    }
}
