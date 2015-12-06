//
//  SecondViewController.swift
//  Safe on the Streets
//
//  Created by Zach Jiroun on 11/30/15.
//  Copyright © 2015 Zach Jiroun. All rights reserved.
//

import UIKit
import XLForm

class SettingsViewController: XLFormViewController {
    
    private struct Tags {
        static let EmergencyContactName = "emergencyContactName"
        static let EmergencyContactNumber = "emergencyContactNumber"
        static let Passcode = "passcode"
        static let CheckInTime = "checkInTime"
        static let AlertMessage = "alertMessage"
        static let HomeAddress = "homeAddress"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "Settings"
        self.tableView.backgroundColor = UIColor.backgroundColor()
        self.initializeForm()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonTouched(sender: AnyObject) {
        // Check for validation errors
        let formErrors = formValidationErrors()
        for errorItem in formErrors {
            let error = errorItem as! NSError
            let validationStatus: XLFormValidationStatus = error.userInfo[XLValidationStatusErrorKey] as! XLFormValidationStatus
            if let rowDescriptor = validationStatus.rowDescriptor, let indexPath = form.indexPathOfFormRow(rowDescriptor), let cell = tableView.cellForRowAtIndexPath(indexPath) {
                self.animateCell(cell)
            }
        }
        if formErrors.count > 0 {
            return
        }
        
        // Save form values to NSUserDefaults
        let defaults = NSUserDefaults.standardUserDefaults()
        let formValues: NSDictionary = form.formValues()
        
        if let name = formValues[Tags.EmergencyContactName] as? String {
            defaults.setObject(name, forKey: Tags.EmergencyContactName)
        }
        
        if let number = formValues[Tags.EmergencyContactNumber] as? String {
            defaults.setObject(number, forKey: Tags.EmergencyContactNumber)
        }
        
        if let checkInTime = formValues[Tags.CheckInTime] as? String {
            defaults.setObject(checkInTime, forKey: Tags.CheckInTime)
        }
        
        if let alertMessage = formValues[Tags.AlertMessage] as? String {
            defaults.setObject(alertMessage, forKey: Tags.AlertMessage)
        }
    }
    
    func initializeForm() {
        let form: XLFormDescriptor
        var section: XLFormSectionDescriptor
        var row: XLFormRowDescriptor
        
        form = XLFormDescriptor(title: "Settings")
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        // Emergency Contact
        section = XLFormSectionDescriptor()
        section.title = "Emergency Contact"
        form.addFormSection(section)
        
        // Emergency Contact Name
        row = XLFormRowDescriptor(tag: Tags.EmergencyContactName, rowType: XLFormRowDescriptorTypeText, title: "Contact Name")
        row.cellConfigAtConfigure["textField.textAlignment"] = NSTextAlignment.Right.rawValue
        row.required = true
        if let name = defaults.stringForKey(Tags.EmergencyContactName) {
            row.value = name
        }
        section.addFormRow(row)
        
        // Emergency Contact Number
        row = XLFormRowDescriptor(tag: Tags.EmergencyContactNumber, rowType: XLFormRowDescriptorTypePhone, title: "Contact Number")
        row.cellConfigAtConfigure["textField.textAlignment"] = NSTextAlignment.Right.rawValue
        row.required = true
        if let number = defaults.stringForKey(Tags.EmergencyContactNumber) {
            row.value = number
        }
        section.addFormRow(row)
        
        // Alert Settings
        section = XLFormSectionDescriptor()
        section.title = "Alert Settings"
        form.addFormSection(section)
        
        // Passcode
        row = XLFormRowDescriptor(tag: Tags.Passcode, rowType:  XLFormRowDescriptorTypeSelectorPush, title: "Passcode")
        row.action.viewControllerStoryboardId = "PasscodeViewController"
        section.addFormRow(row)
        
        // Time Between Check Ins
        row = XLFormRowDescriptor(tag: Tags.CheckInTime, rowType: XLFormRowDescriptorTypePhone, title: "Time Between Check Ins")
        row.leftRightSelectorLeftOptionSelected = true
        row.cellConfigAtConfigure["textField.placeholder"] = "minutes"
        row.cellConfigAtConfigure["textField.textAlignment"] = NSTextAlignment.Right.rawValue
        if let time = defaults.stringForKey(Tags.CheckInTime) {
            row.value = time
        }
        section.addFormRow(row)
        
        // Custom Alert Message
        section = XLFormSectionDescriptor()
        section.title = "Custom Alert Message"
        form.addFormSection(section)
        row = XLFormRowDescriptor(tag: Tags.AlertMessage, rowType: XLFormRowDescriptorTypeTextView)
        if let message = defaults.stringForKey(Tags.AlertMessage) {
            row.value = message
        }
        section.addFormRow(row)

        // Location Settings
        section = XLFormSectionDescriptor()
        section.title = "Location Settings"
        form.addFormSection(section)
        // Set Home Address
        row = XLFormRowDescriptor(tag: Tags.HomeAddress, rowType: XLFormRowDescriptorTypeSelectorPush, title: "Set Home Address")
        section.addFormRow(row)
        
        self.form = form
    }
    
    // Animates the cell with a shake if a required field is not provided
    func animateCell(cell: UITableViewCell) {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.x"
        animation.values =  [0, 20, -20, 10, 0]
        animation.keyTimes = [0, (1 / 6.0), (3 / 6.0), (5 / 6.0), 1]
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.additive = true
        cell.layer.addAnimation(animation, forKey: "shake")
    }
}

