//
//  AddressSearchViewController.swift
//  Safe on the Streets
//
//  Created by Zach Jiroun on 12/6/15.
//  Copyright © 2015 Zach Jiroun. All rights reserved.
//

import UIKit
import MapKit

class AddressSearchViewController: UITableViewController, UISearchBarDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var matchingItems: [MKMapItem] = [MKMapItem]()
    var region: MKCoordinateRegion?
    let reuseIdentifier = "addressCell"
    let locationManager = CLLocationManager()
    var isSettingHomeLocation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.backgroundColor()

        searchBar.delegate = self

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ResultsTableViewCell
        
        // Configure the cell
        let item = matchingItems[indexPath.row]
        cell.nameLabel.text = item.name
        cell.phoneLabel.text = item.phoneNumber
        cell.backgroundColor = UIColor.backgroundColor()
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if isSettingHomeLocation {
            let defaults = NSUserDefaults.standardUserDefaults()
            let indexPath = self.tableView.indexPathForSelectedRow!
            let row = indexPath.row
            let coordinate = matchingItems[row].placemark.coordinate
            let lat = NSNumber(double: coordinate.latitude)
            let lon = NSNumber(double: coordinate.longitude)
            let homeAddress: NSDictionary = ["lat": lat, "lon": lon]
            defaults.setObject(homeAddress, forKey: Tags.HomeAddress)
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            performSegueWithIdentifier("searchRoute", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "searchRoute" {
            let routeViewController = segue.destinationViewController as! RouteViewController
            let row = self.tableView.indexPathForSelectedRow!.row
            routeViewController.destination = matchingItems[row]
        }
    }
    
    // MARK: MapKit Search
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        performSearch()
    }
    
    func performSearch() {
        matchingItems.removeAll()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBar.text
        request.region = self.region!
        
        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler { (response: MKLocalSearchResponse?, error: NSError?) -> Void in
            if error != nil {
                print("Error occured in search: \(error!.localizedDescription)")
            } else if response!.mapItems.count == 0 {
                print("No matches found")
            } else {
                self.matchingItems = response!.mapItems
                self.tableView.reloadData()
            }
            
        }
    }
    
    // MARK: - Location Delegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        
        self.region = region
        
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Error: " + error.localizedDescription)
    }
}
