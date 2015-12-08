//
//  AddressSearchViewController.swift
//  Safe on the Streets
//
//  Created by Zach Jiroun on 12/6/15.
//  Copyright © 2015 Zach Jiroun. All rights reserved.
//

import UIKit
import MapKit
import DZNEmptyDataSet

class AddressSearchViewController: UITableViewController, UISearchBarDelegate, CLLocationManagerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var matchingItems: [MKMapItem] = [MKMapItem]()
    var region: MKCoordinateRegion?
    let reuseIdentifier = "addressCell"
    let locationManager = CLLocationManager()
    var isSettingHomeLocation: Bool = false
    var shouldBeginEditing: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.backgroundColor()

        searchBar.delegate = self

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
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
    
    // MARK - UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchBar.isFirstResponder() {
            // User tapped the 'clear' button
            shouldBeginEditing = false
            matchingItems = []
            tableView.reloadData()
        }
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        let boolToReturn = shouldBeginEditing
        shouldBeginEditing = true
        return boolToReturn
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        performSearch()
    }
    
    // MARK: MapKit Search
    
    func performSearch() {
        matchingItems.removeAll()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBar.text
        request.region = self.region!
        
        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler { (response: MKLocalSearchResponse?, error: NSError?) -> Void in
            if error != nil || response!.mapItems.count == 0 {
                let alert = UIAlertController(title: "No Locations Found", message: "Please try a different location.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
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
    
    // MARK: - DZNEmptyDataSet
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "Search")
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let description: String = "Please enter your destination"
        
        let paragraph: NSMutableParagraphStyle = NSMutableParagraphStyle.init()
        paragraph.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraph.alignment = NSTextAlignment.Center
        
        let attributes: NSDictionary = [NSFontAttributeName: UIFont.systemFontOfSize(18.0), NSForegroundColorAttributeName: UIColor.textColor(), NSParagraphStyleAttributeName: paragraph]
        
        return NSAttributedString(string: description, attributes: attributes as? [String : AnyObject])
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor.backgroundColor()
    }
}
