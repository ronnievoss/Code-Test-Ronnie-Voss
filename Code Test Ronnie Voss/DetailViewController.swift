//
//  DetailViewController.swift
//  Code Test Ronnie Voss
//
//  Created by Ronnie Voss on 10/11/17.
//  Copyright © 2017 Ronnie Voss. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var contact: Contact?
    var managedObjectContext: NSManagedObjectContext? = nil
    
    enum Sections: Int {
        case phoneNumbers = 0
        case emailAddresses = 1
        case addresses = 2
        case details = 3
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    
    let topViewMinHeight: CGFloat = 40
    let topViewMaxHeight: CGFloat = 80
    
    // MARK: - View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showAddContactEditor" {
            if let navController = segue.destination as? UINavigationController, let controller = navController.viewControllers.first as? AddContactViewController {
                controller.contact = contact
                controller.managedObjectContext = managedObjectContext
                controller.title = "Edit Contact"
                controller.setEditing(true, animated: false)
            }
        }
    }
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {

        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = Sections(rawValue: section) else {
            return 0
        }
        
        switch sectionInfo {
        case .details:
            return (contact?.formattedBirthdate.isEmpty)! ? 0 : 1
        case .addresses:
            return contact?.addresses?.count ?? 0
        case .phoneNumbers:
            return contact?.phoneNumbers?.count ?? 0
        case .emailAddresses:
            return contact?.emailAddresses?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let sectionInfo = Sections(rawValue: section) else {
            return ""
        }
        switch sectionInfo {
        case .details:
            let isEmpty = (contact?.formattedBirthdate.count) == 0
            return (isEmpty) ? nil : "Birthdate"
        case .addresses:
            let isEmpty = (contact?.addresses?.count) == 0
            return (isEmpty) ? nil : "Address"
        case .phoneNumbers:
            let isEmpty = (contact?.phoneNumbers?.count) == 0
            return (isEmpty) ? nil : "Phone"
        case .emailAddresses:
            let isEmpty = (contact?.emailAddresses?.count) == 0
            return (isEmpty) ? nil : "Email"
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = UINib(nibName: "EditableSectionHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? EditableSectionHeaderView else {
            return nil
        }
        
        let title = self.tableView(tableView, titleForHeaderInSection: section)
        
        if title == nil {
            return nil
        }
        
        headerView.textLabel?.text = title
        headerView.addButton?.isHidden = !isEditing
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! EditableCell
        cell.isEditable = isEditing
        
        cell.textField?.isUserInteractionEnabled = (indexPath.section == Sections.details.rawValue)
        
        let sectionInfo = Sections(rawValue: indexPath.section)!
        switch (sectionInfo, indexPath.row) {
            
        case (.phoneNumbers, _):
            let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
            let phoneNumber = contact?.phoneNumbers?.sortedArray(using: [sortDescriptor])[indexPath.row] as! PhoneNumber
            cell.label?.text = phoneNumber.label
            cell.textFieldLabel.text = phoneNumber.value
            cell.textField?.placeholder = "(123) 456-7890"
            
        case (.emailAddresses, _):
            let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
            let emailAddress = contact?.emailAddresses?.sortedArray(using: [sortDescriptor])[indexPath.row] as! EmailAddress
            cell.label?.text = emailAddress.label
            cell.textFieldLabel?.text = emailAddress.value
            cell.textField?.placeholder = "my@email.com"
            
        case (.addresses, _):
            let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
            let address = contact?.addresses?.sortedArray(using: [sortDescriptor])[indexPath.row] as! Address
            cell.label?.text = address.label
            cell.textFieldLabel?.text = address.formattedAddress
            cell.textField?.placeholder = "Street"
            
        case (.details, _):
            cell.label?.text = "Birthdate"
            cell.textFieldLabel?.text = contact?.formattedBirthdate
            cell.textField?.placeholder = "Birthdate"
            cell.textField?.tag = EditableCell.Field.birthdate.rawValue
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let sectionInfo = Sections(rawValue: indexPath.section) else {
            return
        }
        
        switch sectionInfo {
        case .phoneNumbers:
            let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
            let phoneNumber = contact?.phoneNumbers?.sortedArray(using: [sortDescriptor])[indexPath.row] as? PhoneNumber
            if let formattedNumber = phoneNumber?.value?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "") {
                let phoneUrl = "tel://\(String(describing: formattedNumber))"
                let url:URL = URL(string: phoneUrl)!
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
            
        case .emailAddresses:
            let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
            let emailAddress = contact?.emailAddresses?.sortedArray(using: [sortDescriptor])[indexPath.row] as? EmailAddress
            if let email = emailAddress?.value {
                let emailUrl = "mailto://\(String(describing: email))"
                let url:URL = URL(string: emailUrl)!
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
            
        case .addresses:
            let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
            let address = contact?.addresses?.sortedArray(using: [sortDescriptor])[indexPath.row] as? Address
            if let addressString = address?.formattedAddress {
                guard let encodedAddress = addressString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
                let mapUrl = "http://maps.apple.com/?address=\(String(describing: encodedAddress))"
                let url:URL = URL(string: mapUrl)!
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        case .details:
            let url:URL = URL(string: "calshow://")!
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
