//
//  AddContactViewController.swift
//  Code Test Ronnie Voss
//
//  Created by Ronnie Voss on 10/11/17.
//  Copyright © 2017 Ronnie Voss. All rights reserved.
//

import UIKit
import CoreData

class AddContactViewController: UITableViewController, UITextFieldDelegate {
    
    var contact: Contact?
    var address: Address?
    var phoneNumber: PhoneNumber?
    var emailAddress: EmailAddress?
    var selectedIndex: Int!
    var managedObjectContext: NSManagedObjectContext? = nil
    var path: IndexPath?
    
    enum Sections: Int {
        case details = 0
        case addresses = 1
        case phoneNumbers = 2
        case emailAddresses = 3
    }
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    // MARK: - View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        tableView.sectionHeaderHeight = 25
        tableView.sectionFooterHeight = 0
        tableView.backgroundColor = UIColor.white
        tableView.allowsSelectionDuringEditing = true
        
        managedObjectContext?.undoManager = UndoManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = Sections(rawValue: section) else {
            return 0
        }
        
        switch sectionInfo {
        case .details:
            return 3
        case .addresses:
            return (contact?.addresses?.count)! + 1
        case .phoneNumbers:
            return (contact?.phoneNumbers?.count)! + 1
        case .emailAddresses:
            return (contact?.emailAddresses?.count)! + 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
        case 0:
            return 0.0
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sectionInfo = Sections(rawValue: indexPath.section) else {
            return UITableView.automaticDimension
        }
        
        switch sectionInfo {
        case .details:
            return 70
        case .addresses:
            if indexPath.row >= (contact?.addresses?.count)! {
                return 44
            }
            return 280
        case .phoneNumbers:
            if indexPath.row >= (contact?.phoneNumbers?.count)! {
                return 44
            }
            return 120.0
        case .emailAddresses:
            if indexPath.row >= (contact?.emailAddresses?.count)! {
                return 44
            }
            return 120.0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var identifier = "Cell"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AddCell")
        
        if let sectionInfo = Sections(rawValue: indexPath.section) {
            switch sectionInfo {
            case .addresses:
                identifier = "Cell2"
                if indexPath.row >= (contact?.addresses?.count)! {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AddCell", for: indexPath)
                    cell.selectionStyle = .none
                    cell.textLabel?.text = "Add Address"
                    return cell
                }
            case .phoneNumbers:
                identifier = "Cell3"
                if indexPath.row >= (contact?.phoneNumbers?.count)! {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AddCell", for: indexPath)
                    cell.selectionStyle = .none
                    cell.textLabel?.text = "Add Phone"
                    return cell
                }
            case .emailAddresses:
                identifier = "Cell4"
                if indexPath.row >= (contact?.emailAddresses?.count)! {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AddCell", for: indexPath)
                    cell.selectionStyle = .none
                    cell.textLabel?.text = "Add Email"
                    return cell
                }
            default:
                break
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! EditableCell
        cell.isEditable = isEditing
        configure(cell, at: indexPath)
        
        return cell
    }
    
    func configure(_ cell: EditableCell, at indexPath: IndexPath) {
        let sectionInfo = Sections(rawValue: indexPath.section)!
        switch (sectionInfo, indexPath.row) {
        case (.details, 0):
            cell.label?.text = "First Name"
            cell.textField?.text = contact?.firstName
            cell.textField?.placeholder = "First name"
            cell.textField?.tag = EditableCell.Field.firstName.rawValue
            if (cell.textField.text?.isEmpty)! {
                cell.textField.becomeFirstResponder()
            }
        case (.details, 1):
            cell.label?.text = "Last Name"
            cell.textField?.text = contact?.lastName
            cell.textField?.placeholder = "Last name"
            cell.textField?.tag = EditableCell.Field.lastName.rawValue
            
        case (.details, 2):
            birthdateTextField = cell.textField
            cell.label?.text = "Birthdate"
            cell.textField?.text = contact?.formattedBirthdate
            cell.textField?.placeholder = "Birthdate"
            cell.textField?.tag = EditableCell.Field.birthdate.rawValue
            
        case (.addresses, _):
            let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
            address = contact?.addresses?.sortedArray(using: [sortDescriptor])[indexPath.row] as? Address
            cell.addressLabel.text = address?.label
            cell.addressLabel.tag = EditableCell.Field.addressLabel.rawValue
            cell.address1.text = address?.addressLine1
            if (cell.address1.text?.isEmpty)! {
                cell.address1.becomeFirstResponder()
            }
            cell.address1.tag = EditableCell.Field.address1.rawValue
            cell.address2.text = address?.addressLine2
            cell.address2.tag = EditableCell.Field.address2.rawValue
            cell.city.text = address?.city
            cell.city.tag = EditableCell.Field.city.rawValue
            cell.state.text = address?.state
            cell.state.tag = EditableCell.Field.state.rawValue
            cell.zipcode.text = address?.zipcode
            cell.zipcode.tag = EditableCell.Field.zipcode.rawValue
        case (.phoneNumbers, _):
            let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
            phoneNumber = contact?.phoneNumbers?.sortedArray(using: [sortDescriptor])[indexPath.row] as? PhoneNumber
            cell.phoneLabel.text = phoneNumber?.label
            cell.phoneLabel.tag = EditableCell.Field.phoneLabel.rawValue
            cell.phoneNumber.text = phoneNumber?.value
            if (cell.phoneNumber.text?.isEmpty)! {
                cell.phoneNumber.becomeFirstResponder()
            }
            cell.phoneNumber.tag = EditableCell.Field.phoneNumber.rawValue
        case (.emailAddresses, _):
            let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
            emailAddress = contact?.emailAddresses?.sortedArray(using: [sortDescriptor])[indexPath.row] as? EmailAddress
            cell.emailLabel.text = emailAddress?.label
            cell.emailLabel.tag = EditableCell.Field.emailLabel.rawValue
            cell.emailAddress.text = emailAddress?.value
            if (cell.emailAddress.text?.isEmpty)! {
                cell.emailAddress.becomeFirstResponder()
            }
            cell.emailAddress.tag = EditableCell.Field.emailAddress.rawValue
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if Sections(rawValue: indexPath.section) == Sections.details {
            return false
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if let sectionInfo = Sections(rawValue: indexPath.section) {
            switch sectionInfo {
            case .addresses:
                if indexPath.row >= (contact?.addresses?.count)! {
                    return .insert
                }
            case .phoneNumbers:
                if indexPath.row >= (contact?.phoneNumbers?.count)! {
                    return .insert
                }
            case .emailAddresses:
                if indexPath.row >= (contact?.emailAddresses?.count)! {
                    return .insert
                }
            default:
                break
            }
        }
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let sectionInfo = Sections(rawValue: indexPath.section) else {
            return
        }
        tableView.beginUpdates()
        if editingStyle == .delete {
            navigationItem.rightBarButtonItem?.isEnabled = true
            
            switch sectionInfo {
            case .details:
                return
            case .addresses:
                let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
                let objects = contact?.addresses?.sortedArray(using: [sortDescriptor]) as? [Address] ?? []
                let object = objects[indexPath.row]
                contact?.removeFromAddresses(object)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            case .phoneNumbers:
                let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
                let objects = contact?.phoneNumbers?.sortedArray(using: [sortDescriptor]) as? [PhoneNumber] ?? []
                let object = objects[indexPath.row]
                contact?.removeFromPhoneNumbers(object)
                managedObjectContext?.delete(object)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            case .emailAddresses:
                let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
                let objects = contact?.emailAddresses?.sortedArray(using: [sortDescriptor]) as? [EmailAddress] ?? []
                let object = objects[indexPath.row]
                contact?.removeFromEmailAddresses(object)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
        } else if editingStyle == .insert {
            
            switch sectionInfo {
            case .details:
                return
            case .addresses:
                let newObject = Address(context: managedObjectContext!)
                self.contact?.addToAddresses(newObject)
                newObject.createdAt = Date().timeIntervalSince1970
                newObject.index = String(0)
                newObject.label = "Home"
                tableView.insertRows(at: [indexPath], with: .automatic)
            case .phoneNumbers:
                let newObject = PhoneNumber(context: managedObjectContext!)
                self.contact?.addToPhoneNumbers(newObject)
                newObject.createdAt = Date().timeIntervalSince1970
                newObject.index = String(0)
                newObject.label = "Home"
                tableView.insertRows(at: [indexPath], with: .automatic)
            case .emailAddresses:
                let newObject = EmailAddress(context: managedObjectContext!)
                self.contact?.addToEmailAddresses(newObject)
                newObject.createdAt = Date().timeIntervalSince1970
                newObject.index = String(0)
                newObject.label = "Home"
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        }
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let sectionInfo = Sections(rawValue: indexPath.section) {
            switch sectionInfo {
            case .addresses:
                if indexPath.row == contact?.addresses?.count {
                    return nil
                }
            case .phoneNumbers:
                if indexPath.row == contact?.phoneNumbers?.count {
                    return nil
                }
            case .emailAddresses:
                if indexPath.row == contact?.emailAddresses?.count {
                    return nil
                }
            default:
                break
            }
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == Sections.addresses.rawValue {
            performSegue(withIdentifier: "showAddressLabel", sender: nil)
        }
        
        if indexPath.section == Sections.phoneNumbers.rawValue {
            performSegue(withIdentifier: "showPhoneLabel", sender: nil)
        }
        
        if indexPath.section == Sections.emailAddresses.rawValue {
            performSegue(withIdentifier: "showEmailLabel", sender: nil)
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddressLabel" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
                let object = contact?.addresses?.sortedArray(using: [sortDescriptor])[indexPath.row] as? Address
                if let navController = segue.destination as? UINavigationController, let controller = navController.viewControllers.first as? LabelViewController {
                    controller.selectedLabel = object?.label
                    controller.selectedIndex = Int((object?.index)!)
                    controller.tag = 1
                }
            }
        }
        
        if segue.identifier == "showPhoneLabel" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
                let object = contact?.phoneNumbers?.sortedArray(using: [sortDescriptor])[indexPath.row] as? PhoneNumber
                if let navController = segue.destination as? UINavigationController, let controller = navController.viewControllers.first as? LabelViewController {
                    controller.selectedLabel = object?.label
                    controller.selectedIndex = Int((object?.index)!)
                    controller.tag = 2
                }
            }
        }
        
        if segue.identifier == "showEmailLabel" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
                let object = contact?.emailAddresses?.sortedArray(using: [sortDescriptor])[indexPath.row] as? EmailAddress
                if let navController = segue.destination as? UINavigationController, let controller = navController.viewControllers.first as? LabelViewController {
                    controller.selectedLabel = object?.label
                    controller.selectedIndex = Int((object?.index)!)
                    controller.tag = 3
                }
            }
        }
    }
    
    @IBAction func unwindSegue(segue:UIStoryboardSegue) {
        if let labelViewController = segue.source as? LabelViewController {
            if let labelText = labelViewController.selectedLabel {
                switch labelViewController.tag {
                case 1:
                    if let indexPath = tableView.indexPathForSelectedRow {
                        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
                        let object = contact?.addresses?.sortedArray(using: [sortDescriptor])[indexPath.row] as? Address
                        object?.label = labelText
                        selectedIndex = labelViewController.selectedLabelIndex
                        let indexValue = String(selectedIndex)
                        object?.index = indexValue
                    }
                case 2:
                    if let indexPath = tableView.indexPathForSelectedRow {
                        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
                        let object = contact?.phoneNumbers?.sortedArray(using: [sortDescriptor])[indexPath.row] as? PhoneNumber
                        object?.label = labelText
                        selectedIndex = labelViewController.selectedLabelIndex
                        let indexValue = String(selectedIndex)
                        object?.index = indexValue
                    }
                case 3:
                    if let indexPath = tableView.indexPathForSelectedRow {
                        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
                        let object = contact?.emailAddresses?.sortedArray(using: [sortDescriptor])[indexPath.row] as? EmailAddress
                        object?.label = labelText
                        selectedIndex = labelViewController.selectedLabelIndex
                        let indexValue = String(selectedIndex)
                        object?.index = indexValue
                    }
                default:
                    return
                }
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    // MARK: - Text Field
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == EditableCell.Field.birthdate.rawValue {
            textField.tintColor = UIColor.clear
            let datePickerView = UIDatePicker()
            datePickerView.datePickerMode = .date
            textField.inputView = datePickerView
            
            let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
            toolbar.items = [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didSetBirthdate))
            ]
            textField.inputAccessoryView = toolbar
            
            datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: UIControl.Event.valueChanged)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        navigationItem.rightBarButtonItem?.isEnabled = !text.isEmpty
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if tableView.isDragging {
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let pointInTable = textField.convert(textField.bounds.origin, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: pointInTable)
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        
        if indexPath?.section == 0 {
            switch textField.tag {
            case EditableCell.Field.firstName.rawValue:
                contact?.firstName = textField.text
            case EditableCell.Field.lastName.rawValue:
                contact?.lastName = textField.text
            case EditableCell.Field.birthdate.rawValue:
                birthdateTextField?.text = contact?.formattedBirthdate
            default:
                break
            }
        }
        
        if indexPath?.section == 1 {
            let addressText = contact?.addresses?.sortedArray(using: [sortDescriptor])[(indexPath?.row)!] as? Address
            switch textField.tag {
            case EditableCell.Field.address1.rawValue:
                addressText?.addressLine1 = textField.text
            case EditableCell.Field.address2.rawValue:
                addressText?.addressLine2 = textField.text
            case EditableCell.Field.city.rawValue:
                addressText?.city = textField.text
            case EditableCell.Field.state.rawValue:
                addressText?.state = textField.text
            case EditableCell.Field.zipcode.rawValue:
                addressText?.zipcode = textField.text
            default:
                break
            }
        }
        
        if indexPath?.section == 2 {
            let phoneText = contact?.phoneNumbers?.sortedArray(using: [sortDescriptor])[(indexPath?.row)!] as? PhoneNumber
            switch textField.tag {
            case EditableCell.Field.phoneNumber.rawValue:
                phoneText?.value = textField.text
            default:
                break
            }
        }
        if indexPath?.section == 3 {
            switch textField.tag {
            case EditableCell.Field.emailAddress.rawValue:
                let emailAddressText = contact?.emailAddresses?.sortedArray(using: [sortDescriptor])[(indexPath?.row)!] as? EmailAddress
                emailAddressText?.value = textField.text
            default:
                break
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField.tag == EditableCell.Field.phoneNumber.rawValue {
            return checkPhoneNumberFormat(string: string, str: str, textField: textField)
        } else {
            return true
        }
    }
    
    func checkPhoneNumberFormat(string: String?, str: String?, textField: UITextField?) -> Bool {
        
        guard let phoneTextField = textField else { return false }
        
        if string == "" { //BackSpace
            return true
        } else if str!.count < 3 {
            if str!.count == 1 {
                phoneTextField.text = "("
            }
        } else if str!.count == 5 {
            phoneTextField.text = phoneTextField.text! + ") "
        } else if str!.count == 10 {
            phoneTextField.text = phoneTextField.text! + "-"
        } else if str!.count > 14 {
            return false
        }
        return true
    }
    
    @IBAction func save() {
        
        self.view.endEditing(true)
        
        guard let items = managedObjectContext?.insertedObjects else {return}
        for item in items {
            if item.entity.name == "PhoneNumber" {
                if item.value(forKeyPath: #keyPath(PhoneNumber.value)) as? String == "" {
                    managedObjectContext?.delete(item)
                }
            }
            if item.entity.name == "EmailAddress" {
                if item.value(forKeyPath: #keyPath(EmailAddress.value)) as? String == "" {
                    managedObjectContext?.delete(item)
                }
            }
        }
        
        do {
            try managedObjectContext?.save()
        } catch let error as NSError {
            let errorDialog = UIAlertController(title: "Error!", message: "Failed to save! \(error): \(error.userInfo)", preferredStyle: .alert)
            errorDialog.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(errorDialog, animated: true)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private
    
    private weak var birthdateTextField: UITextField?
    
    @objc @IBAction private func didTapCancelButton() {
        self.view.endEditing(true)
        managedObjectContext?.rollback()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didSetBirthdate() {
        birthdateTextField?.resignFirstResponder()
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        contact?.birthdate = sender.date
        birthdateTextField?.text = contact?.formattedBirthdate
    }
}

